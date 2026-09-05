{
  dwm,
  fetchpatch,
  lib,
  libxcb,
  libxcursor,
}:
let
  upstreamPatch = name: url: hash: {
    inherit name;
    source = fetchpatch { inherit url hash; };
  };
  applyPatch = import ./apply-patch.nix;
  patchesBeforeAttachbelow = [
    (upstreamPatch "dwm-actualfullscreen"
      "https://dwm.suckless.org/patches/actualfullscreen/dwm-actualfullscreen-6.8.diff"
      "sha256-uyi01obIlp89gzy6WkLuFfdSKhnx+r2crQx9EIbrCcc="
    )
    (upstreamPatch "dwm-restartsig"
      "https://dwm.suckless.org/patches/restartsig/dwm-restartsig-20180523-6.2.diff"
      "sha256-OEvtUpbXZrAC/jlcjxigfCQIGYTnr9kFnXOUi7Xzc2k="
    )
    (upstreamPatch "dwm-movestack"
      "https://dwm.suckless.org/patches/movestack/dwm-movestack-20211115-a786211.diff"
      "sha256-pV02jdJHucu4mG6It9c1sn4T4kKdCKIJWgkifzIYcxA="
    )
    (upstreamPatch "dwm-pertag"
      "https://dwm.suckless.org/patches/pertag/dwm-pertag-20200914-61bb8b2.diff"
      "sha256-wRZP/27V7xYOBnFAGxqeJFXdoDk4K1EQMA3bEoAXr/0="
    )
  ];
  attachbelow =
    upstreamPatch "dwm-attachbelow"
      "https://dwm.suckless.org/patches/attachbelow/dwm-attachbelow-6.2.diff"
      "sha256-Apy+bRQG/MgnJYgrT1aJ6tMrSaK89Ud1nFA/G8NdyqI=";
  patchesAfterAttachbelow = [
    (upstreamPatch "dwm-cfacts-vanitygaps"
      "https://dwm.suckless.org/patches/vanitygaps/dwm-cfacts-vanitygaps-6.4_combo.diff"
      "sha256-i/lvTKDXdUrtxpx0epBUz+FSSlO2M+CJu/8SFr2wbG0="
    )
    (upstreamPatch "dwm-alwayscenter"
      "https://dwm.suckless.org/patches/alwayscenter/dwm-alwayscenter-20200625-f04cac6.diff"
      "sha256-xQEwrNphaLOkhX3ER09sRPB3EEvxC73oNWMVkqo4iSY="
    )
  ];
  swallow =
    upstreamPatch "dwm-swallow" "https://dwm.suckless.org/patches/swallow/dwm-swallow-6.3.diff"
      "sha256-aQvD6pWGOHG9n8RwCEMMDJhjcwzN52/EJmTGcNHLLGA=";
  status2dBarpaddingSystray =
    upstreamPatch "dwm-status2d-barpadding-systray"
      "https://dwm.suckless.org/patches/status2d/dwm-status2d-barpadding-systray-20241014-b663875.diff"
      "sha256-qY42EJUQXguzS6Gs5ZDDbbfErhPM77EW2dvMIR2KxWQ=";
  statuscmdStatus2d =
    upstreamPatch "dwm-statuscmd-status2d"
      "https://dwm.suckless.org/patches/statuscmd/dwm-statuscmd-status2d-20210405-60bb3df.diff"
      "sha256-d7kkM6o+K9KbpEyTkdyJZRBHhN4Lb7cLX3JFb4q+zs4=";
in
(dwm.override {
  conf = ../config/dwm/config.def.h;
  extraLibs = [
    libxcb
    libxcursor
  ];
}).overrideAttrs
  (_: {
    NIX_LDFLAGS = "-lXcursor";
    # Keep upstream patches unchanged. Known overlaps are integrated by the
    # local 6.6 fixup, while unexpected reject counts fail the build.
    patchPhase = ''
      runHook prePatch
      ${lib.concatMapStringsSep "\n" applyPatch patchesBeforeAttachbelow}
      ${applyPatch (
        attachbelow
        // {
          fuzz = 3;
          expectedFailedHunks = 1;
        }
      )}
      ${lib.concatMapStringsSep "\n" applyPatch patchesAfterAttachbelow}
      ${applyPatch (
        swallow
        // {
          fuzz = 0;
          expectedFailedHunks = 5;
        }
      )}
      ${applyPatch (
        status2dBarpaddingSystray
        // {
          fuzz = 0;
          expectedFailedHunks = 6;
        }
      )}
      ${applyPatch (
        statuscmdStatus2d
        // {
          fuzz = 0;
          expectedFailedHunks = 6;
        }
      )}
      patch -p1 --batch --forward --fuzz=0 < ${../config/dwm/patches/dwm-6.6-fixups.diff}
      patch -p1 --batch --forward --fuzz=0 < ${../config/dwm/patches/dwm-themed-cursors.diff}
      runHook postPatch
    '';
  })
