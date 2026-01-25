{ lib, ... }:

{
  # This module disables laptop-specific and bare-metal features for VM configurations
  # Import this in VM host configurations to prevent conflicts

  hardware = {
    # Disable Bluetooth (VMs typically don't need it)
    bluetooth.enable = lib.mkForce false;

    # Override Intel graphics packages with empty list for VMs
    graphics.extraPackages = lib.mkForce [ ];
  };

  services = {
    # Override laptop-specific logind settings for VMs
    logind.settings = {
      Login = {
        HandlePowerKey = lib.mkForce "poweroff";
        HandleLidSwitch = lib.mkForce "ignore";
        HandleLidSwitchExternalPower = lib.mkForce "ignore";
      };
    };

    # Disable TLP if it exists (power management not needed in VMs)
    tlp.enable = lib.mkForce false;

    # Disable laptop-specific power profiles if they exist
    power-profiles-daemon.enable = lib.mkForce false;
  };
}
