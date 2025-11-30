{
  config,
  lib,
  customsecrets,
  ...
}:

let
  cfg = customsecrets.sshKeys;
  hasSourceDir = cfg.sourceDir != null && cfg.sourceDir != "";
in
{
  config = lib.mkIf hasSourceDir {
    home.activation.copySshKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create .ssh directory if it doesn't exist
      run mkdir -p ${config.home.homeDirectory}/.ssh

      # Copy SSH keys from source directory
      ${lib.concatMapStringsSep "\n" (
        key: ''
          # Copy private key if it exists
          if [ -f "${cfg.sourceDir}/${key}" ]; then
            run cp -f "${cfg.sourceDir}/${key}" ${config.home.homeDirectory}/.ssh/${key}
            run chmod 600 ${config.home.homeDirectory}/.ssh/${key}
            $DRY_RUN_CMD echo "Copied SSH private key: ${key}"
          fi

          # Copy public key if it exists
          if [ -f "${cfg.sourceDir}/${key}.pub" ]; then
            run cp -f "${cfg.sourceDir}/${key}.pub" ${config.home.homeDirectory}/.ssh/${key}.pub
            run chmod 644 ${config.home.homeDirectory}/.ssh/${key}.pub
            $DRY_RUN_CMD echo "Copied SSH public key: ${key}.pub"
          fi
        ''
      ) cfg.keys}

      # Set .ssh directory permissions
      run chmod 700 ${config.home.homeDirectory}/.ssh
      $DRY_RUN_CMD echo "SSH keys copied successfully from ${cfg.sourceDir}"
    '';
  };
}
