{ lib, ... }:

{
  # This module disables laptop-specific and bare-metal features for VM configurations
  # Import this in VM host configurations to prevent conflicts

  # Disable Bluetooth (VMs typically don't need it)
  hardware.bluetooth.enable = lib.mkForce false;

  # Override Intel graphics packages with empty list for VMs
  hardware.graphics.extraPackages = lib.mkForce [ ];

  # Override laptop-specific logind settings for VMs
  services.logind.extraConfig = lib.mkForce "";
  services.logind.settings = {
    Login = {
      HandlePowerKey = lib.mkForce "poweroff";
      HandleLidSwitch = lib.mkForce "ignore";
      HandleLidSwitchExternalPower = lib.mkForce "ignore";
    };
  };

  # Disable TLP if it exists (power management not needed in VMs)
  services.tlp.enable = lib.mkForce false;

  # Disable laptop-specific power profiles if they exist
  services.power-profiles-daemon.enable = lib.mkDefault false;
}
