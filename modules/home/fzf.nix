_:
{
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

    ## Theme - Rose Pine
    defaultOptions = [
      "--color=fg:-1,fg+:#e0def4,bg:-1,bg+:#26233a"
      "--color=hl:#eb6f92,hl+:#eb6f92,info:#908caa,marker:#f6c177"
      "--color=prompt:#eb6f92,spinner:#9ccfd8,pointer:#c4a7e7,header:#31748f"
      "--color=border:#6e6a86,label:#908caa,query:#e0def4"
      "--border='double' --border-label='' --preview-window='border-sharp' --prompt='> '"
      "--marker='>' --pointer='>' --separator='─' --scrollbar='│'"
      "--info='right'"
    ];
  };
}
