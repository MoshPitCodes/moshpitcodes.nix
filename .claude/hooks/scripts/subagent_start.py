#!/usr/bin/env python3
"""
Subagent Start Hook

Logs when subagents are spawned during Claude Code sessions.
Useful for tracking agent usage, debugging multi-agent workflows.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def log_subagent_start(log_path: Path, subagent_info: dict):
    """Log subagent start event."""
    log_data = {
        'event': 'subagent_start',
        'session_id': subagent_info.get('session_id'),
        'subagent_id': subagent_info.get('subagent_id'),
        'subagent_type': subagent_info.get('subagent_type'),
        'description': subagent_info.get('description'),
        'timestamp': datetime.now().isoformat()
    }

    log_to_jsonl(log_path, log_data)


def main():
    """Main entry point for subagent_start hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'subagents.jsonl'

        # Log the subagent start
        log_subagent_start(log_path, hook_input)

        # Optional: notify about subagent spawn
        if '--notify' in sys.argv:
            subagent_type = hook_input.get('subagent_type', 'unknown')
            description = hook_input.get('description', 'No description')
            print(f"Subagent started: {subagent_type} - {description}", file=sys.stderr)

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: subagent_start hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
