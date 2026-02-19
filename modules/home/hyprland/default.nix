# Hyprland user configuration (Everforest theme)
{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Monitor configuration
      monitor = [ ",2560x1440@60,auto,1" ];

      # Variables
      "$mod" = "SUPER";
      "$terminal" = "${pkgs.ghostty}/bin/ghostty";
      "$menu" = "${pkgs.rofi}/bin/rofi -show drun || pkill rofi";

      # General
      general = {
        gaps_in = 2;
        gaps_out = 4;
        border_size = 3;
        "col.active_border" = "rgba(D3C6AAff)";
        "col.inactive_border" = "rgba(3D484Dff)";
        layout = "dwindle";
        resize_on_border = false;
      };

      # Decoration
      decoration = {
        rounding = 5;
        rounding_power = 2;
        active_opacity = 0.95;
        inactive_opacity = 0.85;
        blur = {
          enabled = true;
          size = 3;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
        };
        shadow = {
          enabled = true;
          range = 10;
          render_power = 2;
          color = "0x33000000";
        };
      };

      # Animations (easeOut curves)
      animations = {
        enabled = true;
        bezier = [
          "easeOut, 0.25, 1, 0.5, 1"
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1.0"
          "quick, 0.15, 0, 0.1, 1"
        ];
        animation = [
          "global, 1, 5, default"
          "windows, 1, 4.5, easeOutQuint"
          "windowsIn, 1, 2.8, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.2, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "border, 1, 3.0, easeOutQuint"
          "fade, 1, 2.8, quick"
          "layersIn, 1, 2.4, easeOutQuint, popin 87%"
          "layersOut, 1, 2.4, easeOutQuint, popin 87%"
          "fadeLayersIn, 1, 0.2, quick"
          "fadeLayersOut, 1, 1.8, easeOut"
          "workspaces, 1, 2, easeOut, slide"
        ];
      };

      # Input
      input = {
        kb_layout = "de";
        follow_mouse = 1;
        numlock_by_default = true;
        repeat_delay = 300;
        accel_profile = "flat";
        float_switch_override_focus = 0;
        mouse_refocus = 0;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 0;
      };

      # Dwindle layout
      dwindle = {
        force_split = 2;
        pseudotile = true;
        preserve_split = true;
      };

      binds = {
        workspace_back_and_forth = true;
        allow_workspace_cycles = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        enable_swallow = true;
        focus_on_activate = true;
        middle_click_paste = false;
        layers_hog_keyboard_focus = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      cursor = {
        no_warps = true;
      };

      # Layer rules (blur for waybar, launcher, notifications)
      layerrule = [
        "blur 1, match:namespace ^(waybar)$"
        "ignore_alpha 1, match:namespace ^(waybar)$"
        "blur 1, match:namespace ^(launcher)$"
        "ignore_alpha 1, match:namespace ^(launcher)$"
        "blur 1, match:namespace ^(rofi)$"
        "ignore_alpha 1, match:namespace ^(rofi)$"
        "blur 1, match:namespace ^(notifications)$"
        "ignore_alpha 0.5, match:namespace ^(notifications)$"
        "no_anim 1, match:namespace ^(hyprpicker)$"
      ];

      # Window rules (matching old config syntax)
      windowrule = [
        # Rofi launcher
        "pin on, match:class ^(rofi)$"

        # Wallpaper picker
        "float on, match:class ^(waypaper)$"
        "pin on, match:class ^(waypaper)$"

        # Floating dialogs
        "float on, match:class ^(pavucontrol)$"
        "float on, match:class ^(org.pulseaudio.pavucontrol)$"
        "float on, match:class ^(nm-connection-editor)$"
        "float on, match:class ^(org.gnome.Nautilus)$, match:title ^(Properties)$"
        "float on, match:class ^(org.gnome.Calculator)$"
        "float on, match:class ^(xdg-desktop-portal-gtk)$"
        "float on, match:class ^(com.usebottles.bottles)$"

        # File dialogs
        "float on, match:title ^(Open File)$"
        "float on, match:title ^(Open Folder)$"
        "float on, match:title ^(Save As)$"
        "float on, match:title ^(Save File)$"
        "float on, match:title ^(File Upload)$"
        "float on, match:title ^(Confirm to replace files)$"
        "float on, match:title ^(File Operation Progress)$"

        # Generic dialog classes
        "float on, match:class ^(file_progress)$"
        "float on, match:class ^(confirm)$"
        "float on, match:class ^(dialog)$"
        "float on, match:class ^(download)$"
        "float on, match:class ^(notification)$"
        "float on, match:class ^(error)$"
        "float on, match:class ^(confirmreset)$"
        "float on, match:title ^(branchdialog)$"

        # Idle inhibit for fullscreen content
        "idle_inhibit fullscreen, match:class ^(firefox)$"
        "idle_inhibit fullscreen, match:class ^(zen)$"
        "idle_inhibit focus, match:class ^(mpv)$"

        # Browser opacity (subtle inactive transparency)
        "opacity 1.0 0.97, match:class ^([fF]irefox)$"
        "opacity 1.0 0.97, match:class ^([cC]hrom(e|ium))$"
        "opacity 1.0 1.0, match:class ^(zen)$"
        "opacity 1.0 1.0, match:class ^(Zen-browser)$"
        "opacity 1.0 1.0, match:class ^(zen-alpha)$"
        "opacity 1.0 1.0, match:class ^(zen-beta)$"
        "opaque on, match:class ^(zen)$"
        "opaque on, match:class ^(Zen-browser)$"
        "opaque on, match:class ^(zen-alpha)$"
        "opaque on, match:class ^(zen-beta)$"

        # No transparency on media windows
        "opacity 1.0 1.0, match:class ^(mpv)$"
        "opacity 1.0 1.0, match:class ^(vlc)$"
        "opacity 1.0 1.0, match:class ^(imv)$"
        "opacity 1.0 1.0, match:title ^(.*imv.*)$"
        "opacity 1.0 1.0, match:title ^(.*mpv.*)$"

        # Picture in Picture
        "float on, match:title ^(Picture-in-Picture)$"
        "opacity 1.0 1.0, match:title ^(Picture-in-Picture)$"
        "pin on, match:title ^(Picture-in-Picture)$"

        # Media viewers - float + full opacity
        "float on, match:class ^(Viewnior)$"
        "float on, match:class ^(Audacious)$"
        "opacity 1.0 1.0, match:class ^(Audacious)$"

        # Utility windows with size rules
        "float on, match:class ^(zenity)$"
        "size 850 500, match:class ^(zenity)$"
        "float on, match:class ^(org.gnome.FileRoller)$"
        "float on, match:class ^(SoundWireServer)$"
        "size 725 330, match:class ^(SoundWireServer)$"
        "float on, match:title ^(Volume Control)$"
        "size 700 450, match:title ^(Volume Control)$"

        # Workspace assignments
        "workspace 3, match:class ^(evince)$"
        "opacity 1.0 1.0, match:class ^(evince)$"
        "workspace 4, match:class ^(Gimp-2.10)$"
        "workspace 5, match:class ^(Audacious)$"
        "workspace 5, match:class ^(Spotify)$"
        "workspace 7, match:class ^(zen-beta)$"
        "workspace 8, match:class ^(com.obsproject.Studio)$"
        "workspace 1, match:class ^(discord)$"
        "workspace 1, match:title ^(btop-monitor)$"

        # xwaylandvideobridge (OBS screen capture)
        "opacity 0.0 0.0, match:class ^(xwaylandvideobridge)$"
        "no_anim on, match:class ^(xwaylandvideobridge)$"
        "no_initial_focus on, match:class ^(xwaylandvideobridge)$"
        "max_size 1 1, match:class ^(xwaylandvideobridge)$"
        "no_blur on, match:class ^(xwaylandvideobridge)$"

        # Remove context menu transparency in chromium based apps
        "opaque on, match:class ^$, match:title ^$"
        "no_shadow on, match:class ^$, match:title ^$"
        "no_blur on, match:class ^$, match:title ^$"
      ];

      # Key bindings
      bind = [
        # Keybinds help
        "$mod, F1, exec, show-keybinds"

        # Core
        "$mod, Return, exec, $terminal"
        "ALT, Return, exec, [float; size 1431 805] $terminal"
        "$mod SHIFT, Return, exec, [fullscreen] $terminal"
        "$mod, D, exec, $menu"
        "$mod, Q, killactive,"
        "$mod SHIFT, Q, exec, ${pkgs.hyprland}/bin/hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"
        "$mod, E, exec, ${pkgs.nautilus}/bin/nautilus --new-window"
        "ALT, E, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exec '[float; size 1111 700] ${pkgs.nautilus}/bin/nautilus --new-window'"
        "$mod SHIFT, E, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exec '[float; size 1111 700] ${pkgs.ghostty}/bin/ghostty -e ${pkgs.yazi}/bin/yazi'"
        "$mod, Space, exec, toggle_float"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"
        "$mod, K, swapsplit,"
        "$mod, G, togglegroup,"
        "$mod, F, fullscreen,"
        "$mod, M, fullscreen, 1"
        "$mod SHIFT, Escape, exec, power-menu"
        "$mod CTRL, L, exec, ${pkgs.swaylock-effects}/bin/swaylock"
        "$mod CTRL, R, exec, ${pkgs.hyprland}/bin/hyprctl reload"

        # Waybar reload
        "$mod SHIFT, B, exec, ${pkgs.procps}/bin/pkill waybar; ${pkgs.waybar}/bin/waybar &"

        # Wallpaper management
        "$mod, W, exec, wallpaper-picker"
        "$mod SHIFT, W, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exec '[float; size 925 615] ${pkgs.waypaper}/bin/waypaper'"

        # Applications
        "$mod SHIFT, S, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exec '[workspace 5 silent] ${pkgs.soundwireserver}/bin/SoundWireServer'"
        "$mod SHIFT, O, exec, ${pkgs.obs-studio}/bin/obs"
        "$mod SHIFT, N, exec, ${pkgs.obsidian}/bin/obsidian"
        "$mod, T, exec, toggle_opacity"
        "$mod, C, exec, ${pkgs.hyprpicker}/bin/hyprpicker -a"
        "$mod, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"
        "CTRL SHIFT, Escape, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exec '[workspace 9] ${pkgs.mission-center}/bin/missioncenter'"
        "$mod, equal, exec, ${pkgs.woomer}/bin/woomer"

        # Focus movement (arrow keys)
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Focus movement (hjkl)
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Bring focused window to top (arrow keys)
        "$mod, left, alterzorder, top"
        "$mod, right, alterzorder, top"
        "$mod, up, alterzorder, top"
        "$mod, down, alterzorder, top"

        # Bring focused window to top (hjkl)
        "$mod, h, alterzorder, top"
        "$mod, j, alterzorder, top"
        "$mod, k, alterzorder, top"
        "$mod, l, alterzorder, top"

        # Focus floating/tiled windows
        "CTRL ALT, up, exec, ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow floating"
        "CTRL ALT, down, exec, ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow tiled"

        # Window swapping (arrow keys)
        "$mod ALT, left, swapwindow, l"
        "$mod ALT, right, swapwindow, r"
        "$mod ALT, up, swapwindow, u"
        "$mod ALT, down, swapwindow, d"

        # Window moving (arrow keys)
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Window moving (hjkl)
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        # Resize (arrow keys)
        "$mod CTRL, left, resizeactive, -80 0"
        "$mod CTRL, right, resizeactive, 80 0"
        "$mod CTRL, up, resizeactive, 0 -80"
        "$mod CTRL, down, resizeactive, 0 80"

        # Resize (hjkl)
        "$mod CTRL, h, resizeactive, -80 0"
        "$mod CTRL, j, resizeactive, 0 80"
        "$mod CTRL, k, resizeactive, 0 -80"
        "$mod CTRL SHIFT, l, resizeactive, 80 0"

        # Move floating window (arrow keys)
        "$mod ALT, left, moveactive, -80 0"
        "$mod ALT, right, moveactive, 80 0"
        "$mod ALT, up, moveactive, 0 -80"
        "$mod ALT, down, moveactive, 0 80"

        # Move floating window (hjkl)
        "$mod ALT, h, moveactive, -80 0"
        "$mod ALT, j, moveactive, 0 80"
        "$mod ALT, k, moveactive, 0 -80"
        "$mod ALT, l, moveactive, 80 0"

        # Workspace navigation
        "$mod, Tab, workspace, m+1"
        "$mod SHIFT, Tab, workspace, m-1"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace (silent)
        "$mod SHIFT, 1, movetoworkspacesilent, 1"
        "$mod SHIFT, 2, movetoworkspacesilent, 2"
        "$mod SHIFT, 3, movetoworkspacesilent, 3"
        "$mod SHIFT, 4, movetoworkspacesilent, 4"
        "$mod SHIFT, 5, movetoworkspacesilent, 5"
        "$mod SHIFT, 6, movetoworkspacesilent, 6"
        "$mod SHIFT, 7, movetoworkspacesilent, 7"
        "$mod SHIFT, 8, movetoworkspacesilent, 8"
        "$mod SHIFT, 9, movetoworkspacesilent, 9"

        # Open next empty workspace (changed from CTRL+down to avoid resize conflict)
        "$mod CTRL SHIFT, N, workspace, empty"

        # Clipboard manager
        "$mod, V, exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"

        # Mouse workspace scrolling
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Screenshots
        ", Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy area"
        "$mod, Print, exec, ${pkgs.grimblast}/bin/grimblast --notify save area ~/Pictures/Screenshots/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
        "$mod SHIFT, Print, exec, ${pkgs.grimblast}/bin/grimblast --notify copy output"

        # Media keys
        ", XF86AudioMute, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
      ];

      # Repeat bindings (hold to repeat)
      binde = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume lower"
        # ALT+Tab window cycling
        "ALT, Tab, cyclenext,"
        "ALT, Tab, bringactivetotop,"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Autostart with full paths
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        # nm-applet removed - waybar network module provides WiFi status
        "${pkgs.swaynotificationcenter}/bin/swaync"
        "${pkgs.easyeffects}/bin/easyeffects --gapplication-service"
        "${pkgs.poweralertd}/bin/poweralertd"
        "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
        "${pkgs.hyprland}/bin/hyprctl setcursor Bibata-Modern-Ice 24"
        "${pkgs.swww}/bin/swww-daemon"
        "sleep 1 && ${pkgs.swww}/bin/swww img ~/Pictures/wallpapers/default.jpg --transition-type wipe --transition-duration 1"
      ];
    };
  };

  # Foot terminal (lightweight, reliable)
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=11";
        pad = "8x8";
      };
      colors = {
        background = "2d353b";
        foreground = "d3c6aa";
      };
    };
  };
}
