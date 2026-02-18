# Starship prompt configuration (Everforest colors + nerd font symbols preset)
# Config stored in starship.toml to preserve Nerd Font icons from nixfmt stripping
{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Source the TOML directly so nixfmt can't strip the 3-byte Nerd Font icons
  xdg.configFile."starship.toml".source = ./starship.toml;
}
