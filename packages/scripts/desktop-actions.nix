{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "desktop-actions";
  runtimeInputs = [
    pkgs.dmenu
    scripts.region-ocr
    scripts.qr-scan
    scripts.reminder
    scripts.notification-history
    scripts.calculate
    pkgs.networkmanager
    pkgs.wezterm
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    choice=$(printf '%s\n' 'OCR' 'Scan QR' 'Reminders' 'Notification History' \
      'Network Settings' 'Quick Calculate' | dmenu -i -p Actions) || exit 0
    case "$choice" in
      'OCR') exec region-ocr ;;
      'Scan QR') exec qr-scan ;;
      'Reminders') exec reminder ;;
      'Notification History') exec notification-history ;;
      'Network Settings') exec wezterm start --always-new-process -- nmtui ;;
      'Quick Calculate') exec calculate ;;
    esac
  '';
}
