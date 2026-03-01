# vivid LS_COLORS + eza color theme (TokyoNight Storm palette)
{ pkgs, ... }:
let
  # Generate LS_COLORS using vivid with one-dark (neutral dark theme)
  lsColors = builtins.readFile (
    pkgs.runCommand "ls-colors" { } ''
      ${pkgs.vivid}/bin/vivid generate one-dark > $out
    ''
  );

  # TokyoNight Storm color palette for eza
  ezaColors = [
    # Permission bits
    "ur=38;5;146" # user read (fg_dark: #a9b1d6)
    "uw=38;5;210" # user write (red: #f7768e)
    "ux=38;5;79" # user execute (green1: #73daca)
    "ue=38;5;79" # user execute (file)
    "gr=38;5;60" # group read (dark3: #545c7e)
    "gw=38;5;210" # group write
    "gx=38;5;111" # group execute (blue: #7aa2f7)
    "tr=38;5;60" # other read
    "tw=38;5;210" # other write
    "tx=38;5;111" # other execute

    # File types
    "di=38;5;79" # directories (green1: #73daca)
    "ex=38;5;179" # executables (yellow: #e0af68)
    "fi=38;5;189" # regular files (fg: #c0caf5)
    "ln=38;5;210" # symlinks (red: #f7768e)
    "or=38;5;210" # orphaned symlinks

    # Special files
    "pi=38;5;141" # named pipes (magenta: #bb9af7)
    "so=38;5;141" # sockets
    "bd=38;5;141" # block devices
    "cd=38;5;141" # character devices

    # Git status colors
    "ga=38;5;79" # added (green1)
    "gm=38;5;179" # modified (yellow)
    "gd=38;5;210" # deleted (red)
    "gv=38;5;111" # renamed (blue)
    "gt=38;5;141" # type changed (magenta)

    # Metadata
    "sn=38;5;60" # file size (dark3)
    "sb=38;5;60" # file blocks
    "df=38;5;111" # major device number (blue)
    "ds=38;5;111" # minor device number
    "uu=38;5;179" # user (you) (yellow)
    "un=38;5;146" # user (other)
    "gu=38;5;60" # group (yours) (dark3)
    "gn=38;5;60" # group (other)
    "lc=38;5;60" # symlink count
    "lm=38;5;60" # multi-link file

    # Dates
    "da=38;5;146" # timestamp

    # File attributes
    "xa=38;5;60" # extended attributes
  ];
in
{
  home.sessionVariables = {
    LS_COLORS = lsColors;
    EZA_COLORS = builtins.concatStringsSep ":" ezaColors;
  };
}
