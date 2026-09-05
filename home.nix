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
  imports = [ ./home/scripts.nix ];

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
  xsession.initExtra = ''
    pkill -x xss-lock 2>/dev/null || true
    ${pkgs.xss-lock}/bin/xss-lock -l ${lib.getExe lockSession} &
  '';

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
      monospace-font-name = "Iosevka Custom 11";
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
      defaultApplications = {
        "text/html" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/http" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/https" = [ "zen-twilight.desktop" ];
        "x-scheme-handler/mailto" = [ "fastmail.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
      };
    };

    configFile = lib.mapAttrs (_: path: { source = createSymlink path; }) configFiles;

    dataFile."backgrounds/fantasy-woods.jpg".source = ./config/wallpaper/fantasy-woods.jpg;
  };

  services = {
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };
    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      fade = true;
      activeOpacity = 1.0;
      inactiveOpacity = 0.95;
      shadow = true;
      settings = {
        use-damage = false;
        blur = {
          method = "dual_kawase";
          strength = 5;
        };
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "window_type = 'menu'"
          "window_type = 'dropdown_menu'"
          "window_type = 'popup_menu'"
          "_GTK_FRAME_EXTENTS@:c"
          "class_g = 'slop'"
        ];
      };
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
        Environment = [ "PATH=${lib.makeBinPath [ pkgs.xsel ]}:${xsessionPath}" ];
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    xidle-suspend = {
      Unit = {
        Description = "Suspend after 30 minutes of inactivity";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.xautolock}/bin/xautolock -time 30 -detectsleep -locker '${pkgs.systemd}/bin/systemctl suspend'";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

  };

  programs.btop.enable = true;
  programs.home-manager.enable = true;
}
