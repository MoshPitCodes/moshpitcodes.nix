#!/usr/bin/env python3
"""
Post Tool Use Failure Hook

Handles and logs tool execution failures.
Provides debugging information and error context to Claude.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def log_tool_failure(log_path: Path, failure_info: dict):
    """Log tool failure event."""
    log_data = {
        'event': 'tool_failure',
        'session_id': failure_info.get('session_id'),
        'tool_name': failure_info.get('tool_name'),
        'tool_use_id': failure_info.get('tool_use_id'),
        'error_message': failure_info.get('error'),
        'exit_code': failure_info.get('exit_code'),
        'timestamp': datetime.now().isoformat()
    }

    # Include tool input for debugging
    if 'tool_input' in failure_info:
        tool_input = failure_info['tool_input']
        # Sanitize sensitive data
        if isinstance(tool_input, dict):
            # Don't log full file contents
            if 'content' in tool_input:
                tool_input['content'] = f"<{len(tool_input['content'])} chars>"
            log_data['tool_input'] = tool_input

    log_to_jsonl(log_path, log_data)


def provide_error_context(failure_info: dict) -> dict:
    """Provide additional context about the failure to Claude."""
    tool_name = failure_info.get('tool_name', 'unknown')
    error = failure_info.get('error', 'Unknown error')
    exit_code = failure_info.get('exit_code')

    # Build helpful context message
    context_message = f"## Tool Failure: {tool_name}\n\n"
    context_message += f"**Error:** {error}\n\n"

    if exit_code:
        context_message += f"**Exit Code:** {exit_code}\n\n"

    # Add tool-specific guidance
    if tool_name == 'Bash':
        context_message += "**Debugging Tips:**\n"
        context_message += "- Check command syntax\n"
        context_message += "- Verify file paths exist\n"
        context_message += "- Check permissions\n"
        context_message += "- Ensure required tools are installed\n"
    elif tool_name in ['Edit', 'Write']:
        context_message += "**Debugging Tips:**\n"
        context_message += "- Verify file path is correct\n"
        context_message += "- Check write permissions\n"
        context_message += "- Ensure directory exists\n"
    elif tool_name == 'Read':
        context_message += "**Debugging Tips:**\n"
        context_message += "- Verify file exists\n"
        context_message += "- Check read permissions\n"
        context_message += "- Ensure path is absolute\n"

    return {
        'hookSpecificOutput': {
            'hookEventName': 'PostToolUseFailure',
            'additionalContext': context_message
        }
    }


def main():
    """Main entry point for post_tool_use_failure hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'tool_failures.jsonl'

        # Log the failure
        log_tool_failure(log_path, hook_input)

        # Provide error context to Claude
        output = provide_error_context(hook_input)
        print(json.dumps(output))

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: post_tool_use_failure hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
