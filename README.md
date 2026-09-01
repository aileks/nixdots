# NixOS dotfiles

NixOS 26.05 and Home Manager configuration.

## Clone

Clone the `nix` branch recursively:

```bash
git clone --branch nix --recurse-submodules https://github.com/aileks/dotfiles.git ~/.dotfiles
```

For an existing clone:

```bash
git submodule update --init --recursive
```

## Checks

```bash
nixfmt --check flake.nix home.nix modules packages hosts
nix flake check
nix build .#mitishell .#cinder-grove-gtk .#papirus-cinder-grove .#fastmail-desktop .#tensaku
```
