{ pkgs }:
pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.maim
    pkgs.slop
    pkgs.xdotool
    pkgs.xrandr
    pkgs.xclip
    pkgs.libnotify
    pkgs.xdg-user-dirs
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    mode=''${1:-}
    case "$mode" in
      region | window | full) ;;
      *)
        printf 'usage: screenshot <region|window|full>\n' >&2
        exit 2
        ;;
    esac

    pictures_directory=$(xdg-user-dir PICTURES 2>/dev/null || true)
    directory="''${pictures_directory:-''${XDG_PICTURES_DIR:-$HOME/Pictures}}/Screenshots"
    mkdir -p "$directory"
    file="$directory/$(date +%Y-%m-%d_%H-%M-%S-%N).png"

    case "$mode" in
      region)
        geometry=$(slop -f '%w %h %x %y' </dev/null) || exit 0
        read -r width height x y <<<"$geometry"
        printf -v geometry '%sx%s%+d%+d' "$width" "$height" "$x" "$y"
        args=(-g "$geometry")
        ;;
      window)
        if ! window=$(xdotool getactivewindow 2>/dev/null); then
          notify-send -u critical -a Screenshot 'Screenshot failed' 'No focused window is available.'
          exit 1
        fi
        args=(-i "$window")
        ;;
      full) args=() ;;
    esac

    if ! maim "''${args[@]}" "$file"; then
      rm -f -- "$file"
      notify-send -u critical -a Screenshot 'Screenshot failed' 'Could not capture the selected area.'
      exit 1
    fi

    if ! xclip -selection clipboard -t image/png -in "$file"; then
      notify-send -u critical -a Screenshot 'Screenshot saved' 'Could not copy the screenshot to the clipboard.'
      exit 1
    fi

    notify-send -a Screenshot -i "$file" 'Screenshot saved and copied' "$file"
  '';
}
