{ config, lib, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyFile = "${config.home.homeDirectory}/.bash_history";
    historySize = 50000;
    historyFileSize = 10000;
    historyControl = [
      "ignoreboth"
      "erasedups"
    ];
    shellOptions = [
      "cdspell"
      "checkwinsize"
      "extglob"
      "autocd"
      "dirspell"
      "histappend"
      "cmdhist"
      "lithist"
    ];
    shellAliases = {
      ls = "eza --color=always --icons --group-directories-first";
      la = "eza -al --color=always --icons --group-directories-first";
      lt = "eza -T --color=always --icons --group-directories-first";
      rm = "trash";
      c = "clear";
      fzf = "fzf --style full";
      ff = "fastfetch";
      vim = "nvim";
      docker = "podman";
      psql = "${config.lib.nixdots.scripts.pgdev}/bin/pgdev psql";
      ".." = "echo 'cd ..'; cd ..";
      hl = "rg --passthru";
      ga = "git add";
      gaa = "git add --all";
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b";
      gc = "git commit --verbose";
      gcm = "git commit --message";
      gd = "git diff";
      gf = "git fetch";
      gl = "git pull";
      gp = "git push";
      gst = "git status";
      gss = "git status --short";
      gsw = "git switch";
    };
    initExtra = lib.mkMerge [
      (lib.mkOrder 150 "set -o emacs")
      (import ./interactive.nix { inherit config; })
      (lib.mkOrder 2500 (import ./prompt.nix { inherit lib; }))
    ];
  };
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
