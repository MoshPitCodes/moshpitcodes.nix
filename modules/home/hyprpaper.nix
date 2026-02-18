# Hyprpaper wallpaper daemon
# NOTE: Disabled in favor of swww for dynamic wallpaper management
# Configuration preserved for potential future rollback
{ ... }:
{
  services.hyprpaper = {
    enable = false;

    settings = {
      splash = false;
      ipc = "on";

      preload = [ "~/wallpapers/default.jpg" ];
      wallpaper = [ ",~/wallpapers/default.jpg" ];
    };
  };

  # Create wallpaper directory structure
  # Users should add their own wallpaper images to these directories:
  # - ~/Pictures/wallpapers/ - Main wallpaper directory (for wallpaper-picker.sh)
  # - ~/Pictures/wallpapers/randomwallpaper/ - Random wallpaper pool (for random-wallpaper.sh)
  home.file."Pictures/wallpapers/.keep".text = "";
  home.file."Pictures/wallpapers/randomwallpaper/.keep".text = "";
}
