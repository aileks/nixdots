{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "power-menu";
  runtimeInputs = [
    scripts.desktop-feedback
    pkgs.dmenu
    pkgs.systemd
    pkgs.procps
    pkgs.xdotool
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -euo pipefail

    choice=$(printf '%s\n' 'log out' 'suspend' 'reboot' 'shut down' | dmenu -p Power) || exit 0
    case "$choice" in
      'log out') xdotool key --clearmodifiers super+shift+q ;;
      'suspend')
        pgrep -u "$UID" -x xss-lock >/dev/null || {
          desktop-feedback status 'Cannot suspend: automatic screen locking is not running'
          exit 1
        }
        systemctl suspend
        ;;
      'reboot') systemctl reboot ;;
      'shut down') systemctl poweroff ;;
    esac
  '';
}
