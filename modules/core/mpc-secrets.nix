# NixOS Secrets Module
# Provides a declarative interface for external secrets management
# Secrets are stored on NAS and copied/loaded at runtime
#
# Usage in configuration:
#   mpc.secrets = {
#     enable = true;
#     basePath = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets";
#     files = {
#       userPassword = { path = "user-password-hash"; };
#       sambaCredentials = { path = "samba-credentials"; };
#     };
#   };

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.mpc.secrets;
  secretsLib = import ../../lib/mpc-secrets.nix { inherit lib; };
in
{
  options.mpc.secrets = {
    enable = lib.mkEnableOption "MPC secrets management from external files";

    basePath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets";
      description = "Base path where external secrets are stored (e.g., NAS mount)";
      example = "/mnt/nas/.secrets";
    };

    localCachePath = lib.mkOption {
      type = lib.types.str;
      default = "/root/.secrets";
      description = "Local directory where secrets are cached for offline use";
    };

    userPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Relative path (from basePath) to file containing user's hashed password.
        The file should contain only the hash, generated with:
          mkpasswd -m sha-512

        Set to null to use hashedPassword from specialArgs instead.
      '';
      example = "user-password-hash";
    };

    sambaCredentialsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Relative path (from basePath) to samba credentials file.
        File format:
          username=your_username
          password=your_password
          domain=WORKGROUP
      '';
      example = "samba-credentials";
    };

    envSecretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Relative path (from basePath) to shell script containing environment secrets.
        This file is sourced in shell sessions.
        Example contents:
          export ANTHROPIC_API_KEY="sk-ant-..."
          export OPENAI_API_KEY="sk-..."
      '';
      example = "env-secrets.sh";
    };

    sshKeysDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to directory containing SSH keys on NAS";
      example = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.ssh";
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "id_ed25519" ];
      description = "List of SSH key names to copy (both private and .pub)";
      example = [
        "id_ed25519_github"
        "id_ed25519_proxmox"
      ];
    };

    gpgDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to GPG keyring directory on NAS";
      example = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.gnupg";
    };

    ghConfigDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Absolute path to GitHub CLI config directory on NAS";
      example = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.config/gh";
    };

    # Computed full paths for convenience
    files = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      description = "Computed full paths to secret files";
    };
  };

  config = lib.mkIf cfg.enable {
    # Compute full paths
    mpc.secrets.files = {
      userPassword = lib.mkIf (cfg.userPasswordFile != null) "${cfg.basePath}/${cfg.userPasswordFile}";
      sambaCredentials = lib.mkIf (
        cfg.sambaCredentialsFile != null
      ) "${cfg.basePath}/${cfg.sambaCredentialsFile}";
      envSecrets = lib.mkIf (cfg.envSecretsFile != null) "${cfg.basePath}/${cfg.envSecretsFile}";
    };

    # Create local secrets cache directory
    systemd.tmpfiles.rules = [
      "d ${cfg.localCachePath} 0700 root root -"
    ];

    # Activation script to copy secrets from NAS to local cache
    # This runs early in activation before user services start
    system.activationScripts.mpcSecrets = {
      deps = [ "specialfs" ];
      text = ''
        echo "MPC Secrets: Checking external secrets..."

        # Ensure local cache exists
        mkdir -p "${cfg.localCachePath}"
        chmod 700 "${cfg.localCachePath}"

        # Check if NAS is accessible
        if [[ -d "${cfg.basePath}" ]]; then
          echo "MPC Secrets: External secrets directory accessible"

          ${lib.optionalString (cfg.sambaCredentialsFile != null) ''
            # Copy samba credentials
            SRC="${cfg.basePath}/${cfg.sambaCredentialsFile}"
            DST="${cfg.localCachePath}/samba-credentials"
            if [[ -f "$SRC" ]]; then
              cp "$SRC" "$DST"
              chmod 600 "$DST"
              echo "MPC Secrets: Samba credentials cached"
            fi
          ''}

        else
          echo "MPC Secrets: WARNING - External secrets not accessible at ${cfg.basePath}"
          echo "MPC Secrets: Using cached secrets if available"
        fi
      '';
    };

    # Assertions to validate configuration
    assertions = [
      {
        assertion = cfg.basePath != "";
        message = "mpc.secrets.basePath must be set when secrets are enabled";
      }
    ];
  };
}
