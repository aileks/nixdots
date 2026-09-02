{ pkgs, ... }:

{
  imports = [
    ./gpu.nix
    ./hardware-configuration.nix
    ./hostname.nix
    ./storage.nix
  ];

  hardware.graphics.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "26.05";
}
