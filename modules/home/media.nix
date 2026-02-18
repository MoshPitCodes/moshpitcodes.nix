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

  # PDF viewer with osaka-jade theme
  programs.zathura = {
    enable = true;
    options = {
      default-bg = "#11221C";
      default-fg = "#e6d8ba";
      statusbar-bg = "#11221C";
      statusbar-fg = "#e6d8ba";
      inputbar-bg = "#072820";
      inputbar-fg = "#e6d8ba";
      highlight-color = "#71CEAD";
      highlight-active-color = "#71CEAD";
      recolor-lightcolor = "#11221C";
      recolor-darkcolor = "#e6d8ba";
      recolor = true;
    };
  };

  # Image viewer (Wayland-native)
  home.packages = with pkgs; [
    imv
  ];
}
