{ pkgs, ... }:
{
  home.packages = with pkgs; [ lazygit ];

  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      border: single
      # Rose Pine theme
      theme:
        activeBorderColor:
          - "#9ccfd8" # foam
          - bold
        inactiveBorderColor:
          - "#6e6a86" # muted
        optionsTextColor:
          - "#31748f" # pine
        selectedLineBgColor:
          - "#26233a" # highlight
        selectedRangeBgColor:
          - "#26233a" # highlight
        cherryPickedCommitBgColor:
          - "#c4a7e7" # iris
        cherryPickedCommitFgColor:
          - "#e0def4" # text
        unstagedChangesColor:
          - "#eb6f92" # love
        defaultFgColor:
          - "#e0def4" # text
        searchingActiveBorderColor:
          - "#f6c177" # gold
  '';
}
