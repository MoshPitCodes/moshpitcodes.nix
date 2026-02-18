# Hyprlock screen locking configuration (Everforest colors - Layout 4 inspired)
{ pkgs, username, ... }:
{
  programs.hyprlock = {
    enable = false; # Disabled - using swaylock in VMware (hyprlock crashes)

    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
        disable_loading_bar = true;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      # Greeting label
      label = [
        {
          monitor = "";
          text = "Hi ${username} :)";
          color = "rgba(211, 198, 170, 1.0)"; # Everforest foreground
          font_size = 35;
          font_family = "FiraCode Nerd Font";
          position = "0, 260";
          halign = "center";
          valign = "center";
        }
        # Time display
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
          color = "rgba(219, 188, 127, 1.0)"; # Everforest accent (yellow)
          font_size = 80;
          font_family = "FiraCode Nerd Font";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # Date display
        {
          monitor = "";
          text = "cmd[update:60000] echo \"$(date +\"%A, %B %d\")\"";
          color = "rgba(211, 198, 170, 0.8)";
          font_size = 20;
          font_family = "FiraCode Nerd Font";
          position = "0, 40";
          halign = "center";
          valign = "center";
        }
        # Splash text at bottom
        {
          monitor = "";
          text = "cmd[update:1000] hyprctl splash";
          color = "rgba(127, 187, 179, 0.8)"; # Everforest blue
          font_size = 14;
          font_family = "FiraCode Nerd Font";
          position = "0, 30";
          halign = "center";
          valign = "bottom";
        }
      ];

      # Input field (password)
      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.30;
          dots_center = true;
          dots_rounding = -1; # Circle
          outer_color = "rgba(219, 188, 127, 0.9)"; # Everforest accent
          inner_color = "rgba(45, 53, 59, 0.5)"; # Everforest background (transparent)
          font_color = "rgba(211, 198, 170, 1.0)"; # Everforest foreground
          font_family = "FiraCode Nerd Font";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Input Password...</i>";
          hide_input = false;
          rounding = -1; # Complete rounding (oval)
          check_color = "rgba(167, 192, 128, 0.9)"; # Everforest green
          fail_color = "rgba(230, 126, 128, 0.9)"; # Everforest red
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;
          capslock_color = "rgba(230, 126, 128, 0.5)";
          swap_font_color = true;
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
