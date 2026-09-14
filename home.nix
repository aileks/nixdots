{ installation, ... }: {
  imports = [
    ./home/packages.nix
    ./home/environment.nix
    ./home/appearance.nix
    ./home/xdg.nix
    ./home/scripts.nix
    ./home/apps.nix
    ./home/oxwm/default.nix
    ./home/apps/doom
    ./home/apps/bash
    ./home/apps/neovim.nix
    ./home/apps/bat.nix
    ./home/apps/btop.nix
    ./home/apps/cava.nix
    ./home/apps/dunst.nix
    ./home/apps/fastfetch.nix
    ./home/apps/fontconfig.nix
    ./home/apps/qt6ct.nix
    ./home/apps/rsync-home.nix
    ./home/apps/starship.nix
    ./home/apps/yazi.nix
    ./home/session.nix
  ];
  home = {
    username = installation.user.name;
    inherit (installation.user) homeDirectory;
    stateVersion = "26.05";
  };
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  programs.btop.enable = true;
  programs.home-manager.enable = true;
}
