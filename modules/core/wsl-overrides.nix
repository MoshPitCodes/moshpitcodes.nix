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

    # GPG agent: SSH support stays disabled (same as desktop).
    # GNOME Keyring handles SSH via gcr-ssh-agent on both desktop and WSL.
    # In WSL, keyring-wsl.nix starts the keyring daemon without graphical-session.target.
    # GPG cache timeouts (8 hours) are set in modules/core/program.nix for all hosts.
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

    # Add GNOME Keyring D-Bus service files so the secrets + SSH agent are
    # discoverable on the session bus (same packages the desktop has in services.nix)
    dbus.packages = with pkgs; [
      gcr_4
      gnome-keyring
    ];
  };

  # Unlock GNOME Keyring automatically at login via PAM
  # On desktop this happens through the display manager; in WSL we hook into
  # the login and sshd PAM stacks instead.
  security.pam.services = {
    login.enableGnomeKeyring = true;
    sshd.enableGnomeKeyring = true;
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
