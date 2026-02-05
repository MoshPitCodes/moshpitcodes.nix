# NixOS Configuration
# =====================
# This file can be safely committed to Git.
# All secrets are stored in external files on NAS and loaded at runtime.
#
# Architecture:
#   config.nix (this file) -> Paths and non-secret configuration
#   /mnt/nas/.secrets/*    -> Actual secret values (never in git)
#   secrets.nix            -> DEPRECATED, kept for backwards compatibility only
#
# Secret Files on NAS:
#   user-password-hash     -> Output of: mkpasswd -m sha-512
#   samba-credentials      -> username=, password=, domain=
#   env-secrets.sh         -> export ANTHROPIC_API_KEY=, etc.

{
  # ====================
  # User Configuration
  # ====================
  username = "moshpitcodes";
  reponame = "moshpitcodes.nix";

  # ====================
  # Git Configuration
  # ====================
  # Public information only - signing key ID is public
  git = {
    userName = "Mosh Pit";
    userEmail = "moshpitcodes@gmail.com";
    signingkey = "81322B518F331E00";
  };

  # ====================
  # Network Configuration
  # ====================
  network = {
    wifiSSID = ""; # Set per-host if needed
    # WiFi password loaded from external file at runtime
  };

  # ====================
  # Samba Configuration
  # ====================
  # Non-secret samba settings (credentials in external file)
  samba = {
    username = "moshpithome";
    domain = "WORKGROUP";
    # password is NEVER stored here - loaded from credentialsFile at runtime
  };

  # ====================
  # External Secrets Paths
  # ====================
  # These are PATHS ONLY - contents are never read during Nix evaluation
  # Files are accessed at runtime by activation scripts and systemd services
  external = {
    # Base directory for all secrets on NAS
    secretsDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets";

    # User password hash file
    # Generate with: mkpasswd -m sha-512 > user-password-hash
    # File contains ONLY the hash string, no newline preferred
    userPasswordFile = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/user-password-hash";

    # Samba/CIFS credentials file
    # Format:
    #   username=your_username
    #   password=your_password
    #   domain=WORKGROUP
    sambaCredentials = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/samba-credentials";

    # Environment secrets (API keys, tokens)
    # This file is sourced in shell sessions
    # Format:
    #   export ANTHROPIC_API_KEY="sk-ant-..."
    #   export OPENAI_API_KEY="sk-..."
    #   export GITHUB_TOKEN="ghp_..."
    envSecrets = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.secrets/env-secrets.sh";

    # SSH keys directory
    sshKeysDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.ssh";
    sshKeys = [
      "id_ed25519_github"
      "id_ed25519_proxmox"
      "id_ed25519_proxmox_terraform"
    ];

    # GPG keyring directory
    gpgDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.gnupg";

    # GitHub CLI config directory
    ghConfigDir = "/mnt/ugreen-nas/Coding/SecretsBackup2025/.config/gh";
  };

  # ====================
  # API Keys (References Only)
  # ====================
  # These are loaded from external.envSecrets at shell startup
  # The attributes exist for backwards compatibility but should be empty
  apiKeys = {
    anthropic = ""; # Set via ANTHROPIC_API_KEY env var
    openai = ""; # Set via OPENAI_API_KEY env var
  };
}
