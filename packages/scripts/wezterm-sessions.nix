{
  pkgs,
  scripts,
  repositories ? [ ],
  projectRoots ? [ ],
}:
pkgs.writeShellApplication {
  name = "wezterm-sessions";
  runtimeInputs = [
    scripts.desktop-feedback
    pkgs.coreutils
    pkgs.dmenu
    pkgs.findutils
    pkgs.wezterm
    pkgs.jq
  ];
  text = pkgs.lib.removeSuffix "\n" ''
    # Adapted from https://github.com/tonybanters/dmenu-scripts/blob/master/tmux-dmenu.sh
    set -Eeuo pipefail

    trap 'desktop-feedback status "wezterm: could not open workspace" >&2 || true' ERR

    if (($# > 1)) || [[ ''${1-} != ''' && ''${1-} != --select-only ]]; then
      printf 'Usage: wezterm-sessions [--select-only]\n' >&2
      exit 1
    fi

    unset WEZTERM_PANE
    socket="$XDG_RUNTIME_DIR/wezterm-mux.sock"
    export WEZTERM_UNIX_SOCKET="$socket"

    list_panes() {
      if [[ -e $socket || -S $socket ]]; then
        timeout 10s wezterm cli --prefer-mux --no-auto-start list --format json
      else
        printf '[]\n'
      fi
    }

    repositories=(${pkgs.lib.escapeShellArgs repositories})
    project_roots=(${pkgs.lib.escapeShellArgs projectRoots})
    for root in "''${project_roots[@]}"; do
      [[ -d $root ]] || continue
      while IFS= read -r -d ''' git_path; do
        repositories+=("''${git_path%/.git}")
      done < <(find "$root" -name .git -prune -print0 | sort -z)
    done

    panes=$(list_panes)
    workspaces=$(jq -r '[.[].workspace] | unique[]' <<<"$panes")
    menu=('Create new workspace…')
    for repository in "''${repositories[@]}"; do
      [[ $repository != *$'\n'* && $repository != *$'\r'* ]] || continue
      if [[ $repository == "$HOME/"* ]]; then
        menu+=("repo: ~/''${repository#"$HOME/"}")
      else
        menu+=("repo: $repository")
      fi
    done

    while IFS= read -r workspace; do
      [[ -n $workspace ]] && menu+=("workspace: $workspace")
    done <<<"$workspaces"

    choice=$(printf '%s\n' "''${menu[@]}" | dmenu -i -p 'WezTerm:') || exit 0
    [[ -n $choice ]] || exit 0
    found=0
    for entry in "''${menu[@]}"; do
      [[ $choice == "$entry" ]] && found=1 && break
    done

    ((found)) || exit 0

    directory='''
    can_create=false
    if [[ $choice == 'Create new workspace…' ]]; then
      workspace=$(dmenu -p 'New workspace name:' </dev/null) || exit 0
      [[ -n ''${workspace//[[:space:]]/} ]] || exit 0
      [[ $workspace != *$'\n'* && $workspace != *$'\r'* ]] || exit 0
      directory=$HOME
      can_create=true
    elif [[ $choice == 'repo: '* ]]; then
      directory=''${choice#'repo: '}
      [[ $directory != \~/* ]] || directory="$HOME/''${directory#\~/}"
      [[ -d $directory ]] || exit 1
      workspace=''${directory#"$HOME/"}
      can_create=true
    else
      workspace=''${choice#'workspace: '}
    fi

    if [[ ''${1-} == --select-only ]]; then
      jq -n --arg workspace "$workspace" --arg cwd "$directory" --argjson can_create "$can_create" \
        '{workspace: $workspace, cwd: (if $cwd == "" then null else $cwd end), can_create: $can_create}'
      exit 0
    fi

    panes=$(list_panes)
    if ! jq -e --arg workspace "$workspace" 'any(.[]; .workspace == $workspace)' <<<"$panes" >/dev/null; then
      if [[ $can_create != true ]]; then
        desktop-feedback status "wezterm: workspace does not exist: $workspace"
        exit 1
      fi
      timeout 15s wezterm cli --prefer-mux spawn --new-window --workspace "$workspace" --cwd "$directory" >/dev/null
    fi

    wezterm connect --workspace "$workspace" unix
  '';
}
