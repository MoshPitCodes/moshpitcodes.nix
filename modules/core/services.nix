{ pkgs, ... }:
{
  services = {
    gvfs.enable = true;
    gnome = {
      tinysparql.enable = true;
      gnome-keyring.enable = true;
    };
    dbus.enable = true; # needed for gnome-keyring
    fstrim.enable = true; # needed for SSDs

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];
  };
  services.envfs.enable = true;
  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore

    # suspend when power button is long-pressed
    HandleLidSwitch=suspend

    # ignore closing the lid when docked
    HandleLidSwitchExternalPower=ignore

    # lidSwitch = ignore
    # lidSwitchDocked = ignore
    # lidSwitchExternalPower = ignore
  '';

}
