# Btop system monitor configuration (TokyoNight Storm theme)
{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyonight";
      shown_boxes = "cpu mem net proc";
      vim_keys = true;
      rounded_corners = true;
      theme_background = false;
    };
  };

  # TokyoNight Storm btop theme
  xdg.configFile."btop/themes/tokyonight.theme".text = ''
    # Main background
    theme[main_bg]="#24283b"

    # Main text color
    theme[main_fg]="#c0caf5"

    # Title color for boxes
    theme[title]="#c0caf5"

    # Highlight color for keyboard shortcuts
    theme[hi_fg]="#f7768e"

    # Background color of selected items
    theme[selected_bg]="#292e42"

    # Foreground color of selected items
    theme[selected_fg]="#e0af68"

    # Color of inactive/disabled text
    theme[inactive_fg]="#414868"

    # Color of text appearing on top of graphs
    theme[graph_text]="#c0caf5"

    # Misc colors for processes box
    theme[proc_misc]="#9ece6a"

    # Cpu box outline color
    theme[cpu_box]="#414868"

    # Memory/disks box outline color
    theme[mem_box]="#414868"

    # Net up/down box outline color
    theme[net_box]="#414868"

    # Processes box outline color
    theme[proc_box]="#414868"

    # Box divider line and small boxes line color
    theme[div_line]="#414868"

    # Temperature graph colors
    theme[temp_start]="#9ece6a"
    theme[temp_mid]="#e0af68"
    theme[temp_end]="#f7768e"

    # CPU graph colors
    theme[cpu_start]="#9ece6a"
    theme[cpu_mid]="#e0af68"
    theme[cpu_end]="#f7768e"

    # Mem/Disk free meter
    theme[free_start]="#f7768e"
    theme[free_mid]="#e0af68"
    theme[free_end]="#9ece6a"

    # Mem/Disk cached meter
    theme[cached_start]="#7dcfff"
    theme[cached_mid]="#73daca"
    theme[cached_end]="#9ece6a"

    # Mem/Disk available meter
    theme[available_start]="#f7768e"
    theme[available_mid]="#e0af68"
    theme[available_end]="#9ece6a"

    # Mem/Disk used meter
    theme[used_start]="#9ece6a"
    theme[used_mid]="#e0af68"
    theme[used_end]="#f7768e"

    # Download graph colors
    theme[download_start]="#9ece6a"
    theme[download_mid]="#73daca"
    theme[download_end]="#7dcfff"

    # Upload graph colors
    theme[upload_start]="#e0af68"
    theme[upload_mid]="#ff9e64"
    theme[upload_end]="#f7768e"

    # Process box color gradient for threads, mem and cpu usage
    theme[process_start]="#9ece6a"
    theme[process_mid]="#f7768e"
    theme[process_end]="#f7768e"
  '';
}
