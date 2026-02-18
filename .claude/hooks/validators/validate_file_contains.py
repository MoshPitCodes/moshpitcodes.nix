#!/usr/bin/env python3
"""
Validate that files in a directory contain specific required strings.

Usage:
    validate_file_contains.py --directory <dir> --extension <ext> --contains <string> [--contains <string> ...]

Example:
    validate_file_contains.py --directory specs --extension .md --contains "## Task Description" --contains "## Objective"
"""

import argparse
import os
import sys
from pathlib import Path


def validate_file_contains(directory: str, extension: str, required_strings: list[str]) -> tuple[bool, str]:
    """
    Validate that files in the directory contain all required strings.

    Args:
        directory: Directory to check
        extension: File extension to check (e.g., '.md')
        required_strings: List of strings that must be present in the file

    Returns:
        Tuple of (is_valid, message)
    """
    # Get project directory
    project_dir = os.environ.get('CLAUDE_PROJECT_DIR', os.getcwd())
    target_dir = Path(project_dir) / directory

    # Check if directory exists
    if not target_dir.exists():
        return False, f"Directory '{directory}' does not exist"

    # Ensure extension starts with dot
    if not extension.startswith('.'):
        extension = f'.{extension}'

    # Find all files with the extension
    files = list(target_dir.glob(f'*{extension}'))

    if not files:
        return False, f"No files with extension '{extension}' found in '{directory}'"

    # Check the most recently modified file
    latest_file = max(files, key=lambda p: p.stat().st_mtime)

    try:
        content = latest_file.read_text(encoding='utf-8')
    except Exception as e:
        return False, f"Failed to read file '{latest_file.name}': {e}"

    # Check for required strings
    missing_strings = []
    for required in required_strings:
        if required not in content:
            missing_strings.append(required)

    if missing_strings:
        message = f"✗ File '{latest_file.name}' is missing required content:\n"
        for missing in missing_strings:
            message += f"  - {missing}\n"
        return False, message.rstrip()

    return True, f"✓ File '{latest_file.name}' contains all required sections"


def main():
    parser = argparse.ArgumentParser(
        description='Validate that files contain required strings'
    )
    parser.add_argument(
        '--directory',
        required=True,
        help='Directory to check'
    )
    parser.add_argument(
        '--extension',
        required=True,
        help='File extension to check (e.g., .md)'
    )
    parser.add_argument(
        '--contains',
        action='append',
        required=True,
        help='Required string (can be specified multiple times)'
    )

    args = parser.parse_args()

    is_valid, message = validate_file_contains(
        args.directory,
        args.extension,
        args.contains
    )

    print(message)

    if not is_valid:
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
