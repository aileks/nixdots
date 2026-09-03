{
  st,
  harfbuzz,
}:
st.override {
  conf = builtins.readFile ../st/config.def.h;
  patches = [
    ../st/patches/boxdraw.diff
    ../st/patches/scrollback.diff
    ../st/patches/scrollback-mouse.diff
    ../st/patches/scrollback-altscreen.diff
    ../st/patches/alpha.diff
    ../st/patches/font2.diff
    ../st/patches/anysize.diff
    ../st/patches/ligatures.diff
    ../st/patches/bold-is-not-bright.diff
    ../st/patches/clipboard.diff
    ../st/patches/xresources.diff
    ../st/patches/newterm.diff
  ];
  extraLibs = [ harfbuzz ];
}
