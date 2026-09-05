{
  dmenu,
  fetchpatch,
  lib,
}:
let
  upstreamPatch = name: url: hash: expectedFailedHunks: {
    inherit name expectedFailedHunks;
    source = fetchpatch { inherit url hash; };
  };
  applyPatch = import ./apply-patch.nix;
  patches = [
    (upstreamPatch "dmenu-alpha"
      "https://tools.suckless.org/dmenu/patches/alpha/dmenu-alpha-20251118-8b48986.diff"
      "sha256-foR+/EzsrNVI9IgPMMwyLP4FTwDzqjcjZUEe8T4cJSw="
      2
    )
    (upstreamPatch "dmenu-center"
      "https://tools.suckless.org/dmenu/patches/center/dmenu-center-20250407-b1e217b.diff"
      "sha256-60YiyPlQSGN3bk65VrIhc1RSO6Wfx9fAAkoQJLl8sW8="
      0
    )
    (upstreamPatch "dmenu-border"
      "https://tools.suckless.org/dmenu/patches/border/dmenu-border-20230512-0fe460d.diff"
      "sha256-huyZHf+deY4vNwwgBAXRRKhZ0UrxWuBrtpVUe604zb4="
      1
    )
    (upstreamPatch "dmenu-lineheight"
      "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.2.diff"
      "sha256-QdY2T/hvFuQb4NAK7yfBgBrz7Ii7O7QmUv0BvVOdf00="
      0
    )
    (upstreamPatch "dmenu-fuzzymatch"
      "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-5.3.diff"
      "sha256-uPuuwgdH2v37eaefnbQ93ZTMvUBcl3LAjysfOEPD1Y8="
      2
    )
    (upstreamPatch "dmenu-fuzzyhighlight"
      "https://tools.suckless.org/dmenu/patches/fuzzyhighlight/dmenu-fuzzyhighlight-5.3.diff"
      "sha256-YdXuqqxF3MdfRfYPcyXLkWKqLDBJ6SNv4fMBoIQ+UNE="
      0
    )
    (upstreamPatch "dmenu-navhistory-with-search"
      "https://tools.suckless.org/dmenu/patches/navhistory/dmenu-navhistory+search-20250328-52fc8a0.diff"
      "sha256-vMZAdPB6EP1v9QUx8agy4gs9NFBO/HCvRCWI8TnlXxE="
      1
    )
    (upstreamPatch "dmenu-numbers"
      "https://tools.suckless.org/dmenu/patches/numbers/dmenu-numbers-20220512-28fb3e2.diff"
      "sha256-lg7CItn11YPEe7T7aPt1DBybZlnLjKQGC8J+OcY44Js="
      0
    )
  ];
in
(dmenu.override {
  conf = ../config/dmenu/config.def.h;
}).overrideAttrs
  (_: {
    # navhistory-with-search pulls in libm
    NIX_LDFLAGS = "-lm";
    # Known patch conflicts are integrated by the local 5.4 fixup, while
    # unexpected reject counts fail the build.
    patchPhase = ''
      runHook prePatch
      ${lib.concatMapStringsSep "\n" applyPatch patches}
      patch -p1 --batch --forward --fuzz=0 < ${../config/dmenu/patches/dmenu-5.4-fixups.diff}
      patch -p1 --batch --forward --fuzz=0 < ${../config/dmenu/patches/dmenu-max-width.diff}
      runHook postPatch
    '';
  })
