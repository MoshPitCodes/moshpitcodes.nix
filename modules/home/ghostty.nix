{
  inputs,
  pkgs,
  host,
  ...
}:
let
  ghostty = inputs.ghostty.packages.x86_64-linux.default;
in
{
  home.packages = with pkgs; [ ghostty ];

  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = "Maple Mono NF"
    font-size = ${if (host == "laptop") then "12" else "14"}
    font-thicken = true
    font-feature = ss01
    font-feature = ss04

    bold-is-bright = false
    adjust-box-thickness = 1

    # Theme
    theme = "rose-pine"
    background-opacity = 0.66

    cursor-style = bar
    cursor-style-blink = false
    adjust-cursor-thickness = 1

    resize-overlay = never
    copy-on-select = false
    confirm-close-surface = false
    mouse-hide-while-typing = true

    window-theme = ghostty
    window-padding-x = 4
    window-padding-y = 6
    window-padding-balance = true
    window-padding-color = background
    window-inherit-working-directory = true
    window-inherit-font-size = true
    window-decoration = false

    gtk-titlebar = false
    gtk-single-instance = false
    gtk-tabs-location = bottom
    gtk-wide-tabs = false

    auto-update = off
    term = ghostty
    clipboard-paste-protection = false

    # Working Directory
    working-directory = /home/moshpitcodes/Development

    keybind = shift+end=unbind
    keybind = shift+home=unbind
    keybind = ctrl+shift+left=unbind
    keybind = ctrl+shift+right=unbind
    keybind = shift+enter=text:\n
  '';
  xdg.configFile."ghostty/themes/rose-pine".text = ''
    background = #191724
    foreground = #e0def4

    palette = 0=#26233a
    palette = 1=#eb6f92
    palette = 2=#9ccfd8
    palette = 3=#f6c177
    palette = 4=#31748f
    palette = 5=#c4a7e7
    palette = 6=#9ccfd8
    palette = 7=#e0def4
    palette = 8=#6e6a86
    palette = 9=#eb6f92
    palette = 10=#9ccfd8
    palette = 11=#f6c177
    palette = 12=#31748f
    palette = 13=#c4a7e7
    palette = 14=#9ccfd8
    palette = 15=#e0def4

    cursor-color = #e0def4

    selection-foreground = #191724
    selection-background = #c4a7e7
  '';
}
