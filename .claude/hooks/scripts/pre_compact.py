#!/usr/bin/env python3
"""
Pre-Compact Hook

Backs up transcripts before compaction operations.
Preserves full conversation history for auditing and recovery.
"""

import json
import sys
import shutil
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root, ensure_dir_exists
from log_utils import log_to_jsonl


def backup_transcript(transcript_path: Path, backup_dir: Path) -> bool:
    """
    Backup a transcript file before compaction.
    Returns True if backup was successful.
    """
    try:
        if not transcript_path.exists():
            return False

        # Create backup directory
        ensure_dir_exists(backup_dir)

        # Generate backup filename with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_name = f"{transcript_path.stem}_{timestamp}.jsonl"
        backup_path = backup_dir / backup_name

        # Copy the transcript
        shutil.copy2(transcript_path, backup_path)

        return True
    except Exception as e:
        print(f"Backup failed: {e}", file=sys.stderr)
        return False


def main():
    """Main entry point for pre_compact hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()

        # Get transcript path from input
        transcript_path_str = hook_input.get('transcript_path')
        if not transcript_path_str:
            # No transcript path provided
            sys.exit(0)

        transcript_path = Path(transcript_path_str)

        # Set up backup directory
        backup_dir = project_root / '.claude' / 'logs' / 'transcript_backups'

        # Backup the transcript
        success = backup_transcript(transcript_path, backup_dir)

        # Log the operation
        log_path = project_root / '.claude' / 'logs' / 'pre_compact.jsonl'
        log_data = {
            'event': 'pre_compact',
            'session_id': hook_input.get('session_id'),
            'transcript_path': str(transcript_path),
            'backup_success': success,
            'timestamp': datetime.now().isoformat()
        }
        log_to_jsonl(log_path, log_data)

        if success:
            print(f"Transcript backed up to {backup_dir}", file=sys.stderr)
        else:
            print("Warning: Transcript backup failed", file=sys.stderr)

        sys.exit(0)

    except Exception as e:
        # Don't block compaction on error
        print(f"Warning: pre_compact hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
