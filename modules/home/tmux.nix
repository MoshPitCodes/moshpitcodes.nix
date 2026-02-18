# Tmux terminal multiplexer configuration
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 10000;
    baseIndex = 1;
    mouse = true;
    prefix = "C-a";
    keyMode = "vi";

    extraConfig = ''
      # Unbind default prefix
      unbind C-b

      # Pane base index
      set -g pane-base-index 1

      # Sensible split bindings
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Vi-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

      # Osaka Jade status bar
      set -g status-style "bg=#11221C,fg=#e6d8ba"
      set -g status-left-length 30
      set -g status-right-length 50
      set -g status-left "#[bg=#71CEAD,fg=#11221C,bold] #S #[default] "
      set -g status-right "#[fg=#e6d8ba] %Y-%m-%d #[fg=#71CEAD]| #[fg=#e6d8ba]%H:%M "

      # Window status
      set -g window-status-format "#[fg=#214237] #I:#W "
      set -g window-status-current-format "#[bg=#71CEAD,fg=#11221C,bold] #I:#W "
      set -g window-status-separator ""

      # Pane borders
      set -g pane-border-style "fg=#214237"
      set -g pane-active-border-style "fg=#71CEAD"

      # Message style
      set -g message-style "bg=#11221C,fg=#e6d8ba"
    '';
  };
}
