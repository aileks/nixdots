{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Palette and roles from Projects/cinder-grove.nvim.
  colors = {
    background = "#131210";
    container = "#1B1916";
    surface = "#23201C";
    visual = "#3E3A34";
    muted = "#58534C";
    subtle = "#9A938A";
    secondary = "#ACA49B";
    text = "#BBB3A9";
    bright = "#DDD5CA";
    orange = "#E17A3F";
    green = "#879B5C";
    red = "#B34A45";
    yellow = "#D9A441";
    blue = "#6785A1";
    purple = "#9A788F";
    cyan = "#58918C";
  };
  border = {
    fg = colors.orange;
  };
  selected = {
    fg = colors.bright;
    bg = colors.visual;
  };
  fileLocations = pkgs.writeShellApplication {
    name = "file-locations";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      jq
      libnotify
      pcmanfm
      util-linux
      wmenu
      yazi
    ];
    text = builtins.readFile ../bin/file-locations;
  };
in
{
  home.packages = [
    fileLocations
    pkgs.pcmanfm
    pkgs.wl-clipboard
  ];

  programs.wezterm = {
    enable = true;
    # The existing, live-linked .zshrc sources the bundled integration below.
    enableZshIntegration = false;
    settings = {
      enable_wayland = true;
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
          # Also used by wezterm-dmenu to detect a server without starting it.
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

  programs.wezterm.extraConfig = builtins.readFile ../config/wezterm/mux.lua;

  xdg.configFile."wezterm/shell-integration.sh".source =
    "${config.programs.wezterm.package}/etc/profile.d/wezterm.sh";

  programs.yazi = {
    enable = true;
    enableZshIntegration = false;
    extraPackages = [ pkgs.wl-clipboard ];
    settings = {
      mgr = {
        sort_by = "natural";
        sort_sensitive = false;
        sort_dir_first = true;
        show_hidden = true;
        show_symlink = true;
        linemode = "size";
        scrolloff = 3;
      };
      opener = {
        edit = [
          {
            run = "${lib.getExe pkgs.neovim} -- %s";
            desc = "Neovim";
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = "${pkgs.xdg-utils}/bin/xdg-open %s1";
            desc = "Open";
            orphan = true;
            for = "linux";
          }
        ];
        play = [
          {
            run = "${lib.getExe config.programs.mpv.finalPackage} -- %s";
            desc = "mpv";
            orphan = true;
            for = "linux";
          }
        ];
        reveal = [
          {
            run = "${lib.getExe pkgs.pcmanfm} %d1";
            desc = "Show in PCManFM";
            orphan = true;
            for = "linux";
          }
        ];
      };
      open.prepend_rules = [
        {
          mime = "application/{xml,*+xml,*+json,toml,yaml,x-yaml,x-shellscript}";
          use = [
            "edit"
            "reveal"
          ];
        }
      ];
    };
    keymap.mgr.prepend_keymap = [
      {
        on = [
          "g"
          "b"
        ];
        run = "shell -- ${lib.getExe fileLocations}";
        desc = "Bookmarks and mounted drives";
      }
      {
        on = "D";
        run = "remove";
        desc = "Trash selected files";
      }
      {
        on = "<Delete>";
        run = "remove";
        desc = "Trash selected files";
      }
      {
        on = "e";
        run = "shell --block -- ${lib.getExe pkgs.neovim} -- %s";
        desc = "Edit selected files";
      }
    ];
    theme = {
      app.overall = {
        fg = colors.text;
      };
      mgr = {
        cwd = {
          fg = colors.blue;
        };
        find_keyword = {
          fg = colors.yellow;
          bold = true;
        };
        find_position = {
          fg = colors.purple;
          bold = true;
        };
        marker_copied = {
          fg = colors.green;
          bg = colors.green;
        };
        marker_cut = {
          fg = colors.red;
          bg = colors.red;
        };
        marker_marked = {
          fg = colors.cyan;
          bg = colors.cyan;
        };
        marker_selected = {
          fg = colors.yellow;
          bg = colors.yellow;
        };
        count_copied = {
          fg = colors.background;
          bg = colors.green;
        };
        count_cut = {
          fg = colors.background;
          bg = colors.red;
        };
        count_selected = {
          fg = colors.background;
          bg = colors.yellow;
        };
        border_style = {
          fg = colors.muted;
        };
        syntect_theme = "${../config/yazi/cinder-grove.tmTheme}";
      };
      tabs = {
        active = {
          fg = colors.background;
          bg = colors.orange;
          bold = true;
        };
        inactive = {
          fg = colors.subtle;
          bg = colors.container;
        };
      };
      mode = {
        normal_main = {
          fg = colors.background;
          bg = colors.orange;
          bold = true;
        };
        normal_alt = {
          fg = colors.bright;
          bg = colors.surface;
        };
        select_main = {
          fg = colors.background;
          bg = colors.purple;
          bold = true;
        };
        select_alt = {
          fg = colors.bright;
          bg = colors.surface;
        };
        unset_main = {
          fg = colors.background;
          bg = colors.red;
          bold = true;
        };
        unset_alt = {
          fg = colors.bright;
          bg = colors.surface;
        };
      };
      indicator = {
        parent = {
          fg = colors.bright;
          bg = colors.surface;
        };
        current = {
          fg = colors.bright;
          bg = colors.surface;
        };
        preview = {
          underline = true;
        };
      };
      status = {
        overall = {
          fg = colors.text;
          bg = colors.container;
        };
        perm_sep = {
          fg = colors.muted;
        };
        perm_type = {
          fg = colors.blue;
        };
        perm_read = {
          fg = colors.yellow;
        };
        perm_write = {
          fg = colors.red;
        };
        perm_exec = {
          fg = colors.green;
        };
        progress_label = {
          fg = colors.bright;
          bold = true;
        };
        progress_normal = {
          fg = colors.green;
          bg = colors.surface;
        };
        progress_error = {
          fg = colors.yellow;
          bg = colors.red;
        };
      };
      which = {
        inherit border;
        cand = {
          fg = colors.cyan;
        };
        rest = {
          fg = colors.muted;
        };
        desc = {
          fg = colors.text;
        };
        separator_style = {
          fg = colors.muted;
        };
      };
      confirm = {
        inherit border;
        title = {
          fg = colors.orange;
        };
        btn_yes = selected;
        btn_no = {
          fg = colors.subtle;
        };
      };
      spot = {
        inherit border;
        title = {
          fg = colors.orange;
        };
        tbl_col = {
          fg = colors.blue;
        };
        tbl_cell = selected;
      };
      notify = {
        title_info = {
          fg = colors.blue;
        };
        title_warn = {
          fg = colors.yellow;
        };
        title_error = {
          fg = colors.red;
        };
      };
      pick = {
        inherit border;
        active = selected;
        inactive = {
          fg = colors.text;
        };
      };
      input = {
        inherit border selected;
        title = {
          fg = colors.orange;
        };
        value = {
          fg = colors.text;
        };
      };
      cmp = {
        inherit border;
        active = selected;
        inactive = {
          fg = colors.text;
        };
      };
      tasks = {
        inherit border;
        title = {
          fg = colors.orange;
        };
        hovered = selected;
      };
      help = {
        inherit border;
        chord = {
          fg = colors.cyan;
        };
        action = {
          fg = colors.text;
        };
        hovered = selected // {
          bold = true;
        };
      };
      filetype.rules = [
        {
          mime = "**/image/*";
          fg = colors.yellow;
        }
        {
          mime = "**/{audio,video}/*";
          fg = colors.purple;
        }
        {
          mime = "**/application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
          fg = colors.red;
        }
        {
          mime = "**/application/{pdf,doc,rtf}";
          fg = colors.cyan;
        }
        {
          mime = "vfs/{absent,stale}";
          fg = colors.subtle;
        }
        {
          url = "*";
          is = "orphan";
          fg = colors.red;
        }
        {
          url = "*";
          is = "exec";
          fg = colors.green;
        }
        {
          url = "*/";
          fg = colors.blue;
        }
      ];
    };
  };

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

  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.mpris ];
    config = {
      vo = "gpu-next";
      gpu-api = "vulkan";
      gpu-context = "waylandvk";
      vulkan-device = "NVIDIA GeForce RTX 5070";
      hwdec = "nvdec";
      osd-font = "IosevkaTerm Nerd Font";
      osd-color = colors.text;
      osd-outline-color = colors.background;
      osd-selected-color = colors.orange;
      osd-selected-outline-color = colors.background;
    };
    scriptOpts.osc = {
      background_color = colors.background;
      timecode_color = colors.orange;
      title_color = colors.bright;
      time_pos_color = colors.text;
      buttons_color = colors.text;
      small_buttonsL_color = colors.text;
      small_buttonsR_color = colors.text;
      top_buttons_color = colors.text;
      held_element_color = colors.orange;
      time_pos_outline_color = colors.background;
    };
  };
}
