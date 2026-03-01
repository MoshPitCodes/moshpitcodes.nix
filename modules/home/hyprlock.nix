# Hyprlock screen locking configuration (TokyoNight Storm colors)
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
          color = "rgba(192, 202, 245, 1.0)"; # TokyoNight fg
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
          color = "rgba(122, 162, 247, 1.0)"; # TokyoNight blue accent
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
          color = "rgba(192, 202, 245, 0.8)"; # TokyoNight fg (dimmed)
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
          color = "rgba(125, 207, 255, 0.8)"; # TokyoNight cyan
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
          outer_color = "rgba(122, 162, 247, 0.9)"; # TokyoNight blue
          inner_color = "rgba(31, 35, 53, 0.5)"; # TokyoNight bg_dark (transparent)
          font_color = "rgba(192, 202, 245, 1.0)"; # TokyoNight fg
          font_family = "FiraCode Nerd Font";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Input Password...</i>";
          hide_input = false;
          rounding = -1; # Complete rounding (oval)
          check_color = "rgba(158, 206, 106, 0.9)"; # TokyoNight green
          fail_color = "rgba(247, 118, 142, 0.9)"; # TokyoNight red
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;
          capslock_color = "rgba(247, 118, 142, 0.5)"; # TokyoNight red (dimmed)
          swap_font_color = true;
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
