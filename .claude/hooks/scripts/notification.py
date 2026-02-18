#!/usr/bin/env python3
"""
Notification Hook

Processes and logs Claude Code notifications.
Can be extended to send notifications to external systems.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def log_notification(log_path: Path, notification_info: dict):
    """Log notification event."""
    log_data = {
        'event': 'notification',
        'session_id': notification_info.get('session_id'),
        'notification_type': notification_info.get('type'),
        'message': notification_info.get('message'),
        'level': notification_info.get('level', 'info'),
        'timestamp': datetime.now().isoformat()
    }

    log_to_jsonl(log_path, log_data)


def main():
    """Main entry point for notification hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'notifications.jsonl'

        # Log the notification
        log_notification(log_path, hook_input)

        # Could extend to:
        # - Send to Slack/Discord/email
        # - Trigger webhooks
        # - Update dashboards
        # - etc.

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: notification hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
