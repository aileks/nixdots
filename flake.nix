{
  description = "aileks NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    self.submodules = true;

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voxtype.url = "github:peteonrails/voxtype/v1.0.1";
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
        "dwm"
        "dmenu"
        "st"
        "dwmblocks"
        "cinder-grove-gtk"
        "papirus-cinder-grove"
        "fastmail-desktop"
        "nvidia-vaapi-driver"
      ];
      overlay = final: prev: {
        dwm = import ./packages/dwm.nix {
          dwm = prev.dwm;
          inherit (prev)
            fetchpatch
            lib
            libxcb
            libxcursor
            ;
        };
        dmenu = import ./packages/dmenu.nix {
          dmenu = prev.dmenu;
          inherit (prev) fetchpatch lib;
        };
        st = import ./packages/st.nix {
          st = prev.st;
          inherit (prev) fetchpatch lib harfbuzz;
        };
        dwmblocks = final.callPackage ./packages/dwmblocks-async.nix { };
        cinder-grove-gtk = final.callPackage ./packages/cinder-grove-gtk.nix { };
        papirus-cinder-grove = final.callPackage ./packages/papirus-cinder-grove.nix { };
        fastmail-desktop = final.callPackage ./packages/fastmail-desktop.nix { };
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
      sourceCheck =
        pkgs.runCommand "nixdots-source-check"
          {
            nativeBuildInputs = with pkgs; [
              findutils
              libxml2
              lua
              nixfmt
              rsync
              shellcheck
              shfmt
              stdenv.cc
              util-linux
              zsh
            ];
          }
          ''
            cp -R ${self} source
            chmod -R u+w source
            cd source

            find . -path ./config/nvim -prune -o -name '*.nix' -print0 \
              | xargs -0 -r nixfmt --check
            shellcheck --shell=bash bin/*
            shfmt -d -i 2 -ci -bn bin/*
            zsh -n config/zsh/zshrc
            zsh -n config/zsh/cinder-grove.zsh
            find config/nvim -type f -name '*.lua' -print0 | xargs -0 -r -n 1 luac -p
            xmllint --noout config/fontconfig/fonts.conf config/bat/themes/cinder-grove.tmTheme

            touch "$out"
          '';
    in
    {
      lib = { inherit installation; };
      overlays.default = overlay;
      packages.${system} = localPackages;
      checks.${system} = localPackages // hostChecks // { inherit sourceCheck; };
      formatter.${system} = pkgs.nixfmt-tree;

      nixosConfigurations = hosts;
    };
}
