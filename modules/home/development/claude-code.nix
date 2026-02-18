# Claude Code AI assistant configuration
{
  pkgs,
  lib,
  customsecrets,
  ...
}:
let
  anthropicApiKey = customsecrets.apiKeys.anthropic or "";
in
{
  home.packages = [ pkgs.claude-code ];

  # Claude Code settings
  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      model = "sonnet";
      maxTokens = 8192;
      permissions = {
        allow = [
          "Read"
          "Write"
          "Edit"
          "Bash"
          "WebFetch"
          "WebSearch"
        ];
        deny = [
          "**/.env"
          "**/secrets.nix"
          "**/credentials.json"
        ];
      };
    };
  };

  # API key from secrets
  home.sessionVariables =
    lib.optionalAttrs (anthropicApiKey != "") {
      ANTHROPIC_API_KEY = anthropicApiKey;
    }
    // {
      # Disable telemetry
      CLAUDE_CODE_DISABLE_TELEMETRY = "1";
      CLAUDE_CODE_DISABLE_ERROR_REPORTING = "1";
      CLAUDE_CODE_DISABLE_AUTO_UPDATE = "1";
    };

  # Shell aliases
  programs.zsh.shellAliases = {
    claude-setup = ''
      echo "Setting up Claude Code with Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      echo "Anthropic API key loaded from Doppler"
    '';
    claude-doppler = "doppler run -- claude";
  };
}
