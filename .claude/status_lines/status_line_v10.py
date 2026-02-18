#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

"""
Status Line v10 - Combined Workspace + Resource Tracking
Display: [Model] | 📁 directory | 🌿 branch ±N | [###---] 42.5% | ~115k left
Combines workspace context (directory, git) with resource tracking (context window usage)
"""

import json
import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv is optional


# ANSI color codes
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
BRIGHT_WHITE = "\033[97m"
DIM = "\033[90m"
RESET = "\033[0m"


def log_status_line(input_data, status_line_output):
    """Log status line event to logs directory."""
    # Ensure logs directory exists
    log_dir = Path(".claude/logs")
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / 'status_line.json'

    # Read existing log data or initialize empty list
    if log_file.exists():
        with open(log_file, 'r') as f:
            try:
                log_data = json.load(f)
            except (json.JSONDecodeError, ValueError):
                log_data = []
    else:
        log_data = []

    # Create log entry with input data and generated output
    log_entry = {
        "timestamp": datetime.now().isoformat(),
        "version": "v10",
        "input_data": input_data,
        "status_line_output": status_line_output
    }

    # Append the log entry
    log_data.append(log_entry)

    # Write back to file with formatting
    with open(log_file, 'w') as f:
        json.dump(log_data, f, indent=2)


def get_git_branch():
    """Get current git branch if in a git repository."""
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception:
        pass
    return None


def get_git_status():
    """Get git status indicators."""
    try:
        # Check if there are uncommitted changes
        result = subprocess.run(
            ['git', 'status', '--porcelain'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            changes = result.stdout.strip()
            if changes:
                lines = changes.split('\n')
                return f"±{len(lines)}"
    except Exception:
        pass
    return ""


def get_usage_color(percentage):
    """Get color based on usage percentage."""
    if percentage < 50:
        return GREEN
    elif percentage < 75:
        return YELLOW
    elif percentage < 90:
        return RED
    else:
        return "\033[91m"  # Bright red for critical


def create_progress_bar(percentage, width=10):
    """Create a visual progress bar."""
    filled = int((percentage / 100) * width)
    empty = width - filled

    color = get_usage_color(percentage)

    # Use # for filled, - for empty
    bar = f"{color}{'#' * filled}{DIM}{'-' * empty}{RESET}"
    return f"[{bar}]"


def format_tokens(tokens):
    """Format token count in human-readable format."""
    if tokens is None:
        return "0"
    if tokens < 1000:
        return str(int(tokens))
    elif tokens < 1000000:
        return f"{tokens / 1000:.1f}k"
    else:
        return f"{tokens / 1000000:.2f}M"


def generate_status_line(input_data):
    """Generate the combined status line with workspace and resource tracking."""
    parts = []

    # Model display name
    model_info = input_data.get('model', {})
    model_name = model_info.get('display_name', 'Claude')
    parts.append(f"{CYAN}[{model_name}]{RESET}")

    # Current directory
    workspace = input_data.get('workspace', {})
    current_dir = workspace.get('current_dir', '')
    if current_dir:
        dir_name = os.path.basename(current_dir)
        parts.append(f"{BLUE}📁 {dir_name}{RESET}")

    # Git branch and status
    git_branch = get_git_branch()
    if git_branch:
        git_status = get_git_status()
        git_info = f"🌿 {git_branch}"
        if git_status:
            git_info += f" {git_status}"
        parts.append(f"{GREEN}{git_info}{RESET}")

    # Context window usage
    context_data = input_data.get('context_window', {})
    used_percentage = context_data.get('used_percentage', 0) or 0
    context_window_size = context_data.get('context_window_size', 200000) or 200000

    # Calculate remaining tokens from used percentage
    remaining_tokens = int(context_window_size * ((100 - used_percentage) / 100))

    # Progress bar
    progress_bar = create_progress_bar(used_percentage)
    parts.append(progress_bar)

    # Usage percentage with color
    usage_color = get_usage_color(used_percentage)
    parts.append(f"{usage_color}{used_percentage:.1f}%{RESET}")

    # Tokens remaining
    tokens_left_str = format_tokens(remaining_tokens)
    parts.append(f"{BLUE}~{tokens_left_str} left{RESET}")

    return " | ".join(parts)


def main():
    try:
        # Read JSON input from stdin
        input_data = json.loads(sys.stdin.read())

        # Generate status line
        status_line = generate_status_line(input_data)

        # Log the status line event
        log_status_line(input_data, status_line)

        # Output the status line (first line of stdout becomes the status line)
        print(status_line)

        # Success
        sys.exit(0)

    except json.JSONDecodeError:
        # Handle JSON decode errors gracefully - output basic status
        print(f"{RED}[Claude] 📁 JSON Error{RESET}")
        sys.exit(0)
    except Exception:
        # Handle any other errors gracefully - output basic status
        print(f"{RED}[Claude] 📁 Error{RESET}")
        sys.exit(0)


if __name__ == '__main__':
    main()
