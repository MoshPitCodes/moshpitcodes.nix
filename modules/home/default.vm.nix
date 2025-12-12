{
  ...
}:
{
  # VM-specific home-manager configuration
  # This configuration is used for VMs (QEMU, VMware, etc.)
  #
  # Inherits all standard modules from default.nix and applies VM-specific overrides
  # Note: gaming.nix and retroarch.nix are included via default.nix
  #       If you need to disable them in VMs, use lib.mkForce in vm-overrides.nix

  imports = [
    ./default.nix
    ./hyprland/vm-overrides.nix
  ];
}
