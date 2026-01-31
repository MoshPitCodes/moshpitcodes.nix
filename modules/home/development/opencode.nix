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

  # MCP Server packages from flake inputs
  discord-mcp = inputs.mcp-discord.packages.${pkgs.system}.default;
  linear-mcp = inputs.mcp-linearapp.packages.${pkgs.system}.default;

  # Create wrapper scripts that change to the correct directory before running
  discord-mcp-wrapper = pkgs.writeShellScript "discord-mcp-wrapper" ''
    cd ${config.home.homeDirectory}/Development/mcp-discord || exit 1
    exec ${discord-mcp}/bin/discord-mcp "$@"
  '';

  linear-mcp-wrapper = pkgs.writeShellScript "linear-mcp-wrapper" ''
    cd ${config.home.homeDirectory}/Development/mcp-linearapp || exit 1
    exec ${linear-mcp}/bin/linear-mcp "$@"
  '';
in
{
  home = {
    packages = with pkgs; [
      opencode # OpenCode CLI for AI-assisted development
      discord-mcp # Discord MCP Server
      linear-mcp # Linear MCP Server
    ];

    # Create configuration directory for OpenCode
    file = {
      ".config/opencode/.gitkeep".text = "";

      # Symlink MCP servers to ~/.opencode/mcp-servers
      ".opencode/mcp-servers/discord-mcp".source = "${discord-mcp}/bin/discord-mcp";
      ".opencode/mcp-servers/linear-mcp".source = "${linear-mcp}/bin/linear-mcp";

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
        mcp = {
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
        };
      };
    };

    # Set environment variables for OpenCode
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
