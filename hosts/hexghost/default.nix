{
  installation,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  networking.hostName = "hexghost";

  services.xserver.videoDrivers = [ "nvidia" ];

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

  services.ivpn.enable = true;

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "${../../config/OpenRGB}/No RGB.orp";
  };

  home-manager.backupFileExtension = "backup";

  home-manager.users.${installation.user.name} = {
    programs.btop.package = pkgs.btop-cuda;
  };
}
