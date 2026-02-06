{ pkgs, ... }:
let
  # Generate Rose Pine LS_COLORS at build time using vivid
  # This ensures consistent directory/file colors with the Rose Pine theme
  lsColors = builtins.readFile (
    pkgs.runCommand "ls-colors" { } ''
      ${pkgs.vivid}/bin/vivid generate rose-pine > $out
    ''
  );

  # Rose Pine color palette for eza
  # Uses the main Rose Pine palette to ensure consistent theming
  # Reference: https://rosepinetheme.com/palette/
  ezaColors = [
    # Permission bits (user/group/other read/write/execute)
    "ur=38;5;250" # user read (subtle: #908caa)
    "uw=38;5;203" # user write (love: #eb6f92)
    "ux=38;5;117" # user execute (foam: #9ccfd8)
    "ue=38;5;117" # user execute (file)
    "gr=38;5;243" # group read (muted: #6e6a86)
    "gw=38;5;203" # group write
    "gx=38;5;110" # group execute (pine: #31748f)
    "tr=38;5;243" # other read
    "tw=38;5;203" # other write
    "tx=38;5;110" # other execute

    # File types
    "di=38;5;117" # directories (foam: #9ccfd8)
    "ex=38;5;222" # executables (gold: #f6c177)
    "fi=38;5;253" # regular files (text: #e0def4)
    "ln=38;5;204" # symlinks (love: #eb6f92)
    "or=38;5;204" # orphaned symlinks

    # Special files
    "pi=38;5;183" # named pipes (iris: #c4a7e7)
    "so=38;5;183" # sockets
    "bd=38;5;183" # block devices
    "cd=38;5;183" # character devices

    # Git status colors
    "ga=38;5;117" # added (foam)
    "gm=38;5;222" # modified (gold)
    "gd=38;5;203" # deleted (love)
    "gv=38;5;110" # renamed (pine)
    "gt=38;5;183" # type changed (iris)

    # Metadata
    "sn=38;5;243" # file size (muted)
    "sb=38;5;243" # file blocks
    "df=38;5;110" # major device number (pine)
    "ds=38;5;110" # minor device number
    "uu=38;5;222" # user (you) (gold)
    "un=38;5;250" # user (other) (subtle)
    "gu=38;5;243" # group (yours) (muted)
    "gn=38;5;243" # group (other)
    "lc=38;5;243" # symlink count
    "lm=38;5;243" # multi-link file

    # Dates
    "da=38;5;250" # timestamp (subtle)

    # File attributes
    "xa=38;5;243" # extended attributes
  ];
in
{
  home.sessionVariables = {
    LS_COLORS = lsColors;
    EZA_COLORS = builtins.concatStringsSep ":" ezaColors;
  };
}
