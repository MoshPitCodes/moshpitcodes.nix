"""File utilities for Claude Code hooks."""

import os
from pathlib import Path
from typing import Optional


def get_project_root() -> Path:
    """Get the project root directory from environment or current directory."""
    if 'CLAUDE_PROJECT_DIR' in os.environ:
        return Path(os.environ['CLAUDE_PROJECT_DIR'])
    return Path.cwd()


def ensure_dir_exists(path: Path) -> None:
    """Ensure a directory exists, creating it if necessary."""
    path.mkdir(parents=True, exist_ok=True)


def read_file_safe(file_path: Path, max_chars: int = 10000) -> Optional[str]:
    """Safely read a file with error handling and size limits."""
    try:
        if not file_path.exists():
            return None

        # Check file size
        size = file_path.stat().st_size
        if size == 0:
            return None
        if size > max_chars * 2:  # Rough estimate (2 bytes per char)
            # Read only first max_chars
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read(max_chars)
                if len(content) >= max_chars:
                    content += '\n\n... (truncated)'
                return content

        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read(max_chars)
            return content
    except Exception:
        return None


def find_file_up_tree(filename: str, start_dir: Path = None) -> Optional[Path]:
    """Find a file by searching up the directory tree."""
    if start_dir is None:
        start_dir = Path.cwd()

    current = start_dir.resolve()
    while current != current.parent:
        candidate = current / filename
        if candidate.exists():
            return candidate
        current = current.parent

    return None
