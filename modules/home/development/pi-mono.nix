# Pi coding agent configuration
# Installs @mariozechner/pi-coding-agent globally via npm install -g
# so pi can self-update and manage its own packages (extensions, skills, themes).
# Uses NPM_CONFIG_PREFIX=~/.npm-global so npm install -g works without root
# or writing to the read-only Nix store.
{
  pkgs,
  lib,
  customsecrets,
  ...
}:
let
  openaiApiKey = customsecrets.apiKeys.openai or "";
in
{
  # Set npm global prefix to ~/.npm-global so npm install -g works
  # without requiring root or writing to the Nix store.
  # ANTHROPIC_API_KEY is already set by claude-code.nix and opencode.nix
  # (same customsecrets source). Only OPENAI_API_KEY is unique to this module.
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    # Skip startup version check for faster launch
    PI_SKIP_VERSION_CHECK = "1";
  }
  // lib.optionalAttrs (openaiApiKey != "") {
    OPENAI_API_KEY = openaiApiKey;
  };

  # Ensure ~/.npm-global/bin is on PATH so the `pi` command is found
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Install pi coding agent via npm install -g so it can self-update
  # and manage pi packages (extensions, skills, themes) independently.
  home.activation.installPiCodingAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$PATH"
    mkdir -p "$HOME/.npm-global"
    if [ ! -x "$HOME/.npm-global/bin/pi" ]; then
      echo "Installing pi coding agent via npm install -g..."
      $DRY_RUN_CMD npm install -g @mariozechner/pi-coding-agent
    else
      echo "pi coding agent already installed, skipping (use 'pi-update' to update)"
    fi
  '';

  # Pi config directory structure
  home.file = {
    ".pi/agent/.gitkeep".text = "";
  };

  # Shell aliases
  programs.zsh.shellAliases = {
    pi-setup = ''
      echo "Setting up pi with Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      export OPENAI_API_KEY=$(doppler secrets get OPENAI_API_KEY --plain)
      echo "API keys loaded from Doppler"
    '';
    pi-doppler = "doppler run -- pi";
    pi-update = "npm install -g @mariozechner/pi-coding-agent";
  };
}
