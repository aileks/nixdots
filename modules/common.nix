{
  installation,
  lib,
  pkgs,
  ...
}:

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

  boot.kernelPackages = pkgs.linuxPackages_latest;
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
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "i2c"
      "ydotool"
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
  security.pam.services.xsecurelock = { };

  services.xserver = {
    enable = true;
    xkb.options = "terminate:ctrl_alt_bksp";
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };
    displayManager.sessionCommands = ''
      ${pkgs.xrandr}/bin/xrandr --output DP-0 --primary --mode 2560x1440 --rate 200.00 --pos 1080x0 \
        --output HDMI-0 --mode 1920x1080 --rate 200.00 --rotate left --pos 0x-240 || true
      ${pkgs.xkbcomp}/bin/xkbcomp ${../xorg/keymap.xkb} "$DISPLAY"
      ${pkgs.numlockx}/bin/numlockx on
      ${pkgs.xset}/bin/xset r rate 250 50
      ${pkgs.xset}/bin/xset s 600 5
      ${pkgs.xset}/bin/xset dpms 660 660 660
    '';
  };

  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs = {
    dconf.enable = true;
    nix-ld.enable = true;
    ydotool.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
    system-config-printer.enable = true;
    zsh.enable = true;
    localsend.enable = true;
    gpu-screen-recorder.enable = true;
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    iosevka-custom
    pkgs.nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    lmmath
  ];
}
