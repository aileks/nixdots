{ pkgs }:
pkgs.writeShellApplication {
  name = "night-light";
  runtimeInputs = [ pkgs.systemd ];
  text = pkgs.lib.removeSuffix "\n" ''
    case ''${1:-toggle} in
      toggle)
        if systemctl --user is-active --quiet night-light.service; then
          systemctl --user stop night-light.service
        else
          systemctl --user start night-light.service
        fi
        ;;
      *)
        printf 'Usage: night-light [toggle]\n' >&2
        exit 2
        ;;
    esac
  '';
}
