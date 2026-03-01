# bat - cat replacement with syntax highlighting (Everforest theme)
{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "base16";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
    ];
  };
}
