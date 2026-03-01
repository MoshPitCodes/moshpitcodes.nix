# bat - cat replacement with syntax highlighting (TokyoNight Storm theme)
{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "tokyonight_storm";
    };
    themes = {
      tokyonight_storm = {
        src = pkgs.vimPlugins.tokyonight-nvim.src;
        file = "extras/sublime/tokyonight_storm.tmTheme";
      };
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
    ];
  };
}
