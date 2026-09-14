{
  config,
  lib,
  ...
}:
let
  colors = import ../../theme/cinder-grove.nix;
  scripts = config.lib.nixdots.scripts;
in
{
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      enable_wayland = false;
      font = lib.generators.mkLuaInline ''wezterm.font("IosevkaTerm Nerd Font", { weight = "Regular" })'';
      # Automatic rules select Thin for dim text and ExtraBold for bold text.
      font_rules = [
        {
          intensity = "Bold";
          italic = true;
          font = lib.generators.mkLuaInline ''wezterm.font("IosevkaTerm Nerd Font", { weight = "Bold", style = "Italic" })'';
        }
        {
          intensity = "Bold";
          italic = false;
          font = lib.generators.mkLuaInline ''wezterm.font("IosevkaTerm Nerd Font", { weight = "Bold" })'';
        }
        {
          italic = true;
          font = lib.generators.mkLuaInline ''wezterm.font("IosevkaTerm Nerd Font", { weight = "Regular", style = "Italic" })'';
        }
        {
          italic = false;
          font = lib.generators.mkLuaInline ''wezterm.font("IosevkaTerm Nerd Font", { weight = "Regular" })'';
        }
      ];
      font_size = 14;
      window_background_opacity = 0.95;
      window_decorations = "NONE";
      window_close_confirmation = "NeverPrompt";
      hide_tab_bar_if_only_one_tab = false;
      use_fancy_tab_bar = false;
      tab_and_split_indices_are_zero_based = false;
      scrollback_lines = 10000;
      default_gui_startup_args = [
        "connect"
        "unix"
      ];
      unix_domains = [
        {
          name = "unix";
          socket_path = lib.generators.mkLuaInline ''os.getenv("XDG_RUNTIME_DIR") .. "/wezterm-mux.sock"'';
        }
      ];
      colors = {
        foreground = colors.text;
        background = colors.background;
        cursor_bg = colors.bright;
        cursor_border = colors.bright;
        cursor_fg = colors.background;
        selection_fg = colors.bright;
        selection_bg = colors.visual;
        scrollbar_thumb = colors.muted;
        split = colors.orange;
        ansi = with colors; [
          background
          red
          green
          yellow
          blue
          purple
          cyan
          secondary
        ];
        brights = with colors; [
          muted
          red
          green
          yellow
          blue
          purple
          cyan
          bright
        ];
        tab_bar = {
          background = colors.background;
          active_tab = {
            fg_color = colors.background;
            bg_color = colors.orange;
          };
          inactive_tab = {
            fg_color = colors.subtle;
            bg_color = colors.container;
          };
          inactive_tab_hover = {
            fg_color = colors.bright;
            bg_color = colors.surface;
          };
          new_tab = {
            fg_color = colors.subtle;
            bg_color = colors.background;
          };
          new_tab_hover = {
            fg_color = colors.bright;
            bg_color = colors.surface;
          };
        };
      };
    };
  };

  programs.wezterm.extraConfig = import ./wezterm-mux.nix { inherit scripts; };

}
