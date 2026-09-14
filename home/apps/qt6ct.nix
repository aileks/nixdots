{ pkgs, ... }:
{
  xdg.configFile."qt6ct/colors/cinder-grove.conf".text = ''
    [ColorScheme]
    active_colors=#ffbbb3a9, #ff23201c, #ff34312d, #ff1b1916, #ff171613, #ff131210, #ffbbb3a9, #ffddd5ca, #ffbbb3a9, #ff131210, #ff131210, #ff58534c, #ffe17a3f, #ff131210, #ffe17a3f, #ff9a938a, #ff23201c, #ff131210, #ff879b5c, #ffddd5ca, #80878077
    disabled_colors=#ff58534c, #ff1b1916, #ff23201c, #ff1b1916, #ff171613, #ff131210, #ff58534c, #ff706a62, #ff58534c, #ff131210, #ff131210, #ff34312d, #ff706a62, #ff131210, #ff706a62, #ff58534c, #ff1b1916, #ff131210, #ff58534c, #ff706a62, #8058534c
    inactive_colors=#ffaca49b, #ff23201c, #ff34312d, #ff1b1916, #ff171613, #ff131210, #ffaca49b, #ffbbb3a9, #ffaca49b, #ff131210, #ff131210, #ff58534c, #ff9a938a, #ff131210, #ff9a938a, #ff878077, #ff23201c, #ff131210, #ff879b5c, #ffbbb3a9, #80878077
  '';
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    color_scheme_path=/home/aileks/.config/qt6ct/colors/cinder-grove.conf
    cursor_theme=Adwaita
    custom_palette=true
    icon_theme=Papirus-Dark
    standard_dialogs=xdgdesktopportal
    style=Fusion

    [Fonts]
    fixed="Iosevka Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular,0,0"
    general="Adwaita Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular,0,0"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=2
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=${pkgs.qt6Packages.qt6ct}/share/qt6ct/qss/fusion-fixes.qss
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\x4>\0\0\x1\xe\0\0\xe\x31\0\0\x6\x89\0\0\x4@\0\0\x1\x10\0\0\xe/\0\0\x6\x87\0\0\0\0\0\0\0\0\n\0\0\0\x4@\0\0\x1\x10\0\0\xe/\0\0\x6\x87)

    [Troubleshooting]
    force_raster_widgets=1
    ignored_applications=@Invalid()
  '';
}
