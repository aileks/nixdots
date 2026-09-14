{ ... }:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  programs.zathura = {
    enable = true;
    options = {
      font = "IosevkaTerm Nerd Font 12";
      default-bg = colors.background;
      default-fg = colors.text;
      statusbar-bg = colors.container;
      statusbar-fg = colors.text;
      inputbar-bg = colors.container;
      inputbar-fg = colors.text;
      completion-bg = colors.surface;
      completion-fg = colors.text;
      completion-group-bg = colors.container;
      completion-group-fg = colors.orange;
      completion-highlight-bg = colors.visual;
      completion-highlight-fg = colors.bright;
      notification-bg = colors.container;
      notification-fg = colors.text;
      notification-error-bg = colors.container;
      notification-error-fg = colors.red;
      notification-warning-bg = colors.container;
      notification-warning-fg = colors.yellow;
      highlight-color = "rgba(217,164,65,0.5)";
      highlight-active-color = "rgba(225,122,63,0.5)";
      highlight-fg = colors.background;
      recolor = false;
      recolor-darkcolor = colors.text;
      recolor-lightcolor = colors.background;
      recolor-keephue = true;
      recolor-reverse-video = true;
    };
  };

}
