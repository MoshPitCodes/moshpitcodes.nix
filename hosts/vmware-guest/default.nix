{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
    ./../../modules/core/vm-overrides.nix
  ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable VMware guest additions
  virtualisation.vmware.guest.enable = true;

  # Since we're using Wayland/Hyprland, set headless to false
  virtualisation.vmware.guest.headless = false;

  # VMware-specific graphics configuration
  services.xserver.videoDrivers = [ "vmware" ];

  # Hardware acceleration for VMware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Override Intel graphics modules from core config
  boot.kernelModules = lib.mkForce [ "vmw_vsock_vmci_transport" "vmw_balloon" "vmwgfx" ];
  boot.blacklistedKernelModules = [ "i915" "intel_agp" ];

  # Hyprland environment variables for VM compatibility
  environment.sessionVariables = {
    # Disable hardware cursors in Wayland for better VM compatibility
    WLR_NO_HARDWARE_CURSORS = "1";
    # Allow software rendering as fallback
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    # VMware 3D acceleration
    LIBVA_DRIVER_NAME = "vmwgfx";
  };

  # Network configuration for VMware
  # networking.hostName = "nixos-vmware"; # already configured in flake.nix
  networking.networkmanager.enable = true;

  # allow local remote access to make it easier to toy around with the system
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
    };
  };
}
