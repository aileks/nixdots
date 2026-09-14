{ pkgs }:
pkgs.writeShellApplication {
  name = "bar-network";
  runtimeInputs = [
    pkgs.networkmanager
    pkgs.wezterm
    pkgs.gawk
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    [[ ''${BLOCK_BUTTON:-} == 1 ]] && wezterm start --always-new-process -- nmtui >/dev/null 2>&1 &

    type=$(nmcli -t -f TYPE,STATE device status 2>/dev/null | awk -F: '$2 == "connected" { print $1; exit }')
    case $type in
      ethernet)
        printf '󰈀 Wired\n'
        ;;
      wifi)
        read -r signal ssid < <(nmcli -t -f IN-USE,SIGNAL,SSID dev wifi 2>/dev/null | awk -F: '$1 == "*" { signal = $2; sub(/^[^:]*:[^:]*:/, ""); print signal, $0; exit }')
        icon=󰤨
        if ((signal < 25)); then
          icon=󰤯
        elif ((signal < 50)); then
          icon=󰤟
        elif ((signal < 75)); then
          icon=󰤢
        elif ((signal < 95)); then
          icon=󰤥
        fi
        [[ -n $ssid ]] && printf '%s %s\n' "$icon" "$ssid" || printf '%s\n' "$icon"
        ;;
      *)
        printf '󰖪 offline\n'
        ;;
    esac
  '';
}
