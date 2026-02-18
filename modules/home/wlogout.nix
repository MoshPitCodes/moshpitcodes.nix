# Wlogout power menu configuration (Everforest colors - inspired by dianaw353)
{ pkgs, ... }:
let
  # Custom icons path
  iconsPath = ../../assets/wlogout/icons;
in
{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "${pkgs.hyprlock}/bin/hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "sleep 1; ${pkgs.systemd}/bin/systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "${pkgs.hyprland}/bin/hyprctl dispatch exit";
        text = "Exit";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "${pkgs.systemd}/bin/systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "${pkgs.systemd}/bin/systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "${pkgs.systemd}/bin/systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
    style = ''
      /*
       * Wlogout theme - Everforest colors
       * Inspired by dianaw353/dotfiles
       */

      * {
        font-family: "FiraCode Nerd Font", FontAwesome, sans-serif;
        background-image: none;
        transition: 20ms;
        box-shadow: none;
      }

      window {
        background-color: rgba(45, 53, 59, 0.95); /* Everforest background with transparency */
      }

      button {
        color: #d3c6aa; /* Everforest foreground */
        font-size: 20px;

        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;

        border-style: solid;
        background-color: rgba(45, 53, 59, 0.3);
        border: 3px solid #d3c6aa; /* Everforest foreground */

        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
      }

      button:focus,
      button:active,
      button:hover {
        color: #a7c080; /* Everforest green */
        background-color: rgba(45, 53, 59, 0.5);
        border: 3px solid #a7c080; /* Everforest green */
      }

      /*
       * Button icons
       */

      #lock {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${iconsPath}/lock.png"));
      }

      #logout {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${iconsPath}/logout.png"));
      }

      #suspend {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${iconsPath}/suspend.png"));
      }

      #hibernate {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${iconsPath}/hibernate.png"));
      }

      #shutdown {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${iconsPath}/shutdown.png"));
      }

      #reboot {
        margin: 10px;
        border-radius: 20px;
        background-image: image(url("${iconsPath}/reboot.png"));
      }
    '';
  };
}
