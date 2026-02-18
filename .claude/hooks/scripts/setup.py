#!/usr/bin/env python3
"""
Setup Hook

Runs during repository initialization to ensure the hooks environment
is properly configured.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root, ensure_dir_exists
from log_utils import log_to_jsonl


def ensure_log_directories(project_root: Path):
    """Ensure all required log directories exist."""
    log_dirs = [
        project_root / '.claude' / 'logs',
        project_root / '.claude' / 'logs' / 'transcript_backups',
        project_root / '.claude' / 'data',
    ]
    for d in log_dirs:
        ensure_dir_exists(d)


def main():
    """Main entry point for setup hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()

        # Ensure log directories exist
        ensure_log_directories(project_root)

        # Log setup event
        log_path = project_root / '.claude' / 'logs' / 'setup.jsonl'
        log_data = {
            'event': 'setup',
            'session_id': hook_input.get('session_id'),
            'timestamp': datetime.now().isoformat()
        }
        log_to_jsonl(log_path, log_data)

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: setup hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
