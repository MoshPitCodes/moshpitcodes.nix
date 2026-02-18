# Desktop-specific overrides - prevent sleep/hibernation
{ lib, ... }:
{
  # Override logind power management for desktop
  services.logind.settings.Login = {
    HandlePowerKey = lib.mkForce "ignore";
    HandleLidSwitch = lib.mkForce "ignore";
    HandleLidSwitchExternalPower = lib.mkForce "ignore";
  };
}
