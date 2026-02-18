# GPG key management
{
  pkgs,
  lib,
  customsecrets,
  ...
}:
{
  # Copy GPG keys from backup during activation
  home.activation.copyGPGKeys = lib.mkIf (customsecrets ? gpgDir) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "${customsecrets.gpgDir}" ]; then
        # Stop gpg-agent to prevent races with key directory
        ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent 2>/dev/null || true

        # Create .gnupg with proper permissions
        install -d -m 0700 "$HOME/.gnupg"

        # Copy keys (--no-preserve=mode for CIFS mount compatibility)
        cp -rf --no-preserve=mode "${customsecrets.gpgDir}"/* "$HOME/.gnupg/" 2>/dev/null || true

        # Fix permissions
        find "$HOME/.gnupg" -type d -exec chmod 700 {} \;
        find "$HOME/.gnupg" -type f -exec chmod 600 {} \;

        # Restart gpg-agent
        ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent 2>/dev/null || true
      fi
    ''
  );
}
