# Development environment aggregator
{ ... }:
{
  imports = [
    ./development.nix
    ./claude-code.nix
    ./opencode.nix
  ];
}
