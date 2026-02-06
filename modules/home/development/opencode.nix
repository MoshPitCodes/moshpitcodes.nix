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
  githubPat = customsecrets.apiKeys.github or "";

  # Local MCP server directories (contain their own .env and config files)
  discordMcpDir = "${config.home.homeDirectory}/Development/mcp-discord";
  linearMcpDir = "${config.home.homeDirectory}/Development/mcp-linearapp";

  # Create wrapper scripts that run from local directories
  # Wrappers check for directory existence at runtime (not build time)
  # Local directories contain their own .env and webhooks.json files
  discord-mcp-wrapper = pkgs.writeShellScript "discord-mcp-wrapper" ''
    if [ ! -d "${discordMcpDir}" ]; then
      echo "Error: Discord MCP directory not found at ${discordMcpDir}" >&2
      exit 1
    fi
    cd "${discordMcpDir}" || exit 1
    exec ${pkgs.bun}/bin/bun run ${discordMcpDir}/src/index.ts "$@"
  '';

  linear-mcp-wrapper = pkgs.writeShellScript "linear-mcp-wrapper" ''
    if [ ! -d "${linearMcpDir}" ]; then
      echo "Error: Linear MCP directory not found at ${linearMcpDir}" >&2
      exit 1
    fi
    cd "${linearMcpDir}" || exit 1
    exec ${pkgs.bun}/bin/bun run ${linearMcpDir}/src/index.ts "$@"
  '';

  # Build MCP server configuration
  # All servers are always defined - wrappers handle missing directories at runtime
  mcpServers = {
    github = {
      type = "local";
      command = [
        "docker"
        "run"
        "--rm"
        "-i"
        "-e"
        "GITHUB_PERSONAL_ACCESS_TOKEN"
        "ghcr.io/github/github-mcp-server"
      ];
      environment = {
        GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
      };
      enabled = true;
    };
    discord = {
      type = "local";
      command = [ "${discord-mcp-wrapper}" ];
      enabled = true;
    };
    linear = {
      type = "local";
      command = [ "${linear-mcp-wrapper}" ];
      enabled = true;
    };
  };
in
{
  home = {
    packages = with pkgs; [
      opencode # OpenCode CLI for AI-assisted development
      bun # Bun runtime for local MCP servers
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
      }
      // lib.optionalAttrs (githubPat != "") {
        # Set GitHub PAT if available from secrets
        GITHUB_PERSONAL_ACCESS_TOKEN = githubPat;
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
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(doppler secrets get GITHUB_PERSONAL_ACCESS_TOKEN --plain)
      echo "✓ Anthropic API key loaded from Doppler"
      echo "✓ OpenRouter API key loaded from Doppler"
      echo "✓ GitHub PAT loaded from Doppler"
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
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(doppler secrets get GITHUB_PERSONAL_ACCESS_TOKEN --plain)
      echo "✓ Anthropic API key loaded from Doppler"
      echo "✓ OpenRouter API key loaded from Doppler"
      echo "✓ GitHub PAT loaded from Doppler"
    '';

    opencode-doppler = "doppler run -- opencode";
  };
}
