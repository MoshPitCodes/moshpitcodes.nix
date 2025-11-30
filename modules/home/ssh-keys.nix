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
      # Wait for WSL mounts to be ready before attempting to copy
      # This prevents errors during boot when /mnt/c might not be mounted yet
      max_wait=30
      wait_count=0
      while [ ! -d "${cfg.sourceDir}" ] && [ $wait_count -lt $max_wait ]; do
        $DRY_RUN_CMD echo "Waiting for ${cfg.sourceDir} to be available... ($wait_count/$max_wait)"
        sleep 1
        wait_count=$((wait_count + 1))
      done

      if [ ! -d "${cfg.sourceDir}" ]; then
        $DRY_RUN_CMD echo "Warning: SSH key source directory ${cfg.sourceDir} not found after waiting. Skipping SSH key copy."
      else
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
      fi
    '';
  };
}
