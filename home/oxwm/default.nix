{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.dmenu
    pkgs.j4-dmenu-desktop
    pkgs.xclip
    pkgs.xrandr
    pkgs.xdotool
  ];
  xdg.configFile."oxwm/config.lua".source = pkgs.writeText "oxwm-config.lua" (
    import ./config.nix { inherit config pkgs; }
  );
}
