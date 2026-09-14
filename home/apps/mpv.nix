{
  pkgs,
  ...
}:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      modernz
    ];
    config = {
      osc = false;
      vo = "gpu-next";
      gpu-api = "vulkan";
      gpu-context = "x11vk";
      vulkan-device = "NVIDIA GeForce RTX 5070";
      hwdec = "nvdec";
      osd-font = "IosevkaTerm Nerd Font";
      osd-color = colors.text;
      osd-outline-color = colors.background;
      osd-selected-color = colors.orange;
      osd-selected-outline-color = colors.background;
    };
    scriptOpts.modernz = {
      osc_color = colors.background;
      title_color = colors.bright;
      time_color = colors.text;
      side_buttons_color = colors.text;
      middle_buttons_color = colors.text;
      playpause_color = colors.text;
      seekbarfg_color = colors.orange;
      seek_handle_color = colors.orange;
      hover_effect_color = colors.orange;
    };
  };
}
