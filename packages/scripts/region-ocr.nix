{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "region-ocr";
  runtimeInputs = [
    scripts.desktop-feedback
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.maim
    pkgs.slop
    pkgs.xclip
    pkgs.tesseract5
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    umask 077
    directory=$(mktemp -d "''${XDG_RUNTIME_DIR:?}/ocr.XXXXXXXX")
    trap 'rm -rf -- "$directory"' EXIT
    trap 'exit 130' INT TERM HUP

    if ! geometry=$(slop -f '%w %h %x %y' </dev/null 2>"$directory/error"); then
      exit 0
    fi
    read -r width height x y <<<"$geometry"
    printf -v capture_geometry '%sx%s%+d%+d' "$width" "$height" "$x" "$y"

    if ! maim -g "$capture_geometry" "$directory/image.png" 2>"$directory/error" \
      || ! tesseract "$directory/image.png" stdout -l eng >"$directory/text" 2>"$directory/error"; then
      desktop-feedback status 'Text recognition failed'
      exit 1
    fi

    if ! grep -q '[^[:space:]]' "$directory/text"; then
      desktop-feedback status 'No text found'
      exit 0
    fi

    if ! xclip -selection clipboard -in <"$directory/text"; then
      desktop-feedback status 'Could not copy recognized text'
      exit 1
    fi

    desktop-feedback status 'Recognized text copied'
  '';
}
