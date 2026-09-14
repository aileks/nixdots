{ pkgs }:
pkgs.writeShellApplication {
  name = "bar-memory";
  runtimeInputs = [
    pkgs.wezterm
    pkgs.btop
    pkgs.gawk
    pkgs.procps
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    [[ ''${BLOCK_BUTTON:-} == 1 ]] && wezterm start --always-new-process -- btop >/dev/null 2>&1 &

    free --bytes | awk '/^Mem/ { printf " %.0f%%\n", $3 / $2 * 100 }'
  '';
}
