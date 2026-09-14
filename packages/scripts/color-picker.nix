{ pkgs }:
pkgs.writeShellApplication {
  name = "color-picker";
  runtimeInputs = [
    pkgs.maim
    pkgs.slop
    pkgs.xclip
    pkgs.coreutils
    pkgs.ffmpeg
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -euo pipefail

    geometry=$(slop -f '%w %h %x %y' </dev/null) || exit 0
    read -r _ _ x y <<<"$geometry"
    printf -v capture_geometry '1x1%+d%+d' "$x" "$y"
    pixel=$(maim -g "$capture_geometry" - | ffmpeg -loglevel error -i pipe:0 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | od -An -tu1)
    read -r red green blue <<<"$pixel"
    printf -v color '#%02X%02X%02X' "$red" "$green" "$blue"
    xclip -selection clipboard -in <<<"$color"
    printf '%s\n' "$color"
  '';
}
