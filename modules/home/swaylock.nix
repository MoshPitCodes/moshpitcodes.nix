# Swaylock screen lock (TokyoNight Storm theme)
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

      # TokyoNight Storm color scheme
      text-wrong-color = "c0caf5FF";
      text-ver-color = "c0caf5FF";
      text-clear-color = "c0caf5FF";
      key-hl-color = "9ece6aFF"; # TokyoNight green
      bs-hl-color = "f7768eFF"; # TokyoNight red
      ring-clear-color = "7dcfffFF"; # TokyoNight cyan
      ring-wrong-color = "f7768eff"; # TokyoNight red
      ring-ver-color = "9ece6aFF"; # TokyoNight green
      ring-color = "7aa2f7ff"; # TokyoNight blue
      line-clear-color = "FFFFFF00";
      line-ver-color = "FFFFFF00";
      line-wrong-color = "FFFFFF00";
      separator-color = "414868FF"; # TokyoNight terminal_black
      line-color = "FFFFFF00";
      text-color = "c0caf5FF"; # TokyoNight fg
      inside-color = "24283bDD"; # TokyoNight bg
      inside-ver-color = "24283bDD";
      inside-clear-color = "24283bDD";
      inside-wrong-color = "24283bDD";
      layout-bg-color = "FFFFFF00";
      layout-text-color = "c0caf5FF";
    };
  };
}
