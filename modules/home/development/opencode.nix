{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      opencode # OpenCode CLI for AI-assisted development
    ];

    # Create configuration directory for OpenCode
    file = {
      ".config/opencode/.gitkeep".text = "";

      # OpenCode configuration file
      # API key is set via ANTHROPIC_API_KEY environment variable
      # Model format: provider/model (e.g., anthropic/claude-sonnet-4-5-20250929)
      ".config/opencode/config.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        model = "anthropic/claude-sonnet-4-5-20250929";
        theme = "rosepine";
        autoupdate = false;

        # MCP Servers
        mcp = {
          discord = {
            type = "local";
            command = [
              "bash"
              "-c"
              "cd ~/.opencode/mcp-servers/discord_mcp && nix develop --command python discord_mcp.py"
            ];
            enabled = true;
          };
        };
      };
    };
  };

  # Shell aliases for OpenCode with Doppler integration
  programs.zsh.shellAliases = {
    # OpenCode configuration with Doppler
    opencode-setup = ''
      echo "Setting up OpenCode with Doppler..."
      echo "Fetching API keys from Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      echo "Claude API keys loaded from Doppler"
    '';

    # Run opencode with Doppler directly
    opencode-doppler = "doppler run -- opencode";
  };

  programs.bash.shellAliases = {
    opencode-setup = ''
      echo "Setting up OpenCode with Doppler..."
      echo "Fetching API keys from Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      echo "Claude API keys loaded from Doppler"
    '';

    opencode-doppler = "doppler run -- opencode";
  };
}
