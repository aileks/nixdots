{ pkgs }:
pkgs.writeShellApplication {
  name = "desktop-feedback";
  runtimeInputs = [ pkgs.dunst ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    kind=''${1:-}
    (($# == 0)) || shift

    case $kind in
      status)
        (($#)) || {
          printf 'usage: desktop-feedback status <summary>\n' >&2
          exit 2
        }
        dunstify \
          --app-name desktop-feedback \
          --hint string:x-dunst-stack-tag:desktop-feedback \
          --expire-time 1800 \
          "$*"
        ;;
      progress)
        value=''${1:-}
        (($# == 0)) || shift
        if [[ ! $value =~ ^0*([0-9]{1,3})$ ]] || ((10#''${BASH_REMATCH[1]} > 100)) || (($# == 0)); then
          printf 'usage: desktop-feedback progress <0-100> <summary>\n' >&2
          exit 2
        fi
        value=$((10#''${BASH_REMATCH[1]}))
        dunstify \
          --app-name desktop-feedback \
          --hint string:x-dunst-stack-tag:desktop-feedback \
          --expire-time 1800 \
          --hint "int:value:$value" \
          "$*"
        ;;
      *)
        printf 'usage: desktop-feedback <status|progress> ...\n' >&2
        exit 2
        ;;
    esac
  '';
}
