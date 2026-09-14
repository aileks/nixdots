{ ... }:
{
  programs.nix-search-tv = {
    enable = true;
    settings.indexes = [
      "nixpkgs"
      "nixos"
      "home-manager"
    ];
  };

}
