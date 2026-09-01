#!/usr/bin/env zsh
# Cinder Grove
# Author: Caspian Harper

typeset -A ZSH_HIGHLIGHT_STYLES

# brackets
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#B34A45'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#58534C'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#9A938A'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#ACA49B'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#BBB3A9'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#DDD5CA'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'

# cursor
ZSH_HIGHLIGHT_STYLES[cursor]='standout'

# line
ZSH_HIGHLIGHT_STYLES[line]=''

# main
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#B34A45'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#9A788F'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#58918C,underline'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#58918C'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#6785A1,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='none'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#6785A1,underline'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]=''
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=''
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#D9A441'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#58918C'
ZSH_HIGHLIGHT_STYLES[command-substitution]='none'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#D9A441'
ZSH_HIGHLIGHT_STYLES[process-substitution]='none'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#D9A441'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#9A788F'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#9A788F'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#D9A441'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#879B5C'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#879B5C'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#879B5C'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#58918C'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#879B5C,bold'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#879B5C,bold'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#879B5C,bold'
ZSH_HIGHLIGHT_STYLES[assign]='none'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#D9A441'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#58534C'
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='none'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#C87546,bold'

# root
ZSH_HIGHLIGHT_STYLES[root]='standout'

export ZSH_HIGHLIGHT_STYLES
