{
  pkgs,
  inputs,
  username,
  ...
}:

{
  # NOTE: WSL dmesg will still show a warning about wsl-generator being world-writable.
  # This is an upstream Microsoft WSL issue - the generator is created by WSL init
  # with insecure permissions before NixOS runs. No local fix is possible.
  # See: https://github.com/microsoft/WSL/issues

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

    # FHS compatibility for WSL init
    # Fixes: execv(/bin/mount) failed with 2
    extraBin = [
      {
        src = "${pkgs.util-linux}/bin/mount";
        name = "mount";
      }
      {
        src = "${pkgs.util-linux}/bin/umount";
        name = "umount";
      }
    ];

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
        enabled = true; # Keep enabled for Windows Explorer access (\\wsl$\)
        root = "/mnt";
        mountFsTab = false; # Don't mount drives during early boot (use wsl-automount service)
        # Enable metadata support with explicit uid/gid for write access
        options = "metadata,uid=1000,gid=1000";
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

  # UGREEN NAS SMB/CIFS network mount
  # IMPORTANT: Replace "personal_folder" with your actual share name if different
  # To find available shares, run: nix-shell -p samba --run "smbclient -L //192.168.178.144 -U username"
  # Common UGREEN NAS share names: "Public", "personal_folder", "media", etc.
  fileSystems."/mnt/ugreen-nas" = {
    device = "//192.168.178.144/personal_folder";
    fsType = "cifs";
    options = [
      # Authentication
      "credentials=/root/.secrets/samba-credentials"
      "sec=ntlmssp" # Use NTLMv2 authentication

      # User/Group mapping - adjust UID/GID to match your user
      "uid=1000"
      "gid=100"

      # File and directory permissions
      "file_mode=0755"
      "dir_mode=0755"

      # Network and reliability options
      "x-systemd.automount" # Automount on access
      "x-systemd.idle-timeout=300" # Unmount after 5 minutes of inactivity
      "x-systemd.mount-timeout=30" # Timeout for mount attempts
      "x-systemd.requires=network-online.target" # Wait for network
      "noauto" # Don't mount at boot, use automount instead

      # Performance and compatibility
      "vers=3.0" # SMB protocol version (3.0, supports 2.0, 2.1, 3.0)
      "cache=loose" # Better performance, less strict consistency
      "rsize=130048" # Read buffer size (128KB)
      "wsize=130048" # Write buffer size (128KB)

      # Reliability options
      "_netdev" # Network device, don't mount until network is up
      "nofail" # Don't fail boot if mount fails
    ];
  };

  # WSL-specific environment variables
  environment.sessionVariables = {
    # Help GUI applications work via WSLg
    DISPLAY = ":0";
    # Set XDG directories for WSL
    XDG_RUNTIME_DIR = "/run/user/1000";
    # Disable Claude Code telemetry to avoid OTEL errors
    CLAUDE_CODE_ENABLE_TELEMETRY = "false";
    # Set OTEL protocol to work around Claude Code enterprise metrics bug
    OTEL_EXPORTER_OTLP_PROTOCOL = "http/protobuf";
    # SSH_ASKPASS is set by home-manager (default.wsl.nix) to seahorse,
    # matching the desktop. WSLg provides the X11/Wayland forwarding.
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

      # FHS compatibility: timezone data for WSL init
      # Fixes: /usr/share/zoneinfo/Europe/Berlin not found
      "d /usr/share 0755 root root -"
      "L+ /usr/share/zoneinfo - - - - /etc/zoneinfo"

      # FHS compatibility: systemctl for WSL init
      # Partially fixes: popen(systemctl is-system-running) failed
      # Note: Early boot errors before systemd starts are unavoidable
      "d /usr/bin 0755 root root -"
      "L+ /usr/bin/systemctl - - - - /run/current-system/sw/bin/systemctl"
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
          ExecStart =
            let
              mountScript = pkgs.writeShellScript "wsl-mount-drives" ''
                # Wait for Plan 9 server to be ready
                sleep 2

                # Mount each Windows drive if not already mounted
                for drive in C D E F G; do
                  mnt="/mnt/$(echo $drive | tr '[:upper:]' '[:lower:]')"
                  if [ -d "$mnt" ] && ! ${pkgs.util-linux}/bin/mountpoint -q "$mnt"; then
                    ${pkgs.util-linux}/bin/mount -t drvfs "$drive:" "$mnt" -o metadata,uid=1000,gid=1000 2>/dev/null || true
                  fi
                done
              '';
            in
            "${mountScript}";
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
