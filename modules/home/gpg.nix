{
  lib,
  config,
  customsecrets,
  mpcConfig ? { },
  pkgs,
  ...
}:
let
  # Get GPG directory from mpcConfig (preferred) or customsecrets (backwards compat)
  gpgSourceDir =
    if (mpcConfig ? external) && (mpcConfig.external ? gpgDir) && (mpcConfig.external.gpgDir != "") then
      mpcConfig.external.gpgDir
    else
      customsecrets.gpgDir or "";
in
{
  # GPG configuration for commit signing
  # GPG agent configuration is managed at the system level in modules/core/program.nix
  # to avoid conflicts between system and home-manager configurations

  # Copy GPG keyring from backup directory during activation
  home.activation.copyGpgKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sourceDir="${gpgSourceDir}"
    if [[ -n "$sourceDir" && -d "$sourceDir" ]]; then
      echo "Copying GPG keyring from: $sourceDir"
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.gnupg
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 ~/.gnupg
      $DRY_RUN_CMD cp -r $VERBOSE_ARG "$sourceDir"/* ~/.gnupg/
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.gnupg/private-keys-v1.d/* 2>/dev/null || true
      $DRY_RUN_CMD chmod $VERBOSE_ARG 600 ~/.gnupg/trustdb.gpg 2>/dev/null || true
      echo "GPG keyring copied successfully"
    elif [[ -n "$sourceDir" ]]; then
      echo "WARNING: GPG source directory not found: $sourceDir"
    fi
  '';

  # GPG agent settings - cache passwords for longer to reduce prompts
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    defaultCacheTtl = 28800; # 8 hours
    maxCacheTtl = 86400; # 24 hours
    pinentry.package = pkgs.pinentry-curses; # Use terminal-based pinentry for WSL
  };
}
