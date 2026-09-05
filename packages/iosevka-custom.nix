{ iosevka }:
(iosevka.override {
  set = "Custom";
  privateBuildPlan = builtins.readFile ../config/iosevka/iosevka-custom.toml;
}).overrideAttrs
  (_: {
    preBuild = ''
      # Limit font compilation to half the CPUs to avoid running out of memory.
      jobs=$(( $(nproc) / 2 ))
      [ "$jobs" -ge 1 ] || jobs=1
      if [ "$NIX_BUILD_CORES" -gt 0 ] && [ "$NIX_BUILD_CORES" -lt "$jobs" ]; then
        jobs=$NIX_BUILD_CORES
      fi
      export NIX_BUILD_CORES=$jobs
    '';
  })
