{ dmenu }:
dmenu.override {
  conf = ../dmenu/config.def.h;
  patches = [
    ../dmenu/patches/center.diff
    ../dmenu/patches/border.diff
    ../dmenu/patches/line-height.diff
    ../dmenu/patches/fuzzymatch.diff
    ../dmenu/patches/fuzzyhighlight.diff
    ../dmenu/patches/navhistory.diff
    ../dmenu/patches/numbers.diff
  ];
}
