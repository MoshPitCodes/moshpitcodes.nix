# micro text editor (TokyoNight Storm theme)
{ ... }:
{
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "tokyonight";
      autoindent = true;
      cursorline = true;
      mkparents = true;
      rmtrailingws = true;
      savecursor = true;
      saveundo = true;
      scrollbar = true;
      tabsize = 4;
      tabstospaces = true;
      ruler = true;
      colorcolumn = 80;
      ft = {
        nix = {
          tabsize = 2;
        };
      };
    };
  };

  # Custom TokyoNight Storm colorscheme for micro
  xdg.configFile."micro/colorschemes/tokyonight.micro".text = ''
    color-link default "#c0caf5,#24283b"
    color-link comment "#545c7e,#24283b"
    color-link comment.bright "#a9b1d6,#24283b"
    color-link identifier "#7dcfff"
    color-link identifier.class "#7dcfff,bold"
    color-link identifier.var "#c0caf5"
    color-link constant "#bb9af7"
    color-link constant.number "#bb9af7"
    color-link constant.string "#9ece6a"
    color-link constant.string.char "#9ece6a"
    color-link constant.bool "#bb9af7"
    color-link statement "#7aa2f7"
    color-link symbol "#c0caf5"
    color-link symbol.operator "#ff9e64"
    color-link symbol.brackets "#c0caf5"
    color-link symbol.tag "#7aa2f7"
    color-link preproc "#bb9af7"
    color-link type "#73daca"
    color-link type.keyword "#7aa2f7"
    color-link special "#e0af68"
    color-link underlined "#7dcfff,underline"
    color-link error "#f7768e,bold"
    color-link todo "#e0af68,bold"
    color-link statusline "#c0caf5,#1f2335"
    color-link tabbar "#a9b1d6,#1f2335"
    color-link indent-char "#414868"
    color-link line-number "#414868,#24283b"
    color-link current-line-number "#c0caf5,#292e42"
    color-link gutter-error "#f7768e"
    color-link gutter-warning "#e0af68"
    color-link cursor-line "#292e42"
    color-link color-column "#292e42"
    color-link diff-added "#9ece6a"
    color-link diff-modified "#e0af68"
    color-link diff-deleted "#f7768e"
    color-link selection "#c0caf5,#292e42"
    color-link hlsearch "#24283b,#e0af68"
    color-link matchingbrace "#e0af68,underline"
  '';

  # Keybindings
  xdg.configFile."micro/bindings.json".text = builtins.toJSON {
    "CtrlUp" = "CursorUp,CursorUp,CursorUp,CursorUp,CursorUp";
    "CtrlDown" = "CursorDown,CursorDown,CursorDown,CursorDown,CursorDown";
    "CtrlShiftUp" = "ScrollUp,ScrollUp,ScrollUp,ScrollUp,ScrollUp";
    "CtrlShiftDown" = "ScrollDown,ScrollDown,ScrollDown,ScrollDown,ScrollDown";
    "CtrlBackspace" = "DeleteWordLeft";
    "CtrlDelete" = "DeleteWordRight";
  };

  # Assembly comment syntax
  xdg.configFile."micro/syntax/asm.yaml".text = ''
    filetype: asm
    detect:
      filename: "\\.(asm|s|S)$"
    rules:
      - comment:
          start: ";"
          end: "$"
  '';
}
