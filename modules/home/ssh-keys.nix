{
  config,
  lib,
  pkgs,
  customsecrets,
  ...
}:

let
  cfg = customsecrets.sshKeys;
  hasSourceDir = cfg.sourceDir != null && cfg.sourceDir != "";
in
{
  config = lib.mkIf hasSourceDir {
    # SSH key copying via shell initialization instead of home-manager activation
    # This ensures mounts are ready before attempting to access Windows filesystem
    programs.zsh.initExtra = ''
      # Copy SSH keys from Windows on first interactive shell
      # Only runs once per boot to avoid unnecessary overhead
      _copy_ssh_keys_once() {
        local marker_file="$HOME/.ssh/.keys-copied-$$"
        local source_dir="${cfg.sourceDir}"

        # Skip if already copied this session or source doesn't exist
        if [ -f "$marker_file" ] || [ ! -d "$source_dir" ]; then
          return 0
        fi

        # Create .ssh directory if it doesn't exist
        mkdir -p "$HOME/.ssh"

        # Copy SSH keys from source directory
        local copied=0
        ${lib.concatMapStringsSep "\n        " (
          key: ''
        # Copy private key if it exists
        if [ -f "${cfg.sourceDir}/${key}" ]; then
          cp -f "${cfg.sourceDir}/${key}" "$HOME/.ssh/${key}"
          chmod 600 "$HOME/.ssh/${key}"
          copied=1
        fi

        # Copy public key if it exists
        if [ -f "${cfg.sourceDir}/${key}.pub" ]; then
          cp -f "${cfg.sourceDir}/${key}.pub" "$HOME/.ssh/${key}.pub"
          chmod 644 "$HOME/.ssh/${key}.pub"
          copied=1
        fi''
        ) cfg.keys}

        # Set .ssh directory permissions
        chmod 700 "$HOME/.ssh"

        # Create marker file to prevent re-copying this session
        if [ $copied -eq 1 ]; then
          touch "$marker_file"
        fi
      }

      # Run on interactive shell startup
      if [[ $- == *i* ]]; then
        _copy_ssh_keys_once
      fi
    '';
  };
}
