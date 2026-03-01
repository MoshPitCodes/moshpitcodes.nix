# CAVA audio visualizer (Everforest gradient)
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
    gradient_color_1 = '#83c092'
    gradient_color_2 = '#7fbbb3'
    gradient_color_3 = '#a7c080'
    gradient_color_4 = '#dbbc7f'
    gradient_color_5 = '#e67e80'
  '';
}
