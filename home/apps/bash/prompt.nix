{ lib }:
let
  colors = import ../../../theme/cinder-grove.nix;
  rgb =
    color:
    lib.concatMapStringsSep ";"
      (offset: toString (lib.fromHexString (builtins.substring offset 2 color)))
      [
        1
        3
        5
      ];
in
''
  git_prompt_segment() {
    local output line
    local branch='''
    local ahead=0
    local behind=0
    local dirty=0

    output=$(git status --porcelain=v2 --branch 2>/dev/null) || return

    while IFS= read -r line; do
      case $line in
        '# branch.head '*)
          branch=''${line#'# branch.head '}
          ;;

        '# branch.ab '*)
          local ab=''${line#'# branch.ab '}
          local a b
          read -r a b <<<"$ab"
          ahead=''${a#+}
          behind=''${b#-}
          ;;

        *)
          if [[ -n $line && $line != \#* && $line != \!* ]]; then
            dirty=1
          fi
          ;;
      esac
    done <<<"$output"

    if [[ $branch == '(detached)' ]]; then
      branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    fi

    printf ' %s' "$branch"

    ((ahead > 0)) && printf ' ⇡%d' "$ahead"
    ((behind > 0)) && printf ' ⇣%d' "$behind"
    ((dirty)) && printf ' *'
    return 0
  }

  venv_prompt_name() {
    local key value

    [[ -r $VIRTUAL_ENV/pyvenv.cfg ]] || return 1

    while IFS='=' read -r key value; do
      key=''${key//[[:space:]]/}

      if [[ $key == prompt ]]; then
        value=''${value#"''${value%%[![:space:]]*}"}
        value=''${value%"''${value##*[![:space:]]}"}

        printf '%s' "$value"
        return
      fi
    done <"$VIRTUAL_ENV/pyvenv.cfg"
  }

  make_prompt() {
    local status=$1
    local reset=$'\e[0m'
    local bold=$'\e[1m'
    local orange=$'\e[38;2;${rgb colors.orange}m'
    local blue=$'\e[38;2;${rgb colors.blue}m'
    local magenta=$'\e[38;2;${rgb colors.purple}m'
    local muted=$'\e[38;2;${rgb colors.subtle}m'
    local red=$'\e[38;2;${rgb colors.red}m'
    local cyan=$'\e[38;2;${rgb colors.cyan}m'
    local green=$'\e[38;2;${rgb colors.green}m'
    local git_segment='''
    local status_segment='''
    local venv_segment='''
    local jobs_segment='''

    if _prompt_git_text=$(git_prompt_segment); then
      git_segment=" \[''${magenta}\]\''${_prompt_git_text}\[''${reset}\]"
    fi

    if ((status != 0)); then
      status_segment=" \[''${red}\] ''${status}\[''${reset}\]"
    fi

    if [[ -n ''${VIRTUAL_ENV:-} ]]; then
      _prompt_venv_text=$(venv_prompt_name)
      [[ -n $_prompt_venv_text ]] || _prompt_venv_text=''${VIRTUAL_ENV##*/}

      venv_segment=" \[''${green}\] \''${_prompt_venv_text}\[''${reset}\]"
    fi

    local job_count
    job_count=$(jobs -p | wc -l)

    if ((job_count > 0)); then
      jobs_segment=" \[''${muted}\]󰒋 ''${job_count}\[''${reset}\]"
    fi

    PS1="\[''${orange}''${bold}\]\W\[''${reset}\]"
    PS1+="''${git_segment}"
    PS1+=" \[''${muted}\]• \[''${blue}\]\h\[''${reset}\]"
    PS1+="''${venv_segment}"
    PS1+="''${jobs_segment}"
    PS1+="''${status_segment}"
    PS1+='\n'
    PS1+="\[''${cyan}''${bold}\]❯\[''${reset}\] "
  }

  _prompt_command() {
    local status=$?
    history -a
    history -n
    make_prompt "$status"
  }

  _install_prompt_command() {
    local -a previous=()
    local command

    if declare -p PROMPT_COMMAND &>/dev/null; then
      if [[ $(declare -p PROMPT_COMMAND) == 'declare -a'* ]]; then
        previous=("''${PROMPT_COMMAND[@]}")
      elif [[ -n ''${PROMPT_COMMAND:-} ]]; then
        previous=("$PROMPT_COMMAND")
      fi
    fi

    PROMPT_COMMAND=(_prompt_command)

    for command in "''${previous[@]}"; do
      [[ $command == _prompt_command ]] || PROMPT_COMMAND+=("$command")
    done
  }

  _install_prompt_command
  unset -f _install_prompt_command
''
