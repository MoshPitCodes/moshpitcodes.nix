#!/usr/bin/env python3
"""
Idle Session Detector - Prompts Claude when stopping without completing tasks
"""
import json
import sys
import re
from pathlib import Path

def check_for_incomplete_work(transcript_path: str) -> tuple[bool, str]:
    """Check transcript for signs of incomplete work in actual code"""
    try:
        # Read transcript as JSONL
        with open(transcript_path, 'r') as f:
            lines = f.readlines()

        # Get last 20 entries
        recent_lines = lines[-20:] if len(lines) >= 20 else lines

        # Parse JSONL and extract tool inputs (actual code)
        code_content = []
        for line in recent_lines:
            try:
                entry = json.loads(line)
                # Only check tool inputs (Edit, Write, Bash commands)
                if entry.get("type") == "tool_use":
                    tool_name = entry.get("name", "")
                    if tool_name in ["Edit", "Write", "Bash", "NotebookEdit"]:
                        tool_input = entry.get("input", {})
                        # Collect code content from various tool parameters
                        if "content" in tool_input:
                            code_content.append(tool_input["content"])
                        if "new_string" in tool_input:
                            code_content.append(tool_input["new_string"])
                        if "command" in tool_input:
                            code_content.append(tool_input["command"])
                        if "new_source" in tool_input:
                            code_content.append(tool_input["new_source"])
            except (json.JSONDecodeError, KeyError):
                continue

        # Only check actual code content, not conversation
        all_code = '\n'.join(code_content)

        # Patterns indicating incomplete work in code
        incomplete_patterns = [
            (r'#\s*TODO\b', "TODO comments in code"),
            (r'#\s*FIXME\b', "FIXME comments in code"),
            (r'//\s*TODO\b', "TODO comments in code"),
            (r'//\s*FIXME\b', "FIXME comments in code"),
        ]

        for pattern, message in incomplete_patterns:
            if re.search(pattern, all_code, re.IGNORECASE):
                return True, message

        return False, ""

    except Exception:
        # If we can't read transcript, allow stopping
        return False, ""

def main():
    # Read JSON input from stdin
    hook_input = json.load(sys.stdin)

    transcript_path = hook_input.get("transcript_path", "")

    # Check if transcript is available
    if not transcript_path or not Path(transcript_path).exists():
        sys.exit(0)

    # Check for incomplete work
    has_issues, reason = check_for_incomplete_work(transcript_path)

    if has_issues:
        # Output a plain-text message that gets injected as a follow-up user
        # message, prompting Claude to continue working.
        print(f"There appear to be incomplete tasks or errors ({reason}). Please verify all work is complete before stopping.")

    sys.exit(0)

if __name__ == "__main__":
    main()
