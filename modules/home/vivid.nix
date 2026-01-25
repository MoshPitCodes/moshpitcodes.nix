{ pkgs, ... }:
let
  # Generate Rose Pine LS_COLORS at build time using vivid
  # This ensures consistent directory/file colors with the Rose Pine theme
  lsColors = builtins.readFile (
    pkgs.runCommand "ls-colors" { } ''
      ${pkgs.vivid}/bin/vivid generate rose-pine > $out
    ''
  );
in
{
  home.sessionVariables = {
    LS_COLORS = lsColors;
  };
}
