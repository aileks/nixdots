{
  dwm,
  libxcb,
}:
dwm.override {
  conf = ../dwm/config.def.h;
  patches = [
    ../dwm/patches/actualfullscreen.diff
    ../dwm/patches/restartsig.diff
    ../dwm/patches/movestack.diff
    ../dwm/patches/pertag.diff
    ../dwm/patches/attachbelow.diff
    ../dwm/patches/vanitygaps.diff
    ../dwm/patches/cfacts.diff
    ../dwm/patches/alwayscenter.diff
    ../dwm/patches/status2d.diff
    ../dwm/patches/systray.diff
    ../dwm/patches/swallow.diff
    ../dwm/patches/statuscmd-status2d.diff
    ../dwm/patches/primarymon.diff
  ];
  extraLibs = [ libxcb ];
}
