{
  config,
  pkgs,
  ...
}:
let
  scripts = config.lib.nixdots.scripts;
  fileLocations = scripts.file-locations;
in
{
  home.packages = [
    fileLocations
    pkgs.pcmanfm
    pkgs.xclip
  ];

}
