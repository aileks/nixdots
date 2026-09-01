{ ... }:

{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "nixghost";

  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics.enable = true;
  };

  boot.resumeDevice = "/dev/disk/by-uuid/45513cea-156a-4509-879c-aa83683c99df";
  system.stateVersion = "26.05";
}
