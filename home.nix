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
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
  configFiles = {
    "kitty" = "kitty";
    "bat" = "bat";
    "btop" = "btop";
    "cava" = "cava";
    "fastfetch" = "fastfetch";
    "fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    "hypr" = "hypr";
    "mitishell/config.json" = "mitishell/config.json";
    "nvim" = "nvim";
    "qt6ct" = "qt6ct";
    "tmux" = "tmux";
    "xdg-desktop-portal" = "xdg-desktop-portal";
    "starship.toml" = "starship/starship.toml";
  };
  mitishellShellPath = "${pkgs.mitishell}/share/mitishell/shell";
  mitishellLaunchPath = lib.concatStringsSep ":" [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.profileDirectory}/bin"
    "/run/current-system/sw/bin"
    mitishellRuntimePath
  ];
  mitishellQsBin = "${pkgs.quickshell}/bin/qs";
  cinderGroveGtk = pkgs.cinder-grove-gtk;
  papirusCinderGrove = pkgs.papirus-cinder-grove;
  zenTwilight = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
  configureMonitors = pkgs.writeShellApplication {
    name = "configure-monitors";
    runtimeInputs = with pkgs; [
      coreutils
      hyprland
      jq
    ];
    text = builtins.readFile ./bin/configure-monitors;
  };
  monitorWatch = pkgs.writeShellApplication {
    name = "monitor-watch";
    runtimeInputs = with pkgs; [
      coreutils
      socat
    ];
    text = builtins.readFile ./bin/monitor-watch;
  };
  mitishellRuntimePath = lib.makeBinPath (
    with pkgs;
    [
      bash
      coreutils
      ddcutil
      fontconfig
      gpu-screen-recorder
      grim
      hyprland
      hyprpicker
      hyprshutdown
      libnotify
      networkmanager
      power-profiles-daemon
      slurp
      systemd
      tensaku
      wl-clipboard
      zbar
    ]
  );
in
{
  home = {
    username = installation.user.name;
    inherit (installation.user) homeDirectory;
    stateVersion = "26.05";

    packages =
      (with pkgs; [
        _7zz
        gnumake
        (lib.hiPrio gcc)
        clang
        bat
        eza
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
        mise
        kitty
        starship
        tmux
        neovim
        go
        lua
        python3
        uv
        nodejs
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
        gnome-disk-utility
        imv
        celluloid
        papers
        nautilus
        nwg-look
        bitwarden-desktop
        signal-desktop
        fastmail-desktop
        mitishell
        tensaku
        hypridle
        hyprlock
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprshutdown
        quickshell
        grim
        slurp
        wev
        wl-clipboard
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
        cliamp
        tmux-sessionizer
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
      ".local/bin/mitishell".source = lib.getExe pkgs.mitishell;
      ".local/bin/zen-browser-twilight".source = "${zenTwilight}/bin/zen-twilight";
      ".zshrc".source = createSymlink "zsh/zshrc";
      ".antidote/antidote.zsh".source = "${pkgs.antidote}/share/antidote/antidote.zsh";
    };

    sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  };

  gtk = {
    enable = true;
    font = {
      name = "Adwaita Mono";
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
      monospace-font-name = "Maple Mono 11";
      font-antialiasing = "rgba";
      font-hinting = "slight";
      font-rgba-order = "rgb";
      clock-format = "24h";
    };
    "org/gnome/desktop/wm/preferences".button-layout = "";
  };

  xdg = {
    enable = true;
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
      };
    };

    configFile = lib.mapAttrs (_: path: { source = createSymlink path; }) configFiles // {
      "uwsm/env" = {
        text = ''
          export PATH="$HOME/.local/bin:/etc/profiles/per-user/$USER/bin:$PATH"
          export MITISHELL_QS_PATH="${mitishellShellPath}"
          export MITISHELL_QS_BIN="${mitishellQsBin}"
          export NIXOS_OZONE_WL=1
          export ELECTRON_OZONE_PLATFORM_HINT=wayland
          export GDK_BACKEND='wayland,x11,*'
          export QT_QPA_PLATFORM='wayland;xcb'
          export QT_QPA_PLATFORMTHEME=qt6ct
          export SDL_VIDEODRIVER=wayland
          export CLUTTER_BACKEND=wayland
          export XCURSOR_THEME=Adwaita
          export XCURSOR_SIZE=24
          export HYPRCURSOR_THEME=Adwaita
          export HYPRCURSOR_SIZE=24
          export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
        '';
      };
    };

    dataFile."backgrounds/fantasy-woods.jpg".source = ./wallpaper/fantasy-woods.jpg;
  };

  services = {
    hypridle.enable = true;
    hyprpaper.enable = true;
    hyprpolkitagent.enable = true;
    hyprsunset = {
      enable = true;
      package = inputs.hyprsunset.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };
  };

  systemd.user.services = {
    mitishell = {
      Unit = {
        Description = "Mitishell desktop shell";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.quickshell}/bin/quickshell -n -p ${mitishellShellPath}";
        Environment = [
          "MITISHELL_QS_PATH=${mitishellShellPath}"
          "MITISHELL_QS_BIN=${mitishellQsBin}"
          "MITISHELL_BIN=${lib.getExe pkgs.mitishell}"
          "PATH=${mitishellLaunchPath}"
        ];
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session-graphical.slice";
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    monitor-setup = {
      Unit = {
        Description = "Configure Hyprland monitor geometry";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe configureMonitors;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    monitor-watch = {
      Unit = {
        Description = "Reconcile Hyprland monitor topology after hotplug";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [
          graphicalSessionTarget
          "monitor-setup.service"
        ];
      };
      Service = {
        ExecStart = lib.getExe monitorWatch;
        Environment = "CONFIGURE_MONITORS_COMMAND=${lib.getExe configureMonitors}";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    hyprlock = {
      Unit = {
        Description = "Hyprland screen locker";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.hyprlock;
        TimeoutStopSec = 2;
      };
    };

    hyprlock-sleep = {
      Unit = {
        Description = "Stop Hyprlock before sleep";
        Before = [ "sleep.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user stop hyprlock.service";
      };
      Install.WantedBy = [ "sleep.target" ];
    };

  };

  programs.home-manager.enable = true;
}
