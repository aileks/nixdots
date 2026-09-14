{ pkgs }:
pkgs.writeShellApplication {
  name = "bar-clock";
  runtimeInputs = [ pkgs.coreutils ];
  text = pkgs.lib.removeSuffix "\n" ''
    state="''${XDG_RUNTIME_DIR:-/run/user/$UID}/bar-clock-format"

    [[ ''${BLOCK_BUTTON:-} == 1 ]] && {
      if [[ -e $state ]]; then
        rm -f -- "$state" || exit 1
      else
        touch -- "$state" || exit 1
      fi
    }

    if [[ -e $state ]]; then
      format='%a %d %b %I:%M %p'
    else
      format='%a %d %b %H:%M'
    fi

    printf -v current_time "%($format)T" -1
    printf '%s %s\n' '' "$current_time"
  '';
}
