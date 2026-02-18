# Swaylock screen lock (Everforest theme)
{
  pkgs,
  ...
}:
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      daemonize = true;
      datestr = "";
      screenshots = true;
      ignore-empty-password = true;

      indicator = true;
      indicator-radius = 111;
      indicator-thickness = 9;

      effect-blur = "7x5";
      effect-vignette = "0.75:0.75";
      effect-pixelate = 5;

      font = "FiraCode Nerd Font";

      # Everforest color scheme
      text-wrong-color = "d3c6aaFF";
      text-ver-color = "d3c6aaFF";
      text-clear-color = "d3c6aaFF";
      key-hl-color = "dbbc7fFF"; # Everforest yellow/accent
      bs-hl-color = "e67e80FF"; # Everforest red
      ring-clear-color = "7fbbb3FF"; # Everforest blue
      ring-wrong-color = "e67e80ff"; # Everforest red
      ring-ver-color = "a7c080FF"; # Everforest green
      ring-color = "859289ff"; # Everforest gray-green
      line-clear-color = "FFFFFF00";
      line-ver-color = "FFFFFF00";
      line-wrong-color = "FFFFFF00";
      separator-color = "FFFFFF00";
      line-color = "FFFFFF00";
      text-color = "d3c6aaFF"; # Everforest foreground
      inside-color = "2d353bDD"; # Everforest background
      inside-ver-color = "2d353bDD";
      inside-clear-color = "2d353bDD";
      inside-wrong-color = "2d353bDD";
      layout-bg-color = "FFFFFF00";
      layout-text-color = "d3c6aaFF";
    };
  };
}
