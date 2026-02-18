#!/usr/bin/env python3
"""
Security Hook - Blocks dangerous operations and protects sensitive files
"""
import json
import sys
import re
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def block_action(reason: str, hook_input: dict):
    """Block the action and log the security event"""
    try:
        # Get project root and log path
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'security_blocks.jsonl'

        # Prepare log entry
        log_entry = {
            **hook_input,
            "event": "security_block",
            "blocked": True,
            "reason": reason
        }

        # Log the blocked operation
        log_to_jsonl(log_path, log_entry)
    except Exception as e:
        # Don't fail blocking if logging fails
        print(f"Warning: Security logging failed: {e}", file=sys.stderr)

    # Return error to stderr and exit with code 2
    print(reason, file=sys.stderr)
    sys.exit(2)

def main():
    """Main entry point for security_check hook."""
    try:
        # Read JSON input from stdin
        hook_input = json.load(sys.stdin)

        tool_name = hook_input.get("tool_name", "")
        tool_input = hook_input.get("tool_input", {})

        # Check Bash commands
        if tool_name == "Bash":
            command = tool_input.get("command", "")

            # Note: rm -rf and rm --recursive are already denied by permission
            # rules in settings.json. These patterns serve as defense-in-depth
            # for edge cases the permission glob might miss.
            dangerous_rm_patterns = [
                r'rm\s+(-[a-z]*r[a-z]*f|--recursive.*--force|-[a-z]*f[a-z]*r|--force.*--recursive)',
                r'rm\s+-rf\s+/',
                r'rm\s+-rf\s+\.',
                r'rm\s+-rf\s+\*',
            ]

            for pattern in dangerous_rm_patterns:
                if re.search(pattern, command, re.IGNORECASE):
                    block_action("Blocked dangerous rm -rf command for security", hook_input)

            # Block commands that modify system paths (write/delete operations).
            # Read-only commands mentioning system paths are allowed.
            system_paths = ["/etc/", "/usr/", "/var/", "/System/"]
            write_prefixes = re.compile(
                r'(^|[;&|]\s*)(sudo\s+)?(rm|mv|cp|chmod|chown|chgrp|install|ln|mkdir|rmdir|tee|dd|mkfs|mount)\b'
            )
            if write_prefixes.search(command):
                for sys_path in system_paths:
                    if sys_path in command:
                        block_action(f"Blocked system file modification: {sys_path}", hook_input)

        # Check file access (Read, Edit, Write)
        if tool_name in ["Read", "Edit", "Write"]:
            file_path = tool_input.get("file_path", "")

            # Block .env file access (but allow .env.example, .env.sample, .env.template)
            if re.search(r'\.env$', file_path) and not re.search(r'\.(example|sample|template)', file_path):
                block_action("Blocked access to .env file for security", hook_input)

            # Block credential files
            if re.search(r'\.(key|pem)$|credentials\.json$', file_path):
                block_action("Blocked access to credential file for security", hook_input)

        # Allow the action
        sys.exit(0)

    except Exception as e:
        # Don't fail security checks on errors - allow action
        print(f"Warning: security_check hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
