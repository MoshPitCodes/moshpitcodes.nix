_:
let
  custom = {
    font = "Maple Mono NF";
    font_size = "18px";
    font_weight = "bold";
    text_color = "#e0def4";
    background_0 = "#191724";
    background_1 = "#1f1d2e";
    border_color = "#6e6a86";
    red = "#eb6f92";
    green = "#9ccfd8";
    yellow = "#f6c177";
    blue = "#31748f";
    magenta = "#c4a7e7";
    cyan = "#9ccfd8";
    orange = "#f6c177";
    orange_bright = "#ebbcba";
    opacity = "1";
    indicator_height = "2px";
  };
in
{
  programs.waybar.style = with custom; ''
    * {
      border: none;
      border-radius: 0px;
      padding: 0;
      margin: 0;
      font-family: ${font};
      font-weight: ${font_weight};
      opacity: ${opacity};
      font-size: ${font_size};
    }

    window#waybar {
      background: #1f1d2e;
      border: 1px solid #6e6a86;
      border-radius: 5px;
    }

    tooltip {
      background: ${background_1};
      border: 1px solid ${border_color};
    }
    tooltip label {
      margin: 5px;
      color: ${text_color};
    }

    #workspaces {
      padding-left: 15px;
    }
    #workspaces button {
      color: ${yellow};
      padding-left:  5px;
      padding-right: 5px;
      margin-right: 10px;
    }
    #workspaces button.empty {
      color: ${text_color};
    }
    #workspaces button.active {
      color: ${orange_bright};
    }

    #clock {
      color: ${text_color};
    }

    #tray {
      margin-left: 10px;
      color: ${text_color};
    }
    #tray menu {
      background: ${background_1};
      border: 1px solid ${border_color};
      padding: 8px;
    }
    #tray menuitem {
      padding: 1px;
    }

    #pulseaudio, #network, #cpu, #memory, #disk, #battery, #language, #custom-notification {
      padding-left: 5px;
      padding-right: 5px;
      margin-right: 10px;
      color: ${text_color};
    }

    #pulseaudio, #language {
      margin-left: 15px;
    }

    #custom-notification {
      margin-left: 15px;
      padding-right: 2px;
      margin-right: 5px;
    }

    #custom-launcher {
      font-size: 20px;
      color: ${text_color};
      font-weight: bold;
      margin-left: 15px;
      padding-right: 10px;
    }
  '';
}
