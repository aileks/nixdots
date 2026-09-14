{
  pkgs,
  colors ? import ../../theme/cinder-grove.nix,
}:
pkgs.writeShellApplication {
  name = "lock-session";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.procps
    pkgs.util-linux
    pkgs.gawk
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    readonly RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$UID}"
    readonly LOCK_FILE="$RUNTIME_DIR/i3lock-color.lock"

    for cmd in ${pkgs.i3lock-color}/bin/i3lock flock pgrep; do
      command -v "$cmd" >/dev/null 2>&1 || exit 1
    done

    [[ -d "$RUNTIME_DIR" && -O "$RUNTIME_DIR" ]] || exit 1

    exec 9>"$LOCK_FILE"
    flock -w 10 9 || exit 1
    ready_file="$RUNTIME_DIR/i3lock-color.ready"
    already_locked=false
    if [[ -r $ready_file ]]; then
      read -r locker_pid locker_start <"$ready_file" || true
      if [[ ''${locker_pid:-} =~ ^[0-9]+$ && ''${locker_start:-} =~ ^[0-9]+$ ]] \
        && [[ $(awk '{print $22}' "/proc/$locker_pid/stat" 2>/dev/null) == "$locker_start" ]] \
        && [[ $(readlink -f "/proc/$locker_pid/exe" 2>/dev/null) == "$(readlink -f ${pkgs.i3lock-color}/bin/i3lock)" ]]; then
        already_locked=true
      fi
    fi

    i3lock_opts=(
      '--color=${pkgs.lib.removePrefix "#" colors.background}'
      '--inside-color=${pkgs.lib.removePrefix "#" colors.container}ff'
      '--insidever-color=${pkgs.lib.removePrefix "#" colors.surface}ff'
      '--insidewrong-color=${pkgs.lib.removePrefix "#" colors.surface}ff'
      '--ring-color=${pkgs.lib.removePrefix "#" colors.yellow}ff'
      '--ringver-color=${pkgs.lib.removePrefix "#" colors.cyan}ff'
      '--ringwrong-color=${pkgs.lib.removePrefix "#" colors.red}ff'
      '--line-color=${pkgs.lib.removePrefix "#" colors.container}ff'
      '--separator-color=${pkgs.lib.removePrefix "#" colors.muted}ff'
      '--keyhl-color=${pkgs.lib.removePrefix "#" colors.green}ff'
      '--bshl-color=${pkgs.lib.removePrefix "#" colors.orange}ff'
      '--verif-color=${pkgs.lib.removePrefix "#" colors.bright}ff'
      '--wrong-color=${pkgs.lib.removePrefix "#" colors.bright}ff'
      '--modif-color=${pkgs.lib.removePrefix "#" colors.purple}ff'
      '--layout-color=${pkgs.lib.removePrefix "#" colors.blue}ff'
      '--time-color=${pkgs.lib.removePrefix "#" colors.bright}ff'
      '--date-color=${pkgs.lib.removePrefix "#" colors.secondary}ff'
      '--clock'
      '--indicator'
      '--time-str=%H:%M'
      '--date-str=%a, %b %d'
      '--time-size=28'
      '--date-size=11'
      '--verif-size=12'
      '--wrong-size=12'
      '--modif-size=11'
      '--layout-size=11'
      '--radius=80'
      '--ring-width=8'
      '--verif-text=verifying'
      '--wrong-text=incorrect'
      '--noinput-text='
      '--show-failed-attempts'
      '--ignore-empty-password'
    )

    sleep_fd="''${XSS_SLEEP_LOCK_FD:-}"

    if ! "$already_locked"; then
      if [[ "$sleep_fd" =~ ^[0-9]+$ ]] && [[ -e "/proc/$$/fd/$sleep_fd" ]]; then
        ${pkgs.i3lock-color}/bin/i3lock "''${i3lock_opts[@]}" {XSS_SLEEP_LOCK_FD}<&- 9>&-
      else
        ${pkgs.i3lock-color}/bin/i3lock "''${i3lock_opts[@]}" 9>&-
      fi
      locker_pid=$(pgrep -n -u "$UID" -x i3lock) || exit 1
      locker_start=$(awk '{print $22}' "/proc/$locker_pid/stat")
      printf '%s %s\n' "$locker_pid" "$locker_start" >"$ready_file"
    fi
    if [[ "$sleep_fd" =~ ^[0-9]+$ ]] && [[ -e "/proc/$$/fd/$sleep_fd" ]]; then
      exec {XSS_SLEEP_LOCK_FD}<&-
    fi
    flock -u 9
    while [[ $(awk '{print $22}' "/proc/$locker_pid/stat" 2>/dev/null) == "$locker_start" ]]; do
      sleep 0.25
    done
  '';
}
