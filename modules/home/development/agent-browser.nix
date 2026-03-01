# agent-browser — headless browser automation CLI for AI agents
# Uses the global installation method: npm install -g agent-browser
# https://github.com/vercel-labs/agent-browser
# After nixos-rebuild, run `agent-browser install` manually to download Chromium.
# On Linux, use `agent-browser install --with-deps` to also install system dependencies.
{ pkgs, ... }:
let
  agent-browser = pkgs.writeShellScriptBin "agent-browser" ''
    exec ${pkgs.nodejs}/bin/npx -y agent-browser@latest "$@"
  '';
in
{
  home.packages = [ agent-browser ];
}
