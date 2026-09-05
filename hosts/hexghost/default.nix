{
  config,
  inputs,
  installation,
  lib,
  pkgs,
  ...
}:

let
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "610.57.04";
    sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
    sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
    openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
    settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
    persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
  };

  system = pkgs.stdenv.hostPlatform.system;

  voxtypePackage = pkgs.symlinkJoin {
    name = "voxtype-vulkan-with-osd";

    paths = [
      inputs.voxtype.packages.${system}.vulkan
      inputs.voxtype.packages.${system}.osd-gtk4
    ];
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  networking.hostName = "hexghost";

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    deviceSection = ''
      Option "HardDPMS" "false"
    '';
    displayManager.sessionCommands = lib.mkBefore ''
      ${pkgs.xrandr}/bin/xrandr --output DP-0 --primary --mode 2560x1440 --rate 200.00 --pos 1080x240 \
        --output HDMI-0 --mode 1920x1080 --rate 200.00 --rotate left --pos 0x0 || true
    '';
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
  '';

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = nvidiaDriver;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
      kernelSuspendNotifier = false;
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.ydotool.enable = true;
  users.users.${installation.user.name}.extraGroups = [ "ydotool" ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "${../../config/OpenRGB}/No RGB.orp";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${installation.user.name} = {
    imports = [
      inputs.voxtype.homeManagerModules.default
    ];

    programs.btop.package = pkgs.btop-cuda;

    systemd.user.sessionVariables.YDOTOOL_SOCKET = "/run/ydotoold/socket";
    systemd.user.services.voxtype.Service.Environment = [ "YDOTOOL_SOCKET=/run/ydotoold/socket" ];
    systemd.user.services.sxhkd = {
      Unit = {
        Description = "Dictation hotkeys";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.sxhkd}/bin/sxhkd -c ${../../config/sxhkd/sxhkdrc}";
        Environment = [
          "PATH=${
            lib.makeBinPath [ voxtypePackage ]
          }:/etc/profiles/per-user/${installation.user.name}/bin:/run/current-system/sw/bin"
        ];
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    programs.voxtype = {
      enable = true;
      package = voxtypePackage;
      engine = "whisper";
      model.name = "base.en";
      service.enable = true;

      settings = {
        hotkey.enabled = false;
        audio.pause_media = true;
        osd = {
          enabled = true;
          frontend = "gtk4";
          top_margin = 0.6;
        };
        output = {
          mode = "type";
          driver_order = [ "ydotool" ];
          fallback_to_clipboard = true;
          notification = {
            on_recording_start = false;
            on_recording_stop = false;
            on_transcription = false;
          };
        };
      };
    };
  };
}
