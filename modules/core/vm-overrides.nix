{ lib, ... }:

{
  # This module disables laptop-specific and bare-metal features for VM configurations
  # Import this in VM host configurations to prevent conflicts

  # Disable Bluetooth (VMs typically don't need it)
  hardware.bluetooth.enable = lib.mkForce false;

  # Override Intel graphics packages with empty list for VMs
  hardware.graphics.extraPackages = lib.mkForce [ ];

  # Disable laptop-specific logind settings
  services.logind.lidSwitch = lib.mkForce "ignore";
  services.logind.lidSwitchDocked = lib.mkForce "ignore";
  services.logind.lidSwitchExternalPower = lib.mkForce "ignore";

  # Allow power button to work normally in VM (useful for clean shutdown)
  services.logind.extraConfig = ''
    HandlePowerKey=poweroff
    HandleLidSwitch=ignore
    HandleLidSwitchExternalPower=ignore
  '';

  # Disable TLP if it exists (power management not needed in VMs)
  services.tlp.enable = lib.mkForce false;

  # Disable laptop-specific power profiles if they exist
  services.power-profiles-daemon.enable = lib.mkDefault false;
}
