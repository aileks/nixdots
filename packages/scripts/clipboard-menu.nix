{ pkgs, scripts }:
pkgs.writeShellApplication {
  name = "clipboard-menu";
  runtimeInputs = [
    pkgs.clipmenu
    pkgs.dmenu
    pkgs.xclip
    pkgs.coreutils
    pkgs.gawk
    scripts.desktop-feedback
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    set -Eeuo pipefail

    command -v clipmenu >/dev/null || {
      desktop-feedback status 'Clipboard history unavailable'
      exit 1
    }
    export CM_DIR="''${XDG_RUNTIME_DIR:-/run/user/$UID}/clipmenu"
    export CM_LAUNCHER="${pkgs.dmenu}/bin/dmenu"
    exec clipmenu
  '';
}
