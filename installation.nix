{
  user = {
    name = "aileks";
    uid = 1000;
    group = "users";
    gid = 100;
    homeDirectory = "/home/aileks";
  };

  repositoryDirectory = ".dotfiles";

  storage = {
    root = {
      mountPoint = "/";
      label = "nixos";
      fsType = "ext4";
    };
    boot = {
      mountPoint = "/boot";
      label = "boot";
      fsType = "vfat";
    };
    swap.label = "swap";
  };
}
