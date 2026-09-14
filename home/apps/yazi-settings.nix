{
  config,
  lib,
  pkgs,
  ...
}:
let
  colors = import ../../theme/cinder-grove.nix;
  border = {
    fg = colors.orange;
  };
  selected = {
    fg = colors.bright;
    bg = colors.visual;
  };
  scripts = config.lib.nixdots.scripts;
  fileLocations = scripts.file-locations;
in
{
  programs.yazi = {
    enable = true;
    enableBashIntegration = false;
    extraPackages = [ pkgs.xclip ];
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
            run = "${lib.getExe config.programs.neovim.finalPackage} -- %s";
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
        run = "shell --block -- ${lib.getExe config.programs.neovim.finalPackage} -- %s";
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
        syntect_theme = "${config.xdg.configFile."yazi/cinder-grove.tmTheme".source}";
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

}
