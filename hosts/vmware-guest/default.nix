# VMware Guest host configuration
{
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./nas-mount.nix
    ./hgfs-mount.nix
    ../../modules/core
    ../../modules/core/vm-overrides.nix
  ];

  # Hostname
  networking.hostName = "vmware-guest";

  # VMware-specific boot configuration
  boot = {
    # Override kernel modules for VMware
    kernelModules = lib.mkForce [
      "vmw_vsock_vmci_transport"
      "vmw_balloon"
      "vmwgfx"
    ];

    # Blacklist Intel GPU modules (not needed in VM)
    blacklistedKernelModules = [
      "i915"
      "intel_agp"
    ];

    # Set proper framebuffer resolution for VMware (1920x1080)
    kernelParams = [
      "video=1920x1080"
    ];

    # Enable early KMS for VMware to get proper resolution at boot
    initrd.kernelModules = [ "vmwgfx" ];
  };

  # Enable VMware guest additions
  virtualisation.vmware.guest = {
    enable = true;
    headless = false;
  };

  # VMware graphics driver
  services.xserver.videoDrivers = [ "vmware" ];

  # Hardware acceleration for VMware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Environment variables for Wayland in VM
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    LIBVA_DRIVER_NAME = "vmwgfx";
    # Force software OpenGL for GTK/GL apps (vmwgfx has limited GL support)
    LIBGL_ALWAYS_SOFTWARE = "1";
  };

  # SSH for remote access
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ username ];
      PermitRootLogin = "no";
    };
  };

  # Open firewall for SSH
  networking.firewall.allowedTCPPorts = [ 22 ];
}
