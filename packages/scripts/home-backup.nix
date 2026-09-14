{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "home-backup";
  runtimeInputs = [
    scripts.desktop-feedback
    pkgs.coreutils
    pkgs.findutils
    pkgs.rsync
    pkgs.util-linux
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    umask 077

    only_if_due=false
    case ''${1:-} in
      ''') (($# == 0)) || exit 2 ;;
      --if-due)
        (($# == 1)) || exit 2
        only_if_due=true
        ;;
      *)
        printf 'usage: home-backup [--if-due]\n' >&2
        exit 2
        ;;
    esac

    user_name="$(id -un)"
    backup_label="''${BACKUP_LABEL:-External}"
    backup_mount_base="''${BACKUP_MOUNT_BASE:-/run/media/$user_name}"
    source_directory="$HOME/"
    external_mount="$backup_mount_base/$backup_label"
    backup_root="$external_mount/Backups/$(uname -n)"
    snapshots_directory="$backup_root/snapshots"
    latest_link="$backup_root/latest"
    logs_directory="$backup_root/logs"
    timestamp="$(date -u +%Y-%m-%dT%H%M%SZ)"
    new_snapshot="$snapshots_directory/$timestamp"
    incomplete_snapshot="$snapshots_directory/.$timestamp.incomplete"
    excludes="''${XDG_CONFIG_HOME:-$HOME/.config}/rsync-home.excludes"
    state_directory="''${XDG_STATE_HOME:-$HOME/.local/state}/home-backup"
    status_file="$state_directory/status"
    success_file="$state_directory/last-success"
    mkdir -p "$state_directory"

    write_success_time() {
      printf '%s\n' "$1" >"$success_file.tmp"
      mv -f -- "$success_file.tmp" "$success_file"
    }

    write_status() {
      local state=$1 message=''${2:-}
      printf '%s %s%s\n' "$(date -u +%Y-%m-%dT%H%M%SZ)" "$state" \
        "''${message:+ $message}" >"$status_file.tmp"
      mv -f -- "$status_file.tmp" "$status_file"
    }

    notify() {
      desktop-feedback status "Home Backup: $*" >/dev/null 2>&1 || true
    }

    failed() {
      local status=$?
      write_status failed "exit $status"
      printf 'error: Home Backup failed (exit %s). Log: %s\n' \
        "$status" "$logs_directory/$timestamp.log" >&2
      notify "Backup failed (exit $status). Log: $logs_directory/$timestamp.log"
      exit "$status"
    }

    trap failed ERR

    exec 9>"$state_directory/home-backup.lock"
    if ! flock -n 9; then
      printf 'home-backup is already running\n'
      exit 0
    fi

    if "$only_if_due"; then
      last_success='''
      if [[ -r $success_file ]]; then
        last_success=$(<"$success_file")
      elif [[ -L $latest_link && -d $latest_link ]]; then
        # stat the link itself: rsync preserves the source directory's mtime.
        last_success=$(stat -c %Y -- "$latest_link")
        write_success_time "$last_success"
      fi

      now=$(date +%s)
      if [[ $last_success =~ ^[0-9]{1,10}$ ]] \
        && ((now >= 10#$last_success && now - 10#$last_success < 86400)); then
        exit 0
      fi

      schedule_log="$state_directory/scheduled.log"
      if [[ -f $schedule_log ]] && (($(stat -c %s -- "$schedule_log") > 1048576)); then
        mv -f -- "$schedule_log" "$schedule_log.1"
      fi
      exec >>"$schedule_log" 2>&1
      printf '%s Scheduled backup attempt\n' "$timestamp"
    fi

    if ! mountpoint -q "$external_mount"; then
      message="Backup mount not available: $external_mount"
      write_status unavailable "$external_mount"
      notify "$message"
      printf 'error: %s\n' "$message" >&2
      exit 1
    fi

    if [[ ! -r $excludes ]]; then
      write_status failed "missing exclude file: $excludes"
      notify "Missing exclude file: $excludes"
      printf 'error: missing exclude file: %s\n' "$excludes" >&2
      exit 1
    fi

    if [[ -e $new_snapshot || -L $new_snapshot ]]; then
      write_status failed "snapshot already exists: $timestamp"
      printf 'error: snapshot already exists: %s\n' "$new_snapshot" >&2
      exit 1
    fi

    mkdir -p "$snapshots_directory" "$logs_directory"
    find "$snapshots_directory" -mindepth 1 -maxdepth 1 -type d -name '.*.incomplete' \
      -exec rm -rf -- {} +
    mkdir "$incomplete_snapshot"
    write_status started "$timestamp"
    notify 'Backup starting...'

    previous_snapshot='''
    if [[ -L $latest_link ]]; then
      previous_snapshot=$(readlink -f "$latest_link" || true)
    fi

    rsync_options=(
      -aAXH --numeric-ids -x
      --delete-delay --delete-excluded
      --partial-dir=.rsync-partial
      --log-file="$logs_directory/$timestamp.log"
      --exclude-from="$excludes"
    )

    if ! "$only_if_due"; then
      rsync_options+=(--info=progress2 --itemize-changes)
    fi

    if [[ -n $previous_snapshot && -d $previous_snapshot ]]; then
      rsync_options+=(--link-dest="$previous_snapshot")
    fi

    rsync "''${rsync_options[@]}" "$source_directory" "$incomplete_snapshot/"
    mv -T -- "$incomplete_snapshot" "$new_snapshot"
    ln -sfnT "$new_snapshot" "$latest_link"

    mapfile -d ''' -t snapshots < <(find "$snapshots_directory" -mindepth 1 -maxdepth 1 \
      -type d -printf '%f\0' | LC_ALL=C sort -zr)
    completed_count=0
    for snapshot in "''${snapshots[@]}"; do
      [[ $snapshot =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}Z$ ]] || continue
      ((completed_count += 1))
      if ((completed_count > 30)); then
        rm -rf -- "''${snapshots_directory:?}/$snapshot"
      fi
    done

    printf 'Backup complete: %s\n' "$new_snapshot"
    write_status complete "$timestamp"
    write_success_time "$(date +%s)"
    notify 'Backup complete'
  '';
}
