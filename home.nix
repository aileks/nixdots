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
    "dunst" = "dunst";
    "fastfetch" = "fastfetch";
    "fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    "hypr" = "hypr";
    "mitishell/config.json" = "mitishell/config.json";
    "nvim" = "nvim";
    "qt6ct" = "qt6ct";
    "sxhkd" = "sxhkd";
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
  dmenuPkg = pkgs.dmenu.override {
    conf = ./dmenu/config.def.h;
    patches = [
      ./dmenu/patches/center.diff
      ./dmenu/patches/border.diff
      ./dmenu/patches/line-height.diff
    ];
  };
  dwmblocksPkg = pkgs.stdenv.mkDerivation {
    pname = "dwmblocks-async";
    version = "unstable-2026-04-18";
    src = pkgs.fetchFromGitHub {
      owner = "UtkarshVerma";
      repo = "dwmblocks-async";
      rev = "469e6841432693d81a17088706d99ef044a29936";
      hash = "sha256-gACpUAFVT/6Z9IvWQQ+IW7vNG7kzgJeVkXXMJeuw1V0=";
    };
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.xcbutil ];
    postPatch = ''
      cp ${./dwmblocks/config.h} config.h
    '';
    makeFlags = [ "PREFIX=$(out)" ];
    meta.mainProgram = "dwmblocks";
  };
  dwmblocksPath = lib.makeBinPath (
    with pkgs;
    [
      coreutils
      gawk
      procps
      wireplumber
    ]
  );
  barVolume = pkgs.writeShellApplication {
    name = "bar-volume";
    runtimeInputs = with pkgs; [
      gawk
      wireplumber
    ];
    text = builtins.readFile ./bin/bar-volume;
  };
  barSysinfo = pkgs.writeShellApplication {
    name = "bar-sysinfo";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      kitty
      procps
    ];
    text = builtins.readFile ./bin/bar-sysinfo;
  };
  barClock = pkgs.writeShellApplication {
    name = "bar-clock";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ./bin/bar-clock;
  };
  xsessionPath = lib.concatStringsSep ":" [
    "${config.home.profileDirectory}/bin"
    "/run/current-system/sw/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];
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
        cmake
        (lib.hiPrio gcc)
        clang
        clang-tools
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
        celluloid
        lazygit
        duckdb
        postgresql_18
        cava
        fastfetch
        qalculate-gtk
        file-roller
        gnome-disk-utility
        imv
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
        xclip
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
        flameshot
        numlockx
        sxhkd
        wireplumber
        xautolock
        xsecurelock
        xss-lock
      ])
      ++ [
        zenTwilight
        dmenuPkg
        dwmblocksPkg
      ];

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
      ".local/bin/bar-volume".source = lib.getExe barVolume;
      ".local/bin/bar-sysinfo".source = lib.getExe barSysinfo;
      ".local/bin/bar-clock".source = lib.getExe barClock;
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

  xresources.properties."Xft.dpi" = 96;

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
      monospace-font-name = "Iosevka Nerd Font 11";
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
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
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
      };
    };
  };

  systemd.user.services = {
    hypridle.Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    hyprpaper.Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    hyprpolkitagent.Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    hyprsunset.Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    picom.Unit.ConditionEnvironment = "DISPLAY";
    voxtype.Service.Environment = [ "YDOTOOL_SOCKET=/run/ydotoold/socket" ];

    dwmblocks = {
      Unit = {
        Description = "dwm status blocks";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = lib.getExe dwmblocksPkg;
        Environment = [ "PATH=${dwmblocksPath}:${xsessionPath}" ];
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

    sxhkd = {
      Unit = {
        Description = "sxhkd key daemon";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.sxhkd}/bin/sxhkd";
        Environment = [ "PATH=${xsessionPath}" ];
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    xss-lock = {
      Unit = {
        Description = "X screen lock on idle and session lock";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.xss-lock}/bin/xss-lock -l ${pkgs.xsecurelock}/bin/xsecurelock";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

    xidle-suspend = {
      Unit = {
        Description = "Suspend after idle timeout";
        ConditionEnvironment = "DISPLAY";
        PartOf = [ graphicalSessionTarget ];
        After = [ graphicalSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.xautolock}/bin/xautolock -time 30 -detectsleep -locker 'systemctl suspend'";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ graphicalSessionTarget ];
    };

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
