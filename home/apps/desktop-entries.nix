{
  config,
  lib,
  ...
}:
{
  xdg.desktopEntries.yazi = {
    name = "Yazi";
    genericName = "File Manager";
    exec = "${lib.getExe config.programs.wezterm.package} start --always-new-process --class yazi -- ${lib.getExe config.programs.yazi.finalPackage} %f";
    icon = "yazi";
    terminal = false;
    categories = [
      "System"
      "FileTools"
      "FileManager"
    ];
    mimeType = [ "inode/directory" ];
  };

}
