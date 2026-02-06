{ lib, customsecrets, ... }:
{
  # GPG configuration for commit signing
  # GPG agent configuration is managed at the system level in modules/core/program.nix
  # to avoid conflicts between system and home-manager configurations

  # Copy GPG keyring from backup directory during activation
  #
  # gpg-agent creates ~/.gnupg/ and its subdirectories on startup, which can
  # race with this activation script. To ensure private keys are properly copied:
  # 1. Stop gpg-agent so it doesn't hold locks or recreate empty directories
  # 2. Copy all files from the backup, overwriting any stale/empty state
  # 3. Fix permissions (CIFS mounts set 0755 on everything)
  # 4. Restart gpg-agent so it picks up the imported keyring
  home.activation.copyGpgKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${customsecrets.gpgDir or ""}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      # Stop gpg-agent to prevent races with key directory
      $DRY_RUN_CMD gpgconf --kill gpg-agent 2>/dev/null || true

      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.gnupg
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.gnupg

      # Use cp with --no-preserve=mode to avoid CIFS permission issues,
      # then set correct permissions explicitly afterwards
      $DRY_RUN_CMD cp -r --no-preserve=mode $VERBOSE_ARG "$sourceDir"/* ~/.gnupg/

      # Fix permissions: directories need 700, files need 600
      $DRY_RUN_CMD find ~/.gnupg -type d -exec chmod 700 {} \; 2>/dev/null || true
      $DRY_RUN_CMD find ~/.gnupg -type f -exec chmod 600 {} \; 2>/dev/null || true

      # Restart gpg-agent so it discovers the newly imported keys
      $DRY_RUN_CMD gpgconf --launch gpg-agent 2>/dev/null || true
    fi
  '';
}
