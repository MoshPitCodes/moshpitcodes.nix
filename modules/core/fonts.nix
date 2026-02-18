# System font configuration
{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      font-awesome
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "FiraCode Nerd Font"
          "Noto Serif"
        ];
        sansSerif = [
          "FiraCode Nerd Font"
          "Noto Sans"
        ];
        monospace = [ "FiraCode Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
