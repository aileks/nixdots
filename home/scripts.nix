{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  scripts = import ../packages/scripts {
    inherit pkgs;
    nvidia = lib.getBin osConfig.hardware.nvidia.package;
    yazi = config.programs.yazi.finalPackage;
    inherit (config.nixdots.wezterm) repositories projectRoots;
  };
in
{
  options.nixdots.wezterm = {
    repositories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${config.home.homeDirectory}/.dotfiles" ];
      description = "Repositories always listed in wezterm-sessions.";
    };
    projectRoots = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = map (name: "${config.home.homeDirectory}/${name}") [
        "Documents"
        "Projects"
      ];
      description = "Directories searched for Git projects.";
    };
  };
  config = {
    lib.nixdots.scripts = scripts;
    home.packages = builtins.attrValues scripts;
    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = ${pkgs.dmenu}/bin/dmenu -i
      pinentry = ${pkgs.pinentry-gnome3}/bin/pinentry-gnome3
      prompt = Networks
      [editor]
      terminal = ${pkgs.wezterm}/bin/wezterm
      gui_if_available = True
      gui = ${pkgs.networkmanagerapplet}/bin/nm-connection-editor
    '';
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
        ExecStart = "${scripts.reminder}/bin/reminder dispatch";
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
        ExecStart = "${scripts.home-backup}/bin/home-backup";
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
  };
}
