# Discord
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    discord
  ];

  # Discord settings
  xdg.configFile."discord/settings.json".text = builtins.toJSON {
    SKIP_HOST_UPDATE = true;
  };
}
