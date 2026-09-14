{ ... }:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = false;
  programs.starship.settings = {
    "format" =
      "$username$hostname$directory$git_branch$git_state$git_status$python$nodejs$cmd_duration$jobs$status$line_break$character";
    "scan_timeout" = 30;
    "command_timeout" = 500;
    "add_newline" = true;
    "character" = {
      "success_symbol" = "[❯](${colors.cyan})";
      "error_symbol" = "[❯](${colors.red})";
    };
    "directory" = {
      "truncation_length" = 1;
      "truncate_to_repo" = false;
      "style" = "${colors.bright} bold";
      "format" = "[$path]($style)[$read_only]($read_only_style) ";
    };
    "line_break" = {
      "disabled" = false;
    };
    "git_branch" = {
      "symbol" = "";
      "style" = "${colors.blue}";
      "format" = "on [$symbol$branch]($style) ";
    };
    "git_status" = {
      "style" = "${colors.cyan}";
      "format" = "([\\[$all_status$ahead_behind\\]]($style) )";
      "conflicted" = "=\${count}";
      "ahead" = "↑\${count}";
      "behind" = "↓\${count}";
      "diverged" = "↕↑\${ahead_count}↓\${behind_count}";
      "untracked" = "?\${count}";
      "stashed" = "\\$\${count}";
      "modified" = "!\${count}";
      "staged" = "+\${count}";
      "renamed" = "»\${count}";
      "deleted" = "✘\${count}";
    };
    "git_state" = {
      "style" = "${colors.yellow}";
      "format" = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
    };
    "cmd_duration" = {
      "min_time" = 2000;
      "style" = "${colors.cyan}";
      "format" = "[$duration]($style) ";
      "show_milliseconds" = false;
    };
    "status" = {
      "style" = "${colors.red}";
      "format" = "[$status]($style) ";
      "disabled" = false;
      "pipestatus" = true;
      "pipestatus_separator" = "|";
      "pipestatus_format" = "\\[$pipestatus\\] => [$status]($style) ";
    };
    "username" = {
      "style_user" = "${colors.yellow} bold";
      "style_root" = "${colors.red} bold";
      "format" = "[$user]($style) ";
      "show_always" = false;
    };
    "hostname" = {
      "style" = "${colors.yellow}";
      "format" = "at [$hostname]($style) ";
      "ssh_only" = true;
    };
    "jobs" = {
      "style" = "${colors.yellow}";
      "format" = "[$symbol$number]($style) ";
      "symbol" = "✦ ";
      "threshold" = 1;
    };
    "python" = {
      "style" = "${colors.cyan}";
      "format" = "[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style) ";
      "symbol" = "";
      "detect_env_vars" = [ "VIRTUAL_ENV" ];
    };
    "nodejs" = {
      "style" = "${colors.cyan}";
      "format" = "[$symbol($version)]($style) ";
      "symbol" = "";
    };
  };
}
