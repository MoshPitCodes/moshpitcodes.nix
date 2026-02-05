# Configuration Loader
# Loads config.nix with external secrets support
# Handles fallback to secrets.nix for backwards compatibility

{
  lib ? (import <nixpkgs> { }).lib,
}:

let
  # Helper to read a file if it exists
  readFileIfExists =
    path: default:
    if builtins.pathExists path then
      lib.strings.removeSuffix "\n" (builtins.readFile path)
    else
      default;

  # Load configuration based on what files exist
  loadConfig =
    basePath:
    let
      configPath = basePath + "/config.nix";
      secretsPath = basePath + "/secrets.nix";

      # Load config.nix if it exists, otherwise secrets.nix
      baseConfig =
        if builtins.pathExists configPath then
          import configPath
        else if builtins.pathExists secretsPath then
          import secretsPath
        else
          throw "Neither config.nix nor secrets.nix found in ${basePath}";

      # If config.nix exists and has external files configured
      hasExternalConfig = builtins.pathExists configPath && baseConfig ? external;

      # Load external secrets if configured
      externalSecrets =
        if hasExternalConfig then
          let
            ext = baseConfig.external;
            secretsDir = ext.secretsDir or "";
          in
          {
            # Load user password hash from external file
            hashedPassword =
              if ext ? userPasswordFile then
                readFileIfExists ext.userPasswordFile baseConfig.hashedPassword or ""
              else
                baseConfig.hashedPassword or "";

            # Samba configuration with external credentials
            samba = {
              username = baseConfig.samba.username or "guest";
              password = ""; # Never stored in config
              domain = baseConfig.samba.domain or "WORKGROUP";
              credentialsFile = ext.sambaCredentials or "";
            };

            # SSH keys configuration
            sshKeys = {
              sourceDir = ext.sshKeysDir or "";
              keys =
                ext.sshKeys or [
                  "id_ed25519"
                  "id_rsa"
                ];
            };

            # GPG directory
            gpgDir = ext.gpgDir or "";

            # GitHub CLI config directory
            ghConfigDir = ext.ghConfigDir or "";

            # Environment secrets file
            envSecretsFile = ext.envSecrets or "";
          }
        else
          { };

      # Merge base config with external secrets
      finalConfig =
        baseConfig
        // externalSecrets
        // {
          # Ensure these always exist with defaults
          apiKeys =
            baseConfig.apiKeys or {
              anthropic = "";
              openai = "";
            };
          network =
            baseConfig.network or {
              wifiSSID = "";
              wifiPassword = "";
            };
        };
    in
    finalConfig;
in
{
  inherit loadConfig readFileIfExists;
}
