{
  dwm,
  fetchpatch,
  lib,
  libxcb,
}:
let
  upstreamPatch = name: url: hash: {
    inherit name;
    source = fetchpatch { inherit url hash; };
  };
  strictPatch = patch: ''
    patch -p1 --batch --forward --fuzz=3 --no-backup-if-mismatch < ${patch.source}
  '';
  patchWithKnownConflicts = patch: fuzz: expectedFailedHunks: ''
    if patch_output=$(patch -p1 --batch --forward --fuzz=${toString fuzz} \
      --no-backup-if-mismatch --reject-file=- < ${patch.source} 2>&1); then
      patch_status=0
    else
      patch_status=$?
    fi
    printf '%s\n' "$patch_output"
    failed_hunks=$(printf '%s\n' "$patch_output" | awk \
      '/Hunk #[0-9]+ FAILED/ { count++ } END { print count + 0 }')
    if [ "$patch_status" -ne 1 ] || [ "$failed_hunks" -ne ${toString expectedFailedHunks} ]; then
      echo "unexpected patch result for ${patch.name}: status=$patch_status failed_hunks=$failed_hunks" >&2
      exit 1
    fi
  '';
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
  conf = ../dwm/config.def.h;
  extraLibs = [
    libxcb
  ];
}).overrideAttrs
  (old: {
    # Keep upstream patches unchanged. Known overlaps are integrated by the
    # local 6.6 fixup, while unexpected reject counts fail the build.
    patchPhase = ''
      runHook prePatch
      ${lib.concatMapStringsSep "\n" strictPatch patchesBeforeAttachbelow}
      ${patchWithKnownConflicts attachbelow 3 1}
      ${lib.concatMapStringsSep "\n" strictPatch patchesAfterAttachbelow}
      ${patchWithKnownConflicts swallow 0 5}
      ${patchWithKnownConflicts status2dBarpaddingSystray 0 6}
      ${patchWithKnownConflicts statuscmdStatus2d 0 6}
      patch -p1 --batch --forward --fuzz=0 < ${../dwm/patches/dwm-6.6-fixups.diff}
      runHook postPatch
    '';
  })
