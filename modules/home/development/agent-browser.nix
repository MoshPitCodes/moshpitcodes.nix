# agent-browser — headless browser automation CLI for AI agents
# Uses pkgs.playwright-driver for NixOS-compatible Chromium (no `agent-browser install` needed)
# https://github.com/vercel-labs/agent-browser
{ pkgs, ... }:
let
  agent-browser = pkgs.writeShellScriptBin "agent-browser" ''
    export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    exec ${pkgs.nodejs}/bin/npx -y agent-browser@latest "$@"
  '';
in
{
  home.packages = [ agent-browser ];
}
