# NixOS dotfiles

NixOS 26.05 and Home Manager configuration.

## Clone

Clone recursively:

```bash
git clone --recurse-submodules https://github.com/aileks/nixdots.git ~/.dotfiles
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
