# GTK/Qt theming configuration (Osaka Jade theme)
{ pkgs, ... }:
{
  gtk = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };
    theme = {
      name = "adw-gtk3-dark";
      # Use adw-gtk3 for proper GTK3/GTK4 dark theme support
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # Everforest GTK color overrides
  xdg.configFile."gtk-3.0/gtk.css".text = ''
    @define-color accent_color #D3C6AA;
    @define-color accent_fg_color #D3C6AA;
    @define-color accent_bg_color #232A2E;
    @define-color window_bg_color #232A2E;
    @define-color window_fg_color #D3C6AA;
    @define-color headerbar_bg_color #232A2E;
    @define-color headerbar_fg_color #D3C6AA;
    @define-color popover_bg_color #232A2E;
    @define-color popover_fg_color #D3C6AA;
    @define-color view_bg_color #2D353B;
    @define-color view_fg_color #D3C6AA;
    @define-color card_bg_color #2D353B;
    @define-color card_fg_color #D3C6AA;
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_border_color @window_bg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
  '';

  xdg.configFile."gtk-4.0/gtk.css".text = ''
    @define-color accent_color #D3C6AA;
    @define-color accent_fg_color #D3C6AA;
    @define-color accent_bg_color #232A2E;
    @define-color window_bg_color #232A2E;
    @define-color window_fg_color #D3C6AA;
    @define-color headerbar_bg_color #232A2E;
    @define-color headerbar_fg_color #D3C6AA;
    @define-color popover_bg_color #232A2E;
    @define-color popover_fg_color #D3C6AA;
    @define-color view_bg_color #2D353B;
    @define-color view_fg_color #D3C6AA;
    @define-color card_bg_color #2D353B;
    @define-color card_fg_color #D3C6AA;
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_border_color @window_bg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
  '';
}
