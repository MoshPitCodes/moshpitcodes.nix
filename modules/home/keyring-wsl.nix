{ pkgs, ... }:
{
  # GNOME Keyring for WSL - provides the same secrets + SSH agent as desktop
  #
  # On desktop, home-manager's services.gnome-keyring starts the keyring via
  # graphical-session-pre.target (triggered by Hyprland) and installs the
  # gcr-ssh-agent socket/service units. In WSL there is no graphical session,
  # so we replicate both pieces manually:
  #
  #   1. gnome-keyring-daemon  - secrets component (org.freedesktop.secrets)
  #   2. gcr-ssh-agent         - SSH agent at $XDG_RUNTIME_DIR/gcr/ssh
  #
  # This gives WSL the same D-Bus secrets service and SSH socket as desktop:
  #   - git-credential-libsecret  (same as desktop)
  #   - SSH_AUTH_SOCK=gcr/ssh      (same as desktop)

  home.packages = with pkgs; [
    gnome-keyring
    libsecret # secret-tool CLI for debugging
    gcr_4 # gcr-ssh-agent (SSH agent component, v4+)
    seahorse # GUI for managing keyring (works via WSLg)
  ];

  # -- 1. GNOME Keyring daemon (secrets) ------------------------------------
  # Type=forking because gnome-keyring-daemon daemonizes itself.
  # Only the "secrets" component is needed here; SSH is handled by gcr-ssh-agent.
  systemd.user.services.gnome-keyring-daemon = {
    Unit = {
      Description = "GNOME Keyring (secrets)";
      After = [ "dbus.socket" ];
      Requires = [ "dbus.socket" ];
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # -- 2. gcr-ssh-agent (SSH) -----------------------------------------------
  # Socket-activated: the socket listens at $XDG_RUNTIME_DIR/gcr/ssh and
  # launches gcr-ssh-agent on first connection. ExecStartPost exports
  # SSH_AUTH_SOCK so all child processes of the user session inherit it.
  # This mirrors the upstream gcr socket/service units that the desktop gets
  # from home-manager's services.gnome-keyring.components = ["ssh"].
  systemd.user.sockets.gcr-ssh-agent = {
    Unit = {
      Description = "GCR ssh-agent wrapper";
    };
    Socket = {
      Priority = 6;
      Backlog = 5;
      ListenStream = "%t/gcr/ssh";
      ExecStartPost = "-${pkgs.systemd}/bin/systemctl --user set-environment SSH_AUTH_SOCK=%t/gcr/ssh";
      DirectoryMode = "0700";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };

  systemd.user.services.gcr-ssh-agent = {
    Unit = {
      Description = "GCR ssh-agent wrapper";
      Requires = [ "gcr-ssh-agent.socket" ];
    };
    Service = {
      Type = "simple";
      StandardError = "journal";
      Environment = "SSH_AUTH_SOCK=%t/gcr/ssh";
      ExecStart = "${pkgs.gcr_4}/libexec/gcr-ssh-agent --base-dir %t/gcr";
      Restart = "on-failure";
    };
    Install = {
      Also = [ "gcr-ssh-agent.socket" ];
      WantedBy = [ "default.target" ];
    };
  };
}
