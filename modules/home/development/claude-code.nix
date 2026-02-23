# Claude Code AI assistant configuration
# Uses the official native installer (https://claude.ai/install.sh) instead of
# nixpkgs, so Claude Code can auto-update itself in the background.
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
  # Install Claude Code via native installer if not already present.
  # The installer downloads the binary to ~/.claude/ and sets up
  # ~/.claude/bin/claude as the launcher with shell integration.
  # We inject Nix store paths into PATH so the installer script can
  # find curl, sha256sum, chmod, etc.
  home.activation.installClaudeCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "$HOME/.claude/bin/claude" ]; then
      echo "Installing Claude Code via native installer..."
      export PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            curl
            coreutils
            bash
            gnutar
            gzip
          ]
        )
      }:$PATH"
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh -o /tmp/claude-install.sh
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash /tmp/claude-install.sh
      rm -f /tmp/claude-install.sh
    else
      echo "Claude Code already installed, skipping (auto-updates enabled)"
    fi
  '';

  # Ensure ~/.claude/bin is on PATH so the native binary is found
  home.sessionPath = [ "$HOME/.claude/bin" ];

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
    };

  # Shell aliases
  programs.zsh.shellAliases = {
    claude-setup = ''
      echo "Setting up Claude Code with Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      echo "Anthropic API key loaded from Doppler"
    '';
    claude-doppler = "doppler run -- claude";
    claude-update = "${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash";
  };
}
