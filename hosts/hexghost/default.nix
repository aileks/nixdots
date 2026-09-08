{
  inputs,
  installation,
  lib,
  pkgs,
  ...
}:

let
  monitorEdids = builtins.fromJSON (builtins.readFile ./monitor-edids.json);
  mainDisplay = {
    mode = "2560x1440";
    rate = "200.00";
    primary = true;
    position = "0x0";
  };
  portraitDisplay = {
    mode = "1920x1080";
    rate = "200.00";
    rotate = "left";
    position = "0x0";
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
      ${pkgs.autorandr}/bin/autorandr --change
    '';
  };

  services.autorandr = {
    enable = true;
    profiles = {
      desktop = {
        fingerprint = monitorEdids;
        config = {
          DP-0 = mainDisplay // {
            position = "1080x240";
          };
          HDMI-0 = portraitDisplay;
        };
      };
      main = {
        fingerprint = { inherit (monitorEdids) DP-0; };
        config = {
          DP-0 = mainDisplay;
          HDMI-0.enable = false;
        };
      };
      portrait = {
        fingerprint = { inherit (monitorEdids) HDMI-0; };
        config = {
          HDMI-0 = portraitDisplay // {
            primary = true;
          };
          DP-0.enable = false;
        };
      };
    };
    hooks.postswitch.desktop = ''
      if ${pkgs.systemd}/bin/systemctl --user is-active --quiet graphical-session.target; then
        ${pkgs.systemd}/bin/systemctl --user start wallpaper.service
        /etc/profiles/per-user/${installation.user.name}/bin/night-light apply
      fi
    '';
  };
  # The upstream NixOS hook is attached to sleep.target, before actual suspend.
  systemd.services.autorandr = {
    wantedBy = lib.mkForce [ "suspend.target" ];
    after = [ "systemd-suspend.service" ];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c548", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
  '';

  hardware.nvidia = {
    modesetting.enable = true;
    videoAcceleration = true;
    open = true;
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

  services.ivpn.enable = true;

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "${../../config/OpenRGB}/No RGB.orp";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${installation.user.name} = {
    xdg.configFile."autostart/autorandr.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=autorandr
      Hidden=true
    '';
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
