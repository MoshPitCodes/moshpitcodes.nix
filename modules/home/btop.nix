# Btop system monitor configuration (Everforest theme)
{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "everforest";
      shown_boxes = "cpu mem net proc";
      vim_keys = true;
      rounded_corners = true;
      theme_background = false;
    };
  };

  # Everforest btop theme
  xdg.configFile."btop/themes/everforest.theme".text = ''
    # Main background
    theme[main_bg]="#2d353b"

    # Main text color
    theme[main_fg]="#d3c6aa"

    # Title color for boxes
    theme[title]="#d3c6aa"

    # Highlight color for keyboard shortcuts
    theme[hi_fg]="#e67e80"

    # Background color of selected items
    theme[selected_bg]="#3d484d"

    # Foreground color of selected items
    theme[selected_fg]="#dbbc7f"

    # Color of inactive/disabled text
    theme[inactive_fg]="#2d353b"

    # Color of text appearing on top of graphs
    theme[graph_text]="#d3c6aa"

    # Misc colors for processes box
    theme[proc_misc]="#a7c080"

    # Cpu box outline color
    theme[cpu_box]="#3d484d"

    # Memory/disks box outline color
    theme[mem_box]="#3d484d"

    # Net up/down box outline color
    theme[net_box]="#3d484d"

    # Processes box outline color
    theme[proc_box]="#3d484d"

    # Box divider line and small boxes line color
    theme[div_line]="#3d484d"

    # Temperature graph colors
    theme[temp_start]="#a7c080"
    theme[temp_mid]="#dbbc7f"
    theme[temp_end]="#f85552"

    # CPU graph colors
    theme[cpu_start]="#a7c080"
    theme[cpu_mid]="#dbbc7f"
    theme[cpu_end]="#f85552"

    # Mem/Disk free meter
    theme[free_start]="#f85552"
    theme[free_mid]="#dbbc7f"
    theme[free_end]="#a7c080"

    # Mem/Disk cached meter
    theme[cached_start]="#7fbbb3"
    theme[cached_mid]="#83c092"
    theme[cached_end]="#a7c080"

    # Mem/Disk available meter
    theme[available_start]="#f85552"
    theme[available_mid]="#dbbc7f"
    theme[available_end]="#a7c080"

    # Mem/Disk used meter
    theme[used_start]="#a7c080"
    theme[used_mid]="#dbbc7f"
    theme[used_end]="#f85552"

    # Download graph colors
    theme[download_start]="#a7c080"
    theme[download_mid]="#83c092"
    theme[download_end]="#7fbbb3"

    # Upload graph colors
    theme[upload_start]="#dbbc7f"
    theme[upload_mid]="#e69875"
    theme[upload_end]="#e67e80"

    # Process box color gradient for threads, mem and cpu usage
    theme[process_start]="#a7c080"
    theme[process_mid]="#e67e80"
    theme[process_end]="#f85552"
  '';
}
