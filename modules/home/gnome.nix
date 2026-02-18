# GNOME utilities and keyring
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    evince # PDF viewer
    file-roller # Archive manager
    gnome-text-editor

    # Nautilus preview and thumbnail support
    sushi # Quick preview (spacebar in Nautilus)
    webp-pixbuf-loader # WebP image preview
    poppler # PDF thumbnails
    ffmpegthumbnailer # Video thumbnails
    libheif # HEIF/HEIC image support
  ];

  # GNOME Keyring: secrets + SSH agent
  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
  };

  dconf.settings = {
    "org/gnome/TextEditor" = {
      custom-font = "FiraCode Nerd Font 15";
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

    # Nautilus (GNOME Files) settings
    "org/gnome/nautilus/preferences" = {
      show-image-thumbnails = "always"; # Generate thumbnails for images
      show-directory-item-counts = "always"; # Show folder item counts
      click-policy = "double"; # Double-click to open
    };

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "standard"; # Default icon size
    };
  };
}
