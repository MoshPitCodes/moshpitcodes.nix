# Development environment aggregator
{ ... }:
{
  imports = [
    ./development.nix
    ./claude-code.nix
    ./kilo-code.nix
    ./kiro-code.nix
    ./opencode.nix
    ./agent-browser.nix
    ./pi-mono.nix
  ];
}
