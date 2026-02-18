#!/usr/bin/env python3
"""
Session End Hook

Logs session completion and performs cleanup tasks.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def log_session_end(log_path: Path, session_info: dict):
    """Log session end event."""
    log_data = {
        'event': 'session_end',
        'session_id': session_info.get('session_id'),
        'reason': session_info.get('reason', 'unknown'),
        'timestamp': datetime.now().isoformat()
    }

    log_to_jsonl(log_path, log_data)


def main():
    """Main entry point for session_end hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'session_end.jsonl'

        # Log the session end
        log_session_end(log_path, hook_input)

        # Could add cleanup tasks here:
        # - Archive logs
        # - Update statistics
        # - Sync with external systems
        # - etc.

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: session_end hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
