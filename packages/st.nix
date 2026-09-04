{
  st,
  lib,
  harfbuzz,
}:
let
  patch = p: "patch -p1 --fuzz=3 --no-backup-if-mismatch < ${../st/patches + "/${p}"} || true";
  patches = [
    "st-scrollback-reflow-standalone.diff"
    "st-boxdraw.diff"
    "st-undercurl.diff"
    "st-ligatures-boxdraw.diff"
    "st-glyph-wide-support-boxdraw.diff"
    "st-alpha.diff"
    "st-font2.diff"
    "st-anysize.diff"
    "st-bold-is-not-bright.diff"
    "st-clipboard.diff"
    "st-xresources.diff"
    "st-newterm.diff"
  ];
in
(st.override {
  conf = builtins.readFile ../st/config.def.h;
  extraLibs = [ harfbuzz ];
}).overrideAttrs
  (old: {
    # a few hunks drift against 0.9.3's current patch interactions;
    # st-0.9.3-fixups.diff integrates exactly those rejects
    patchPhase = ''
      runHook prePatch
      ${lib.concatStringsSep "\n" (map patch patches)}
      patch -p1 < ${../st/patches/st-0.9.3-fixups.diff}
      runHook postPatch
    '';
  })
