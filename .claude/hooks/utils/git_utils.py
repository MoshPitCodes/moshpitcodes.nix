"""Git utilities for Claude Code hooks."""

import subprocess
from typing import Dict, Optional, Tuple


def run_git_command(args: list, cwd: str = None) -> Tuple[bool, str]:
    """Run a git command and return (success, output)."""
    try:
        result = subprocess.run(
            ['git'] + args,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0, result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False, ""


def get_git_branch(cwd: str = None) -> Optional[str]:
    """Get the current git branch name."""
    success, output = run_git_command(['branch', '--show-current'], cwd)
    return output if success else None


def get_git_uncommitted_count(cwd: str = None) -> int:
    """Get the number of uncommitted files."""
    success, output = run_git_command(['status', '--porcelain'], cwd)
    if not success:
        return 0
    return len([line for line in output.split('\n') if line.strip()])


def get_git_status(cwd: str = None) -> Dict[str, any]:
    """Get comprehensive git status information."""
    branch = get_git_branch(cwd)
    uncommitted = get_git_uncommitted_count(cwd)

    # Check if repo is clean
    is_clean = uncommitted == 0

    # Get last commit info
    success, last_commit = run_git_command(
        ['log', '-1', '--pretty=%h - %s (%cr)'],
        cwd
    )

    return {
        'branch': branch,
        'uncommitted_count': uncommitted,
        'is_clean': is_clean,
        'last_commit': last_commit if success else None,
        'is_git_repo': branch is not None
    }


def is_git_repo(cwd: str = None) -> bool:
    """Check if the directory is a git repository."""
    success, _ = run_git_command(['rev-parse', '--git-dir'], cwd)
    return success
