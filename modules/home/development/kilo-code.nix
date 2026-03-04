# Kilo Code AI-assisted development configuration
{ pkgs, ... }:
let
  kilo = pkgs.writeShellScriptBin "kilo" ''
    exec ${pkgs.nodejs}/bin/npx -y @kilocode/cli "$@"
  '';
in
{
  home = {
    packages = [ kilo ];

    file = {
      ".config/kilo/.gitkeep".text = "";
    };
  };

  programs.zsh.shellAliases = {
    kilo-doppler = "doppler run -- kilo";
  };
}
