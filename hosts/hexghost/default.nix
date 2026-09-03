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

  voxtypePackage = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.onnx-cuda;
in
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "hexghost";

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = nvidiaDriver;
    nvidiaSettings = true;
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${installation.user.name} = {
    imports = [ inputs.voxtype.homeManagerModules.default ];

    home.packages = with pkgs; [
      btop-cuda
      openrgb
    ];

    programs.voxtype = {
      enable = true;

      package = voxtypePackage;

      engine = "parakeet";

      service.enable = true;

      settings = {
        parakeet = {
          model = "parakeet-tdt-0.6b-v3";
        };

        output = {
          mode = "type";
          fallback_to_clipboard = true;
        };
      };
    };
  };
}
