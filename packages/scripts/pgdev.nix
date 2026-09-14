{ pkgs }:
let
  defaults = pkgs.writeText "pgdev-defaults" ''
    : "''${PGDEV_IMAGE:=docker.io/library/postgres:18-bookworm}"
    : "''${PGDEV_CONTAINER:=dotfiles-postgres-18}"
    : "''${PGDEV_VOLUME:=dotfiles-postgres-18-data}"
    : "''${PGDEV_PORT:=5432}"
    : "''${PGDEV_USER:=$(id -un)}"
    : "''${PGDEV_DATABASE:=$(id -un)}"
  '';
in
pkgs.writeShellApplication {
  name = "pgdev";
  extraShellCheckFlags = [ "-x" ];
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.podman
    pkgs.util-linux
    pkgs.iproute2
    pkgs.passt
    pkgs.slirp4netns
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    export PATH="/run/wrappers/bin:$PATH"
    set +x
    set -Eeuo pipefail
    umask 077

    fail() {
      printf 'pgdev: %s\n' "$*" >&2
      exit 1
    }
    note() { printf 'pgdev: %s\n' "$*" >&2; }

    ((EUID != 0)) || fail 'Run as the desktop user, never root or sudo podman.'
    source ${defaults}

    [[ $PGDEV_IMAGE =~ ^docker.io/library/postgres:([0-9]+)-bookworm(@sha256:[a-f0-9]{64})?$ ]] || fail 'Use a major-pinned official postgres bookworm image.'
    major=''${BASH_REMATCH[1]}
    ((major >= 18)) || fail 'This helper uses the PostgreSQL 18+ volume layout.'
    for name in "$PGDEV_CONTAINER" "$PGDEV_VOLUME"; do
      [[ $name =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || fail 'Invalid container or volume name.'
    done
    [[ $PGDEV_PORT =~ ^[0-9]{1,5}$ ]] || fail 'Port must be between 1024 and 65535.'
    PGDEV_PORT=$((10#$PGDEV_PORT))
    ((PGDEV_PORT >= 1024 && PGDEV_PORT <= 65535)) || fail 'Port must be between 1024 and 65535.'
    identifier() {
      [[ $1 =~ ^[a-zA-Z_][a-zA-Z0-9_-]{0,62}$ ]] || fail 'Use a database/role name of 1-63 letters, digits, underscores or hyphens, starting with a letter or underscore.'
    }
    identifier "$PGDEV_USER"
    identifier "$PGDEV_DATABASE"
    state_root=''${XDG_STATE_HOME:-$HOME/.local/state}/postgres
    state=$state_root/$PGDEV_CONTAINER
    secret=$PGDEV_CONTAINER-password
    owner=io.aileks.pgdev
    schema=$major:$PGDEV_USER:$PGDEV_DATABASE
    settings=$schema:$PGDEV_VOLUME:$PGDEV_PORT
    podman=(podman --remote=false --cgroup-manager=systemd --events-backend=journald)

    # Keep conmon and rootless networking processes from inheriting our lock.
    podman_local() { "''${podman[@]}" "$@" 9>&-; }

    exists() {
      local result=0
      podman_local "$1" exists "$2" || result=$?
      ((result < 2)) || fail "Podman could not check $1 $2."
      return "$result"
    }
    owned() {
      local kind=$1 resource=$2 format
      format="{{index .Labels \"$owner\"}}"
      [[ $kind != container ]] || format="{{index .Config.Labels \"$owner\"}}"
      [[ $kind != secret ]] || format="{{index .Spec.Labels \"$owner\"}}"
      [[ $(podman_local "$kind" inspect --format "$format" "$resource") == "$PGDEV_CONTAINER" ]] || fail "Unrelated $kind name collision: $resource"
    }
    check_volume() {
      exists volume "$PGDEV_VOLUME" || fail 'Volume is absent; run pgdev init explicitly.'
      owned volume "$PGDEV_VOLUME"
      [[ $(podman_local volume inspect --format '{{index .Labels "io.aileks.pgdev.schema"}}' "$PGDEV_VOLUME") == "$schema" ]] || fail 'Volume initialization settings differ. Keep its original major/user/database; use a new volume for a migration.'
    }
    check_container() {
      owned container "$PGDEV_CONTAINER"
      [[ $(podman_local container inspect --format '{{index .Config.Labels "io.aileks.pgdev.settings"}}' "$PGDEV_CONTAINER") == "$settings" ]] || fail 'Container settings changed. Stop and explicitly remove only the owned container before recreating it.'
    }
    private_dir() {
      local directory=$1 resolved
      resolved=$(realpath -m -- "$directory")
      [[ $resolved != /nix/store && $resolved != /nix/store/* ]] || fail 'Runtime files must be outside the Nix store.'
      [[ ! -L $directory ]] || fail "Refusing symlinked private directory: $directory"
      if [[ -e $directory ]]; then
        [[ -d $directory && -O $directory && $(stat -c %a -- "$directory") == 700 ]] || fail "Expected an owned mode 0700 directory: $directory"
      else
        mkdir -p -- "$directory"
      fi
    }
    private_file() {
      [[ -f $1 && ! -L $1 && -O $1 && $(stat -c %a -- "$1") == 600 ]] || fail "Expected an owned mode 0600 file: $1"
      local parent
      parent=$(dirname -- "$1")
      [[ -O $parent && $(stat -c %a -- "$parent") == 700 ]] || fail "Password file needs a private mode 0700 parent: $parent"
    }
    preflight() {
      local mapping name runtime
      name=$(id -un)
      for runtime in podman newuidmap newgidmap flock ss; do
        command -v "$runtime" >/dev/null || fail "Required command missing: $runtime"
      done
      for mapping in /etc/subuid /etc/subgid; do
        awk -F: -v name="$name" -v uid="$EUID" '($1 == name || $1 == uid) && $3 >= 65536 { found=1 } END { exit !found }' "$mapping" || fail "Missing subordinate IDs in $mapping; check the NixOS subordinate-ID account configuration."
      done
      [[ $(podman_local info --format '{{.Host.Security.Rootless}}') == true ]] || fail 'Rootless Podman is unavailable.'
      # shellcheck disable=SC2016
      podman_local unshare sh -c 'for f in /proc/self/uid_map /proc/self/gid_map; do awk "\$1 > 0 && \$3 >= 65536 {ok=1} END {exit !ok}" "$f" || exit; done' || fail 'Podman subordinate-ID mappings are unavailable; check newuidmap/newgidmap and restart the login session after account setup.'
      command -v pasta >/dev/null || command -v slirp4netns >/dev/null || fail 'Rootless networking requires pasta or slirp4netns.'
    }
    load_image() {
      if [[ -f $state/image ]]; then
        read -r image <"$state/image"
      else
        image=$(podman_local image inspect --format '{{.Id}}' "$PGDEV_IMAGE") || fail 'Image absent; run pgdev init or explicitly pull the configured image.'
      fi
      podman_local image exists "$image" || fail 'Recorded image is missing; run pgdev init --pull after removing the stopped container.'
    }
    # Only the general client forwards caller connection settings. Local maintenance
    # uses a separate environment and a password file scoped to loopback/port/user.
    client() {
      local program=$1 variable
      shift
      local -a options=(--env "PGHOST=127.0.0.1" --env "PGPORT=$PGDEV_PORT" --env "PGUSER=$PGDEV_USER" --env "PGDATABASE=$PGDEV_DATABASE")
      for variable in PGHOST PGHOSTADDR PGPORT PGUSER PGDATABASE PGCONNECT_TIMEOUT PGAPPNAME PGOPTIONS PGSSLMODE PGSSLNEGOTIATION PGCHANNELBINDING PGTARGETSESSIONATTRS PGCLIENTENCODING PGTZ PGDATESTYLE; do
        [[ ! -v $variable ]] || options+=(--env "$variable")
      done
      if [[ -n ''${PGPASSFILE:-} ]]; then
        private_file "$PGPASSFILE"
        options+=(--volume "$(realpath -- "$PGPASSFILE"):/run/pgpass:ro" --env PGPASSFILE=/run/pgpass)
      fi
      [[ ! -t 0 || ! -t 1 ]] || options+=(-t)
      exec "''${podman[@]}" run --rm -i --pull=never --image-volume=ignore --network=host --log-driver=none \
        --label "$owner=$PGDEV_CONTAINER" --entrypoint="$program" "''${options[@]}" "$image" "$@"
    }
    local_client() {
      local program=$1 database=$2
      shift 2
      local -a limit=()
      # Bound readiness and short administrative SQL, including startup overhead.
      [[ $program != psql && $program != pg_isready ]] || limit=(--timeout=10)
      podman_local run --rm -i --pull=never --image-volume=ignore --network=host --log-driver=none "''${limit[@]}" \
        --label "$owner=$PGDEV_CONTAINER" --entrypoint="$program" --volume "$state/pgpass:/run/pgpass:ro" \
        --env PGPASSFILE=/run/pgpass --env PGHOST=127.0.0.1 --env "PGPORT=$PGDEV_PORT" \
        --env "PGUSER=$PGDEV_USER" --env "PGDATABASE=$database" --env PGCONNECT_TIMEOUT=3 \
        "$image" "$@"
    }
    credentials() {
      private_file "$state/password"
      private_file "$state/pgpass"
      exists secret "$secret" || fail 'Secret missing. Recover the original credentials; pgdev init can reimport the existing password file.'
      owned secret "$secret"
    }
    initialize() {
      preflight
      local pull=''${1:-} password
      [[ -z $pull || $pull == --pull ]] || fail 'Usage: pgdev init [--pull]'
      if exists container "$PGDEV_CONTAINER"; then
        check_container
        [[ -z $pull ]] || fail 'Stop and remove the owned container before explicitly pulling an update.'
      fi
      if exists volume "$PGDEV_VOLUME"; then
        check_volume
        private_file "$state/password"
      fi
      if exists secret "$secret"; then
        owned secret "$secret"
        private_file "$state/password"
      fi
      if [[ $pull == --pull ]]; then
        podman_local pull "$PGDEV_IMAGE" >&2
      elif [[ ! -f $state/image ]] && ! podman_local image exists "$PGDEV_IMAGE"; then
        podman_local pull "$PGDEV_IMAGE" >&2
      fi
      if [[ ! -f $state/image || $pull == --pull ]]; then
        podman_local image inspect --format '{{.Id}}' "$PGDEV_IMAGE" >"$state/image.tmp"
        mv -- "$state/image.tmp" "$state/image"
      fi
      load_image
      podman_local image inspect --format '{{.Digest}}' "$image" >"$state/digest"
      note "Image digest: $(cat "$state/digest")"
      podman_local run --rm --pull=never --image-volume=ignore --network=bridge --log-driver=k8s-file --label "$owner=$PGDEV_CONTAINER" --entrypoint=true "$image" || fail 'Rootless runtime/network check failed; no isolation settings have been disabled.'
      if [[ ! -e $state/password ]]; then
        # Hex has no pgpass delimiters; the password never leaves files/stdin.
        (
          set -o noclobber
          od -An -N32 -tx1 /dev/urandom | tr -d ' \n' >"$state/password"
        )
      fi
      private_file "$state/password"
      [[ -s $state/password ]] || fail 'Empty password file; recover credentials before continuing.'
      if ! exists secret "$secret"; then
        podman_local secret create --label "$owner=$PGDEV_CONTAINER" "$secret" "$state/password" >&2
      fi
      password=$(<"$state/password")
      [[ $password =~ ^[a-f0-9]{64}$ ]] || fail 'Expected the original generated password file.'
      printf '127.0.0.1:%s:*:%s:%s\n' "$PGDEV_PORT" "$PGDEV_USER" "$password" >"$state/pgpass.tmp"
      unset password
      mv -- "$state/pgpass.tmp" "$state/pgpass"
      if ! exists volume "$PGDEV_VOLUME"; then
        podman_local volume create --label "$owner=$PGDEV_CONTAINER" --label "io.aileks.pgdev.schema=$schema" "$PGDEV_VOLUME" >&2
      fi
      note 'Initialized. Run pgdev start explicitly; initialization does not start the server.'
    }
    query_ready() {
      local_client psql "$PGDEV_DATABASE" -X -w -At -v ON_ERROR_STOP=1 -c 'SELECT 1' </dev/null >/dev/null
    }
    start() {
      check_volume
      credentials
      load_image
      if exists container "$PGDEV_CONTAINER"; then
        check_container
      else
        podman_local create --name "$PGDEV_CONTAINER" --pull=never \
          --label "$owner=$PGDEV_CONTAINER" --label "io.aileks.pgdev.settings=$settings" \
          --network=bridge --publish "127.0.0.1:$PGDEV_PORT:5432" --log-driver=k8s-file \
          --restart=no --volume "$PGDEV_VOLUME:/var/lib/postgresql" \
          --secret "$secret,type=mount,target=postgres-password" \
          --env POSTGRES_PASSWORD_FILE=/run/secrets/postgres-password \
          --env "POSTGRES_USER=$PGDEV_USER" --env "POSTGRES_DB=$PGDEV_DATABASE" \
          --env POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256 \
          --env POSTGRES_HOST_AUTH_METHOD=scram-sha-256 "$image" >&2
      fi
      if [[ $(podman_local inspect --format '{{.State.Running}}' "$PGDEV_CONTAINER") != true ]]; then
        [[ -z $(ss -H -ltn "sport = :$PGDEV_PORT") ]] || fail "Port $PGDEV_PORT is already in use. Set PGDEV_PORT, then remove only the stopped owned container to recreate its publication."
        podman_local start "$PGDEV_CONTAINER" >&2 || fail "Could not start $PGDEV_CONTAINER; check port $PGDEV_PORT and pgdev logs."
      fi
      local deadline=$((SECONDS + 60))
      while ((SECONDS < deadline)); do
        [[ $(podman_local inspect --format '{{.State.Running}}' "$PGDEV_CONTAINER") == true ]] || fail 'Server exited; inspect pgdev logs.'
        if local_client pg_isready "$PGDEV_DATABASE" -t 2 </dev/null >/dev/null 2>&1; then
          query_ready || fail 'TCP is accepting connections but authentication/query failed. Initialization variables do not update an existing database.'
          note "Ready on 127.0.0.1:$PGDEV_PORT."
          return
        fi
        sleep 1
      done
      fail 'Readiness timed out after 60 seconds; inspect pgdev logs.'
    }
    status() {
      if ! exists container "$PGDEV_CONTAINER"; then
        note absent
        return
      fi
      check_container
      local running exit_code started
      read -r running exit_code started < <(podman_local inspect --format '{{.State.Running}} {{.State.ExitCode}} {{.State.StartedAt}}' "$PGDEV_CONTAINER")
      [[ ! -f $state/digest ]] || note "Recorded digest: $(cat "$state/digest")"
      if [[ $running != true ]]; then
        if ((exit_code == 0)); then note stopped; else
          note failed
          return 1
        fi
      else
        load_image
        if local_client pg_isready "$PGDEV_DATABASE" -t 2 </dev/null >/dev/null 2>&1; then
          if query_ready 2>/dev/null; then note ready; else
            note failed
            return 1
          fi
        elif (($(date +%s) - $(date -d "$started" +%s) < 60)); then
          note starting
        else
          note failed
          return 1
        fi
      fi
    }
    dump() (
      local database=$1 temporary destination
      identifier "$database"
      check_volume
      credentials
      load_image
      private_dir "$state_root/backups"
      temporary=$(mktemp "$state_root/backups/.dump.XXXXXXXX")
      trap 'rm -f -- "$temporary"' EXIT
      destination=$state_root/backups/$database-$(date -u +%Y%m%dT%H%M%SZ)-''${temporary##*.}.dump
      local_client pg_dump "$database" -w -Fc >"$temporary"
      mv -- "$temporary" "$destination"
      printf '%s\n' "$destination"
    )
    restore() {
      local database=$1 archive=$2
      identifier "$database"
      [[ -f $archive && -r $archive ]] || fail 'Restore input must be a readable file.'
      check_volume
      credentials
      load_image
      local_client pg_restore "$PGDEV_DATABASE" --list <"$archive" >/dev/null
      # CREATE DATABASE refuses any existing target, including an empty database.
      local_client psql "$PGDEV_DATABASE" -X -w -v ON_ERROR_STOP=1 -v "target=$database" >&2 <<'SQL'
    SELECT format('CREATE DATABASE %I', :'target') \gexec
    SQL
      local_client pg_restore "$database" -w --exit-on-error --single-transaction --dbname="$database" <"$archive"
      note "Restored into $database. Verify it before using or deleting any other database."
    }

    if [[ ''${0##*/} == psql ]]; then
      command=psql
    else
      command=''${1:-help}
      shift || true
    fi
    case $command in
      help | --help | -h)
        printf 'Usage: pgdev {init [--pull]|start|stop|status|logs [OPTIONS]|psql [ARGS]|dump DB|restore TARGET_DB FILE}\n'
        exit
        ;;
      init) (($# <= 1)) || fail 'Usage: pgdev init [--pull]' ;;
      start | stop | status) (($# == 0)) || fail "Usage: pgdev $command" ;;
      dump) (($# == 1)) || fail 'Usage: pgdev dump DB' ;;
      restore) (($# == 2)) || fail 'Usage: pgdev restore TARGET_DB FILE' ;;
      logs | psql) ;;
      *) fail "Unknown command: $command" ;;
    esac
    command -v podman >/dev/null || fail 'Podman is not installed.'
    if [[ $command == psql ]]; then
      load_image
      client psql "$@"
    fi
    if [[ $command == status ]]; then
      status
      exit
    fi
    # Serialize lifecycle and backup operations for this instance, not SQL sessions.
    private_dir "$state_root"
    private_dir "$state"
    exec 9>"$state/lock"
    flock -w 10 9 || fail 'Another pgdev operation is in progress.'
    case $command in
      init) initialize "$@" ;;
      start) start ;;
      stop)
        if exists container "$PGDEV_CONTAINER"; then
          owned container "$PGDEV_CONTAINER"
          podman_local stop --time 30 "$PGDEV_CONTAINER" >&2
        else note absent; fi
        ;;
      logs)
        exists container "$PGDEV_CONTAINER" || fail 'Container absent.'
        owned container "$PGDEV_CONTAINER"
        flock -u 9
        exec "''${podman[@]}" logs "$@" "$PGDEV_CONTAINER"
        ;;
      dump) dump "$@" ;;
      restore) restore "$@" ;;
    esac
  '';
}
