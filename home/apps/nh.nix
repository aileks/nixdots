{
  config,
  installation,
  ...
}:
{
  programs.nh = {
    enable = true;
    osFlake = "${config.home.homeDirectory}/${installation.repositoryDirectory}";
    clean.enable = false;
  };

}
