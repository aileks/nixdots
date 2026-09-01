{
  description = "aileks NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    self.submodules = true;

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      localPackageNames = [
        "mitishell"
        "cinder-grove-gtk"
        "papirus-cinder-grove"
        "fastmail-desktop"
        "tensaku"
      ];
      overlay = final: _prev: {
        mitishell = final.callPackage ./packages/mitishell.nix { };
        cinder-grove-gtk = final.callPackage ./packages/cinder-grove-gtk.nix { };
        papirus-cinder-grove = final.callPackage ./packages/papirus-cinder-grove.nix { };
        fastmail-desktop = final.callPackage ./packages/fastmail-desktop.nix { };
        tensaku = final.callPackage ./packages/tensaku.nix { };
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
      localPackages = nixpkgs.lib.genAttrs localPackageNames (name: pkgs.${name});
    in
    {
      overlays.default = overlay;
      packages.${system} = localPackages;
      checks.${system} = localPackages;

      nixosConfigurations.nixghost = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ({ ... }: { nixpkgs.overlays = [ overlay ]; })
          ./modules/common.nix
          ./hosts/nixghost
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              extraSpecialArgs = { inherit inputs; };
              users.aileks = import ./home.nix;
            };
          }
        ];
      };
    };
}
