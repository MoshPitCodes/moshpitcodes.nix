{ config, lib, pkgs, ... }:

{
  # WSL manages its own DNS resolution
  networking.nameservers = lib.mkForce [ ];

  # Enable DrvFs and 9p filesystem support for WSL drive mounting
  boot.supportedFilesystems = [ "drvfs" "9p" "9pnet_virtio" ];

  # Disable bootloader configuration - WSL doesn't use traditional bootloaders
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # Disable hardware-specific modules that are incompatible with WSL
  hardware.graphics.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  # Disable Hyprland and desktop environment
  programs.hyprland.enable = lib.mkForce false;
  programs.hyprland.xwayland.enable = lib.mkForce false;

  # Disable X server configuration
  services.xserver.enable = lib.mkForce false;
  services.displayManager.autoLogin.enable = lib.mkForce false;

  # Disable pipewire - WSL can use it but typically doesn't need it
  services.pipewire.enable = lib.mkForce false;
  services.pipewire.alsa.enable = lib.mkForce false;
  services.pipewire.pulse.enable = lib.mkForce false;
  services.pipewire.jack.enable = lib.mkForce false;
  # PulseAudio is mutually exclusive with PipeWire, disabling PipeWire is enough
  # hardware.pulseaudio.enable is handled by the audio module

  # Disable Steam and gaming-related packages
  programs.steam.enable = lib.mkForce false;

  # Disable Flatpak - not typically needed in WSL
  services.flatpak.enable = lib.mkForce false;

  # Disable virtualization - WSL itself is already virtualized
  # Docker can be enabled in the host config if needed (not forcing disable here)
  # virtualisation.docker.enable is controlled by the host config
  virtualisation.libvirtd.enable = lib.mkForce false;

  # Keep these enabled as they work fine in WSL:
  # - networking
  # - nix helper (nh)
  # - security settings
  # - basic services
  # - system settings
  # - user configuration
}
