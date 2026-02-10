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
  githubPat = customsecrets.apiKeys.github-pat or "";

  # Extract Discord webhooks from secrets with fallback to empty strings
  discordWebhooks =
    customsecrets.discord.webhooks or {
      messages = "";
      releases = "";
      teasers = "";
      changelog = "";
    };

  # Local MCP server directories (contain their own .env and config files)
  linearMcpDir = "${config.home.homeDirectory}/Development/mcp-linearapp";
  elasticMcpDir = "${config.home.homeDirectory}/Development/mcp-elasticssearch";

  # Create wrapper scripts that run from local directories
  # Wrappers check for directory existence at runtime (not build time)
  # Local directories contain their own .env and webhooks.json files
  linear-mcp-wrapper = pkgs.writeShellScript "linear-mcp-wrapper" ''
    if [ ! -d "${linearMcpDir}" ]; then
      echo "Error: Linear MCP directory not found at ${linearMcpDir}" >&2
      exit 1
    fi
    cd "${linearMcpDir}" || exit 1
    exec ${pkgs.bun}/bin/bun run ${linearMcpDir}/src/index.ts "$@"
  '';

  elastic-mcp-wrapper = pkgs.writeShellScript "elastic-mcp-wrapper" ''
    if [ ! -d "${elasticMcpDir}" ]; then
      echo "Error: Elastic Stack MCP directory not found at ${elasticMcpDir}" >&2
      exit 1
    fi
    cd "${elasticMcpDir}" || exit 1

    # Set environment variables for Elasticsearch and Kibana
    export ES_URL="http://localhost:9200"
    export ES_USERNAME="elastic"
    export ES_PASSWORD="changeme"
    export KIBANA_URL="http://localhost:5601"
    export KIBANA_USERNAME="elastic"
    export KIBANA_PASSWORD="changeme"
    export LOG_LEVEL="info"

    exec ${pkgs.nodejs}/bin/node ${elasticMcpDir}/dist/index.js "$@"
  '';

  # MCP servers from Nix flakes (no Docker required)
  # Disabled: GitHub MCP server from Nix flake
  # githubMcpServer = inputs.mcp-github.packages.${pkgs.stdenv.hostPlatform.system}.github-mcp-server;
  discordMcpServer =
    inputs.mcp-discord.packages.${pkgs.stdenv.hostPlatform.system}.discord-mcp-server;

  # Build MCP server configuration
  # All servers are always defined - wrappers handle missing directories at runtime
  mcpServers = {
    # Disabled: GitHub MCP server
    # github = {
    #   type = "local";
    #   command = [
    #     "${githubMcpServer}/bin/github-mcp-server"
    #     "stdio"
    #   ];
    #   enabled = true;
    # }
    # // lib.optionalAttrs (githubPat != "") {
    #   env = lib.filterAttrs (_: v: v != "") {
    #     GITHUB_PERSONAL_ACCESS_TOKEN = githubPat;
    #   };
    # };
    discord = {
      type = "local";
      command = [ "${discordMcpServer}/bin/discord-mcp-server" ];
      enabled = true;
    };
    linear = {
      type = "local";
      command = [ "${linear-mcp-wrapper}" ];
      enabled = true;
    };
    elastic-stack = {
      type = "local";
      command = [ "${elastic-mcp-wrapper}" ];
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

  # Create Discord MCP webhook configuration automatically
  home.activation.discordWebhooks =
    let
      hasWebhooks =
        (discordWebhooks.messages or "") != ""
        || (discordWebhooks.releases or "") != ""
        || (discordWebhooks.teasers or "") != ""
        || (discordWebhooks.changelog or "") != "";
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] (
      if hasWebhooks then
        ''
          $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/discord_mcp

          # Create webhooks.json with ISO 8601 timestamp
          cat > ~/.config/discord_mcp/webhooks.json <<'WEBHOOKS_JSON'
          {
            "messages": {
              "url": "${discordWebhooks.messages or ""}",
              "description": "General messages (discord_send_message)",
              "added_at": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
            },
            "releases": {
              "url": "${discordWebhooks.releases or ""}",
              "description": "Release announcements (discord_send_announcement)",
              "added_at": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
            },
            "teasers": {
              "url": "${discordWebhooks.teasers or ""}",
              "description": "Teaser announcements (discord_send_teaser)",
              "added_at": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
            },
            "changelog": {
              "url": "${discordWebhooks.changelog or ""}",
              "description": "Changelog posts (discord_send_changelog)",
              "added_at": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
            }
          }
          WEBHOOKS_JSON

          $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.config/discord_mcp/webhooks.json
          echo "Discord MCP webhooks configured in ~/.config/discord_mcp/webhooks.json"
        ''
      else
        ''
          echo "No Discord webhooks configured in secrets.nix - skipping webhook setup"
        ''
    );
}
