{
  dwm,
  lib,
  libxcb,
  libxres,
}:
let
  patch = p: "patch -p1 --fuzz=3 --no-backup-if-mismatch < ${../dwm/patches + "/${p}"} || true";
  patches = [
    "dwm-actualfullscreen.diff"
    "dwm-restartsig.diff"
    "dwm-movestack.diff"
    "dwm-pertag.diff"
    "dwm-attachbelow.diff"
    "dwm-cfacts-vanitygaps.diff"
    "dwm-alwayscenter.diff"
    "dwm-betterswallow.diff"
    "dwm-status2d-barpadding-systray.diff"
  ];
in
(dwm.override {
  conf = ../dwm/config.def.h;
  extraLibs = [
    libxcb
    libxres
  ];
}).overrideAttrs
  (old: {
    # official patches carry a few 6.6-drifted hunks; dwm-6.6-fixups.diff
    # integrates exactly those rejects
    patchPhase = ''
      runHook prePatch
      ${lib.concatStringsSep "\n" (map patch patches)}
      patch -p1 < ${../dwm/patches/dwm-6.6-fixups.diff}
      runHook postPatch
    '';
  })
