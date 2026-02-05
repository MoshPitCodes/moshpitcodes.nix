{
  lib,
  customsecrets,
  mpcConfig ? { },
  pkgs,
  ...
}:
let
  # Get backup destination from mpcConfig (preferred) or fall back to default
  nasBackupDir =
    if
      (mpcConfig ? external) && (mpcConfig.external ? secretsDir) && (mpcConfig.external.secretsDir != "")
    then
      # Derive backup root from secrets dir (go up one level)
      builtins.dirOf mpcConfig.external.secretsDir
    else
      "/mnt/ugreen-nas/Coding/SecretsBackup2025";

  # Backup script
  backupScript = pkgs.writeShellScript "backup-keys" ''
    #!/usr/bin/env bash
    set -euo pipefail

    BACKUP_DIR="${nasBackupDir}"

    # Check if NAS is mounted
    if ! mountpoint -q /mnt/ugreen-nas; then
      echo "ERROR: NAS is not mounted at /mnt/ugreen-nas"
      exit 1
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"/{.ssh,.gnupg,.config/gh,.secrets}

    echo "Backing up SSH keys..."
    ${pkgs.rsync}/bin/rsync -av --delete \
      --exclude='known_hosts*' \
      --exclude='config' \
      ~/.ssh/ "$BACKUP_DIR/.ssh/" || true

    echo "Backing up GPG keyring..."
    ${pkgs.rsync}/bin/rsync -av --delete \
      --exclude='*.lock' \
      --exclude='*.tmp' \
      --exclude='S.*' \
      --exclude='gpg-agent.conf' \
      ~/.gnupg/ "$BACKUP_DIR/.gnupg/" || true

    echo "Backing up GitHub CLI config..."
    ${pkgs.rsync}/bin/rsync -av --delete \
      ~/.config/gh/ "$BACKUP_DIR/.config/gh/" || true

    echo "Backing up secrets..."
    if [[ -f ~/.secrets/env-secrets.sh ]]; then
      ${pkgs.rsync}/bin/rsync -av \
        ~/.secrets/env-secrets.sh "$BACKUP_DIR/.secrets/" || true
    fi

    # Set proper permissions on NAS backup
    chmod -R 700 "$BACKUP_DIR"/.ssh "$BACKUP_DIR"/.gnupg "$BACKUP_DIR"/.config/gh "$BACKUP_DIR"/.secrets 2>/dev/null || true
    chmod 600 "$BACKUP_DIR"/.ssh/* 2>/dev/null || true
    chmod 644 "$BACKUP_DIR"/.ssh/*.pub 2>/dev/null || true
    chmod 600 "$BACKUP_DIR"/.secrets/* 2>/dev/null || true

    echo "Backup completed successfully at $(date)"
  '';
in
{
  # Systemd service to backup keys
  systemd.user.services.backup-keys = {
    Unit = {
      Description = "Backup SSH and GPG keys to NAS";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${backupScript}";
      # Only run if NAS is mounted
      ExecStartPre = "${pkgs.coreutils}/bin/mountpoint -q /mnt/ugreen-nas";
    };
  };

  # Timer to run backup weekly
  systemd.user.timers.backup-keys = {
    Unit = {
      Description = "Weekly backup of SSH and GPG keys";
    };

    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      Unit = "backup-keys.service";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Add manual backup alias
  programs.zsh.shellAliases = {
    backup-keys = "systemctl --user start backup-keys.service";
    backup-keys-status = "systemctl --user status backup-keys.service";
  };
}
