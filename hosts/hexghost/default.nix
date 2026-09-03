{
  config,
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
    home.packages = with pkgs; [
      voxtype-onnx
      btop-cuda
    ];

    systemd.user.services.voxtype = {
      Unit = {
        Description = "VoxType push-to-talk voice-to-text daemon";
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "pipewire.service"
          "pipewire-pulse.service"
        ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.voxtype-onnx}/bin/voxtype daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
