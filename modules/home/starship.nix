{ lib, ... }:
{
  programs.starship = {
    enable = false;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    settings = {
      format = lib.concatStrings [
        "[](color_orange)"
        "$os"
        "[](bg:color_yellow fg:color_orange)"
        "$directory"
        "[](fg:color_yellow bg:color_aqua)"
        "$git_branch"
        "$git_status"
        "[](fg:color_aqua bg:color_blue)"
        "$nix_shell"
        "[](fg:color_blue bg:color_bg3)"
        "$cmd_duration"
        "[](fg:color_bg3) "
      ];

      palette = "rose_pine";
      palettes.rose_pine = {
        color_fg0 = "#e0def4";
        color_bg1 = "#1f1d2e";
        color_bg3 = "#26233a";
        color_blue = "#31748f";
        color_aqua = "#9ccfd8";
        color_green = "#9ccfd8";
        color_orange = "#f6c177";
        color_purple = "#c4a7e7";
        color_red = "#eb6f92";
        color_yellow = "#f6c177";
      };

      os = {
        disabled = false;
        style = "bg:color_orange bold fg:color_fg0";
        symbols = {
          NixOS = " ";
        };
      };

      directory = {
        style = "bold fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)";
        truncation_length = 3;
      };

      git_branch = {
        symbol = "";
        style = "bg:color_aqua";
        format = "[[ $symbol $branch ](bold fg:color_fg0 bg:color_aqua)]($style)";
      };

      git_status = {
        style = "bg:color_aqua bold fg:color_fg0";
        format = "[$all_status$ahead_behind]($style)";
      };

      nix_shell = {
        format = "[ via nix $name ]($style)";
        style = "bg:color_blue bold fg:color_fg0";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:color_bg1";
        format = "[[   $time ](fg:color_fg0 bg:color_bg1)]($style)";
      };

      cmd_duration = {
        format = "[ 󰔛 $duration ]($style)";
        disabled = false;
        style = "bg:color_bg3 fg:color_fg0";
        show_notifications = false;
        min_time_to_notify = 60000;
      };

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[  ](bold fg:color_green)";
        error_symbol = "[  ](bold fg:color_red)";
      };
    };
  };
}
