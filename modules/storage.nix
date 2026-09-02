{ installation, ... }:

let
  inherit (installation.storage) root boot swap;
in
{
  boot.resumeDevice = "/dev/disk/by-label/${swap.label}";

  fileSystems.${root.mountPoint} = {
    inherit (root) label fsType;
  };

  fileSystems.${boot.mountPoint} = {
    inherit (boot) label fsType;
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ { inherit (swap) label; } ];
}
