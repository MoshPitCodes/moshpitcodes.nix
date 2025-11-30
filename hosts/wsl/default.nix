{ pkgs, inputs, username, ... }:

{
  imports = [
    # Import NixOS-WSL module
    inputs.nixos-wsl.nixosModules.wsl

    # Import core modules
    ../../modules/core/default.nix

    # Import WSL-specific overrides to disable incompatible modules
    ../../modules/core/wsl-overrides.nix
  ];

  # WSL-specific configuration
  wsl = {
    enable = true;
    defaultUser = username;

    # Windows interoperability
    interop = {
      register = true;
      includePath = true;
    };

    # WSL configuration
    wslConf = {
      # Enable systemd in WSL
      boot = {
        systemd = true;
      };

      automount = {
        root = "/mnt";
        # Enable metadata support for proper permissions
        options = "metadata,umask=022,fmask=011";
        # Explicitly enable fstab mounting for Windows drives
        # NixOS-WSL defaults this to false when systemd is enabled, but we need it true
        mountFsTab = true;
      };

      network = {
        generateResolvConf = true;
        generateHosts = true;
      };

      interop = {
        enabled = true;
        appendWindowsPath = true;
      };

      gpu = {
        enabled = true;
      };
    };

    # Enable start menu launchers
    startMenuLaunchers = true;
  };

  # Enable Docker support in WSL
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Podman configuration (lightweight alternative to Docker)
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true; # Create docker alias for podman
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  # Enable SSH server for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Enable dbus - required for systemd user sessions
  services.dbus.enable = true;

  # Basic system settings
  networking.hostName = "nixos-wsl";
  system.stateVersion = "25.05";

  # User setup is handled by modules/core/user.nix

  # WSL-specific environment variables
  environment.sessionVariables = {
    # Help GUI applications work via WSLg
    DISPLAY = ":0";
    # Set XDG directories for WSL
    XDG_RUNTIME_DIR = "/run/user/$UID";
    # Disable Claude Code telemetry to avoid OTEL errors
    CLAUDE_CODE_ENABLE_TELEMETRY = "false";
    # Set OTEL protocol to work around Claude Code enterprise metrics bug
    OTEL_EXPORTER_OTLP_PROTOCOL = "http/protobuf";
  };

  # Additional packages useful in WSL
  environment.systemPackages = with pkgs; [
    wslu # Collection of WSL utilities
    wget
    curl
    git
  ];

  # Enable nix-command and flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable lingering for the default user so systemd user session starts automatically
  # This ensures home-manager services and user systemd units work properly
  systemd.tmpfiles.rules = [
    "f /var/lib/systemd/linger/${username} 0644 root root - -"
  ];

  # Start systemd user session on boot using systemd system service
  # This is necessary because WSL doesn't automatically start user sessions
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
  };

  # Ensure PAM is configured to start systemd user sessions
  security.pam.services.login.startSession = true;
  security.pam.services.sshd.startSession = true;
}
