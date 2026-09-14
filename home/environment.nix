{ config, pkgs, ... }: {
  home = {
    sessionVariables = {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = 24;
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      MOZ_DISABLE_RDD_SANDBOX = 1;
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      BEMOJI_PICKER_CMD = "${pkgs.dmenu}/bin/dmenu -i -p emoji";
      BEMOJI_CLIP_CMD = "${pkgs.xclip}/bin/xclip -selection clipboard";
    };
  };
}
