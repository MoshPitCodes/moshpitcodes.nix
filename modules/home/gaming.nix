# Gaming: CLI games and utilities
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # CLI games
    vitetris
    nethack

    # Gaming utilities
    ckan # Kerbal Space Program mod manager
  ];
}
