{
  config,
  installation,
  lib,
  pkgs,
  ...
}:
let
  home = config.home-manager.users.${installation.user.name};
  session = import ../home/oxwm/session.nix {
    inherit pkgs;
    inherit (home.xsession) profileExtra;
    variables = builtins.attrNames (home.home.sessionVariables // home.home.sessionSearchVariables);
    screenrecord = home.lib.nixdots.scripts.screenrecord;
    profile = "/etc/profiles/per-user/${installation.user.name}";
  };
  oxwmSession = pkgs.symlinkJoin {
    name = "oxwm-session";
    paths = [ pkgs.oxwm ];
    postBuild = ''
      rm "$out/share/xsessions/oxwm.desktop"
      cat > "$out/share/xsessions/oxwm.desktop" <<DESKTOP
      [Desktop Entry]
      Name=oxwm
      Exec=${session}/bin/oxwm-session
      Type=Application
      DesktopNames=oxwm;X-NIXOS-SYSTEMD-AWARE;
      DESKTOP
    '';
    passthru.providedSessions = [ "oxwm" ];
  };
in
{
  system.build.oxwmSession = session;
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    windowManager.oxwm = {
      enable = true;
      package = oxwmSession;
    };
    xkb = {
      layout = "aileks";
      extraLayouts.aileks = {
        description = "US with Caps Lock and right Control swapped";
        languages = [ "eng" ];
        symbolsFile = pkgs.writeText "aileks-xkb" (import ./keyboard.nix);
      };
    };
    autoRepeatDelay = 250;
    autoRepeatInterval = 20;
  };
  services.libinput.mouse.accelProfile = "flat";
  services.logind.settings.Login.IdleAction = "ignore";
  programs.i3lock = {
    enable = true;
    package = pkgs.i3lock-color;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };
  users.users.${installation.user.name} = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
}
