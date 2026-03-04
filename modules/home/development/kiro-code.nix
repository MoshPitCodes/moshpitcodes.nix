# Kiro IDE/CLI configuration
# Uses the official native installer (https://cli.kiro.dev/install) instead of
# nixpkgs, so Kiro can auto-update itself in the background.
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
  # Install Kiro via native installer if not already present.
  # The installer downloads the binary to ~/.kiro/ and sets up
  # ~/.kiro/bin/kiro as the launcher with shell integration.
  # We inject Nix store paths into PATH so the installer script can
  # find curl, sha256sum, chmod, etc.
  home.activation.installKiro = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "$HOME/.kiro/bin/kiro" ]; then
      echo "Installing Kiro via native installer..."
      export PATH="${
        lib.makeBinPath (
          with pkgs;
          [
            curl
            coreutils
            bash
            gnutar
            gzip
            unzip
          ]
        )
      }:$PATH"
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -fsSL https://cli.kiro.dev/install -o /tmp/kiro-install.sh
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash /tmp/kiro-install.sh
      rm -f /tmp/kiro-install.sh
    else
      echo "Kiro already installed, skipping (auto-updates enabled)"
    fi
  '';

  # Ensure ~/.kiro/bin is on PATH so the native binary is found
  home.sessionPath = [ "$HOME/.kiro/bin" ];

  # Create Kiro config directory
  home.file.".config/kiro/.gitkeep" = {
    text = "";
  };

  # API key from secrets
  home.sessionVariables = lib.optionalAttrs (anthropicApiKey != "") {
    ANTHROPIC_API_KEY = anthropicApiKey;
  };

  # Shell aliases
  programs.zsh.shellAliases = {
    kiro-doppler = "doppler run -- kiro";
  };
}
