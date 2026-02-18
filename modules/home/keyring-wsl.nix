# WSL gnome-keyring via systemd user service
# On desktop, gnome-keyring starts via graphical-session-pre.target
# On WSL, we start it explicitly via a plain systemd service
{ pkgs, ... }:
{
  systemd.user.services.gnome-keyring-wsl = {
    Unit = {
      Description = "GNOME Keyring daemon (WSL)";
      After = [ "default.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets,ssh";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "default.target" ];
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
}
