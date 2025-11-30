{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      evince # pdf
      file-roller # archive
      gnome-text-editor # gedit
      gnome-keyring # keyring for credentials
      ssh-askpass-fullscreen # GUI SSH password prompt
    ];

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "pkcs11" ]; # Remove SSH component, use SSH agent instead
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
