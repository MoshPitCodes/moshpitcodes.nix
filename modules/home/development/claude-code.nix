{ lib, pkgs, customsecrets, ... }:
let
  # Extract API key from secrets with fallback to empty string
  anthropicApiKey = customsecrets.apiKeys.anthropic or "";

  # Global settings.json content for ~/.claude/settings.json
  globalSettings = {
    # Model configuration - using Claude Sonnet 4.5
    model = "claude-sonnet-4-5-20250929";
    maxTokens = 8192;

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

    # Copy project CLAUDE.md to ~/.claude/ as a global reference
    # This provides context for all Claude Code sessions
    ".claude/CLAUDE.md" = lib.mkIf (builtins.pathExists /mnt/ugreen-nas/Coding/moshpitcodes/moshpitcodes.nix/CLAUDE.md) {
      source = /mnt/ugreen-nas/Coding/moshpitcodes/moshpitcodes.nix/CLAUDE.md;
    };

    # Create agents directory
    ".claude/agents/.gitkeep".text = "";
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
  } // lib.optionalAttrs (anthropicApiKey != "") {
    # Set Anthropic API key if available from secrets
    ANTHROPIC_API_KEY = anthropicApiKey;
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
      echo "✓ Anthropic API key loaded from Doppler"
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
