{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  openBtop = "${pkgs.wezterm}/bin/wezterm start --always-new-process -- ${lib.getExe config.programs.btop.package}";
  resetWindowSize = pkgs.writeShellApplication {
    name = "reset-window-size";
    runtimeInputs = [
      pkgs.jq
      pkgs.mango
    ];
    text = builtins.readFile ../bin/reset-window-size;
  };
  tagBindings = lib.concatMapStringsSep "\n" (
    tag:
    let
      number = toString tag;
    in
    ''
      bind=SUPER,${number},view,${number}
      bind=SUPER+CTRL,${number},toggleview,${number}
      bind=SUPER+SHIFT,${number},tagsilent,${number}
      bind=SUPER+CTRL+SHIFT,${number},toggletag,${number}
    ''
  ) (lib.range 1 7);
  bar = {
    output = "DP-4";
    name = "main";
    layer = "top";
    position = "top";
    height = 25;
    spacing = 0;
    modules-left = [
      "ext/workspaces"
      "custom/mango-window"
    ];
    modules-center = [ "mpris" ];
    modules-right = [
      "custom/bar-dnd"
      "pulseaudio"
      "group/processor"
      "custom/bar-memory"
      "custom/bar-gpu"
      "clock"
      "tray"
    ];
    "ext/workspaces" = {
      format = "{name}";
      all-outputs = false;
      ignore-hidden = true;
      on-click = "activate";
      on-click-right = "deactivate";
    };
    "custom/mango-window" = {
      exec = ''
        ${pkgs.mango}/bin/mmsg watch all-monitors | ${pkgs.jq}/bin/jq --unbuffered -c '.monitors[] | select(.name == "DP-4") | {text: ((.active_client.title // "") | @html)}'
      '';
      return-type = "json";
      restart-interval = 1;
      tooltip = false;
      max-length = 65;
    };
    "custom/bar-dnd" = {
      exec = "bar-dnd";
      return-type = "json";
      interval = 1;
      on-click = "notification-history";
      on-click-middle = "${pkgs.dunst}/bin/dunstctl history-clear";
      on-click-right = "dnd-toggle";
      exec-on-event = true;
    };
    pulseaudio = {
      format = "  {volume}%";
      format-muted = "󰖁  mute";
      tooltip-format = "{desc}\nVolume: {volume}%";
      on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      on-click-right = "${pkgs.wezterm}/bin/wezterm start --always-new-process -- ${pkgs.wiremix}/bin/wiremix";
      on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
      on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-";
    };
    "group/processor" = {
      orientation = "horizontal";
      modules = [
        "cpu"
        "custom/bar-cpu-temperature"
      ];
    };
    cpu = {
      interval = 5;
      format = "  {usage}%";
      on-click = openBtop;
    };
    "custom/bar-cpu-temperature" = {
      exec = "bar-cpu-temperature";
      return-type = "json";
      interval = 10;
      on-click = openBtop;
    };
    "custom/bar-memory" = {
      exec = "bar-memory";
      format = "󰍛  {}";
      return-type = "json";
      interval = 10;
      on-click = openBtop;
    };
    "custom/bar-gpu" = {
      exec = "bar-gpu";
      format = "󰢮  {}";
      return-type = "json";
      interval = 5;
      on-click = "${pkgs.wezterm}/bin/wezterm start --always-new-process -- ${lib.getExe pkgs.nvtopPackages.nvidia}";
    };
    clock = {
      format = "  {:%a %b %d %H:%M}";
      format-alt = "  {:%Y-%m-%d %H:%M}";
      tooltip-format = "<tt>{calendar}</tt>";
      calendar = {
        mode = "month";
        on-scroll = 1;
        format.today = "<span color='#e17a3f'><b>{}</b></span>";
      };
      actions = {
        on-scroll-up = "shift_up";
        on-scroll-down = "shift_down";
      };
    };
    mpris = {
      player = "playerctld";
      format = "{status_icon} {dynamic}";
      dynamic-order = [
        "artist"
        "title"
      ];
      dynamic-len = 38;
      title-len = 38;
      max-length = 40;
      tooltip-format = "{player} ({status})\n{artist}\n{title}\n{album}";
      status-icons = {
        playing = "";
        paused = "";
        stopped = "";
      };
    };
    tray = {
      icon-size = 16;
      spacing = 5;
    };
  };
in
{
  imports = [ inputs.mango.hmModules.mango ];

  services.playerctld.enable = true;
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  home.packages = [
    resetWindowSize
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

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "graphical-session.target" ];
    };
    settings = [ bar ];
    style = ''
      * {
        font-family: "Iosevka Nerd Font";
        font-size: 11pt;
        font-weight: 600;
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
      #custom-mango-window, #mpris, #custom-bar-dnd, #pulseaudio, #cpu,
      #custom-bar-memory, #custom-bar-gpu, #clock, #tray {
        padding: 0 8px;
      }
      #cpu {
        padding-right: 5px;
      }
      #custom-bar-cpu-temperature {
        padding-right: 8px;
      }
      #custom-bar-memory {
        color: #6785a1;
      }
      #custom-bar-dnd.paused, #cpu, #custom-bar-cpu-temperature {
        color: #e17a3f;
      }
      #custom-bar-gpu {
        color: #9a788f;
      }
      #pulseaudio {
        color: #879b5c;
      }
      #pulseaudio.muted {
        color: #b34a45;
      }
      #mpris.paused, #mpris.stopped, #custom-bar-gpu.unavailable,
      #custom-bar-dnd.unavailable {
        color: #58534c;
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
