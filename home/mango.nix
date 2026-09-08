{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  monitorLayout = pkgs.writeShellApplication {
    name = "monitor-layout";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.mango
      pkgs.util-linux
      pkgs.wlr-randr
    ];
    text = builtins.readFile ../bin/monitor-layout;
  };
  desktopTag = pkgs.writeShellApplication {
    name = "desktop-tag";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.mango
      pkgs.util-linux
    ];
    text = builtins.readFile ../bin/desktop-tag;
  };
  tagBindings = lib.concatMapStringsSep "\n" (
    tag:
    let
      number = toString tag;
    in
    ''
      bind=SUPER,${number},spawn,desktop-tag view ${number}
      bind=SUPER+CTRL,${number},spawn,desktop-tag toggleview ${number}
      bind=SUPER+SHIFT,${number},spawn,desktop-tag tag ${number}
      bind=SUPER+CTRL+SHIFT,${number},spawn,desktop-tag toggletag ${number}
    ''
  ) (lib.range 1 8);
  bar = output: {
    inherit output;
    layer = "top";
    position = "top";
    height = 25;
    spacing = 0;
    modules-left = [ "ext/workspaces" ];
    modules-center = [ "custom/mango-window" ];
    "ext/workspaces" = {
      format = "{name}";
      all-outputs = false;
      ignore-hidden = true;
      on-click = "activate";
      on-click-right = "deactivate";
    };
    "custom/mango-window" = {
      exec = ''
        ${pkgs.mango}/bin/mmsg watch all-monitors | ${pkgs.jq}/bin/jq --unbuffered -c '.monitors[] | select(.name == "${output}") | {text: ((.active_client.title // "") | @html)}'
      '';
      return-type = "json";
      restart-interval = 1;
      tooltip = false;
      max-length = 65;
      on-click-middle = "mmsg dispatch zoom";
    };
    "custom/bar-dnd" = {
      exec = "bar-dnd";
      interval = 1;
      tooltip = false;
      on-click = "dnd-toggle";
      exec-on-event = true;
    };
    "custom/bar-volume" = {
      exec = "bar-volume";
      interval = 2;
      format = "  {}";
      tooltip = false;
      on-click = "BLOCK_BUTTON=1 bar-volume";
      on-click-right = "BLOCK_BUTTON=3 bar-volume";
      on-scroll-up = "BLOCK_BUTTON=4 bar-volume";
      on-scroll-down = "BLOCK_BUTTON=5 bar-volume";
      exec-on-event = true;
    };
    "custom/bar-sysinfo" = {
      exec = "bar-sysinfo";
      interval = 10;
      format = "  {}";
      tooltip = false;
      on-click = "BLOCK_BUTTON=1 bar-sysinfo";
      exec-on-event = true;
    };
    "custom/bar-clock" = {
      exec = "bar-clock";
      interval = 1;
      format = "  {}";
      tooltip = false;
      on-click = "BLOCK_BUTTON=1 bar-clock";
      exec-on-event = true;
    };
    tray = {
      icon-size = 16;
      spacing = 5;
    };
  };
in
{
  imports = [ inputs.mango.hmModules.mango ];

  lib.nixdots.monitorLayout = monitorLayout;
  home.packages = [
    monitorLayout
    desktopTag
    pkgs.wmenu
  ];

  wayland.windowManager.mango = {
    enable = true;
    package = pkgs.mango;
    extraConfig = builtins.readFile ../config/mango/config.conf + "\n" + tagBindings;
    systemd = {
      enable = true;
      xdgAutostart = true;
      variables = lib.mkAfter (
        [
          "MANGO_INSTANCE_SIGNATURE"
          "PATH"
        ]
        ++ builtins.attrNames config.home.sessionVariables
      );
    };
    autostart_sh = ''
      # Stop desktop services when Mango closes its IPC connection.
      trap '${pkgs.systemd}/bin/systemctl --user stop mango-session.target' EXIT
      ${pkgs.mango}/bin/mmsg watch all-monitors >/dev/null
    '';
  };

  systemd.user.services.mango-monitors = {
    Unit = {
      Description = "Mango output layout and tag placement";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "MANGO_INSTANCE_SIGNATURE";
    };
    Service = {
      ExecStart = "${lib.getExe monitorLayout} watch";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "graphical-session.target" ];
    };
    settings = [
      (
        bar "DP-4"
        // {
          name = "main";
          modules-right = [
            "custom/bar-dnd"
            "custom/bar-volume"
            "custom/bar-sysinfo"
            "custom/bar-clock"
            "tray"
          ];
        }
      )
      (
        bar "HDMI-A-2"
        // {
          name = "portrait";
        }
      )
    ];
    style = ''
      * {
        font-family: "Iosevka Nerd Font";
        font-size: 11pt;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
      }
      window#waybar {
        color: #bbb3a9;
        background: #131210;
      }
      #workspaces button {
        padding: 0 8px;
        color: #bbb3a9;
        background: transparent;
      }
      #workspaces button.active {
        color: #131210;
        background: #e17a3f;
      }
      #workspaces button.urgent {
        color: #ddd5ca;
        background: #b34a45;
      }
      #workspaces button:hover {
        box-shadow: none;
        background: #58534c;
      }
      #custom-mango-window, #custom-bar-volume, #custom-bar-sysinfo,
      #custom-bar-clock, #tray {
        padding: 0 8px;
      }
      #custom-bar-dnd {
        color: #e17a3f;
      }
      tooltip {
        color: #ddd5ca;
        background: #131210;
        border: 1px solid #58534c;
      }
    '';
  };

  systemd.user.services.waybar.Service.Environment = [
    "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
  ];
}
