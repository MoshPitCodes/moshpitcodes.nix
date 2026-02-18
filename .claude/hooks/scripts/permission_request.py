#!/usr/bin/env python3
"""
Permission Request Hook

Logs permission request events for auditing.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def main():
    """Main entry point for permission_request hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'permissions.jsonl'

        # Log the permission request
        log_data = {
            'event': 'permission_request',
            'session_id': hook_input.get('session_id'),
            'tool_name': hook_input.get('tool_name'),
            'tool_input': hook_input.get('tool_input'),
            'timestamp': datetime.now().isoformat()
        }

        # Check for --log-only flag
        if '--log-only' in sys.argv:
            log_to_jsonl(log_path, log_data)

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: permission_request hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
