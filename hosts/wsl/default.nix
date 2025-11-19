{ config, pkgs, inputs, ... }:

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
    defaultUser = "moshpitcodes";

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
        # Add uid/gid for proper permissions and metadata support
        options = "metadata,uid=1000,gid=100,umask=022,fmask=011";
      };

      network = {
        generateResolvConf = true;
        generateHosts = true;
      };

      interop = {
        enabled = true;
        appendWindowsPath = true;
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

  # Basic system settings
  networking.hostName = "nixos-wsl";
  system.stateVersion = "25.05";

  # Ensure proper user setup
  users.users.moshpitcodes = {
    isNormalUser = true;
    home = "/home/moshpitcodes";
  };

  # WSL-specific environment variables
  environment.sessionVariables = {
    # Help GUI applications work via WSLg
    DISPLAY = ":0";
    # Set XDG directories for WSL
    XDG_RUNTIME_DIR = "/run/user/$UID";
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
}
