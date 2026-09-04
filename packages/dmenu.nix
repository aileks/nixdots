{
  dmenu,
  lib,
}:
let
  patch = p: "patch -p1 --fuzz=3 --no-backup-if-mismatch < ${../dmenu/patches + "/${p}"} || true";
  patches = [
    "dmenu-alpha.diff"
    "dmenu-center.diff"
    "dmenu-border.diff"
    "dmenu-lineheight.diff"
    "dmenu-fuzzymatch.diff"
    "dmenu-fuzzyhighlight.diff"
    "dmenu-navhistory-with-search.diff"
    "dmenu-numbers.diff"
  ];
in
(dmenu.override {
  conf = ../dmenu/config.def.h;
}).overrideAttrs
  (old: {
    # navhistory-with-search pulls in libm
    NIX_LDFLAGS = "-lm";
    # usage()-string hunks drift on 5.4; dmenu-5.4-fixups.diff integrates them
    patchPhase = ''
      runHook prePatch
      ${lib.concatStringsSep "\n" (map patch patches)}
      patch -p1 < ${../dmenu/patches/dmenu-5.4-fixups.diff}
      runHook postPatch
    '';
  })
