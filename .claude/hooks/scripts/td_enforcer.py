#!/usr/bin/env python3
"""
TD Enforcer - Ensures all code changes are linked to TD tasks
"""
import json
import sys
import subprocess
import re
from pathlib import Path

def is_td_available() -> bool:
    """Check if TD is installed and initialized"""
    try:
        subprocess.run(["td", "--version"], capture_output=True, check=True)
        return Path(".todos").exists()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def get_active_task() -> str | None:
    """Get the currently active TD task"""
    try:
        result = subprocess.run(
            ["td", "status", "--json"],
            capture_output=True,
            text=True,
            check=True
        )
        status = json.loads(result.stdout)
        focused = status.get("focused", {})
        if focused and "issue" in focused:
            return focused["issue"].get("id")
        return None
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None

def is_file_linked(task_key: str, file_path: str) -> bool:
    """Check if file is linked to the task"""
    try:
        result = subprocess.run(
            ["td", "status", "--file", file_path],
            capture_output=True,
            text=True,
            check=True
        )
        return task_key in result.stdout
    except subprocess.CalledProcessError:
        return False

def link_file_to_task(task_key: str, file_path: str):
    """Link file to the current task"""
    try:
        subprocess.run(
            ["td", "link", task_key, file_path],
            capture_output=True,
            check=True
        )
    except subprocess.CalledProcessError:
        pass

def is_code_file(file_path: str) -> bool:
    """Check if file is a code file that should be tracked"""
    code_extensions = [
        '.ts', '.tsx', '.js', '.jsx', '.go', '.py', '.java', '.kt',
        '.rs', '.c', '.cpp', '.h', '.hpp', '.rb', '.php', '.swift'
    ]
    return any(file_path.endswith(ext) for ext in code_extensions)

def main():
    try:
        # Read JSON input from stdin
        hook_input = json.load(sys.stdin)

        # Check if TD is available
        if not is_td_available():
            sys.exit(0)

        tool_name = hook_input.get("tool_name", "")
        tool_input = hook_input.get("tool_input", {})
        file_path = tool_input.get("file_path", "")

        # Only enforce for Edit and Write operations on code files
        if tool_name not in ["Edit", "Write"]:
            sys.exit(0)

        if not file_path or not is_code_file(file_path):
            sys.exit(0)

        # Get current active task
        active_task = get_active_task()

        # If no task is active, block and instruct Claude to create one
        if not active_task:
            print("No active TD task. Create a task first using: td create \"<description>\" && td start <task-id>", file=sys.stderr)
            sys.exit(2)

        # Check if file is linked, if not, auto-link it
        if not is_file_linked(active_task, file_path):
            link_file_to_task(active_task, file_path)

        # Allow the operation
        sys.exit(0)

    except Exception as e:
        # Don't block operations if the enforcer itself fails
        print(f"Warning: td_enforcer hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == "__main__":
    main()
