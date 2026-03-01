# lazygit - terminal git UI (Everforest theme)
{ pkgs, ... }:
{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      nerdFontsVersion: "3"
      theme:
        activeBorderColor:
          - "#83c092"
          - bold
        inactiveBorderColor:
          - "#859289"
        searchingActiveBorderColor:
          - "#dbbc7f"
          - bold
        optionsTextColor:
          - "#7fbbb3"
        selectedLineBgColor:
          - "#3d484d"
        cherryPickedCommitFgColor:
          - "#7fbbb3"
        cherryPickedCommitBgColor:
          - "#3d484d"
        markedBaseCommitFgColor:
          - "#7fbbb3"
        markedBaseCommitBgColor:
          - "#3d484d"
        unstagedChangesColor:
          - "#e67e80"
        defaultFgColor:
          - "#d3c6aa"
  '';
}
