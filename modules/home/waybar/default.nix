# Waybar status bar configuration (Everforest theme)
{
  pkgs,
  lib,
  host,
  ...
}:
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 0;
        reload_style_on_change = true;

        modules-left = [
          "hyprland/workspaces"
          "custom/filemanager"
          "cpu"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "custom/easyeffects"
          "pulseaudio"
        ]
        ++ (lib.optionals (host != "vmware-guest") [
          "backlight"
          "battery"
        ])
        ++ [
          "network"
          "bluetooth"
          "tray"
          "custom/notification"
        ];

        "hyprland/workspaces" = {
          on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace r-1";
          on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace r+1";
          on-click = "activate";
          active-only = false;
          all-outputs = false;
          format = "{icon}";
          format-icons = {
            "1" = "●";
            "2" = "●";
            "3" = "●";
            "4" = "●";
            "5" = "●";
            "6" = "●";
            "7" = "●";
            "8" = "●";
            "9" = "●";
            active = "●";
            default = "○";
            urgent = "!";
          };
          # Host-specific persistent workspaces
          persistent-workspaces =
            if host == "desktop" then
              {
                # Desktop: 3-monitor setup
                "HDMI-A-1" = [
                  1
                  2
                  3
                ];
                "DP-1" = [
                  4
                  5
                  6
                ];
                "DP-2" = [
                  7
                  8
                  9
                ];
              }
            else if host == "laptop" then
              {
                # Laptop: Support both docked and undocked configurations
                # Docked: USB-C dock monitors (DP-5, DP-6, DP-7)
                "DP-5" = [
                  1
                  2
                  3
                ];
                "DP-6" = [
                  4
                  5
                  6
                ];
                "DP-7" = [
                  7
                  8
                  9
                ];
                # Undocked: Built-in display gets all workspaces
                "eDP-1" = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                  9
                ];
              }
            else
              {
                # VM/other hosts: single monitor, all workspaces
                "*" = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                  9
                ];
              };
        };

        clock = {
          format = "{:%H:%M:%S  -  %A, %d}";
          format-alt = "{:%d/%m/%Y}";
          tooltip = false;
          interval = 1;
        };

        cpu = {
          interval = 1;
          format = "  {icon0}{icon1}{icon2}{icon3} {usage:>2}%";
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          on-click = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.btop}/bin/btop";
        };

        "custom/easyeffects" = {
          format = "󰺢";
          on-click = "${pkgs.easyeffects}/bin/easyeffects";
          tooltip-format = "Audio Effects";
        };

        pulseaudio = {
          scroll-step = 1;
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            default = [
              ""
              ""
              " "
            ];
          };
          tooltip-format = "Playing at {volume}%";
          on-click = "${pkgs.pamixer}/bin/pamixer -t";
          on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        network = {
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰤮";
          tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          interval = 3;
          spacing = 1;
        };

        bluetooth = {
          format = "";
          format-disabled = "󰂲";
          format-connected = "";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };

        "custom/filemanager" = {
          format = "󰉋";
          on-click = "${pkgs.nautilus}/bin/nautilus --new-window";
          tooltip-format = "Open Filemanager";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon} ";
          format-icons = {
            notification = "<span foreground='#e67e80'>󰂞</span>";
            none = "<span foreground='#a7c080'>󰂚</span>";
            dnd-notification = "<span foreground='#e67e80'>󰂞</span>";
            dnd-none = "<span foreground='#a7c080'>󰂚</span>";
            inhibited-notification = "<span foreground='#e67e80'>󰂞</span>";
            inhibited-none = "<span foreground='#a7c080'>󰂚</span>";
            dnd-inhibited-notification = "<span foreground='#e67e80'>󰂞</span>";
            dnd-inhibited-none = "<span foreground='#a7c080'>󰂚</span>";
          };
          return-type = "json";
          exec-if = "which ${pkgs.swaynotificationcenter}/bin/swaync-client";
          exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
          on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
          on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
          escape = true;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [
            "󰃞"
            "󰃟"
            "󰃠"
          ];
          on-scroll-up = "${pkgs.swayosd}/bin/swayosd-client --brightness raise";
          on-scroll-down = "${pkgs.swayosd}/bin/swayosd-client --brightness lower";
        };
      };
    };

    style = ''
      /* Everforest color scheme */
      @define-color foreground #d3c6aa;
      @define-color background #2d353b;
      @define-color accent #dbbc7f;
      @define-color red #e67e80;
      @define-color green #a7c080;
      @define-color blue #7fbbb3;
      @define-color hover #3d484d;

      /* Global Styles */
      * {
        font-family: "FiraCode Nerd Font";
        font-size: 13px;
        min-height: 0;
        padding-right: 0px;
        padding-left: 0px;
        padding-bottom: 0px;
      }

      /* Waybar Container */
      #waybar {
        background: transparent;
        color: @foreground;
        margin: 0px 0px 2px 0px;
        font-weight: 500;
      }

      /* Left Modules - Individual Rounded Blocks */
      #workspaces,
      #custom-filemanager,
      #cpu {
        background-color: @background;
        padding: 0.3rem 0.7rem;
        margin: 5px 0px;
        border-radius: 6px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        min-width: 0;
        border: none;
        transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
      }

      #workspaces {
        padding: 2px;
        margin-left: 7px;
        margin-right: 5px;
      }

      #custom-filemanager {
        margin-right: 5px;
        color: @foreground;
      }

      #cpu {
        color: @foreground;
      }

      /* Hover effects for left modules */
      #custom-filemanager:hover,
      #cpu:hover {
        background-color: @hover;
      }

      #workspaces button {
        color: @foreground;
        border-radius: 5px;
        padding: 0.3rem 0.6rem;
        background: transparent;
        transition: all 0.2s ease-in-out;
        border: none;
        outline: none;
      }

      #workspaces button.active {
        color: @accent;
        background-color: rgba(219, 188, 127, 0.1);
        box-shadow: inset 0 0 0 1px rgba(219, 188, 127, 0.2);
      }

      #workspaces button:hover {
        background: @hover;
        color: @foreground;
      }

      /* Center Module - Clock */
      #clock {
        background-color: @background;
        padding: 0.3rem 0.7rem;
        margin: 5px 0px;
        border-radius: 6px;
        box-shadow: 0 1px 3px rgba(127, 187, 179, 0.2);
        min-width: 0;
        border: none;
        transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
        color: @blue;
        font-weight: 500;
      }

      #clock:hover {
        background-color: rgba(127, 187, 179, 0.1);
      }

      /* Right Modules - Seamless Bar */
      #custom-easyeffects,
      #pulseaudio,
      #backlight,
      #battery,
      #network,
      #bluetooth,
      #tray,
      #custom-notification {
        background-color: @background;
        padding: 0.3rem 0.7rem;
        margin: 5px 0px;
        border-radius: 0;
        box-shadow: none;
        min-width: 0;
        border: none;
        transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
        color: @foreground;
      }

      #custom-easyeffects:hover,
      #pulseaudio:hover,
      #backlight:hover,
      #battery:hover,
      #network:hover,
      #bluetooth:hover,
      #tray:hover,
      #custom-notification:hover {
        background-color: @hover;
      }

      #custom-easyeffects {
        margin-left: 5px;
        border-top-left-radius: 6px;
        border-bottom-left-radius: 6px;
      }

      #custom-notification {
        border-top-right-radius: 6px;
        border-bottom-right-radius: 6px;
        margin-right: 7px;
      }

      /* State-based colors */
      #network.disconnected {
        color: @red;
      }

      #bluetooth.on {
        color: @blue;
      }

      #bluetooth.connected {
        color: @accent;
      }

      #battery.charging,
      #battery.plugged {
        color: @green;
      }

      #battery.warning:not(.charging) {
        color: @accent;
      }

      #battery.critical:not(.charging) {
        color: @red;
      }

      /* Tooltip Styles */
      tooltip {
        background-color: @background;
        color: @foreground;
        padding: 5px 12px;
        margin: 5px 0px;
        border-radius: 6px;
        border: 1px solid rgba(255, 255, 255, 0.1);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        font-size: 12px;
      }
    '';
  };
}
