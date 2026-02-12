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

  # MCP servers from Nix flakes (no Docker required)
  tdSidecarMcpServer =
    inputs.mcp-td-sidecar.packages.${pkgs.stdenv.hostPlatform.system}.td-sidecar-mcp-server;

  # Build MCP server configuration
  mcpServers = {
    td-sidecar = {
      type = "stdio";
      command = "${tdSidecarMcpServer}/bin/td-sidecar-mcp-server";
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

  # Register MCP servers with Claude Code using activation script
  # Claude Code stores MCP servers in ~/.claude.json, not ~/.claude/settings.json
  # This script reconciles on each rebuild: adds desired servers and removes any
  # that are no longer declared in the Nix configuration
  home.activation.claudeCodeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_JSON="$HOME/.claude.json"
    JQ="${pkgs.jq}/bin/jq"
    CLAUDE="${pkgs.claude-code}/bin/claude"

    # Desired MCP server names from Nix configuration
    DESIRED_SERVERS=(${lib.concatMapStringsSep " " (name: ''"${name}"'') (builtins.attrNames mcpServers)})

    is_desired() {
      local name="$1"
      for desired in "''${DESIRED_SERVERS[@]}"; do
        [[ "$name" == "$desired" ]] && return 0
      done
      return 1
    }

    # Reconcile: remove MCP servers not declared in Nix configuration
    if [ -f "$CLAUDE_JSON" ]; then
      # Remove unmanaged servers from user scope
      while IFS= read -r server; do
        [ -z "$server" ] && continue
        if ! is_desired "$server"; then
          echo "Removing unmanaged MCP server: $server (user scope)"
          $CLAUDE mcp remove "$server" --scope user 2>/dev/null || true
        fi
      done < <($JQ -r '.mcpServers // {} | keys[]' "$CLAUDE_JSON" 2>/dev/null)

      # Remove Nix-managed servers from project scopes
      # Only targets servers whose command points to /nix/store/ (installed via Nix)
      $JQ -r '
        .projects // {} | to_entries[] | .key as $p |
        .value.mcpServers // {} | to_entries[] |
        select(.value.command | test("^/nix/store/")) |
        "\($p)\t\(.key)"
      ' "$CLAUDE_JSON" 2>/dev/null | while IFS=$'\t' read -r project server; do
        [ -z "$server" ] && continue
        if ! is_desired "$server"; then
          echo "Removing Nix-managed MCP server: $server (project: $project)"
          $DRY_RUN_CMD $JQ --arg p "$project" --arg s "$server" \
            'del(.projects[$p].mcpServers[$s])' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
            && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
        fi
      done
    fi

    # Function to add MCP server, removing and re-adding if it exists
    add_mcp_server() {
      local name="$1"
      local command="$2"
      shift 2
      local env_args=("$@")

      if $CLAUDE mcp get "$name" --scope user &>/dev/null; then
        echo "Updating MCP server: $name (user scope)"
        $CLAUDE mcp remove "$name" --scope user &>/dev/null || true
      fi

      echo "Registering MCP server: $name (user scope)"
      $CLAUDE mcp add "$name" --scope user "''${env_args[@]}" -- "$command" || {
        echo "Warning: Failed to register MCP server $name"
      }
    }

    # Register desired MCP servers
    add_mcp_server "td-sidecar" "${tdSidecarMcpServer}/bin/td-sidecar-mcp-server"

    echo "MCP servers reconciled for Claude Code"
  '';

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
}
