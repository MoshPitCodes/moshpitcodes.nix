# System services configuration
{ ... }:
{
  services = {
    # D-Bus
    dbus.enable = true;

    # GVFS for file manager functionality
    gvfs.enable = true;

    # Periodic SSD TRIM
    fstrim.enable = true;

    # Logind configuration (using new settings format)
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandlePowerKey = "suspend";
    };

    # GNOME Keyring
    gnome.gnome-keyring.enable = true;
  };
}
