{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  graphicalSessionTarget = "graphical-session.target";
  repo = "${config.home.homeDirectory}/nixos-btw";
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
    username = "aileks";
    homeDirectory = "/home/aileks";
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
        socat
        sqlite
        trash-cli
        unzip
        wget
        zip
        zoxide
        alacritty
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
        btop
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
        voxtype-onnx
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
      ".gitconfig".source = ./git/.gitconfig;
      ".gitignore_global".source = ./git/.gitignore_global;
      ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${repo}/zsh/zshrc";
      ".antidote/antidote.zsh".source = "${pkgs.antidote}/share/antidote/antidote.zsh";
    };

    sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
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
      font-name = "Adwaita Sans 11";
      monospace-font-name = "GeistMono Nerd Font 11";
      font-antialiasing = "grayscale";
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

    configFile = {
      "alacritty".source = ./alacritty;
      "bat".source = ./bat;
      "btop".source = ./btop;
      "cava".source = ./cava;
      "fastfetch".source = ./fastfetch;
      "fontconfig/fonts.conf".source = ./fontconfig/fonts.conf;
      "hypr".source = config.lib.file.mkOutOfStoreSymlink "${repo}/hypr";
      "mitishell/config.json".source =
        config.lib.file.mkOutOfStoreSymlink "${repo}/mitishell/config.json";
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${repo}/nvim";
      "qt6ct".source = ./qt6ct;
      "tmux".source = ./tmux;
      "voxtype".source = ./voxtype;
      "xdg-desktop-portal".source = ./xdg-desktop-portal;
      "starship.toml".source = ./starship/starship.toml;
      "uwsm/env".text = ''
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

    voxtype = {
      Unit = {
        Description = "Voxtype push-to-talk voice-to-text daemon";
        PartOf = [ graphicalSessionTarget ];
        After = [
          graphicalSessionTarget
          "pipewire.service"
          "pipewire-pulse.service"
        ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.voxtype-onnx} -q daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };
  };

  programs.home-manager.enable = true;
}
