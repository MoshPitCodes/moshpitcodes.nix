{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "rose-pine";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      # batgrep  # Moved to environment.systemPackages to avoid test failures
      # batdiff
    ];
    themes = {
      rose-pine = {
        src = pkgs.fetchFromGitHub {
          owner = "rose-pine";
          repo = "tm-theme";
          rev = "c4235f9a65fd180ac0f5e4396e3a86e21a0884ec";
          sha256 = "sha256-jji8WOKDkzAq8K+uSZAziMULI8Kh7e96cBRimGvIYKY=";
        };
        file = "dist/themes/rose-pine.tmTheme";
      };
    };
  };
}
