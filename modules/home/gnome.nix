{ pkgs, ... }:
{
  home.packages = with pkgs; [
    evince # pdf
    file-roller # archive
    gnome-text-editor # gedit
  ];

  # GNOME Keyring manages credentials (secrets) and SSH agent (gcr-ssh-agent)
  # SSH_ASKPASS uses seahorse (configured in hyprland/variables.nix)
  # AddKeysToAgent in openssh.nix auto-loads keys on first use
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
