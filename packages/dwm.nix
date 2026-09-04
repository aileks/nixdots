{
  dwm,
  lib,
  libxcb,
}:
let
  patchPath = name: ../dwm/patches + "/${name}";
  strictPatch = name: ''
    patch -p1 --batch --forward --fuzz=3 --no-backup-if-mismatch < ${patchPath name}
  '';
  patchWithKnownConflicts = name: fuzz: expectedFailedHunks: ''
    if patch_output=$(patch -p1 --batch --forward --fuzz=${toString fuzz} \
      --no-backup-if-mismatch --reject-file=- < ${patchPath name} 2>&1); then
      patch_status=0
    else
      patch_status=$?
    fi
    printf '%s\n' "$patch_output"
    failed_hunks=$(printf '%s\n' "$patch_output" | awk \
      '/Hunk #[0-9]+ FAILED/ { count++ } END { print count + 0 }')
    if [ "$patch_status" -ne 1 ] || [ "$failed_hunks" -ne ${toString expectedFailedHunks} ]; then
      echo "unexpected patch result for ${name}: status=$patch_status failed_hunks=$failed_hunks" >&2
      exit 1
    fi
  '';
  patchesBeforeAttachbelow = [
    "dwm-actualfullscreen.diff"
    "dwm-restartsig.diff"
    "dwm-movestack.diff"
    "dwm-pertag.diff"
  ];
  patchesAfterAttachbelow = [
    "dwm-cfacts-vanitygaps.diff"
    "dwm-alwayscenter.diff"
  ];
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
      ${patchWithKnownConflicts "dwm-attachbelow.diff" 3 1}
      ${lib.concatMapStringsSep "\n" strictPatch patchesAfterAttachbelow}
      ${patchWithKnownConflicts "dwm-swallow.diff" 0 5}
      ${patchWithKnownConflicts "dwm-status2d-barpadding-systray.diff" 0 6}
      patch -p1 --batch --forward --fuzz=0 < ${../dwm/patches/dwm-6.6-fixups.diff}
      runHook postPatch
    '';
  })
