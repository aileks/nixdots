{ config }:
let
  colors = import ../../../theme/cinder-grove.nix;
in
''
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$PATH:$HOME/.local/bin" ;;
  esac

  export NPM_CONFIG_PREFIX="$HOME/.local"
  export GREP_COLORS='mt=1;36'
  export DOCKER_HOST="unix://''${XDG_RUNTIME_DIR:-/run/user/$UID}/podman/podman.sock"

  export PNPM_HOME="$HOME/.local/share/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  bind 'set completion-ignore-case on'
  bind 'set completion-map-case on'
  bind 'set show-all-if-ambiguous on'

  y() {
    local cwd_file cwd result

    cwd_file=$(mktemp -t yazi-cwd.XXXXXX) || return

    ${config.programs.yazi.finalPackage}/bin/yazi "$@" --cwd-file="$cwd_file"
    result=$?

    cwd=$(<"$cwd_file")
    command rm -f -- "$cwd_file"

    if [[ -n $cwd && $cwd != "$PWD" ]]; then
      builtin cd -- "$cwd" || return
    fi

    return "$result"
  }

  export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

  export FZF_ALT_C_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'eza --tree --color=always --icons {}'"

  export FZF_DEFAULT_OPTS="
    --color=fg:${colors.secondary}
    --color=fg+:${colors.bright}
    --color=bg:${colors.background}
    --color=bg+:${colors.selectionBackground}
    --color=hl:${colors.subduedOrange}
    --color=hl+:${colors.brightYellow}
    --color=info:${colors.secondary}
    --color=marker:${colors.subduedOrange}
    --color=prompt:${colors.subduedOrange}
    --color=spinner:${colors.brightOrange}
    --color=pointer:${colors.yellow}
    --color=header:${colors.red}
    --color=border:${colors.secondary}
    --color=query:${colors.bright}
    --color=gutter:${colors.background}
    --highlight-line
    --info=inline-right
    --layout=reverse
    --pointer='█'
    --scrollbar='▌'
    --multi
    --border=top
  "

  export _ZO_FZF_OPTS="
    $FZF_DEFAULT_OPTS
    --height=50%
    --preview 'eza --color=always --icons --group-directories-first {2..}'
    --preview-window=down,border-top
    --bind 'ctrl-b:preview-up,ctrl-f:preview-down'
    --bind 'ctrl-/:change-preview-window(right|hidden|)'
  "
''
