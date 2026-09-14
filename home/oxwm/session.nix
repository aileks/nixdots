{
  pkgs,
  profile,
  profileExtra,
  variables ? [ ],
  screenrecord,
}:
pkgs.writeShellApplication {
  name = "oxwm-session";
  runtimeInputs = [
    pkgs.systemd
    pkgs.dbus
    pkgs.xset
    pkgs.xdotool
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    # shellcheck source=/dev/null
    source ${profile}/etc/profile.d/hm-session-vars.sh
    export XDG_SESSION_TYPE=x11 XDG_CURRENT_DESKTOP=oxwm XDG_SESSION_DESKTOP=oxwm
    export PATH="/run/wrappers/bin:${profile}/bin:/run/current-system/sw/bin:$PATH"
    : "''${DISPLAY:?An Xorg display is required}"
    : "''${XDG_SESSION_ID:?A logind session is required}"
    ${profileExtra}
    variables=(DISPLAY XDG_SESSION_ID XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP PATH ${pkgs.lib.escapeShellArgs variables})
    [[ ! -v XAUTHORITY ]] || variables+=(XAUTHORITY)
    systemctl --user import-environment "''${variables[@]}"
    dbus-update-activation-environment --systemd "''${variables[@]}"
    cleanup() {
      ${screenrecord}/bin/screenrecord stop || true
      systemctl --user stop oxwm-session.target graphical-session.target
      systemctl --user unset-environment DISPLAY XAUTHORITY XDG_SESSION_ID XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
      dbus-update-activation-environment DISPLAY= XAUTHORITY= XDG_SESSION_ID= XDG_SESSION_TYPE= XDG_CURRENT_DESKTOP= XDG_SESSION_DESKTOP=
    }
    trap cleanup EXIT
    xset s off
    xset b off
    xset r rate 250 50
    xset dpms 0 0 900
    systemctl --user start oxwm-session.target
    ${pkgs.oxwm}/bin/oxwm &
    wm=$!
    shutdown() {
      xdotool key --clearmodifiers super+shift+q || true
      wait "$wm" || true
    }
    trap shutdown TERM INT HUP
    wait "$wm"
  '';
}
