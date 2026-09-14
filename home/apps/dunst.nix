{ pkgs, ... }:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  xdg.configFile."dunst/dunstrc".text = ''
    [global]
        dmenu = ${pkgs.dmenu}/bin/dmenu -i -p notification
        monitor = 0
    follow = none
    width = 380
    height = (0, 120)
    origin = top-right
    offset = (5, 5)
    frame_width = 2
    frame_color = "${colors.muted}"
    separator_color = frame
    font = Iosevka Nerd Font 12
    icon_position = left
    icon_theme = Papirus-Dark
    max_icon_size = 32
    gap_size = 6
    padding = 10
    horizontal_padding = 12
    text_icon_padding = 10
    corner_radius = 0
    format = "<b>%s</b>\n%b"
    timeout = 5

    [urgency_low]
    background = "${colors.background}"
    foreground = "${colors.text}"
    frame_color = "${colors.muted}"
    timeout = 4

    [urgency_normal]
    background = "${colors.background}"
    foreground = "${colors.text}"
    frame_color = "${colors.subtle}"
    timeout = 5

    [urgency_critical]
    background = "${colors.background}"
    foreground = "${colors.bright}"
    frame_color = "${colors.red}"
    timeout = 0

    [desktop-feedback]
    appname = desktop-feedback
    format = "<b>%s</b>"
    icon_position = off
    highlight = "${colors.orange}"
    timeout = 2
    history_ignore = yes
    override_pause_level = 100

    [reminder]
    appname = reminder
    markup = no
    timeout = 0
  '';
}
