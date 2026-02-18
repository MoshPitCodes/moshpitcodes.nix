# Custom utility scripts
{ pkgs, ... }:
let
  # Wallpaper management (using swww)
  wall-change = pkgs.writeShellApplication {
    name = "wall-change";
    runtimeInputs = with pkgs; [
      swww
      procps
    ];
    text = builtins.readFile ./scripts/wall-change.sh;
  };
  wallpaper-picker = pkgs.writeShellScriptBin "wallpaper-picker" (
    builtins.readFile ./scripts/wallpaper-picker.sh
  );
  random-wallpaper = pkgs.writeShellScriptBin "random-wallpaper" (
    builtins.readFile ./scripts/random-wallpaper.sh
  );

  # Background process launcher
  runbg = pkgs.writeShellScriptBin "runbg" (builtins.readFile ./scripts/runbg.sh);

  # Music/media scripts
  music = pkgs.writeShellScriptBin "music" (builtins.readFile ./scripts/music.sh);
  lofi = pkgs.writeScriptBin "lofi" (builtins.readFile ./scripts/lofi.sh);

  # Hyprland toggle scripts
  toggle_blur = pkgs.writeScriptBin "toggle_blur" (builtins.readFile ./scripts/toggle_blur.sh);
  toggle_opacity = pkgs.writeScriptBin "toggle_opacity" (
    builtins.readFile ./scripts/toggle_opacity.sh
  );
  toggle_waybar = pkgs.writeScriptBin "toggle_waybar" (builtins.readFile ./scripts/toggle_waybar.sh);
  toggle_float = pkgs.writeScriptBin "toggle_float" (builtins.readFile ./scripts/toggle_float.sh);

  # System info
  maxfetch = pkgs.writeScriptBin "maxfetch" (builtins.readFile ./scripts/maxfetch.sh);
  ascii = pkgs.writeScriptBin "ascii" (builtins.readFile ./scripts/ascii.sh);

  # File compression utilities
  compress = pkgs.writeScriptBin "compress" (builtins.readFile ./scripts/compress.sh);
  extract = pkgs.writeScriptBin "extract" (builtins.readFile ./scripts/extract.sh);

  # Keybindings display
  show-keybinds = pkgs.writeScriptBin "show-keybinds" (builtins.readFile ./scripts/keybinds.sh);

  # VM management
  vm-start = pkgs.writeScriptBin "vm-start" (builtins.readFile ./scripts/vm-start.sh);

  # Screen recording and screenshots
  record = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);
  screenshot = pkgs.writeScriptBin "screenshot" (builtins.readFile ./scripts/screenshot.sh);

  # Power menu (rofi-power-menu)
  power-menu = pkgs.writeScriptBin "power-menu" (builtins.readFile ./scripts/power-menu.sh);

  # Tmux session manager
  tmux-sessions = pkgs.writeShellScriptBin "tmux-sessions" (
    builtins.readFile ./scripts/tmux-sessions.sh
  );
in
{
  home.packages = with pkgs; [
    # Wallpaper
    wall-change
    wallpaper-picker
    random-wallpaper

    # Background launcher
    runbg

    # Music/media
    music
    lofi

    # Hyprland toggles
    toggle_blur
    toggle_opacity
    toggle_waybar
    toggle_float

    # System info
    maxfetch
    ascii

    # File utilities
    compress
    extract

    # Keybindings
    show-keybinds

    # VM
    vm-start

    # Screen capture
    record
    screenshot

    # Power menu
    power-menu

    # Tmux
    tmux-sessions
  ];
}
