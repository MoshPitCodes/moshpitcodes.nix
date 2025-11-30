{ pkgs, inputs, username, ... }:

{
  imports = [
    # Import NixOS-WSL module
    inputs.nixos-wsl.nixosModules.wsl

    # Import core modules
    ../../modules/core/default.wsl.nix

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

  # Enable SSH server for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
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

  systemd = {
    # Enable lingering for the default user so systemd user session starts automatically
    # This ensures home-manager services and user systemd units work properly
    tmpfiles.rules = [
      "f /var/lib/systemd/linger/${username} 0644 root root - -"
    ];

    services = {
      # Start systemd user session on boot using systemd system service
      # This is necessary because WSL doesn't automatically start user sessions
      "user@" = {
        overrideStrategy = "asDropin";
      };

      # Workaround for WSL automount timing issue
      # The built-in automount sometimes fails to mount Windows drives on boot
      # This service ensures drives are mounted after systemd is fully running
      wsl-automount = {
        description = "Mount Windows drives via drvfs";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = let
            mountScript = pkgs.writeShellScript "wsl-mount-drives" ''
              # Wait for Plan 9 server to be ready
              sleep 2

              # Mount each Windows drive if not already mounted
              for drive in C D E F G; do
                mnt="/mnt/$(echo $drive | tr '[:upper:]' '[:lower:]')"
                if [ -d "$mnt" ] && ! ${pkgs.util-linux}/bin/mountpoint -q "$mnt"; then
                  ${pkgs.util-linux}/bin/mount -t drvfs "$drive:" "$mnt" -o metadata,umask=022,fmask=011 2>/dev/null || true
                fi
              done
            '';
          in "${mountScript}";
        };
      };
    };
  };

  # Ensure PAM is configured to start systemd user sessions
  security.pam.services = {
    login.startSession = true;
    sshd.startSession = true;
  };
}
