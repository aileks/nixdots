{
  config,
  lib,
  pkgs,
  ...
}:

let
  barDnd = pkgs.writeShellApplication {
    name = "bar-dnd";
    runtimeInputs = [ pkgs.dunst ];
    text = builtins.readFile ../bin/bar-dnd;
  };
  barVolume = pkgs.writeShellApplication {
    name = "bar-volume";
    runtimeInputs = with pkgs; [
      gawk
      wireplumber
    ];
    text = builtins.readFile ../bin/bar-volume;
  };
  barSysinfo = pkgs.writeShellApplication {
    name = "bar-sysinfo";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.procps
      pkgs.st
      config.programs.btop.package
    ];
    text = builtins.readFile ../bin/bar-sysinfo;
  };
  barClock = pkgs.writeShellApplication {
    name = "bar-clock";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ../bin/bar-clock;
  };
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [
      dmenu
      procps
      systemd
    ];
    text = ''
      choice=$(printf '%s\n' "log out" "suspend" "reboot" "shut down" | dmenu -p power)
      case "$choice" in
        "log out") pkill dwm ;;
        "suspend") systemctl suspend ;;
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
  tmuxDmenu = pkgs.writeShellApplication {
    name = "tmux-dmenu";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.dmenu
      pkgs.findutils
      pkgs.st
      pkgs.tmux
    ];
    text = builtins.readFile ../bin/tmux-dmenu;
  };
  nightLight = pkgs.writeShellApplication {
    name = "night-light";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.gammastep
    ];
    text = builtins.readFile ../bin/night-light;
  };
  volume = pkgs.writeShellApplication {
    name = "volume";
    runtimeInputs = [
      desktopFeedback
      pkgs.gawk
      pkgs.procps
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
      libnotify
      slop
      util-linux
      xdg-user-dirs
      xdotool
      xrandr
    ]);
    text = builtins.readFile ../bin/screenrecord;
  };
  recordingInhibit = pkgs.writeShellApplication {
    name = "recording-inhibit";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
      pkgs.xset
    ];
    text = builtins.readFile ../bin/recording-inhibit;
  };
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
      maim
      slop
      xclip
      xdg-user-dirs
      xdotool
    ];
    text = builtins.readFile ../bin/screenshot;
  };
  recordMenu = pkgs.writeShellApplication {
    name = "record-menu";
    runtimeInputs = [
      pkgs.dmenu
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
      pkgs.xclip
      pkgs.diffutils
    ];
    text = builtins.readFile ../bin/private-clipboard;
  };
  regionOcr = pkgs.writeShellApplication {
    name = "region-ocr";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.slop
      pkgs.maim
      pkgs.xclip
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
      pkgs.slop
      pkgs.maim
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
      pkgs.dmenu
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
      pkgs.dmenu
      pkgs.gnugrep
    ];
    text = builtins.readFile ../bin/notification-history;
  };
  calculate = pkgs.writeShellApplication {
    name = "calculate";
    runtimeInputs = [
      desktopFeedback
      pkgs.coreutils
      pkgs.dmenu
      pkgs.libqalculate
      pkgs.xclip
    ];
    text = builtins.readFile ../bin/calculate;
  };
  monitorMenu = pkgs.writeShellApplication {
    name = "monitor-menu";
    runtimeInputs = [
      desktopFeedback
      pkgs.autorandr
      pkgs.dmenu
      pkgs.gnugrep
    ];
    text = builtins.readFile ../bin/monitor-menu;
  };
  desktopActions = pkgs.writeShellApplication {
    name = "desktop-actions";
    runtimeInputs = [
      regionOcr
      qrScan
      reminder
      notificationHistory
      calculate
      monitorMenu
      nightLight
      powerMenu
      pkgs.dmenu
      pkgs.dunst
      pkgs.networkmanager_dmenu
      pkgs.clipmenu
      pkgs.st
      pkgs.wiremix
    ];
    text = builtins.readFile ../bin/desktop-actions;
  };
in
{
  home.packages = [
    barDnd
    barVolume
    barSysinfo
    barClock
    powerMenu
    desktopFeedback
    homeBackup
    tmuxDmenu
    nightLight
    volume
    brightness
    dndToggle
    microphoneMute
    screenrecord
    screenshot
    recordMenu
    regionOcr
    qrScan
    reminder
    notificationHistory
    calculate
    monitorMenu
    desktopActions
  ];

  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = ${pkgs.dmenu}/bin/dmenu -i
    pinentry = ${pkgs.pinentry-gtk2}/bin/pinentry-gtk-2
    prompt = Networks
    [editor]
    terminal = ${pkgs.st}/bin/st
    gui_if_available = True
    gui = ${pkgs.networkmanagerapplet}/bin/nm-connection-editor
  '';

  systemd.user.services.private-clipboard = {
    Unit = {
      Description = "Temporary private QR clipboard";
      PartOf = [ "graphical-session.target" ];
      Conflicts = [ "clipmenud.service" ];
      Before = [ "clipmenud.service" ];
      ConditionEnvironment = "DISPLAY";
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
      ConditionEnvironment = "DISPLAY";
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
