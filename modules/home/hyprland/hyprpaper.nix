{
  config,
  pkgs,
  ...
}:

{
  # Ensure hyprpaper is installed
  home.packages = with pkgs; [
    hyprpaper
  ];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # Preload wallpaper for better performance
    preload = ${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg

    # Set wallpaper for each monitor
    # Note: hyprpaper 0.7.6 does not support block-based syntax or fit_mode in config
    # fit_mode must be set via IPC commands only
    wallpaper = eDP-1,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    wallpaper = DP-5,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    wallpaper = DP-6,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    wallpaper = DP-7,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg

    # Enable IPC for runtime control (required for waypaper)
    ipc = on

    # Disable splash screen
    splash = false
  '';
}
