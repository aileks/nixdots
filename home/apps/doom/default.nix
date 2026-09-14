{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  doom = config.programs.doom-emacs;
  sources = {
    "init.el" = import ./init.el.nix;
    "packages.el" = import ./packages.el.nix;
    "config.el" = import ./config.el.nix;
    "+bindings.el" = import ./+bindings.el.nix;
    "+org.el" = import ./+org.el.nix;
    "+sql.el" = import ./+sql.el.nix;
    "+dbt.el" = import ./+dbt.el.nix;
    "+lang-extras.el" = import ./+lang-extras.el.nix;
    "+tasks.el" = import ./+tasks.el.nix;
    "snippets/zig-mode/print" = import ./snippets.nix;
    "snippets/zig-ts-mode/.yas-parents" = "zig-mode\n";
  };
in
{
  imports = [ inputs.doom-emacs.homeModule ];

  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs-gtk;
    experimentalFetchTree = true;
    doomDir = pkgs.linkFarm "doom-config" (
      lib.mapAttrsToList (name: text: {
        inherit name;
        path = pkgs.writeText "doom-${builtins.baseNameOf name}" text;
      }) sources
    );
    extraPackages = epkgs: [
      (epkgs.treesit-grammars.with-grammars (
        grammars: with grammars; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-cmake
          tree-sitter-json
          tree-sitter-lua
          tree-sitter-make
          tree-sitter-markdown
          tree-sitter-markdown-inline
          tree-sitter-python
          tree-sitter-yaml
          tree-sitter-zig
        ]
      ))
    ];
    extraBinPackages = with pkgs; [
      bash
      bash-language-server
      basedpyright
      clang-tools
      cmake
      coreutils
      fd
      gcc
      git
      gnumake
      lua-language-server
      pandoc
      prettier
      python3
      ripgrep
      ruff
      shellcheck
      shfmt
      sql-language-server
      sqlfluff
      uv
      vscode-langservers-extracted
      yaml-language-server
      zig
      zls
      config.lib.nixdots.scripts.psql
    ];
  };

  services.emacs = {
    enable = true;
    startWithUserSession = "graphical";
    client = {
      enable = true;
      arguments = [
        "--create-frame"
        "--alternate-editor=${doom.finalEmacsPackage}/bin/emacs"
      ];
    };
  };
}
