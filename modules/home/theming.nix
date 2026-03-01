# GTK/Qt theming configuration (TokyoNight Storm theme)
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

  # TokyoNight Storm GTK color overrides
  xdg.configFile."gtk-3.0/gtk.css".text = ''
    @define-color accent_color #7aa2f7;
    @define-color accent_fg_color #c0caf5;
    @define-color accent_bg_color #1f2335;
    @define-color window_bg_color #1f2335;
    @define-color window_fg_color #c0caf5;
    @define-color headerbar_bg_color #1f2335;
    @define-color headerbar_fg_color #c0caf5;
    @define-color popover_bg_color #1f2335;
    @define-color popover_fg_color #c0caf5;
    @define-color view_bg_color #24283b;
    @define-color view_fg_color #c0caf5;
    @define-color card_bg_color #24283b;
    @define-color card_fg_color #c0caf5;
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_border_color @window_bg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
  '';

  xdg.configFile."gtk-4.0/gtk.css".text = ''
    @define-color accent_color #7aa2f7;
    @define-color accent_fg_color #c0caf5;
    @define-color accent_bg_color #1f2335;
    @define-color window_bg_color #1f2335;
    @define-color window_fg_color #c0caf5;
    @define-color headerbar_bg_color #1f2335;
    @define-color headerbar_fg_color #c0caf5;
    @define-color popover_bg_color #1f2335;
    @define-color popover_fg_color #c0caf5;
    @define-color view_bg_color #24283b;
    @define-color view_fg_color #c0caf5;
    @define-color card_bg_color #24283b;
    @define-color card_fg_color #c0caf5;
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_border_color @window_bg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
  '';
}
