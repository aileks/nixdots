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
      installation = import ./installation.nix;
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
      hostNames = [
        "nixghost"
        "hexghost"
      ];
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
            (
              { pkgs, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  # backupCommand = "${pkgs.trash-cli}/bin/trash-put";
                  extraSpecialArgs = { inherit inputs installation; };
                  users.${installation.user.name} = import ./home.nix;
                };
              }
            )
          ];
        };
      hosts = nixpkgs.lib.genAttrs hostNames mkHost;
      hostChecks = nixpkgs.lib.mapAttrs' (
        hostName: host: nixpkgs.lib.nameValuePair "nixos-${hostName}" host.config.system.build.toplevel
      ) hosts;
      sourceCheck =
        pkgs.runCommand "nixdots-source-check"
          {
            INSTALLATION_TEST_JSON = builtins.toJSON installation;
            nativeBuildInputs = with pkgs; [
              findutils
              jq
              libxml2
              lua
              nixfmt
              shellcheck
              shfmt
              util-linux
              zsh
            ];
          }
          ''
            cp -R ${self} source
            chmod -R u+w source
            cd source

            find . -path ./nvim -prune -o -name '*.nix' -print0 \
              | xargs -0 -r nixfmt --check
            shellcheck bin/* tests/*.bash
            shfmt -d -i 2 -ci -bn bin/* tests/*.bash
            bash tests/install.bash
            bash tests/monitors.bash
            zsh -n zsh/zshrc
            find hypr nvim -type f -name '*.lua' -exec luac -p {} \;
            jq empty mitishell/config.json
            xmllint --noout fontconfig/fonts.conf bat/themes/cinder-grove.tmTheme

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
