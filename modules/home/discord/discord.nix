{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Install official Discord client
    discord

    # Install DiscoCSS for CSS injection
    discocss
  ];

  # Copy your gruvbox theme to the DiscoCSS themes directory
  xdg.configFile."discords-css/themes/gruvbox.theme.css".source = ./gruvbox.css;

  # Basic DiscoCSS configuration to apply your theme
  xdg.configFile."discords-css/config.json".text = ''
    {
      "themesFolder": "themes",
      "loadThemes": ["gruvbox.theme.css"],
      "notifications": true,
      "autoReload": true
    }
  '';
}
