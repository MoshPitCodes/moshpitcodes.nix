# OpenCode AI-assisted development configuration
{
  lib,
  pkgs,
  customsecrets,
  ...
}:
let
  anthropicApiKey = customsecrets.apiKeys.anthropic or "";
  openrouterApiKey = customsecrets.apiKeys.openrouter or "";
  opencode = pkgs.writeShellScriptBin "opencode" ''
    exec ${pkgs.nodejs}/bin/npx -y opencode-ai@latest "$@"
  '';
in
{
  home = {
    packages = [ opencode ];

    # OpenCode directory structure
    file = {
      ".config/opencode/.gitkeep".text = "";
      ".config/opencode/agents/.gitkeep".text = "";
      ".config/opencode/commands/.gitkeep".text = "";
      ".config/opencode/modes/.gitkeep".text = "";
      ".config/opencode/plugins/.gitkeep".text = "";
      ".config/opencode/skills/.gitkeep".text = "";
      ".config/opencode/themes/.gitkeep".text = "";
      ".config/opencode/tools/.gitkeep".text = "";

      ".config/opencode/config.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        model = "openrouter/openai/gpt-5.2";
        theme = "rosepine";
        autoupdate = false;
        # Prevent file watcher from tracking plugin logs and session data.
        # Without this, diff summaries include full log file contents on every
        # turn, causing multi-MB messages that bloat the SQLite database and
        # drive memory usage into the tens of gigabytes.
        watcher = {
          ignore = [
            ".opencode/logs/**"
            ".opencode/data/**"
          ];
        };
      };
    };

    sessionVariables =
      lib.optionalAttrs (anthropicApiKey != "") {
        ANTHROPIC_API_KEY = anthropicApiKey;
      }
      // lib.optionalAttrs (openrouterApiKey != "") {
        OPENROUTER_API_KEY = openrouterApiKey;
      };
  };

  programs.zsh.shellAliases = {
    opencode-setup = ''
      echo "Setting up OpenCode with Doppler..."
      export ANTHROPIC_API_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain)
      export OPENROUTER_API_KEY=$(doppler secrets get OPENROUTER_API_KEY --plain)
      echo "API keys loaded from Doppler"
    '';
    opencode-doppler = "doppler run -- opencode";
  };
}
