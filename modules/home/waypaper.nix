{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    waypaper
    swww
  ];

  # Waypaper configuration for wallpaper selection GUI
  # Uses swww backend which has native waypaper integration
  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    language = en
    folder = ${config.home.homeDirectory}/Pictures/wallpapers/
    monitors = All
    wallpaper = ${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    backend = swww
    fill = fill
    sort = name
    color = #ffffff
    subfolders = False
    show_hidden = False
    show_gifs_only = False
    post_command =
    number_of_columns = 3
    swww_transition_type = wipe
    swww_transition_step = 90
    swww_transition_angle = 30
    swww_transition_duration = 2
    swww_transition_fps = 60
    use_xdg_state = False

    [Virtual-1]
    wallpaper = ${config.home.homeDirectory}/Pictures/wallpapers/mix/titlwinzbst81.jpg
    fill = fill
  '';
}
