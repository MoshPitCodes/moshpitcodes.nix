# fzf - fuzzy finder with fd/bat/eza integration (Everforest theme)
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

    # Everforest color theme
    defaultOptions = [
      "--color=fg:-1,fg+:#d3c6aa,bg:-1,bg+:#3d484d"
      "--color=hl:#a7c080,hl+:#a7c080,info:#7fbbb3,marker:#dbbc7f"
      "--color=prompt:#e67e80,spinner:#83c092,pointer:#d699b6,header:#7fbbb3"
      "--color=border:#475258,label:#9da9a0,query:#d3c6aa"
      "--border='double' --border-label='' --preview-window='border-sharp' --prompt='> '"
      "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
      "--info='right'"
    ];
  };
}
