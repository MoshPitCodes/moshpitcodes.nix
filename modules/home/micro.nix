_:
{
  programs.micro = {
    enable = true;

    settings = {
      "colorscheme" = "rose-pine";
      "*.nix" = {
        "tabsize" = 2;
      };
      "*.ml" = {
        "tabsize" = 2;
      };
      "*.asm" = {
        "tabsize" = 2;
      };
      "ft:asm" = {
        "commenttype" = "; %s";
      };
      "makefile" = {
        "tabstospaces" = false;
      };
      "tabstospaces" = true;
      "tabsize" = 4;
      "mkparents" = true;
      "colorcolumn" = 80;
    };
  };

  xdg.configFile."micro/bindings.json".text = ''
    {
      "Ctrl-Up": "CursorUp,CursorUp,CursorUp,CursorUp,CursorUp",
      "Ctrl-Down": "CursorDown,CursorDown,CursorDown,CursorDown,CursorDown",
      "Ctrl-Backspace": "DeleteWordLeft",
      "Ctrl-Delete": "DeleteWordRight",
      "CtrlShiftUp": "ScrollUp,ScrollUp,ScrollUp,ScrollUp,ScrollUp",
      "CtrlShiftDown": "ScrollDown,ScrollDown,ScrollDown,ScrollDown,ScrollDown"
    }
  '';

  xdg.configFile."micro/colorschemes/rose-pine.micro".text = ''
    color-link default "#e0def4"
    color-link comment "#6e6a86"
    color-link symbol "#f6c177"
    color-link constant "#c4a7e7"
    color-link constant.string "#f6c177"
    color-link constant.string.char "#f6c177"
    color-link identifier "#9ccfd8"
    color-link statement "#eb6f92"
    color-link preproc "#eb6f92,235"
    color-link type "#eb6f92"
    color-link special "#f6c177"
    color-link underlined "underline #191724"
    color-link error "#eb6f92"
    color-link hlsearch "#191724,#f6c177"
    color-link diff-added "#9ccfd8"
    color-link diff-modified "#f6c177"
    color-link diff-deleted "#eb6f92"
    color-link gutter-error "#eb6f92"
    color-link gutter-warning "#f6c177"
    color-link line-number "#6e6a86"
    color-link current-line-number "#9ccfd8"
    color-link cursor-line "#26233a"
    color-link color-column "#6e6a86"
    color-link statusline "#9ccfd8"
    color-link tabbar "#e0def4,#26233a"
    color-link type "#ebbcba"
    color-link todo "#f6c177"
  '';
}
