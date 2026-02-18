# WSL-specific overrides - disable desktop/audio/graphics features
{ lib, ... }:
{
  # No hardware graphics in WSL
  hardware.graphics.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  # No display manager
  services.greetd.enable = lib.mkForce false;

  # No audio stack
  services.pipewire.enable = lib.mkForce false;
  security.rtkit.enable = lib.mkForce false;

  # No power management
  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkForce "ignore";
    HandleLidSwitchExternalPower = lib.mkForce "ignore";
    HandlePowerKey = lib.mkForce "ignore";
  };
}
