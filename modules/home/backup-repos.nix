{
  config,
  pkgs,
  lib,
  customsecrets,
  host,
  ...
}:

let
  cfg = config.services.backup-repos;
  backupPath = customsecrets.backup.nasBackupPath or "/mnt/ugreen-nas/backups/repositories";
in
{
  options.services.backup-repos = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automated repository backups to NAS (default: disabled)";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "02:00";
      description = "When to run the backup (systemd calendar format, e.g., '02:00' for 2 AM daily)";
    };

    useChecksum = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use checksums instead of modification time to detect changes (slower but more accurate, prevents unnecessary writes)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Systemd user service for backing up repositories
    systemd.user.services.backup-repos = {
      Unit = {
        Description = "Backup Development Repositories to NAS";
        After = [ "network-online.target" ];
        # Don't restart service when configuration changes (only run on timer or manual invocation)
        X-RestartIfChanged = false;
      };
      Service = {
        Type = "oneshot";

        # Pre-flight check: ensure NAS mount exists
        ExecCondition = "${pkgs.coreutils}/bin/test -d /mnt/ugreen-nas";

        # Rsync backup with proper flags
        ExecStart = pkgs.writeShellScript "backup-repos" ''
          set -euo pipefail

          SOURCE="${config.home.homeDirectory}/Development/"
          DEST="${backupPath}/"
          LOG_FILE="${config.home.homeDirectory}/.local/state/backup-repos.log"

          # Create log directory if it doesn't exist
          ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$LOG_FILE")"

          # Log start time
          ${pkgs.coreutils}/bin/echo "=== Backup started at $(${pkgs.coreutils}/bin/date -Iseconds) ===" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"

          # Check if source directory exists
          if [ ! -d "$SOURCE" ]; then
            ${pkgs.coreutils}/bin/echo "ERROR: Source directory $SOURCE does not exist" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
            exit 1
          fi

          # Check if destination is accessible
          if [ ! -d "/mnt/ugreen-nas" ]; then
            ${pkgs.coreutils}/bin/echo "ERROR: NAS mount /mnt/ugreen-nas not available" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
            exit 1
          fi

          # Create backup destination if it doesn't exist
          ${pkgs.coreutils}/bin/mkdir -p "$DEST" 2>&1 | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE" || {
            ${pkgs.coreutils}/bin/echo "ERROR: Failed to create backup destination $DEST" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
            exit 1
          }

          # Perform rsync backup
          ${pkgs.rsync}/bin/rsync \
            --archive \
            --verbose \
            --human-readable \
            --delete \
            ${lib.optionalString cfg.useChecksum "--checksum"} \
            --exclude='.git/objects/pack/*.lock' \
            --exclude='node_modules/' \
            --exclude='target/' \
            --exclude='.direnv/' \
            --exclude='result' \
            --exclude='result-*' \
            --log-file="$LOG_FILE" \
            "$SOURCE" "$DEST" 2>&1 | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"

          RSYNC_EXIT=$?

          if [ $RSYNC_EXIT -eq 0 ]; then
            ${pkgs.coreutils}/bin/echo "=== Backup completed successfully at $(${pkgs.coreutils}/bin/date -Iseconds) ===" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
          else
            ${pkgs.coreutils}/bin/echo "=== Backup failed with exit code $RSYNC_EXIT at $(${pkgs.coreutils}/bin/date -Iseconds) ===" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
            exit $RSYNC_EXIT
          fi
        '';

        # Success notification (skip on WSL where notification daemon isn't available)
        ExecStartPost = pkgs.writeShellScript "backup-success-notify" ''
          if [ "$SERVICE_RESULT" = "success" ]; then
            # Only send notification if notification service is available
            if ${pkgs.procps}/bin/pgrep -x "notification-daemon\|dunst\|mako" > /dev/null 2>&1; then
              ${pkgs.libnotify}/bin/notify-send \
                --urgency=normal \
                --icon=dialog-information \
                "Repository Backup" \
                "Backup to NAS completed successfully at $(${pkgs.coreutils}/bin/date +%H:%M)"
            fi
          fi
        '';

        # Failure notification (skip on WSL where notification daemon isn't available)
        ExecStopPost = pkgs.writeShellScript "backup-failure-notify" ''
          if [ "$SERVICE_RESULT" != "success" ]; then
            # Only send notification if notification service is available
            if ${pkgs.procps}/bin/pgrep -x "notification-daemon\|dunst\|mako" > /dev/null 2>&1; then
              ${pkgs.libnotify}/bin/notify-send \
                --urgency=critical \
                --icon=dialog-error \
                "Repository Backup Failed" \
                "Backup to NAS failed. Check logs with: journalctl --user -u backup-repos.service"
            fi
          fi
        '';

        # Restart on failure with backoff
        Restart = "on-failure";
        RestartSec = 300; # 5 minutes
      };
      Install = {
        WantedBy = [ ]; # Activated by timer, not on boot
      };
    };

    # Systemd user timer for scheduled backups
    systemd.user.timers.backup-repos = {
      Unit = {
        Description = "Daily Repository Backup Timer";
      };
      Timer = {
        OnCalendar = cfg.schedule;
        Persistent = true; # Run on next boot if missed
        RandomizedDelaySec = "10m"; # Add random delay to avoid system load spikes
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
