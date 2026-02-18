# VM-specific overrides
# Disable laptop/bare-metal features that don't make sense in VMs
{ lib, ... }:
{
  # Disable Bluetooth (VMs don't need it)
  hardware.bluetooth.enable = lib.mkForce false;

  # Disable TLP power management
  services.tlp.enable = lib.mkForce false;

  # Disable power-profiles-daemon
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Override logind for VM (using new settings format)
  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkForce "ignore";
    HandleLidSwitchExternalPower = lib.mkForce "ignore";
    HandlePowerKey = lib.mkForce "ignore";
  };
}
