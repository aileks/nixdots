{
  config,
  lib,
  pkgs,
  ...
}:
let
  monitors = import ./oxwm/monitors.nix {
    inherit pkgs;
    monitors = import ../hosts/hexghost/monitors.nix;
  };
  target = "graphical-session.target";
  scripts = config.lib.nixdots.scripts;
  service = description: command: {
    Unit = {
      Description = description;
      PartOf = [ target ];
      After = [ target ];
      ConditionEnvironment = "DISPLAY";
    };
    Service = {
      ExecStart = command;
      Restart = "on-failure";
    };
    Install.WantedBy = [ target ];
  };
in
{
  lib.nixdots.monitors = monitors;
  systemd.user.targets.oxwm-session.Unit = {
    Description = "Oxwm graphical session";
    BindsTo = [ target ];
    Wants = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };
  services.playerctld.enable = true;
  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
  services.picom = {
    enable = true;
    backend = "egl";
    vSync = true;
    shadow = true;
    shadowOpacity = 0.4;
    fade = false;
    inactiveOpacity = 0.95;
    settings = {
      use-damage = false;
      xrender-sync-fence = true;
      shadow-radius = 14;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "window_type = 'menu'"
      ];
      opacity-rule = [ "100:class_g = 'mpv'" ];
      blur = {
        method = "dual_kawase";
        strength = 5;
      };
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "class_g = 'slop'"
        "class_g = 'org.wezfurlong.wezterm'"
      ];
    };
  };
  home.sessionVariables = {
    CM_LAUNCHER = "${pkgs.dmenu}/bin/dmenu";
    CM_MAX_CLIPS = "20";
    CM_SELECTIONS = "clipboard";
  };
  xdg.configFile."autostart/polkit-gnome-authentication-agent-1.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=PolicyKit Authentication Agent
    Hidden=true
  '';
  systemd.user.services = {
    playerctld = {
      Unit = {
        PartOf = [ target ];
        After = [ target ];
      };
      Install.WantedBy = lib.mkForce [ target ];
    };
    bitwarden = service "Bitwarden" "${pkgs.bitwarden-desktop}/bin/bitwarden";
    localsend = service "LocalSend" "${pkgs.localsend}/bin/localsend";
    monitors = {
      Unit = {
        Description = "Configure monitors by EDID";
        Before = [ "wallpaper.service" ];
        PartOf = [ target ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${monitors}/bin/configure-monitors";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ target ];
    };
    clipmenud = (service "Clipboard history" "${pkgs.clipmenu}/bin/clipmenud") // {
      Service = {
        ExecStart = "${pkgs.clipmenu}/bin/clipmenud";
        Environment = [
          "CM_SELECTIONS=clipboard"
          "CM_MAX_CLIPS=20"
          "CM_DIR=%t/clipmenu"
        ];
        Restart = "on-failure";
        UMask = "0077";
      };
    };
    xss-lock = service "Lock before sleep" "${pkgs.xss-lock}/bin/xss-lock --session=\${XDG_SESSION_ID} --transfer-sleep-lock -- ${scripts.lock-session}/bin/lock-session";
    idle-lock = service "Lock after ten idle minutes" "${pkgs.xautolock}/bin/xautolock -time 10 -locker ${scripts.idle-locker}/bin/idle-locker -notify 30 -notifier '${pkgs.libnotify}/bin/notify-send -t 2000 -a xautolock \"Locking in 30 seconds\"'";
    night-light = {
      Unit = {
        Description = "Night light at 4800 K";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "DISPLAY";
      };
      Service = {
        ExecStart = "${pkgs.gammastep}/bin/gammastep -c /dev/null -m randr -l 0:0 -t 4800:4800 -r";
        Restart = "on-failure";
      };
    };
    wallpaper = {
      Unit = {
        Description = "Desktop wallpaper";
        PartOf = [ target ];
        After = [ target ];
        ConditionEnvironment = "DISPLAY";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.xwallpaper}/bin/xwallpaper --zoom ${../config/wallpaper/fantasy-woods.jpg}";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ target ];
    };
    dunst = service "Desktop notifications" "${pkgs.dunst}/bin/dunst";
    polkit-gnome = service "PolicyKit authentication agent" "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    wezterm-mux = service "WezTerm multiplexing server" "${config.programs.wezterm.package}/bin/wezterm-mux-server --config-file ${config.xdg.configHome}/wezterm/wezterm.lua";
  };
}
