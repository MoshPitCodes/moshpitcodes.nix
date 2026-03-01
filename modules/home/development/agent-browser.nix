# agent-browser — headless browser automation CLI for AI agents
# Uses the global installation method: npm install -g agent-browser
# https://github.com/vercel-labs/agent-browser
{
  lib,
  pkgs,
  ...
}:
let
  agent-browser = pkgs.writeShellScriptBin "agent-browser" ''
    exec ${pkgs.nodejs}/bin/npx -y agent-browser@latest "$@"
  '';
in
{
  home.packages = [ agent-browser ];

  # Download Chromium on first use (equivalent to `agent-browser install`)
  home.activation.installAgentBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    AGENT_BROWSER_DIR="$HOME/.cache/ms-playwright"
    if [ ! -d "$AGENT_BROWSER_DIR" ]; then
      echo "agent-browser: downloading Chromium (first-time setup)..."
      $DRY_RUN_CMD ${pkgs.nodejs}/bin/npx -y agent-browser@latest install
    else
      echo "agent-browser: Chromium already installed, skipping"
    fi
  '';
}
