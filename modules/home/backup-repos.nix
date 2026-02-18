# Automated NAS backup service for ~/Development
{
  pkgs,
  lib,
  config,
  customsecrets,
  host,
  ...
}:
let
  backupPath = customsecrets.backup.nasBackupPath or "";
  hasBackupPath = backupPath != "";
in
{
  # Only enable if backup path is configured
  systemd.user.services.backup-repos = lib.mkIf hasBackupPath {
    Unit = {
      Description = "Backup Development repositories to NAS";
      After = [ "default.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "backup-repos" ''
        set -euo pipefail
        LOG="$HOME/.local/state/backup-repos.log"
        mkdir -p "$(dirname "$LOG")"

        log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

        SOURCE="$HOME/Development/"
        DEST="${backupPath}/${host}"

        # Pre-flight checks
        if [ ! -d "$SOURCE" ]; then
          log "ERROR: Source directory $SOURCE does not exist"
          exit 1
        fi

        # Check parent directory (the configured backup path)
        if [ ! -d "${backupPath}" ] && [ ! -L "${backupPath}" ]; then
          log "WARNING: Destination ${backupPath} not available (NAS not mounted?). Skipping."
          ${pkgs.libnotify}/bin/notify-send -u normal "Backup Skipped" "NAS not available at ${backupPath}" 2>/dev/null || true
          exit 0
        fi

        # Create destination subdirectory if needed
        mkdir -p "$DEST" 2>/dev/null || true

        log "Starting backup: $SOURCE -> $DEST"

        ${pkgs.rsync}/bin/rsync -rltv --delete \
          --no-perms --no-owner --no-group \
          --chmod=D755,F644 \
          --exclude='node_modules/' \
          --exclude='target/' \
          --exclude='.direnv/' \
          --exclude='result' \
          --exclude='.git/objects/' \
          --exclude='*.lock' \
          --temp-dir=/tmp \
          "$SOURCE" "$DEST/" 2>&1 | tee -a "$LOG"

        log "Backup completed successfully"
        ${pkgs.libnotify}/bin/notify-send -u low "Backup Complete" "Development repos backed up to NAS" 2>/dev/null || true
      '';

      Restart = "on-failure";
      RestartSec = "5min";
    };
  };

  systemd.user.timers.backup-repos = lib.mkIf hasBackupPath {
    Unit.Description = "Daily Development backup timer";

    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "10min";
    };

    Install.WantedBy = [ "timers.target" ];
  };

  # Shell aliases for backup management
  programs.zsh.shellAliases = lib.mkIf hasBackupPath {
    backup-repos-now = "systemctl --user start backup-repos.service";
    backup-repos-status = "systemctl --user status backup-repos.service";
    backup-repos-logs = "tail -50 ~/.local/state/backup-repos.log";
    backup-repos-timer = "systemctl --user list-timers backup-repos.timer";
  };
}
