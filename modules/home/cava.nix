_:
{
  programs.cava = {
    enable = true;
  };

  xdg.configFile."cava/config".text = ''
    # custom cava config

    [general]
    autosens = 1
    overshoot = 0

    [color]
    gradient = 1
    gradient_count = 8

    gradient_color_1 = '#9ccfd8'
    gradient_color_2 = '#c4a7e7'
    gradient_color_3 = '#c4a7e7'
    gradient_color_4 = '#ebbcba'
    gradient_color_5 = '#ebbcba'
    gradient_color_6 = '#f6c177'
    gradient_color_7 = '#eb6f92'
    gradient_color_8 = '#eb6f92'
  '';
}
