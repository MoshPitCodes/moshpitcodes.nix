"""Shared utilities for Claude Code hooks."""

from .log_utils import setup_logger, log_to_jsonl
from .git_utils import get_git_status, get_git_branch, get_git_uncommitted_count
from .file_utils import read_file_safe, ensure_dir_exists, get_project_root

__all__ = [
    'setup_logger',
    'log_to_jsonl',
    'get_git_status',
    'get_git_branch',
    'get_git_uncommitted_count',
    'read_file_safe',
    'ensure_dir_exists',
    'get_project_root',
]
