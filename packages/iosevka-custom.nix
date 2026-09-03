{ iosevka }:
(iosevka.override {
  set = "Custom";
  privateBuildPlan = builtins.readFile ./iosevka-custom.toml;
}).overrideAttrs
  (_: {
    # avoids oom
    preBuild = ''
      jobs=$(( $(nproc) ))
      [ "$jobs" -ge 1 ] || jobs=1
      export NIX_BUILD_CORES=$jobs
    '';
  })
