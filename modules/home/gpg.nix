{ lib, customsecrets, ... }:
{
  # GPG configuration for commit signing
  # GPG agent configuration is managed at the system level in modules/core/program.nix
  # to avoid conflicts between system and home-manager configurations

  # Copy GPG keyring from backup directory during activation
  home.activation.copyGpgKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${customsecrets.gpgDir or ""}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.gnupg
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.gnupg
      $DRY_RUN_CMD cp -r $VERBOSE_ARG "$sourceDir"/* ~/.gnupg/
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.gnupg/private-keys-v1.d/* 2>/dev/null || true
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.gnupg/trustdb.gpg 2>/dev/null || true
    fi
  '';

  # Optional: Configure programs.gpg if beneficial
  # programs.gpg = {
  #   enable = true;
  #   settings = {
  #     # Add GPG settings here if needed
  #   };
  # };
}
