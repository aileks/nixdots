{ pkgs, ... }:

{
  boot.loader = {
    limine = {
      enable = true;
      maxGenerations = 10;
      enableEditor = false;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  hardware = {
    i2c.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy.AutoEnable = true;
      };
    };
  };

  qt.enable = true;

  users.users.aileks = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "i2c"
    ];
  };

  services = {
    displayManager.ly.enable = true;
    openssh.enable = true;
    printing.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs = {
    dconf.enable = true;
    nix-ld.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    system-config-printer.enable = true;
    zsh.enable = true;
    localsend.enable = true;
    gpu-screen-recorder.enable = true;
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    maple-mono.truetype
    maple-mono.NF
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    lmodern
    lmmath
  ];
}
