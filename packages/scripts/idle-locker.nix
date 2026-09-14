{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "idle-locker";
  runtimeInputs = [
    scripts.lock-session
    pkgs.coreutils
    pkgs.procps
    pkgs.systemd
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -u

    lock_pid=$(pgrep -n -u "$UID" -x i3lock 2>/dev/null || true)
    if [[ -z $lock_pid ]]; then
      lock-session &
      lock_pid=$!
    fi

    minutes_locked=0
    while kill -0 "$lock_pid" 2>/dev/null; do
      sleep 60
      kill -0 "$lock_pid" 2>/dev/null || break
      ((minutes_locked += 1))
      if ((minutes_locked >= 20)); then
        systemctl suspend
      fi
    done

    wait "$lock_pid" 2>/dev/null || true
  '';
}
