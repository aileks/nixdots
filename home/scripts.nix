{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  barDnd = pkgs.writeShellApplication {
    name = "bar-dnd";
    runtimeInputs = [
      pkgs.dunst
      pkgs.jq
    ];
    text = builtins.readFile ../bin/bar-dnd;
  };
  barMemory = pkgs.writeShellApplication {
    name = "bar-memory";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.jq
      pkgs.procps
    ];
    text = builtins.readFile ../bin/bar-memory;
  };
  barCpuTemperature = pkgs.writeShellApplication {
    name = "bar-cpu-temperature";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.jq
    ];
    text = builtins.readFile ../bin/bar-cpu-temperature;
  };
  barGpu = pkgs.writeShellApplication {
    name = "bar-gpu";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      (lib.getBin osConfig.hardware.nvidia.package)
    ];
    text = builtins.readFile ../bin/bar-gpu;
  };
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [
      config.lib.nixdots.lockSession
      pkgs.systemd
      pkgs.mango
      pkgs.wmenu
    ];
    text = ''
      choice=$(printf '%s\n' "log out" "suspend" "reboot" "shut down" | wmenu -p power) || exit 0
      case "$choice" in
        "log out") mmsg dispatch quit ;;
        "suspend") lock-session && systemctl suspend ;;
        "reboot") systemctl reboot ;;
        "shut down") systemctl poweroff ;;
      esac
    '';
  };
  desktopFeedback = pkgs.writeShellApplication {
    name = "desktop-feedback";
    runtimeInputs = [ pkgs.dunst ];
    text = builtins.readFile ../bin/desktop-feedback;
  };
  homeBackup = pkgs.writeShellApplication {
    name = "home-backup";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.findutils
      pkgs.rsync
      pkgs.systemd
      pkgs.util-linux
    ];
    text = builtins.readFile ../bin/home-backup;
  };
  weztermDmenu = pkgs.writeShellApplication {
    name = "wezterm-dmenu";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.wmenu
      pkgs.findutils
      pkgs.wezterm
      pkgs.jq
    ];
    text = builtins.readFile ../bin/wezterm-dmenu;
  };
  nightLight = pkgs.writeShellApplication {
    name = "night-light";
    runtimeInputs = [
      desktopFeedback
      pkgs.systemd
    ];
    text = builtins.readFile ../bin/night-light;
  };
  volume = pkgs.writeShellApplication {
    name = "volume";
    runtimeInputs = [
      desktopFeedback
      pkgs.gawk
      pkgs.wireplumber
    ];
    text = builtins.readFile ../bin/volume;
  };
  brightness = pkgs.writeShellApplication {
    name = "brightness";
    runtimeInputs = [
      desktopFeedback
      pkgs.ddcutil
      pkgs.gawk
    ];
    text = builtins.readFile ../bin/brightness;
  };
  dndToggle = pkgs.writeShellApplication {
    name = "dnd-toggle";
    runtimeInputs = [
      desktopFeedback
      pkgs.dunst
    ];
    text = builtins.readFile ../bin/dnd-toggle;
  };
  microphoneMute = pkgs.writeShellApplication {
    name = "microphone-mute";
    runtimeInputs = [
      desktopFeedback
      pkgs.wireplumber
    ];
    text = builtins.readFile ../bin/microphone-mute;
  };
  screenrecord = pkgs.writeShellApplication {
    name = "screenrecord";
    runtimeInputs = [
      recordingInhibit
    ]
    ++ (with pkgs; [
      coreutils
      gawk
      gpu-screen-recorder
      jq
      libnotify
      mango
      slurp
      util-linux
      xdg-user-dirs
    ]);
    text = builtins.readFile ../bin/screenrecord;
  };
  recordingInhibit = pkgs.writeShellApplication {
    name = "recording-inhibit";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = builtins.readFile ../bin/recording-inhibit;
  };
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      jq
      libnotify
      mango
      slurp
      wl-clipboard
      xdg-user-dirs
    ];
    text = builtins.readFile ../bin/screenshot;
  };
  recordMenu = pkgs.writeShellApplication {
    name = "record-menu";
    runtimeInputs = [
      pkgs.wmenu
      screenrecord
    ];
    text = builtins.readFile ../bin/record-menu;
  };
  privateClipboard = pkgs.writeShellApplication {
    name = "private-clipboard";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.systemd
      pkgs.util-linux
      pkgs.wl-clipboard
      pkgs.diffutils
    ];
    text = builtins.readFile ../bin/private-clipboard;
  };
  clipboardMenu = pkgs.writeShellApplication {
    name = "clipboard-menu";
    runtimeInputs = [
      desktopFeedback
      pkgs.cliphist
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.wl-clipboard
      pkgs.wmenu
    ];
    text = builtins.readFile ../bin/clipboard-menu;
  };
  regionOcr = pkgs.writeShellApplication {
    name = "region-ocr";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.slurp
      pkgs.grim
      pkgs.wl-clipboard
      (pkgs.tesseract5.override { enableLanguages = [ "eng" ]; })
    ];
    text = builtins.readFile ../bin/region-ocr;
  };
  qrScan = pkgs.writeShellApplication {
    name = "qr-scan";
    runtimeInputs = [
      desktopFeedback
      privateClipboard
      pkgs.coreutils
      pkgs.diffutils
      pkgs.glibc.bin
      pkgs.slurp
      pkgs.grim
      pkgs.zbar
      pkgs.xmlstarlet
    ];
    text = builtins.readFile ../bin/qr-scan;
  };
  reminder = pkgs.writeShellApplication {
    name = "reminder";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.wmenu
      pkgs.dunst
      pkgs.gnugrep
      pkgs.jq
      pkgs.util-linux
    ];
    text = builtins.readFile ../bin/reminder;
  };
  notificationHistory = pkgs.writeShellApplication {
    name = "notification-history";
    runtimeInputs = [
      desktopFeedback
      pkgs.dunst
      pkgs.jq
      pkgs.wmenu
      pkgs.gnugrep
    ];
    text = builtins.readFile ../bin/notification-history;
  };
  calculate = pkgs.writeShellApplication {
    name = "calculate";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.wmenu
      pkgs.libqalculate
      pkgs.wl-clipboard
    ];
    text = builtins.readFile ../bin/calculate;
  };
  colorPicker = pkgs.writeShellApplication {
    name = "color-picker";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
    ];
    text = ''
      geometry=$(slurp -p </dev/null) || exit 0
      # A single pixel at scale 1 ends the PPM image with three RGB bytes.
      pixel=$(grim -s 1 -g "$geometry" -t ppm - | tail -c 3 | od -An -tu1)
      read -r red green blue <<< "$pixel"
      printf -v color '#%02X%02X%02X' "$red" "$green" "$blue"
      printf '%s' "$color" | wl-copy
      printf '%s\n' "$color"
    '';
  };
  desktopActions = pkgs.writeShellApplication {
    name = "desktop-actions";
    runtimeInputs = [
      regionOcr
      qrScan
      reminder
      notificationHistory
      calculate
      pkgs.wmenu
      pkgs.networkmanager_dmenu
    ];
    text = builtins.readFile ../bin/desktop-actions;
  };
