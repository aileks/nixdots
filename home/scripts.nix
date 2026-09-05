{ config, pkgs, ... }:

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
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gpu-screen-recorder
      libnotify
      slop
      util-linux
      xdg-user-dirs
      xdotool
      xrandr
    ];
    text = builtins.readFile ../bin/screenrecord;
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
  ];

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
