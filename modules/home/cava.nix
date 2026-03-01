# CAVA audio visualizer (TokyoNight Storm gradient)
{ ... }:
{
  programs.cava = {
    enable = true;
  };

  xdg.configFile."cava/config".text = ''
    [general]
    autosens = 1
    overshoot = 0

    [color]
    gradient = 1
    gradient_count = 5
    gradient_color_1 = '#7aa2f7'
    gradient_color_2 = '#7dcfff'
    gradient_color_3 = '#bb9af7'
    gradient_color_4 = '#ff9e64'
    gradient_color_5 = '#f7768e'
  '';
}