in
{
  home.packages = [
    barDnd
    barMemory
    barCpuTemperature
    barGpu
    powerMenu
    desktopFeedback
    homeBackup
    weztermDmenu
    nightLight
    volume
    brightness
    dndToggle
    microphoneMute
    screenrecord
    screenshot
    recordMenu
    clipboardMenu
    regionOcr
    qrScan
    reminder
    notificationHistory
    calculate
    colorPicker
    desktopActions
  ];

  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = ${pkgs.wmenu}/bin/wmenu -i
    pinentry = ${pkgs.pinentry-gnome3}/bin/pinentry-gnome3
    prompt = Networks
    [editor]
    terminal = ${pkgs.wezterm}/bin/wezterm
    gui_if_available = True
    gui = ${pkgs.networkmanagerapplet}/bin/nm-connection-editor
  '';

  systemd.user.services.private-clipboard = {
    Unit = {
      Description = "Temporary private QR clipboard";
      PartOf = [ "graphical-session.target" ];
      Conflicts = [ "cliphist.service" ];
      Before = [ "cliphist.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${pkgs.coreutils}/bin/timeout --foreground --kill-after=2s 60s ${lib.getExe privateClipboard} serve";
      ExecStopPost = "${lib.getExe privateClipboard} restore";
      SuccessExitStatus = [ 124 ];
      TimeoutStopSec = 2;
      UMask = "0077";
    };
  };

  systemd.user.services.reminders = {
    Unit = {
      Description = "Deliver due reminders";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "dunst.service"
      ];
      Requisite = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe reminder} dispatch";
      UMask = "0077";
    };
  };
  systemd.user.timers.reminders = {
    Unit.PartOf = [ "graphical-session.target" ];
    Timer = {
      OnCalendar = "*-*-* *:*:00";
      OnActiveSec = "5s";
      AccuracySec = "1s";
      Persistent = true;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.home-backup = {
    Unit.Description = "Back up home to the External drive";
    Service = {
      Type = "oneshot";
      ExecStart = "${homeBackup}/bin/home-backup";
      TimeoutStartSec = "infinity";
      UMask = "0077";
    };
  };

  systemd.user.timers.home-backup = {
    Unit.Description = "Daily home backup";
    Timer = {
      OnCalendar = "*-*-* 09:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
