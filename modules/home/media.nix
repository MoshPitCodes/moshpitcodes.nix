# Media applications configuration
{ pkgs, ... }:
{
  # Video player
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      vo = "gpu";
      hwdec = "auto-safe";
    };
  };

  # PDF viewer with TokyoNight Storm theme
  programs.zathura = {
    enable = true;
    options = {
      default-bg = "#1f2335";
      default-fg = "#c0caf5";
      statusbar-bg = "#1f2335";
      statusbar-fg = "#c0caf5";
      inputbar-bg = "#072820";
      inputbar-fg = "#c0caf5";
      highlight-color = "#73daca";
      highlight-active-color = "#73daca";
      recolor-lightcolor = "#1f2335";
      recolor-darkcolor = "#c0caf5";
      recolor = true;
    };
  };

  # Image viewer (Wayland-native)
  home.packages = with pkgs; [
    imv
  ];
}
