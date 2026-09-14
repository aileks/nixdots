{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "audio";
  runtimeInputs = [
    scripts.desktop-feedback
    pkgs.gawk
    pkgs.wireplumber
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    fail() {
      desktop-feedback status "$1 failed" || true
      exit 1
    }

    case ''${1:-} in
      sink)
        target=@DEFAULT_AUDIO_SINK@
        case ''${2:-} in
          up) operation=(wpctl set-volume -l 1.0 "$target" 5%+) ;;
          down) operation=(wpctl set-volume -l 1.0 "$target" 5%-) ;;
          mute) operation=(wpctl set-mute "$target" toggle) ;;
          *)
            printf 'usage: audio sink <up|down|mute> | audio mic mute\n' >&2
            exit 2
            ;;
        esac
        "''${operation[@]}" || fail 'Volume change'
        state=$(wpctl get-volume "$target") || fail 'Volume state'
        value=$(awk -v v="''${state#Volume: }" 'BEGIN { printf "%.0f", v * 100 }')
        if [[ $state == *'[MUTED]'* ]]; then
          desktop-feedback progress "$value" 'Volume muted' || true
        else
          desktop-feedback progress "$value" "Volume $value%" || true
        fi
        ;;
      mic)
        [[ ''${2:-} == mute ]] || {
          printf 'usage: audio sink <up|down|mute> | audio mic mute\n' >&2
          exit 2
        }
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || fail 'Microphone change'
        state=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@) || fail 'Microphone state'
        if [[ $state == *'[MUTED]'* ]]; then
          desktop-feedback status 'Microphone muted' || true
        else
          desktop-feedback status 'Microphone unmuted' || true
        fi
        ;;
      *)
        printf 'usage: audio sink <up|down|mute> | audio mic mute\n' >&2
        exit 2
        ;;
    esac
  '';
}
