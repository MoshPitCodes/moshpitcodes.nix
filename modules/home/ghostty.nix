# Ghostty terminal configuration (Everforest theme)
{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty ];

  # Ghostty config file
  xdg.configFile."ghostty/config".text = ''
    font-family = FiraCode Nerd Font
    font-size = 12

    theme = Everforest Dark Hard

    cursor-style = block
    cursor-style-blink = true

    window-padding-x = 8
    window-padding-y = 8

    background-opacity = 0.95

    confirm-close-surface = false
  '';
}
