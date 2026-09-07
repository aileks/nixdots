{
  config,
  inputs,
  installation,
  lib,
  pkgs,
  ...
}:

let
  graphicalSessionTarget = "graphical-session.target";
  repo = "${config.home.homeDirectory}/${installation.repositoryDirectory}";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink "${repo}/config/${path}";
  configFiles = {
    "autostart/picom.desktop" = "autostart/picom.desktop";
    "bat" = "bat";
    "btop" = "btop";
    "cava" = "cava";
    "dunst" = "dunst";
    "fastfetch" = "fastfetch";
    "fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    "nvim" = "nvim";
    "qt6ct" = "qt6ct";
    "rsync-home.excludes" = "rsync-home.excludes";
    "tmux" = "tmux";
    "starship.toml" = "starship/starship.toml";
  };
  cinderGroveGtk = pkgs.cinder-grove-gtk;
  papirusCinderGrove = pkgs.papirus-cinder-grove;
  zenTwilight = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
  xsessionPath = lib.concatStringsSep ":" [
    "${config.home.profileDirectory}/bin"
    "/run/current-system/sw/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];
  lockSession = pkgs.writeShellApplication {
    name = "lock-session";
    runtimeInputs = [
      pkgs.systemd
      pkgs.xsecurelock
    ];
    text = builtins.readFile ./bin/lock-session;
  };
in
{
  imports = [
    ./home/scripts.nix
    ./home/lf.nix
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
        st
        dmenu
        starship
        tmux
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
        celluloid
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
        chromium
        polkit_gnome
        gammastep
        xcolor
        clipmenu
        bemoji
        xclip
        maim
        slop
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
        tmux-sessionizer
        anki
        easyeffects
        dunst
        feh
        numlockx
        wiremix
        wireplumber
        xdotool
        xsecurelock
        xss-lock
        bubblewrap
      ])
      ++ [ zenTwilight ];

    pointerCursor = {
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
      MOZ_X11_EGL = 1;
    };
  };

  xsession.enable = true;
  xsession.importedVariables = [
    "XCURSOR_THEME"
    "XCURSOR_SIZE"
    "XCURSOR_PATH"
    "XDG_CURRENT_DESKTOP"
    "QT_QPA_PLATFORMTHEME"
  ];

  xresources.properties."Xft.dpi" = 96;

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
        // forTypes "io.github.celluloid_player.Celluloid.desktop" [
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
          "inode/directory" = [ "thunar.desktop" ];
        };
    };

    configFile = lib.mapAttrs (_: path: { source = createSymlink path; }) configFiles;

    dataFile."backgrounds/fantasy-woods.jpg".source = ./config/wallpaper/fantasy-woods.jpg;
  };

  services = {
    screen-locker = {
      enable = true;
      lockCmd = lib.getExe lockSession;
      inactiveInterval = 10;
      xss-lock.extraOptions = [ "--transfer-sleep-lock" ];
      xss-lock.screensaverCycle = 5;
    };
    xsettingsd = {
      enable = true;
      settings = {
        "Net/ThemeName" = config.gtk.theme.name;
        "Net/IconThemeName" = config.gtk.iconTheme.name;
        "Gtk/FontName" = "${config.gtk.font.name} ${toString config.gtk.font.size}";
        "Gtk/CursorThemeName" = config.gtk.cursorTheme.name;
        "Gtk/CursorThemeSize" = config.gtk.cursorTheme.size;
        "Xft/DPI" = config.xresources.properties."Xft.dpi" * 1024;
        "Xft/Antialias" = 1;
        "Xft/Hinting" = 1;
        "Xft/HintStyle" = "hintslight";
        "Xft/RGBA" = "rgb";
      };
    };
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };
    picom = {
      enable = true;
      # The module otherwise emits legacy options that conflict with rules.
      settings = lib.mkForce {
        backend = "glx";
        vsync = true;
        fading = true;
        fade-delta = 10;
        fade-in-step = 0.028;
        fade-out-step = 0.03;
        shadow = true;
        shadow-offset-x = -15;
        shadow-offset-y = -15;
        shadow-opacity = 0.75;
        use-damage = false;
        blur = {
          method = "dual_kawase";
          strength = 5;
        };
      };
      extraConfig = builtins.readFile ./config/picom-rules.conf;
    };
  };

  systemd.user.services = {
    picom.Unit.ConditionEnvironment = "DISPLAY";
    # Leave time for the locker within logind's sleep inhibitor deadline.
    picom.Service.TimeoutStopSec = 2;

    dwmblocks = {
      Unit = {
        Description = "dwm status blocks";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.dwmblocks;
        Environment = [ "PATH=${xsessionPath}" ];
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    dunst = {
      Unit = {
        Description = "dunst notification daemon";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.dunst}/bin/dunst";
        Environment = [ "PATH=${xsessionPath}" ];
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    wallpaper = {
      Unit = {
        Description = "Set X wallpaper";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.feh} --no-fehbg --bg-fill ${config.home.homeDirectory}/.local/share/backgrounds/fantasy-woods.jpg";
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    polkit-gnome = {
      Unit = {
        Description = "polkit-gnome authentication agent";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    clipmenud = {
      Unit = {
        Description = "clipmenu clipboard history daemon";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.clipmenu}/bin/clipmenud";
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.xsel ]}:${xsessionPath}"
          "CM_MAX_CLIPS=50"
        ];
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    xssproxy = {
      Unit = {
        Description = "Forward application screensaver inhibitors to X11";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.xssproxy;
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

  };

  programs.btop.enable = true;
  programs.home-manager.enable = true;
}
