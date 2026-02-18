# SwayNotificationCenter configuration (Everforest colors)
{ pkgs, ... }:
{
  xdg.configFile."swaync/config.json".text = builtins.toJSON {
    "$schema" = "/etc/xdg/swaync/configSchema.json";
    positionX = "right";
    positionY = "top";
    control-center-width = 360;
    notification-window-width = 360;
    notification-icon-size = 48;
    notification-body-image-height = 100;
    notification-body-image-width = 200;
    timeout = 5;
    timeout-low = 3;
    timeout-critical = 0;
    fit-to-screen = true;
    widgets = [
      "title"
      "dnd"
      "notifications"
    ];
    widget-config = {
      title = {
        text = "Notifications";
        clear-all-button = true;
        button-text = "Clear";
      };
      dnd = {
        text = "Do Not Disturb";
      };
    };
  };

  xdg.configFile."swaync/style.css".text = ''
    * {
      font-family: "FiraCode Nerd Font";
      font-size: 13px;
    }

    .control-center {
      background: rgba(45, 53, 59, 0.95);
      border-radius: 5px;
      border: 2px solid #3d484d;
      margin: 10px;
      padding: 10px;
    }

    .notification-row {
      outline: none;
    }

    .notification {
      border-radius: 5px;
      margin: 5px 0px;
      padding: 0px;
      background: #3d484d;
      border: 1px solid #3d484d;
    }

    .notification-content {
      padding: 10px;
    }

    .close-button {
      background: #a7c080;
      color: #2d353b;
      border-radius: 50%;
      padding: 2px;
      margin: 5px;
    }

    .notification-default-action:hover {
      background: #3d484d;
    }

    .widget-title {
      color: #d3c6aa;
      font-weight: bold;
      font-size: 16px;
      margin: 5px 10px;
    }

    .widget-title button {
      background: #a7c080;
      color: #2d353b;
      border-radius: 5px;
      padding: 4px 12px;
      border: none;
    }

    .widget-dnd {
      color: #d3c6aa;
      margin: 5px 10px;
    }

    .widget-dnd > switch {
      border-radius: 5px;
      background: #3d484d;
    }

    .widget-dnd > switch:checked {
      background: #a7c080;
    }
  '';
}
