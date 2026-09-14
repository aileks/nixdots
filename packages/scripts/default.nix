{
  pkgs,
  nvidia ? pkgs.linuxPackages.nvidia_x11,
  yazi ? pkgs.yazi,
  repositories ? [ ],
  projectRoots ? [ ],
}:
let
  scripts = {
    audio = import ./audio.nix { inherit pkgs scripts; };
    bar-clock = import ./bar-clock.nix { inherit pkgs; };
    bar-cpu-temperature = import ./bar-cpu-temperature.nix { inherit pkgs; };
    bar-dnd = import ./bar-dnd.nix { inherit pkgs scripts; };
    bar-gpu = import ./bar-gpu.nix { inherit pkgs nvidia; };
    bar-memory = import ./bar-memory.nix { inherit pkgs; };
    bar-network = import ./bar-network.nix { inherit pkgs; };
    bar-volume = import ./bar-volume.nix { inherit pkgs scripts; };
    brightness = import ./brightness.nix { inherit pkgs scripts; };
    calculate = import ./calculate.nix { inherit pkgs scripts; };
    clipboard-menu = import ./clipboard-menu.nix { inherit pkgs scripts; };
    color-picker = import ./color-picker.nix { inherit pkgs; };
    desktop-actions = import ./desktop-actions.nix { inherit pkgs scripts; };
    desktop-feedback = import ./desktop-feedback.nix { inherit pkgs; };
    dnd-toggle = import ./dnd-toggle.nix { inherit pkgs scripts; };
    file-locations = import ./file-locations.nix { inherit pkgs yazi; };
    home-backup = import ./home-backup.nix { inherit pkgs scripts; };
    idle-locker = import ./idle-locker.nix { inherit pkgs scripts; };
    lock-session = import ./lock-session.nix { inherit pkgs; };
    night-light = import ./night-light.nix { inherit pkgs; };
    notification-history = import ./notification-history.nix { inherit pkgs scripts; };
    pgdev = import ./pgdev.nix { inherit pkgs; };
    power-menu = import ./power-menu.nix { inherit pkgs scripts; };
    qr-scan = import ./qr-scan.nix { inherit pkgs scripts; };
    region-ocr = import ./region-ocr.nix { inherit pkgs scripts; };
    reminder = import ./reminder.nix { inherit pkgs scripts; };
    screenrecord = import ./screenrecord.nix { inherit pkgs; };
    screenshot = import ./screenshot.nix { inherit pkgs; };
    wezterm-sessions = import ./wezterm-sessions.nix {
      inherit
        pkgs
        scripts
        repositories
        projectRoots
        ;
    };
    psql = pkgs.writeShellApplication {
      name = "psql";
      text = ''exec ${scripts.pgdev}/bin/pgdev psql "$@"'';
    };
  };
in
scripts
