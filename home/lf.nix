{
  config,
  lib,
  pkgs,
  ...
}:

let
  lf = lib.getExe config.programs.lf.package;
  file = lib.getExe pkgs.file;
  batThemeCache = pkgs.runCommand "lf-bat-theme-cache" { nativeBuildInputs = [ pkgs.bat ]; } ''
    mkdir -p themes
    cp ${../config/bat/themes/cinder-grove.tmTheme} themes/cinder-grove.tmTheme
    bat cache --build --source . --target "$out"
  '';
  textPreview = pkgs.writeShellApplication {
    name = "lf-text-preview";
    runtimeInputs = [ pkgs.bat ];
    text = ''
      export BAT_CACHE_PATH=${batThemeCache}
      export COLORTERM=truecolor
      bat --no-config --theme=cinder-grove --color=always --style=plain \
        --paging=never --wrap=never --line-range "1:''${3:-40}" -- "$1"
    '';
  };
  preview = pkgs.writeShellApplication {
    name = "lf-preview";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      height=''${3:-40}
      status=0
      timeout --kill-after=1s 3s ${lib.getExe config.programs.pistol.package} \
        --config ${config.home.file."${config.xdg.configHome}/pistol/pistol.conf".source} \
        "$@" | head -n "$height" || status=$?
      # Filling the preview pane can close the pipe before pistol finishes.
      if [ "$status" -eq 141 ]; then exit 0; fi
      exit "$status"
    '';
  };
  findCommand = type: action: ''
    ''${{
      args=(--absolute-path --type ${type} --print0 --exclude .git)
      if [ "$lf_hidden" = true ]; then args+=(--hidden); fi
      IFS= read -r -d "" target < <(
        ${lib.getExe pkgs.fd} "''${args[@]}" |
          ${lib.getExe pkgs.fzf} --read0 --print0 --no-multi --height=100%
      ) || exit 0
      quoted_path=$(printf '%s' "$target" | ${lib.getExe pkgs.jq} -Rs .)
      ${lf} -remote "send $id ${action} $quoted_path"
    }}
  '';
in
{
  xdg.configFile."lf/icons".text = ''
    di 
    fi 
    ln 
    or 
    ex 
  '';

  programs.pistol = {
    enable = true;
    associations = [
      {
        mime = "^(text/.*|application/(json|.*\\+json|javascript|xml|.*\\+xml|x-shellscript)|inode/x-empty)$";
        command = "${lib.getExe textPreview} %pistol-filename% %pistol-extra0% %pistol-extra1%";
      }
      {
        mime = "^application/pdf$";
        command = "${pkgs.poppler-utils}/bin/pdftotext -f 1 -l 5 -layout %pistol-filename% -";
      }
    ];
  };

  programs.lf = {
    enable = true;
    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
      number = true;
      scrolloff = 3;
      incsearch = true;
      info = "size";
      shell = "${pkgs.bash}/bin/bash";
      shellopts = [
        "-eu"
        "-o"
        "pipefail"
      ];
    };

    previewer.source = lib.getExe preview;

    commands = {
      open = ''
        ''${{
          mime=$(${file} --brief --mime-type --dereference -- "$f")
          case "$mime" in
            text/*|application/json|application/*+json|application/javascript|application/xml|application/*+xml|application/x-shellscript|inode/x-empty)
              ${lib.getExe pkgs.neovim} -- "$f"
              ;;
            *) ${lf} -remote "send $id desktop-open" ;;
          esac
        }}
      '';
      desktop-open = ''&${pkgs.xdg-utils}/bin/xdg-open "$f"'';
      mkdir = ''
        %{{
          printf 'Directory name: '
          IFS= read -r name || exit 0
          [ -n "$name" ] || exit 0
          ${pkgs.coreutils}/bin/mkdir -p -- "$name"
          ${lf} -remote "send $id reload"
        }}
      '';
      mkfile = ''
        %{{
          printf 'File name: '
          IFS= read -r name || exit 0
          [ -n "$name" ] || exit 0
          if [ -e "$name" ] || [ -L "$name" ]; then
            printf 'Already exists: %s\n' "$name" >&2
            exit 1
          fi
          (set -o noclobber; : > "$name")
          ${lf} -remote "send $id reload"
        }}
      '';
      delete = ''
        %{{
          [ -n "$fx" ] || exit 0
          # lf exports selections separated by newlines; arrays preserve spaces and globs.
          mapfile -t selected <<< "$fx"
          status=0
          ${pkgs.trash-cli}/bin/trash-put -- "''${selected[@]}" || status=$?
          if [ "$status" -eq 0 ]; then ${lf} -remote "send $id unselect"; fi
          ${lf} -remote "send $id reload"
          exit "$status"
        }}
      '';
      copy-path = ''
        %{{
          [ -n "$fx" ] || exit 0
          printf '%s\n' "$fx" | ${pkgs.xclip}/bin/xclip -selection clipboard
          ${lf} -remote "send $id echomsg Paths copied"
        }}
      '';
      fzf-file = findCommand "f" "select";
      fzf-directory = findCommand "d" "cd";
    };

    keybindings = {
      "<enter>" = "open";
      e = ''$${lib.getExe pkgs.neovim} -- "$f"'';
      a = "mkdir";
      A = "mkfile";
      D = "delete";
      "<delete>" = "delete";
      "." = "set hidden!";
      Y = "copy-path";
      "<c-p>" = "fzf-file";
      "<c-o>" = "fzf-directory";
      "<f-2>" = "maps";
      gp = "cd ~/Projects";
      gd = "cd ~/Documents";
      gD = "cd ~/Downloads";
      gr = "cd ~/Recordings";
      gs = "cd ~/Screenshots";
    };
  };
}
