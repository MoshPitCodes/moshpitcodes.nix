{
  lib,
  pkgs,
  config,
  ...
}:

{
  # WSL manages its own DNS resolution
  networking.nameservers = lib.mkForce [ ];

  # Make absolutely sure Wi-Fi is off in WSL
  networking.wireless.enable = lib.mkForce false;

  # (Optional but recommended)
  # Prevent wpa_supplicant from ever existing
  systemd.services.wpa_supplicant.enable = lib.mkForce false;

  boot = {
    # Enable DrvFs and 9p filesystem support for WSL drive mounting
    supportedFilesystems = [
      "drvfs"
      "9p"
      "9pnet_virtio"
    ];

    # Disable bootloader configuration - WSL doesn't use traditional bootloaders
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };

  hardware = {
    # Disable hardware-specific modules that are incompatible with WSL
    graphics.enable = lib.mkForce false;
    bluetooth.enable = lib.mkForce false;

    # Disable ALSA persistence - WSL doesn't have sound cards
    alsa.enablePersistence = lib.mkForce false;
  };

  programs = {
    # Disable Hyprland and desktop environment
    hyprland = {
      enable = lib.mkForce false;
      xwayland.enable = lib.mkForce false;
    };

    # Disable Steam and gaming-related packages
    steam.enable = lib.mkForce false;

    # Enable GPG agent SSH support in WSL
    # Desktop uses GNOME Keyring for SSH; WSL has no graphical session so
    # gnome-keyring never starts. GPG agent is already running, so we enable
    # its SSH socket as the SSH agent backend.
    # NixOS gnupg module automatically sets SSH_AUTH_SOCK via environment.extraInit.
    gnupg.agent = {
      enableSSHSupport = lib.mkForce true;
      # Use curses pinentry for CLI passphrase prompts (no GUI in WSL)
      pinentryPackage = lib.mkForce pkgs.pinentry-curses;
      settings = {
        # Cache SSH key passphrases for 8 hours (development sessions)
        default-cache-ttl-ssh = 28800;
        max-cache-ttl-ssh = 28800;
        # Cache GPG passphrases for 8 hours (commit signing)
        default-cache-ttl = 28800;
        max-cache-ttl = 28800;
        # Allow loopback pinentry for non-interactive contexts (scripts, IDEs)
        allow-loopback-pinentry = true;
      };
    };
  };

  services = {
    # Disable X server configuration
    xserver.enable = lib.mkForce false;
    displayManager.autoLogin.enable = lib.mkForce false;

    # Disable pipewire - WSL can use it but typically doesn't need it
    pipewire = {
      enable = lib.mkForce false;
      alsa.enable = lib.mkForce false;
      pulse.enable = lib.mkForce false;
      jack.enable = lib.mkForce false;
    };
    # PulseAudio is mutually exclusive with PipeWire, disabling PipeWire is enough
    # hardware.pulseaudio.enable is handled by the audio module

    # Disable Flatpak - not typically needed in WSL
    flatpak.enable = lib.mkForce false;
  };

  # Disable virtualization - WSL itself is already virtualized
  # Docker can be enabled in the host config if needed (not forcing disable here)
  # virtualisation.docker.enable is controlled by the host config
  virtualisation.libvirtd.enable = lib.mkForce false;

  # Keep these enabled as they work fine in WSL:
  # - networking
  # - security settings
  # - basic services
  # - system settings
  # - user configuration
}
