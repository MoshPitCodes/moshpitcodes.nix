#!/usr/bin/env python3
"""
Validate that a new file was created in the specified directory with the expected extension.

Usage:
    validate_new_file.py --directory <dir> --extension <ext>

Example:
    validate_new_file.py --directory specs --extension .md
"""

import argparse
import os
import sys
from pathlib import Path


def validate_new_file(directory: str, extension: str) -> tuple[bool, str]:
    """
    Validate that at least one new file exists in the directory with the specified extension.

    Args:
        directory: Directory to check for new files
        extension: File extension to look for (e.g., '.md')

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

    # Get the most recently modified file
    latest_file = max(files, key=lambda p: p.stat().st_mtime)

    return True, f"✓ Found file: {latest_file.name}"


def main():
    parser = argparse.ArgumentParser(
        description='Validate that a new file was created'
    )
    parser.add_argument(
        '--directory',
        required=True,
        help='Directory to check for new files'
    )
    parser.add_argument(
        '--extension',
        required=True,
        help='File extension to look for (e.g., .md)'
    )

    args = parser.parse_args()

    is_valid, message = validate_new_file(args.directory, args.extension)

    print(message)

    if not is_valid:
        sys.exit(1)

    sys.exit(0)


if __name__ == '__main__':
    main()
