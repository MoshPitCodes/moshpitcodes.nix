# X server, keyboard layout, and input configuration
{ ... }:
{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "de";
    };

    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
    };
  };

  # Prevent getting stuck at shutdown
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
