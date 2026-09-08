{
  config,
  inputs,
  installation,
  lib,
  pkgs,
  ...
}:

let
  repo = "${config.home.homeDirectory}/${installation.repositoryDirectory}";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink "${repo}/config/${path}";
  configFiles = {
    "bat" = "bat";
    "btop" = "btop";
    "cava" = "cava";
    "dunst" = "dunst";
    "fastfetch" = "fastfetch";
    "fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    "nvim" = "nvim";
    "qt6ct" = "qt6ct";
    "rsync-home.excludes" = "rsync-home.excludes";
    "starship.toml" = "starship/starship.toml";
  };
  cinderGroveGtk = pkgs.cinder-grove-gtk;
  papirusCinderGrove = pkgs.papirus-cinder-grove;
  zenTwilight = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
  helium =
    (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      flags = [ "--ozone-platform=wayland" ];
    }).overrideAttrs
      (previous: {
        # Binary wrappers pass this obsolete shell expansion as a literal URL.
        preFixup =
          builtins.replaceStrings
            [ ''--add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"'' ]
            [ "" ]
            previous.preFixup;
      });

in
{
  imports = [
    ./home/scripts.nix
    ./home/apps.nix
    ./home/mango.nix
    ./home/session.nix
  ];

  home = {
    username = installation.user.name;
    inherit (installation.user) homeDirectory;
    stateVersion = "26.05";

    packages =
      (with pkgs; [
        _7zz
        tree
        gnumake
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
        neovim
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
        duckdb
        postgresql_18
        cava
        fastfetch
        qalculate-gtk
        file-roller
        gh
        gnome-disk-utility
        imv
        papers
        bitwarden-desktop
        signal-desktop
        fastmail-desktop
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
        zbar
        podman-compose
        adwaita-icon-theme
        papirus-cinder-grove
        qt6Packages.qt6ct
        darkly
        hunspell
        hunspellDicts.en_US
        (tesseract5.override { enableLanguages = [ "eng" ]; })
        anki
        easyeffects
        dunst
        wiremix
        wireplumber
        bubblewrap
      ])
      ++ [
        zenTwilight
        helium
      ];

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    file = {
      ".local/bin/zen-browser-twilight".source = "${zenTwilight}/bin/zen-twilight";
      ".zshrc".source = createSymlink "zsh/zshrc";
      ".antidote/antidote.zsh".source = "${pkgs.antidote}/share/antidote/antidote.zsh";
    };

    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

    sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = 24;
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      MOZ_DISABLE_RDD_SANDBOX = 1;
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland";
      EDITOR = "nvim";
      VISUAL = "nvim";
      BEMOJI_PICKER_CMD = "${pkgs.wmenu}/bin/wmenu -i -p emoji";
      BEMOJI_CLIP_CMD = "${pkgs.wl-clipboard}/bin/wl-copy";
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "Adwaita Sans";
      size = 11;
      package = pkgs.adwaita-fonts;
    };
    theme = {
      name = "Cinder-Grove-Dark";
      package = cinderGroveGtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = papirusCinderGrove;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    colorScheme = "dark";
    gtk3.extraConfig.gtk-decoration-layout = "";
    gtk4 = {
      extraConfig.gtk-decoration-layout = "";
      extraCss = ''
        @import url("file://${cinderGroveGtk}/share/themes/Cinder-Grove-Dark/gtk-4.0/cinder-grove.css");
        @import url("file://${cinderGroveGtk}/share/themes/Cinder-Grove-Dark/gtk-4.0/accent.css");
      '';
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Cinder-Grove-Dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Adwaita";
      cursor-size = 24;
      font-name = lib.mkForce "Adwaita Sans 11";
      monospace-font-name = "Iosevka Nerd Font 12";
      font-antialiasing = "rgba";
      font-hinting = "slight";
      font-rgba-order = "rgb";
      clock-format = "24h";
    };
    "org/gnome/desktop/wm/preferences".button-layout = "";
  };

  xdg = {
    enable = true;
    autostart.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications =
        let
          forTypes = desktop: types: lib.genAttrs types (_: [ desktop ]);
        in
        forTypes "zen-twilight.desktop" [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ]
        // forTypes "imv.desktop" [
          "image/avif"
          "image/bmp"
          "image/gif"
          "image/heif"
          "image/jpeg"
          "image/jpg"
          "image/jxl"
          "image/pjpeg"
          "image/png"
          "image/qoi"
          "image/svg+xml"
          "image/tiff"
          "image/tiff-fx"
          "image/webp"
          "image/x-bmp"
          "image/x-farbfeld"
          "image/x-png"
        ]
        // forTypes "mpv.desktop" [
          "application/ogg"
          "application/vnd.apple.mpegurl"
          "application/vnd.ms-asf"
          "application/x-matroska"
          "audio/aac"
          "audio/ac3"
          "audio/flac"
          "audio/m4a"
          "audio/mp4"
          "audio/mpeg"
          "audio/ogg"
          "audio/opus"
          "audio/vnd.rn-realaudio"
          "audio/wav"
          "audio/webm"
          "audio/x-aiff"
          "audio/x-ape"
          "audio/x-flac"
          "audio/x-m4a"
          "audio/x-matroska"
          "audio/x-mpegurl"
          "audio/x-ms-wma"
          "audio/x-scpls"
          "audio/x-vorbis+ogg"
          "audio/x-wav"
          "video/3gpp"
          "video/3gpp2"
          "video/mp2t"
          "video/mp4"
          "video/mpeg"
          "video/ogg"
          "video/quicktime"
          "video/webm"
          "video/x-flv"
          "video/x-m4v"
          "video/x-matroska"
          "video/x-ms-asf"
          "video/x-msvideo"
          "video/x-ms-wmv"
          "video/x-theora+ogg"
        ]
        // forTypes "org.gnome.Papers.desktop" [
          "application/pdf"
          "application/x-bzpdf"
          "application/x-gzpdf"
          "application/x-xzpdf"
          "application/vnd.comicbook+zip"
          "application/vnd.comicbook-rar"
          "application/x-cb7"
          "application/x-cbr"
          "application/x-cbt"
          "application/x-cbz"
          "image/vnd.djvu"
          "image/vnd.djvu+multipage"
        ]
        // forTypes "onlyoffice-desktopeditors.desktop" [
          "application/epub+zip"
          "application/msword"
          "application/msword-template"
          "application/oxps"
          "application/rtf"
          "application/vnd.ms-excel"
          "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
          "application/vnd.ms-excel.sheet.macroEnabled.12"
          "application/vnd.ms-excel.template.macroEnabled.12"
          "application/vnd.ms-powerpoint"
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
          "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
          "application/vnd.ms-powerpoint.template.macroEnabled.12"
          "application/vnd.ms-word.document.macroEnabled.12"
          "application/vnd.ms-word.template.macroEnabled.12"
          "application/vnd.ms-xpsdocument"
          "application/vnd.oasis.opendocument.presentation"
          "application/vnd.oasis.opendocument.presentation-template"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.oasis.opendocument.spreadsheet-template"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.oasis.opendocument.text-template"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
          "application/vnd.openxmlformats-officedocument.presentationml.template"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
          "text/csv"
          "text/tab-separated-values"
        ]
        // forTypes "org.gnome.FileRoller.desktop" [
          "application/gzip"
          "application/vnd.rar"
          "application/x-7z-compressed"
          "application/x-bzip"
          "application/x-bzip-compressed-tar"
          "application/x-compress"
          "application/x-compressed-tar"
          "application/x-cpio"
          "application/x-gzip"
          "application/x-lz4"
          "application/x-lz4-compressed-tar"
          "application/x-lzip"
          "application/x-lzip-compressed-tar"
          "application/x-lzma"
          "application/x-lzma-compressed-tar"
          "application/x-rar"
          "application/x-rar-compressed"
          "application/x-tar"
          "application/x-xz"
          "application/x-xz-compressed-tar"
          "application/x-zip-compressed"
          "application/x-zstd-compressed-tar"
          "application/zip"
          "application/zstd"
        ]
        // forTypes "nvim.desktop" [
          "application/javascript"
          "application/json"
          "application/toml"
          "application/x-shellscript"
          "application/xml"
          "application/yaml"
          "text/css"
          "text/javascript"
          "text/markdown"
          "text/plain"
          "text/x-c"
          "text/x-c++"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-go"
          "text/x-java"
          "text/x-lua"
          "text/x-makefile"
          "text/x-nix"
          "text/x-python"
          "text/x-rust"
          "text/x-script.python"
          "text/x-sh"
          "text/x-tex"
          "text/x-toml"
          "text/x-yaml"
          "text/xml"
        ]
        // {
          "x-scheme-handler/mailto" = [ "fastmail.desktop" ];
          "inode/directory" = [ "yazi.desktop" ];
        };
    };

    configFile = lib.mapAttrs (_: path: { source = createSymlink path; }) configFiles;

    dataFile."backgrounds/fantasy-woods.jpg".source = ./config/wallpaper/fantasy-woods.jpg;
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  programs.btop.enable = true;
  programs.home-manager.enable = true;
}
