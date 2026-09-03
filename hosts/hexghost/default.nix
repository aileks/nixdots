{
  config,
  inputs,
  installation,
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

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.i2c.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = nvidiaDriver;
    nvidiaSettings = true;
    powerManagement.enable = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${installation.user.name} = {
    imports = [
      inputs.voxtype.homeManagerModules.default
    ];

    home.packages = with pkgs; [
      btop-cuda
    ];

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
