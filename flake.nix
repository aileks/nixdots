{
  description = "aileks NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
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
      installation = import ./installation.nix;
      localPackageNames = [
        "dmenu"
        "oxwm"
        "cinder-grove-gtk"
        "papirus-cinder-grove"
        "nvidia-vaapi-driver"
        "sql-language-server"
      ];
      overlay = final: prev: {
        dmenu = final.callPackage ./packages/dmenu.nix { dmenu = prev.dmenu; };
        oxwm = final.callPackage ./packages/oxwm.nix { oxwm = prev.oxwm; };
        cinder-grove-gtk = final.callPackage ./packages/cinder-grove-gtk.nix { };
        papirus-cinder-grove = final.callPackage ./packages/papirus-cinder-grove.nix { };
        sql-language-server = final.callPackage ./packages/sql-language-server.nix { };
        nvidia-vaapi-driver = prev.nvidia-vaapi-driver.overrideAttrs (
          finalAttrs: previousAttrs: {
            version = "0.0.18";
            src = prev.fetchFromGitHub {
              owner = "elFarto";
              repo = "nvidia-vaapi-driver";
              rev = "v${finalAttrs.version}";
              hash = "sha256-cEEPRKoWtNXk8LsDbkhNjnIY7UD1rfYbv2Q6ThG0YLg=";
            };
            meta = previousAttrs.meta // {
              changelog = "https://github.com/elFarto/nvidia-vaapi-driver/releases/tag/v${finalAttrs.version}";
            };
          }
        );
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
      localPackages = nixpkgs.lib.genAttrs localPackageNames (name: pkgs.${name});
      hostNames = [ "hexghost" ];
      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs installation; };
          modules = [
            (_: { nixpkgs.overlays = [ overlay ]; })
            ./modules/common.nix
            ./modules/storage.nix
            (./hosts + "/${hostName}")
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs installation; };
                users.${installation.user.name} = import ./home.nix;
              };
            }
          ];
        };
      hosts = nixpkgs.lib.genAttrs hostNames mkHost;
      hostChecks = nixpkgs.lib.mapAttrs' (
        hostName: host: nixpkgs.lib.nameValuePair "nixos-${hostName}" host.config.system.build.toplevel
      ) hosts;
      home = hosts.hexghost.config.home-manager.users.${installation.user.name};
      scripts = home.lib.nixdots.scripts;
      helpers = {
        install = installer;
        oxwm-session = hosts.hexghost.config.system.build.oxwmSession;
        configure-monitors = home.lib.nixdots.monitors;
      };
      generatedChecks = import ./checks {
        inherit
          pkgs
          self
          scripts
          helpers
          home
          ;
      };
      installer = import ./packages/install.nix { inherit pkgs; };

    in
    {
      lib = { inherit installation; };
      overlays.default = overlay;
      packages.${system} =
        localPackages
        // scripts
        // helpers
        // {
          doom-emacs = home.programs.doom-emacs.finalEmacsPackage;
          neovim = home.programs.neovim.finalPackage;
        };
      apps.${system}.install = {
        type = "app";
        program = "${installer}/bin/nixdots-install";
      };
      checks.${system} = localPackages // hostChecks // generatedChecks;
      formatter.${system} = pkgs.nixfmt-tree;

      nixosConfigurations = hosts;
    };
}
