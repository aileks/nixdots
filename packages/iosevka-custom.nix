{ iosevka }:
iosevka.override {
  set = "Custom";
  privateBuildPlan = builtins.readFile ../config/iosevka/iosevka-custom.toml;
}
