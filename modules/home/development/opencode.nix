{
  lib,
  pkgs,
  config,
  customsecrets,
  inputs,
  ...
}:
let
  # Extract API keys from secrets with fallback to empty string
  anthropicApiKey = customsecrets.apiKeys.anthropic or "";
  openrouterApiKey = customsecrets.apiKeys.openrouter or "";

  # MCP servers from Nix flakes
  tdSidecarMcpServer =
    inputs.mcp-td-sidecar.packages.${pkgs.stdenv.hostPlatform.system}.td-sidecar-mcp-server;

  # Build MCP server configuration
  mcpServers = {
    td-sidecar = {
      type = "local";
      command = [ "${tdSidecarMcpServer}/bin/td-sidecar-mcp-server" ];
      enabled = true;
    };
  };
in
{
  home = {
    packages = with pkgs; [
      opencode # OpenCode CLI for AI-assisted development
    ];

    # Create configuration directory and subdirectories for OpenCode
    # OpenCode looks for agents, commands, plugins, etc. in ~/.config/opencode/
    # Reference: https://opencode.ai/docs/config#locations
    file = {
      ".config/opencode/.gitkeep".text = "";
      ".config/opencode/agents/.gitkeep".text = "";
      ".config/opencode/commands/.gitkeep".text = "";
      ".config/opencode/modes/.gitkeep".text = "";
      ".config/opencode/plugins/.gitkeep".text = "";
      ".config/opencode/skills/.gitkeep".text = "";
      ".config/opencode/themes/.gitkeep".text = "";
      ".config/opencode/tools/.gitkeep".text = "";

      # OpenCode configuration file
      # API keys are set via environment variables:
      #   - ANTHROPIC_API_KEY for Anthropic models
      #   - OPENROUTER_API_KEY for OpenRouter models
      # Model format: provider/model
      #   - Anthropic: anthropic/claude-sonnet-4-5-20250929
      #   - OpenRouter: openrouter/anthropic/claude-sonnet-4-5-20250929
      ".config/opencode/config.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        model = "anthropic/claude-sonnet-4-5-20250929";
        theme = "rosepine";
        autoupdate = false;

        # MCP Servers
        mcp = mcpServers;
      };
    };

    # Set environment variables for OpenCode
    # Global config is at ~/.config/opencode/ by default (no env var needed)
    sessionVariables =
      lib.optionalAttrs (anthropicApiKey != "") {
        # Set Anthropic API key if available from secrets
        ANTHROPIC_API_KEY = anthropicApiKey;
      }
      // lib.optionalAttrs (openrouterApiKey != "") {
        # Set OpenRouter API key if available from secrets
        OPENROUTER_API_KEY = openrouterApiKey;
      };
  };

  # Shell aliases for OpenCode with Doppler integration
  programs.zsh.shellAliases = {
    # OpenCode configuration with Doppler
    opencode-setup = ''
      echo "Setting up OpenCode with Doppler..."
      echo "Fetching API keys from Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      export OPENROUTER_API_KEY=$(doppler secrets get OPENROUTER_API_KEY --plain)
      echo "✓ Anthropic API key loaded from Doppler"
      echo "✓ OpenRouter API key loaded from Doppler"
    '';

    # Run opencode with Doppler directly
    opencode-doppler = "doppler run -- opencode";
  };

  programs.bash.shellAliases = {
    opencode-setup = ''
      echo "Setting up OpenCode with Doppler..."
      echo "Fetching API keys from Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      export OPENROUTER_API_KEY=$(doppler secrets get OPENROUTER_API_KEY --plain)
      echo "✓ Anthropic API key loaded from Doppler"
      echo "✓ OpenRouter API key loaded from Doppler"
    '';

    opencode-doppler = "doppler run -- opencode";
  };
}
