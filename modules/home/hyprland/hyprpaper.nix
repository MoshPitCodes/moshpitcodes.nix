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
    # Preload all your wallpapers for better performance
    preload = ${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg

    # Configure each monitor with the proper wallpaper
    wallpaper = eDP-1,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    wallpaper = DP-5,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    wallpaper = DP-6,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    wallpaper = DP-7,${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg

    # Enable IPC for runtime control
    ipc = on

    # Disable splash screen
    splash = false

    # Configuration for monitors
    # This requires hyprpaper 0.6.0 or newer for the 'fit' option
    fit = DP-6,fill
    fit = DP-7,fill
    fit = DP-5,stretch
    fit = eDP-1,fill
  '';
}
