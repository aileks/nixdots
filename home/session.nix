{
  config,
  lib,
  pkgs,
  ...
}:

let
  target = "graphical-session.target";
  lockSession = pkgs.writeShellApplication {
    name = "lock-session";
    runtimeInputs = [ pkgs.systemd ];
    text = builtins.readFile ../bin/lock-session;
  };
  lock = "${lockSession}/bin/lock-session";
  displaysOn = "${pkgs.wlopm}/bin/wlopm --on '*'";
in
{
  lib.nixdots.lockSession = lockSession;
  home.packages = [
    lockSession
    pkgs.wlopm
  ];

  xdg.configFile."autostart/polkit-gnome-authentication-agent-1.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=PolicyKit Authentication Agent
    Hidden=true
  '';

  programs.swaylock = {
    enable = true;
    settings = {
      color = "131210";
      font = "Adwaita Sans";
      indicator-radius = 80;
      inside-color = "1B1916";
      ring-color = "D9A441";
      key-hl-color = "879B5C";
      bs-hl-color = "E17A3F";
      text-color = "DDD5CA";
      line-uses-inside = true;
      show-failed-attempts = true;
    };
  };

  services.cliphist = {
    enable = true;
    allowImages = false;
    extraOptions = [
      "-max-items"
      "50"
      "-max-dedupe-search"
      "50"
    ];
    systemdTargets = [ target ];
  };

  services.swayidle = {
    enable = true;
    systemdTargets = [ target ];
    timeouts = [
      {
        timeout = 600;
        command = lock;
      }
      {
        timeout = 900;
        command = "${pkgs.wlopm}/bin/wlopm --off '*'";
        resumeCommand = displaysOn;
      }
      {
        timeout = 1800;
        command = "${lock} && ${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = {
      lock = lock;
      before-sleep = lock;
      after-resume = "${displaysOn}; ${pkgs.systemd}/bin/systemctl --user try-restart night-light.service";
    };
  };

  systemd.user.services = {
    session-lock = {
      Unit = {
        Description = "Lock the Wayland session";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.swaylock}/bin/swaylock -f";
        TimeoutStartSec = 10;
      };
    };

    night-light = {
      Unit = {
        Description = "Night light at 4800 K";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.gammastep}/bin/gammastep -c /dev/null -m wayland -l 0:0 -t 4800:4800 -r";
        Restart = "on-failure";
      };
    };

    wallpaper = {
      Unit = {
        Description = "Desktop wallpaper";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${config.xdg.dataHome}/backgrounds/fantasy-woods.jpg -m fill";
        Restart = "on-failure";
      };
      Install.WantedBy = [ target ];
    };

    dunst = {
      Unit = {
        Description = "Desktop notifications";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.dunst}/bin/dunst";
        Environment = "PATH=${
          lib.makeBinPath [
            pkgs.wmenu
            pkgs.xdg-utils
          ]
        }:/run/current-system/sw/bin:/etc/profiles/per-user/${config.home.username}/bin";
        Restart = "on-failure";
      };
      Install.WantedBy = [ target ];
    };

    polkit-gnome = {
      Unit = {
        Description = "PolicyKit authentication agent";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = [ target ];
    };
  };
}
