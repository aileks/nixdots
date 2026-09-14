{ ... }:
let
  colors = import ../../theme/cinder-grove.nix;
in
{
  xdg.configFile."cava/config".text = ''
    [general]
    framerate = 60
    autosens = 1
    sensitivity = 100
    bars = 0
    bar_width = 2
    bar_spacing = 1
    center_align = 1
    lower_cutoff_freq = 50
    higher_cutoff_freq = 10000
    sleep_timer = 3

    [input]
    method = pipewire
    source = auto

    [output]
    method = noncurses
    orientation = bottom
    channels = stereo
    mono_option = average
    reverse = 0
    synchronized_sync = 1
    show_idle_bar_heads = 0

    [color]
    background = '${colors.background}'
    foreground = '${colors.orange}'
    gradient = 1
    gradient_color_1 = '${colors.blue}'
    gradient_color_2 = '${colors.green}'
    gradient_color_3 = '${colors.yellow}'
    gradient_color_4 = '${colors.orange}'
    gradient_color_5 = '${colors.bright}'

    [smoothing]
    noise_reduction = 77
  '';
}
