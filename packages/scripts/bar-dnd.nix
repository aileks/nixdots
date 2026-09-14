{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "bar-dnd";
  runtimeInputs = [
    pkgs.dunst
    scripts.notification-history
    scripts.dnd-toggle
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    case ''${BLOCK_BUTTON:-} in
      1) dnd-toggle >/dev/null 2>&1 & ;;
      2) dunstctl history-clear >/dev/null 2>&1 & ;;
      3) notification-history >/dev/null 2>&1 & ;;
    esac

    if ! pause_level=$(dunstctl get-pause-level 2>/dev/null); then
      printf '󰂜\n'
      exit 0
    fi

    if ((pause_level > 0)); then
      printf '󰂛\n'
    else
      printf '󰂚\n'
    fi
  '';
}
