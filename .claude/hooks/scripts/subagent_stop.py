#!/usr/bin/env python3
"""
Subagent Stop Hook

Logs when subagents complete their work during Claude Code sessions.
Tracks agent completion status and duration.
"""

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def find_subagent_start_time(log_path: Path, subagent_id: str):
    """Find the start time for a subagent by reading the log file."""
    try:
        if not log_path.exists():
            return None

        # Read log file and find matching start event
        with open(log_path, 'r') as f:
            for line in f:
                try:
                    entry = json.loads(line.strip())
                    if (entry.get('event') == 'subagent_start' and
                        entry.get('subagent_id') == subagent_id):
                        return entry.get('timestamp')
                except json.JSONDecodeError:
                    continue
    except Exception:
        pass
    return None


def calculate_duration_seconds(start_time: str, end_time: str):
    """Calculate duration in seconds between two ISO timestamps."""
    try:
        start_dt = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
        end_dt = datetime.fromisoformat(end_time.replace('Z', '+00:00'))
        duration = (end_dt - start_dt).total_seconds()
        return round(duration, 2)
    except Exception:
        return None


def log_subagent_stop(log_path: Path, subagent_info: dict):
    """Log subagent stop event with duration tracking."""
    current_time = datetime.now().isoformat()
    subagent_id = subagent_info.get('subagent_id')

    log_data = {
        'event': 'subagent_stop',
        'session_id': subagent_info.get('session_id'),
        'subagent_id': subagent_id,
        'subagent_type': subagent_info.get('subagent_type'),
        'status': subagent_info.get('status', 'completed'),
        'timestamp': current_time
    }

    # Try to find start time and calculate duration
    if subagent_id:
        start_time = find_subagent_start_time(log_path, subagent_id)
        if start_time:
            duration = calculate_duration_seconds(start_time, current_time)
            if duration is not None:
                log_data['duration_seconds'] = duration
                log_data['duration_minutes'] = round(duration / 60, 2)
                log_data['start_time'] = start_time

    log_to_jsonl(log_path, log_data)


def main():
    """Main entry point for subagent_stop hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'subagents.jsonl'

        # Log the subagent stop
        log_subagent_stop(log_path, hook_input)

        # Optional: notify about subagent completion
        if '--notify' in sys.argv:
            subagent_type = hook_input.get('subagent_type', 'unknown')
            status = hook_input.get('status', 'completed')
            print(f"Subagent {status}: {subagent_type}", file=sys.stderr)

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: subagent_stop hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
