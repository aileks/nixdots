{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "bar-volume";
  runtimeInputs = [
    scripts.audio
    pkgs.wireplumber
    pkgs.gawk
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    case ''${BLOCK_BUTTON:-} in
      1) audio sink mute ;;
      4) audio sink up ;;
      5) audio sink down ;;
    esac

    volume=$(wpctl get-volume '@DEFAULT_AUDIO_SINK@' 2>/dev/null) || {
      printf 'n/a\n'
      exit 0
    }

    if [[ $volume == *'[MUTED]'* ]]; then
      printf '%s mute\n' ''
      exit 0
    fi

    percent=$(awk '{ printf "%.0f", $2 * 100 }' <<<"$volume")
    printf '%s %s%%\n' '' "$percent"
  '';
}
