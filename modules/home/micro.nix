# micro text editor (Everforest theme)
{ ... }:
{
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "everforest";
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

  # Custom Everforest colorscheme for micro
  xdg.configFile."micro/colorschemes/everforest.micro".text = ''
    color-link default "#d3c6aa,#2d353b"
    color-link comment "#859289,#2d353b"
    color-link comment.bright "#9da9a0,#2d353b"
    color-link identifier "#83c092"
    color-link identifier.class "#83c092,bold"
    color-link identifier.var "#d3c6aa"
    color-link constant "#d699b6"
    color-link constant.number "#d699b6"
    color-link constant.string "#a7c080"
    color-link constant.string.char "#a7c080"
    color-link constant.bool "#d699b6"
    color-link statement "#e67e80"
    color-link symbol "#d3c6aa"
    color-link symbol.operator "#e69875"
    color-link symbol.brackets "#d3c6aa"
    color-link symbol.tag "#e67e80"
    color-link preproc "#dbbc7f"
    color-link type "#dbbc7f"
    color-link type.keyword "#e67e80"
    color-link special "#7fbbb3"
    color-link underlined "#7fbbb3,underline"
    color-link error "#e67e80,bold"
    color-link todo "#dbbc7f,bold"
    color-link statusline "#d3c6aa,#3d484d"
    color-link tabbar "#d3c6aa,#3d484d"
    color-link indent-char "#475258"
    color-link line-number "#859289,#2d353b"
    color-link current-line-number "#d3c6aa,#3d484d"
    color-link gutter-error "#e67e80"
    color-link gutter-warning "#dbbc7f"
    color-link cursor-line "#3d484d"
    color-link color-column "#3d484d"
    color-link diff-added "#a7c080"
    color-link diff-modified "#dbbc7f"
    color-link diff-deleted "#e67e80"
    color-link selection "#d3c6aa,#475258"
    color-link hlsearch "#2d353b,#dbbc7f"
    color-link matchingbrace "#dbbc7f,underline"
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
