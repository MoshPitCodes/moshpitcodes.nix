# fzf - fuzzy finder with fd/bat/eza integration (TokyoNight Storm theme)
_: {
  programs.fzf = {
    enable = true;

    enableZshIntegration = true;
    tmux.enableShellIntegration = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
    ];
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --color=always {} | head -200'"
    ];

    # TokyoNight Storm color theme
    defaultOptions = [
      "--color=fg:-1,fg+:#c0caf5,bg:-1,bg+:#292e42"
      "--color=hl:#9ece6a,hl+:#9ece6a,info:#7aa2f7,marker:#e0af68"
      "--color=prompt:#f7768e,spinner:#73daca,pointer:#bb9af7,header:#7aa2f7"
      "--color=border:#414868,label:#545c7e,query:#c0caf5"
      "--border='double' --border-label='' --preview-window='border-sharp' --prompt='> '"
      "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
      "--info='right'"
    ];
  };
}
