# agent-browser - headless browser automation CLI for AI agents
# Keeps the Playwright runtime and browser bundle in Nix so there is no
# separate `agent-browser install` or `playwright install-deps` step.
# https://github.com/vercel-labs/agent-browser
{ pkgs, ... }:
let
  playwrightBrowsers = pkgs.playwright-driver.browsers;

  agent-browser = pkgs.writeShellApplication {
    name = "agent-browser";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      export PLAYWRIGHT_BROWSERS_PATH="${playwrightBrowsers}"
      export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
      export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
      export PLAYWRIGHT_NODEJS_PATH="${pkgs.nodejs}/bin/node"

      exec npx -y agent-browser@latest "$@"
    '';
  };
in
{
  home.packages = [
    agent-browser
    pkgs.playwright-driver
    playwrightBrowsers
  ];

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${playwrightBrowsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
  };
}
