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

    hyprsunset.url = "github:hyprwm/hyprsunset/v0.4.0";
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
      machine = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          (_: { nixpkgs.overlays = [ overlay ]; })
          ./modules/common.nix
          ./hosts/machine
          home-manager.nixosModules.home-manager
          (
            { pkgs, ... }:
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupCommand = "${pkgs.trash-cli}/bin/trash-put";
                extraSpecialArgs = { inherit inputs; };
                users.aileks = import ./home.nix;
              };
            }
          )
        ];
      };
      sourceCheck =
        pkgs.runCommand "nixdots-source-check"
          {
            nativeBuildInputs = with pkgs; [
              findutils
              jq
              libxml2
              lua
              nixfmt
              shellcheck
              shfmt
              zsh
            ];
          }
          ''
            cp -R ${self} source
            chmod -R u+w source
            cd source

            find . -path ./nvim -prune -o -name '*.nix' -print0 \
              | xargs -0 -r nixfmt --check
            shellcheck bin/install
            shfmt -d -i 2 -ci -bn bin/install
            zsh -n zsh/zshrc
            find hypr nvim -type f -name '*.lua' -exec luac -p {} \;
            jq empty mitishell/config.json
            xmllint --noout fontconfig/fonts.conf bat/themes/cinder-grove.tmTheme

            touch "$out"
          '';
    in
    {
      overlays.default = overlay;
      packages.${system} = localPackages;
      checks.${system} = localPackages // {
        inherit sourceCheck;
        machine = machine.config.system.build.toplevel;
      };
      formatter.${system} = pkgs.nixfmt-tree;

      nixosConfigurations = {
        inherit machine;
      }
      // {
        "${machine.config.networking.hostName}" = machine;
      };
    };
}
