{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  zenBrowser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
  helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  lib.nixdots.zenBrowser = zenBrowser;
  home = {
    packages =
      (with pkgs; [
        _7zz
        tree
        gnumake
        bubblewrap
        cmake
        (lib.hiPrio gcc)
        clang
        clang-tools
        bat
        eza
        psmisc
        fd
        fzf
        git
        jq
        ripgrep
        sqlite
        trash-cli
        unzip
        wget
        zip
        zoxide
        starship
        ivpn-ui
        go
        lua
        python3
        uv
        nodejs
        pnpm
        nixd
        nixfmt
        tree-sitter
        lazygit
        isd
        gdu
        smartmontools
        nvme-cli
        bluetui
        duckdb
        cava
        fastfetch
        qalculate-gtk
        libqalculate
        file-roller
        gh
        gnome-disk-utility
        imv
        bitwarden-desktop
        bitwarden-cli
        signal-desktop
        onlyoffice-desktopeditors
        polkit_gnome
        gammastep
        bemoji
        playerctl
        libnotify
        inotify-tools
        xdg-utils
        ffmpeg
        ffmpegthumbnailer
        alsa-utils
        ddcutil
        libva-utils
        mesa-demos
        vulkan-tools
        nvtopPackages.nvidia
        zbar
        podman-compose
        podman-tui
        adwaita-icon-theme
        papirus-cinder-grove
        qt6Packages.qt6ct
        hunspell
        hunspellDicts.en_US
        (tesseract5.override { enableLanguages = [ "eng" ]; })
        anki
        easyeffects
        dunst
        wiremix
        wireplumber
        zig
      ])
      ++ [
        (import ../packages/postgresql-client.nix { inherit pkgs; })
        zenBrowser
        helium
      ];

  };
}
