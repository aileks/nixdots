{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config.theme = "cinder-grove";
    themes.cinder-grove.src = pkgs.writeText "cinder-grove.tmTheme" (
      import ../../theme/cinder-grove-tmtheme.nix
    );
  };
}
