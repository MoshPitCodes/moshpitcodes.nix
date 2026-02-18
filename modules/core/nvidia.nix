# Nvidia proprietary driver configuration for RTX 4070Ti Super
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # For Steam/Wine

      # Nvidia-specific packages
      extraPackages = with pkgs; [
        nvidia-vaapi-driver # VAAPI support for video acceleration
        libva-utils
        vulkan-loader
        vulkan-validation-layers
      ];
    };

    nvidia = {
      # Modesetting is required for Wayland
      modesetting.enable = true;

      # Nvidia power management (experimental, can cause sleep/wake issues)
      # Disabled for desktop use
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (kernel driver only, not user-space)
      # Alpha quality for RTX 40 series as of 2024-2025, use `false` for stability
      open = false;

      # Enable the Nvidia settings menu
      nvidiaSettings = true;

      # Use production drivers for maximum stability
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  # Nvidia kernel modules
  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  # Nvidia driver parameters for modesetting (required for Wayland)
  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=1
  '';

  # Environment variables for Nvidia + Wayland/Hyprland
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1"; # Uncomment if cursor issues occur
  };

  # Nvidia utilities
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring
  ];
}
