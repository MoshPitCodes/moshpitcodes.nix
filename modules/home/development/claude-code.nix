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

  # MCP servers from Nix flakes (no Docker required)
  discordMcpServer = inputs.mcp-discord.packages.${pkgs.system}.discord-mcp-server;

  # Build MCP server configuration
  # All servers are always defined - wrappers handle missing directories at runtime
  mcpServers = {
    discord = {
      type = "stdio";
      command = "${discordMcpServer}/bin/discord-mcp-server";
      args = [ ];
      env = { };
    };
    linear = {
      type = "stdio";
      command = "${linear-mcp-wrapper}";
      args = [ ];
      env = { };
    };
  };

  # Global settings.json content for ~/.claude/settings.json
  globalSettings = {
    # Model configuration - using Claude Sonnet 4.5
    model = "claude-sonnet-4-5-20250929";
    maxTokens = 8192;

    # MCP Servers configuration
    mcpServers = mcpServers;

    # Permissions configuration
    permissions = {
      # Allow common development tools
      allowedTools = [
        "Read"
        "Write"
        "Edit"
        "Glob"
        "Grep"
        "Bash"
        "TodoWrite"
        "WebSearch"
        "WebFetch"
        "NotebookEdit"
      ];

      # Deny access to sensitive files
      deny = [
        "Read(./.env)"
        "Read(./.env.*)"
        "Read(./secrets.nix)"
        "Read(./**/secrets.nix)"
        "Read(./.credentials.json)"
        "Read(./credentials.json)"
        "Write(./production.config.*)"
        "Write(./.env)"
        "Write(./.env.*)"
        "Write(./secrets.nix)"
      ];
    };
  };

  # Settings for local override (project-specific settings)
  # This is an example - actual local settings should be per-project
  localSettingsExample = {
    # Example: project-specific model or token limits
    maxTokens = 4096;
  };
in
{
  # Install Claude Code package
  home.packages = with pkgs; [
    claude-code # Anthropic's Claude Code CLI
    bun # Bun runtime for local MCP servers (Linear)
  ];

  # Create ~/.claude directory and configuration files
  home.file = {
    # Global settings.json
    ".claude/settings.json" = {
      text = builtins.toJSON globalSettings;
      # This file should be writable by the user for modifications
      onChange = ''
        if [ -L "$HOME/.claude/settings.json" ]; then
          cp -f "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.tmp"
          rm -f "$HOME/.claude/settings.json"
          mv "$HOME/.claude/settings.json.tmp" "$HOME/.claude/settings.json"
          chmod u+w "$HOME/.claude/settings.json"
        fi
      '';
    };

    # Example local settings template (commented out by default)
    # Users can uncomment and customize per project
    ".claude/settings.local.json.example" = {
      text = builtins.toJSON localSettingsExample;
    };

    # Create agents directory
    ".claude/agents/.gitkeep".text = "";

    # Create config directory
    ".config/claude-code/.gitkeep".text = "";
  };

  # Set environment variables for Claude Code
  home.sessionVariables = {
    # Privacy and telemetry settings - disable all non-essential traffic
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    DISABLE_TELEMETRY = "1";
    DISABLE_ERROR_REPORTING = "1";
    DISABLE_BUG_COMMAND = "1";
    DISABLE_AUTOUPDATER = "1";
    CLAUDE_CODE_MAX_OUTPUT_TOKENS = "8000";
    DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
    DISABLE_COST_WARNINGS = "1";
  }
  // lib.optionalAttrs (anthropicApiKey != "") {
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

  # Create activation script to set up credentials if API key exists
  # This mimics the structure of the existing .credentials.json file
  home.activation.claudeCodeCredentials = lib.mkIf (anthropicApiKey != "") (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create ~/.claude directory if it doesn't exist
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.claude
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.claude

      # Only create credentials file if it doesn't exist already
      # This preserves OAuth tokens if user is authenticated via web
      if [[ ! -f ~/.claude/.credentials.json ]]; then
        # Note: This is a placeholder structure
        # Claude Code uses OAuth for authentication, not API keys in credentials
        # The API key is set via ANTHROPIC_API_KEY environment variable instead
        echo "Note: Claude Code uses web authentication (OAuth) by default."
        echo "Set ANTHROPIC_API_KEY environment variable for API key authentication."
      fi
    ''
  );

  # Add shell aliases for Claude Code with Doppler integration
  programs.zsh.shellAliases = {
    # Claude Code setup helper
    claude-code-setup = ''
      echo "Claude Code Configuration:"
      echo "  Global settings: ~/.claude/settings.json"
      echo "  Project settings: .claude/settings.json"
      echo "  Local settings: .claude/settings.local.json"
      echo ""
      echo "Authentication options:"
      echo "  1. Web auth (recommended): Run 'claude-code auth'"
      echo "  2. API key: Set ANTHROPIC_API_KEY environment variable"
      echo ""
      echo "Current configuration:"
      [ -f ~/.claude/settings.json ] && echo "  ✓ Global settings configured" || echo "  ✗ Global settings missing"
      [ -n "$ANTHROPIC_API_KEY" ] && echo "  ✓ API key set" || echo "  ✗ API key not set"
    '';

    # Run Claude Code with Doppler for secrets management
    claude-code-doppler = "doppler run -- claude-code";

    # Load API keys from Doppler
    claude-code-load-secrets = ''
      echo "Loading Claude Code secrets from Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      export OPENROUTER_API_KEY=$(doppler secrets get OPENROUTER_API_KEY --plain)
      export GITHUB_PERSONAL_ACCESS_TOKEN=$(doppler secrets get GITHUB_PERSONAL_ACCESS_TOKEN --plain)
      echo "✓ Anthropic API key loaded from Doppler"
      echo "✓ OpenRouter API key loaded from Doppler"
      echo "✓ GitHub PAT loaded from Doppler"
    '';
  };

  programs.bash.shellAliases = {
    # Same aliases for bash users
    claude-code-setup = ''
      echo "Claude Code Configuration:"
      echo "  Global settings: ~/.claude/settings.json"
      echo "  Project settings: .claude/settings.json"
      echo "  Local settings: .claude/settings.local.json"
      echo ""
      echo "Authentication options:"
      echo "  1. Web auth (recommended): Run 'claude-code auth'"
      echo "  2. API key: Set ANTHROPIC_API_KEY environment variable"
    '';

    claude-code-doppler = "doppler run -- claude-code";
  };

  # Create Discord MCP webhook configuration automatically
  # This is shared between OpenCode and Claude Code
  home.activation.discordWebhooksClaudeCode =
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

                    # Create webhooks.json with ISO 8601 timestamp (shared with OpenCode)
                    if [ ! -f ~/.config/discord_mcp/webhooks.json ]; then
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
                    fi
        ''
      else
        ''
          echo "No Discord webhooks configured in secrets.nix - skipping webhook setup for Claude Code"
        ''
    );
}
