{
  config,
  lib,
  ...
}:

let
  # bin/install updates this choice for the target machine.
  enableNvidia = false;
in
{
  services.xserver.videoDrivers = lib.mkIf enableNvidia [ "nvidia" ];

  hardware.nvidia = lib.mkIf enableNvidia {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
