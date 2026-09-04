{
  st,
  fetchpatch,
  lib,
  harfbuzz,
}:
let
  upstreamPatch = name: url: hash: expectedFailedHunks: {
    inherit name expectedFailedHunks;
    source = fetchpatch { inherit url hash; };
  };
  applyPatch = patch: ''
    if patch_output=$(patch -p1 --batch --forward --fuzz=3 \
      --no-backup-if-mismatch --reject-file=- < ${patch.source} 2>&1); then
      patch_status=0
    else
      patch_status=$?
    fi
    printf '%s\n' "$patch_output"
    failed_hunks=$(printf '%s\n' "$patch_output" | awk '
      /Hunk #[0-9]+ FAILED/ { count++ }
      /out of [0-9]+ hunks ignored/ { count += $1 }
      END { print count + 0 }
    ')
    expected_status=${if patch.expectedFailedHunks == 0 then "0" else "1"}
    if [ "$patch_status" -ne "$expected_status" ] || \
      [ "$failed_hunks" -ne ${toString patch.expectedFailedHunks} ]; then
      echo "unexpected patch result for ${patch.name}: status=$patch_status failed_hunks=$failed_hunks" >&2
      exit 1
    fi
  '';
  patches = [
    (upstreamPatch "st-scrollback-reflow-standalone"
      "https://st.suckless.org/patches/scrollback-reflow-standalone/st-scrollback-reflow-standalone-0.9.3.diff"
      "sha256-QLig9iae6woVGEsiruJdyZCG7ZdycPzl/NcXP9e08tI="
      0
    )
    (upstreamPatch "st-boxdraw" "https://st.suckless.org/patches/boxdraw/st-boxdraw_v2-0.8.5.diff"
      "sha256-WN/R6dPuw1eviHOvVVBw2VBSMDtfi1LCkXyX36EJKi4="
      0
    )
    (upstreamPatch "st-undercurl"
      "https://st.suckless.org/patches/undercurl/st-undercurl-0.9-20240103.diff"
      "sha256-9ReeNknxQJnu4l3kR+G3hfNU+oxGca5agqzvkulhaCg="
      0
    )
    (upstreamPatch "st-ligatures-boxdraw"
      "https://st.suckless.org/patches/ligatures/0.9.3/st-ligatures-boxdraw-20251007-0.9.3.diff"
      "sha256-mKUiwRcu1jhRDVKKllU4Y0uuBccSsAJUEoT2c+tnfHU="
      2
    )
    (upstreamPatch "st-glyph-wide-support-boxdraw"
      "https://st.suckless.org/patches/glyph_wide_support/st-glyph-wide-support-boxdraw-20220411-ef05519.diff"
      "sha256-MtOFgi8W8SOaj/NpZAg8IGCOR6e3JnfxWw7COVO0RkU="
      5
    )
    (upstreamPatch "st-alpha" "https://st.suckless.org/patches/alpha/st-alpha-20240814-a0274bc.diff"
      "sha256-foKCxYE58T+7GsPRB7ALNzDWCNTvlIsLPojoi0OOeaY="
      0
    )
    (upstreamPatch "st-font2" "https://st.suckless.org/patches/font2/st-font2-0.8.5.diff"
      "sha256-tSMk5c5Hz6/dv3tcyh+0R91Vy1jgU52Y1sjqy2o08x4="
      0
    )
    (upstreamPatch "st-anysize"
      "https://st.suckless.org/patches/anysize/st-anysize-20220718-baa9357.diff"
      "sha256-yx9VSwmPACx3EN3CAdQkxeoJKJxQ6ziC9tpBcoWuWHc="
      0
    )
    (upstreamPatch "st-bold-is-not-bright"
      "https://st.suckless.org/patches/bold-is-not-bright/st-bold-is-not-bright-20190127-3be4cf1.diff"
      "sha256-IhrTgZ8K3tcf5HqSlHm3GTacVJLOhO7QPho6SCGXTHw="
      0
    )
    (upstreamPatch "st-clipboard" "https://st.suckless.org/patches/clipboard/st-clipboard-0.8.3.diff"
      "sha256-y7N2dem0mGg2wZqtrMYWoAbfgcm/OU6eNXPhZPoYZ88="
      0
    )
    (upstreamPatch "st-xresources"
      "https://st.suckless.org/patches/xresources/st-xresources-20260524-688f70a.diff"
      "sha256-sAXugRLc7h8kEGB3FZsCQF1ygt9YQLtAQjh4VtHfQ7o="
      0
    )
    (upstreamPatch "st-newterm" "https://st.suckless.org/patches/newterm/st-newterm-0.9.diff"
      "sha256-U4UhvROueU3S45lN3F8BdQ/mABhxJYM923mVaQCol+Y="
      0
    )
  ];
in
(st.override {
  conf = builtins.readFile ../st/config.def.h;
  extraLibs = [ harfbuzz ];
}).overrideAttrs
  (old: {
    # Known patch conflicts are integrated by the local 0.9.3 fixup, while
    # unexpected reject counts fail the build.
    patchPhase = ''
      runHook prePatch
      ${lib.concatMapStringsSep "\n" applyPatch patches}
      patch -p1 --batch --forward --fuzz=0 < ${../st/patches/st-0.9.3-fixups.diff}
      runHook postPatch
    '';
  })
