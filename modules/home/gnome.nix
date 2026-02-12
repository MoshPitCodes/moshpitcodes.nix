{ pkgs, ... }:
{
  home.packages = with pkgs; [
    evince # pdf
    file-roller # archive
    gnome-text-editor # gedit
  ];

  # GNOME Keyring: secrets + SSH agent (unified across desktop and WSL)
  #
  # Desktop: home-manager's services.gnome-keyring starts via graphical-session-pre.target
  #          (triggered by Hyprland). SSH_ASKPASS uses seahorse (hyprland/variables.nix).
  # WSL:    keyring-wsl.nix starts the daemon via a plain systemd user service.
  #         SSH_ASKPASS uses seahorse via WSLg (default.wsl.nix).
  #
  # Both use git-credential-libsecret (git.nix) and AddKeysToAgent (openssh.nix).
  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  dconf.settings = {
    "org/gnome/TextEditor" = {
      custom-font = "Maple Mono NF 15";
      highlight-current-line = true;
      indent-style = "space";
      restore-session = false;
      show-grid = false;
      show-line-numbers = true;
      show-right-margin = false;
      style-scheme = "builder-dark";
      style-variant = "dark";
      tab-width = "uint32 4";
      use-system-font = false;
      wrap-text = false;
    };
  };
}
