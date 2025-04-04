{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprpaper
    # swww
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    hyprpicker
    grim
    slurp
    wl-clip-persist
    cliphist
    wf-recorder
    glib
    wayland
    direnv
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    extraConfig = ''
      # Input settings
      input {
        follow_mouse = 1
        sensitivity = 0.0
        accel_profile = flat
      }

      # Add other Hyprland config sections here
    '';

    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # Nvidia patches no longer needed
    # enableNvidiaPatches = false;
    systemd.enable = true;
  };
}
