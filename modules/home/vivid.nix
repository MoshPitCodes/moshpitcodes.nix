# vivid LS_COLORS + eza color theme (Everforest palette)
{ pkgs, ... }:
let
  # Generate LS_COLORS using vivid with one-dark (neutral dark theme)
  lsColors = builtins.readFile (
    pkgs.runCommand "ls-colors" { } ''
      ${pkgs.vivid}/bin/vivid generate one-dark > $out
    ''
  );

  # Everforest color palette for eza
  ezaColors = [
    # Permission bits
    "ur=38;5;250" # user read (light grey)
    "uw=38;5;167" # user write (red: #e67e80)
    "ux=38;5;108" # user execute (aqua: #83c092)
    "ue=38;5;108" # user execute (file)
    "gr=38;5;102" # group read (grey: #859289)
    "gw=38;5;167" # group write
    "gx=38;5;109" # group execute (blue: #7fbbb3)
    "tr=38;5;102" # other read
    "tw=38;5;167" # other write
    "tx=38;5;109" # other execute

    # File types
    "di=38;5;108" # directories (aqua: #83c092)
    "ex=38;5;179" # executables (yellow: #dbbc7f)
    "fi=38;5;187" # regular files (fg: #d3c6aa)
    "ln=38;5;167" # symlinks (red: #e67e80)
    "or=38;5;167" # orphaned symlinks

    # Special files
    "pi=38;5;175" # named pipes (purple: #d699b6)
    "so=38;5;175" # sockets
    "bd=38;5;175" # block devices
    "cd=38;5;175" # character devices

    # Git status colors
    "ga=38;5;108" # added (aqua)
    "gm=38;5;179" # modified (yellow)
    "gd=38;5;167" # deleted (red)
    "gv=38;5;109" # renamed (blue)
    "gt=38;5;175" # type changed (purple)

    # Metadata
    "sn=38;5;102" # file size (grey)
    "sb=38;5;102" # file blocks
    "df=38;5;109" # major device number (blue)
    "ds=38;5;109" # minor device number
    "uu=38;5;179" # user (you) (yellow)
    "un=38;5;250" # user (other)
    "gu=38;5;102" # group (yours) (grey)
    "gn=38;5;102" # group (other)
    "lc=38;5;102" # symlink count
    "lm=38;5;102" # multi-link file

    # Dates
    "da=38;5;250" # timestamp

    # File attributes
    "xa=38;5;102" # extended attributes
  ];
in
{
  home.sessionVariables = {
    LS_COLORS = lsColors;
    EZA_COLORS = builtins.concatStringsSep ":" ezaColors;
  };
}
