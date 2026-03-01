# lazygit - terminal git UI (TokyoNight Storm theme)
{ pkgs, ... }:
{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      nerdFontsVersion: "3"
      theme:
        activeBorderColor:
          - "#73daca"
          - bold
        inactiveBorderColor:
          - "#414868"
        searchingActiveBorderColor:
          - "#e0af68"
          - bold
        optionsTextColor:
          - "#7dcfff"
        selectedLineBgColor:
          - "#292e42"
        cherryPickedCommitFgColor:
          - "#7aa2f7"
        cherryPickedCommitBgColor:
          - "#292e42"
        markedBaseCommitFgColor:
          - "#7dcfff"
        markedBaseCommitBgColor:
          - "#292e42"
        unstagedChangesColor:
          - "#f7768e"
        defaultFgColor:
          - "#c0caf5"
  '';
}
