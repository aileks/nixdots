{
  installation,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./xorg.nix ];

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;
  system.stateVersion = "26.05";

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

  users.groups.${installation.user.group}.gid = lib.mkDefault installation.user.gid;

  users.users.${installation.user.name} = {
    isNormalUser = true;
    inherit (installation.user) uid group;
    shell = pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "networkmanager"
      "i2c"
    ];
  };

  services = {
    displayManager.ly = {
      enable = true;
      x11Support = true;
    };
    blueman.enable = true;
    openssh.enable = true;
    printing.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    gnome = {
      gnome-keyring.enable = true;
      gcr-ssh-agent.enable = false;
    };
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

  environment.etc."xdg/pcmanfm/default/pcmanfm.conf".text = ''
    [volume]
    mount_on_startup=0
    mount_removable=0
    autorun=0
  '';

  environment.etc."xdg/libfm/libfm.conf".text = ''
    [config]
    terminal=wezterm
    archiver=file-roller
  '';

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs = {
    dconf.enable = true;
    nix-ld.enable = true;
    system-config-printer.enable = true;
    localsend.enable = true;
    gpu-screen-recorder.enable = true;
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    lmmath
  ];
}
