{
  config,
  lib,
  pkgs,
  ...
}:
let
  colors = import ../../theme/cinder-grove.nix;
  palette = {
    inherit (colors)
      background
      container
      surface
      visual
      text
      purple
      cyan
      ;
    overlay = colors.muted;
    text_muted = colors.muted;
    text_subtle = colors.subtle;
    text_secondary = colors.secondary;
    text_bright = colors.bright;
    primary = colors.orange;
    secondary = colors.green;
    error = colors.red;
    warning = colors.yellow;
    success = colors.green;
    info = colors.blue;
  };
  theme = pkgs.vimUtils.buildVimPlugin {
    pname = "cinder-grove.nvim";
    version = "67daacd1d36970112d3d139812779438e754e95e";
    src = pkgs.fetchFromGitHub {
      owner = "aileks";
      repo = "cinder-grove.nvim";
      rev = "67daacd1d36970112d3d139812779438e754e95e";
      hash = "sha256-cAsw0QC24HJn+lfcpNNnAxN6V1B9T4/yyja3y7yaukM=";
    };
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = [ theme ];
    extraPackages = [ pkgs.xclip ];
    initLua = ''
      local opt = vim.opt

      opt.number = true
      opt.cursorline = true
      opt.scrolloff = 8
      opt.termguicolors = true
      opt.showmode = false
      opt.signcolumn = "yes"
      opt.mouse = "a"
      opt.ignorecase = true
      opt.smartcase = true
      opt.hlsearch = false
      opt.tabstop = 4
      opt.shiftwidth = 4
      opt.expandtab = true
      opt.undofile = true
      opt.swapfile = false
      opt.clipboard = "unnamedplus"
      opt.splitbelow = true
      opt.splitright = true
      opt.completeopt = { "menu", "menuone", "noselect" }
      opt.wildmenu = true
      opt.statusline = " %f %m%r%= %l:%c "

      require("cinder-grove").setup({
        transparent = true,
        colors = ${lib.generators.toLua { } palette},
      })

      vim.cmd.colorscheme("cinder-grove")

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.highlight.on_yank({ higroup = "Yank", timeout = 200 })
        end,
      })
    '';
  };
  home.sessionVariables = {
    SUDO_EDITOR = "nvim";
    MANPAGER = "${lib.getExe config.programs.neovim.finalPackage} +Man!";
  };
}
