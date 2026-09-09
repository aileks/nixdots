{
  config,
  installation,
  lib,
  pkgs,
  ...
}:

let
  colors = import ../theme/cinder-grove.nix;
  border = {
    fg = colors.orange;
  };
  selected = {
    fg = colors.bright;
    bg = colors.visual;
  };
  quteBitwarden = pkgs.writeShellApplication {
    name = "qute-bitwarden";
    runtimeInputs = with pkgs; [
      python3
      bitwarden-cli
      keyutils
      pinentry-gnome3
      wmenu
      coreutils
    ];
    text = ''exec python3 ${../config/qutebrowser}/bitwarden.py "$@"'';
  };
  quteReadeck = pkgs.writeShellApplication {
    name = "qute-readeck";
    runtimeInputs = [ pkgs.python3 ];
    text = ''exec python3 ${../config/qutebrowser/readeck.py} "$@"'';
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

  programs.nh = {
    enable = true;
    osFlake = "${config.home.homeDirectory}/${installation.repositoryDirectory}";
    clean.enable = false;
  };

  programs.nix-search-tv = {
    enable = true;
    settings.indexes = [
      "nixpkgs"
      "nixos"
      "home-manager"
    ];
  };

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

  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = true;
    keyBindings.normal = {
      ",p" = "spawn --userscript ${lib.getExe quteBitwarden}";
      ",u" = "spawn --userscript ${lib.getExe quteBitwarden} --username-only";
      ",P" = "spawn --userscript ${lib.getExe quteBitwarden} --password-only";
      ",t" = "spawn --userscript ${lib.getExe quteBitwarden} --totp-only";
      ",r" = "spawn --userscript ${lib.getExe quteReadeck}";
    };
    greasemonkey = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/1ab9f20435cdc39c6551e940fb7788d3207161e6/youtube_adblock.js";
        hash = "sha256-AyD9VoLJbKPfqmDEwFIEBMl//EIV/FYnZ1+ona+VU9c=";
      })
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/1ab9f20435cdc39c6551e940fb7788d3207161e6/youtube_sponsorblock.js";
        hash = "sha256-2sNlWL0KOAOMe2pllyKVBT4gAICokyDOuHPkVfUrYN4=";
      })
      (pkgs.fetchurl {
        url = "https://cdn2.frankerfacez.com/script/ffz_injector.user.js";
        hash = "sha256-KKfPQtHHkpoV1m6kDnFHxm9HXH5/ubc5lUk+P0LPeLY=";
      })
    ];
    settings = {
      fonts.default_family = "IosevkaTerm Nerd Font";
      fonts.default_size = "12pt";
      content.blocking.method = "both";
      colors = {
        webpage.preferred_color_scheme = "dark";
        webpage.darkmode.enabled = false;
        completion = {
          fg = colors.text;
          even.bg = colors.container;
          odd.bg = colors.surface;
          match.fg = colors.orange;
          category = {
            bg = colors.background;
            fg = colors.orange;
            border.top = colors.background;
            border.bottom = colors.background;
          };
          item.selected = {
            bg = colors.visual;
            fg = colors.bright;
            match.fg = colors.orange;
            border.top = colors.orange;
            border.bottom = colors.orange;
          };
          scrollbar = {
            bg = colors.container;
            fg = colors.muted;
          };
        };
        hints = {
          bg = colors.orange;
          fg = colors.background;
          match.fg = colors.surface;
        };
        keyhint = {
          bg = colors.container;
          fg = colors.text;
          suffix.fg = colors.orange;
        };
        prompts = {
          bg = colors.container;
          fg = colors.text;
          border = "1px solid ${colors.orange}";
          selected = {
            bg = colors.visual;
            fg = colors.bright;
          };
        };
        messages = {
          error = {
            bg = colors.container;
            fg = colors.red;
            border = colors.red;
          };
          warning = {
            bg = colors.container;
            fg = colors.yellow;
            border = colors.yellow;
          };
          info = {
            bg = colors.container;
            fg = colors.text;
            border = colors.blue;
          };
        };
        downloads = {
          bar.bg = colors.background;
          start = {
            bg = colors.blue;
            fg = colors.background;
          };
          stop = {
            bg = colors.green;
            fg = colors.background;
          };
          error = {
            bg = colors.red;
            fg = colors.background;
          };
        };
        tabs = {
          bar.bg = colors.background;
          even = {
            bg = colors.container;
            fg = colors.text;
          };
          odd = {
            bg = colors.surface;
            fg = colors.text;
          };
          selected = {
            even = {
              bg = colors.orange;
              fg = colors.background;
            };
            odd = {
              bg = colors.orange;
              fg = colors.background;
            };
          };
          pinned = {
            even = {
              bg = colors.container;
              fg = colors.text;
            };
            odd = {
              bg = colors.surface;
              fg = colors.text;
            };
            selected = {
              even = {
                bg = colors.orange;
                fg = colors.background;
              };
              odd = {
                bg = colors.orange;
                fg = colors.background;
              };
            };
          };
          indicator = {
            start = colors.blue;
            stop = colors.green;
            error = colors.red;
          };
        };
        statusbar = {
          normal = {
            bg = colors.background;
            fg = colors.text;
          };
          private = {
            bg = colors.surface;
            fg = colors.purple;
          };
          command = {
            bg = colors.container;
            fg = colors.text;
            private = {
              bg = colors.surface;
              fg = colors.purple;
            };
          };
          insert = {
            bg = colors.green;
            fg = colors.background;
          };
          passthrough = {
            bg = colors.blue;
            fg = colors.background;
          };
          caret = {
            bg = colors.purple;
            fg = colors.background;
            selection = {
              bg = colors.visual;
              fg = colors.bright;
            };
          };
          progress.bg = colors.orange;
          url = {
            fg = colors.text;
            error.fg = colors.red;
            warn.fg = colors.yellow;
            hover.fg = colors.orange;
            success.http.fg = colors.text;
            success.https.fg = colors.green;
          };
        };
        contextmenu = {
          menu = {
            bg = colors.container;
            fg = colors.text;
          };
          selected = {
            bg = colors.visual;
            fg = colors.bright;
          };
          disabled = {
            bg = colors.container;
            fg = colors.muted;
          };
        };
        tooltip = {
          bg = colors.container;
          fg = colors.text;
        };
      };
    };
  };

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
    scripts = with pkgs.mpvScripts; [
      mpris
      modernz
    ];
    config = {
      osc = false;
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
