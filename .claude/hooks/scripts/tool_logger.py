#!/usr/bin/env python3
"""
Tool Usage Logger - Logs all tool calls to JSONL file
"""
import json
import sys
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def main():
    """Main entry point for tool_logger hook."""
    try:
        # Read JSON input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root and log path
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'tool_use.jsonl'

        # Log tool usage
        log_to_jsonl(log_path, hook_input)

        # Allow the action to proceed
        sys.exit(0)

    except Exception as e:
        # Don't fail the tool use on logging error
        print(f"Warning: tool_logger hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
