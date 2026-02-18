#!/usr/bin/env python3
"""
Session Start Hook

Loads development context at the beginning of a Claude Code session.
Provides git status, recent issues, and project documentation.
"""

import json
import sys
import subprocess
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from git_utils import get_git_status, is_git_repo
from file_utils import get_project_root, read_file_safe
from log_utils import log_to_jsonl


def get_recent_issues(cwd: Path, limit: int = 5) -> list:
    """Get recent GitHub issues if gh CLI is available."""
    try:
        result = subprocess.run(
            ['gh', 'issue', 'list', '--limit', str(limit), '--json', 'number,title,state'],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode == 0:
            issues = json.loads(result.stdout)
            return issues
    except (FileNotFoundError, subprocess.TimeoutExpired, json.JSONDecodeError):
        pass
    return []


def load_development_context(cwd: Path, session_info: dict) -> dict:
    """Load comprehensive development context."""
    context = {
        'timestamp': datetime.now().isoformat(),
        'session_id': session_info.get('session_id'),
        'session_source': session_info.get('source', 'unknown'),
    }

    # Git status
    if is_git_repo(str(cwd)):
        git_status = get_git_status(str(cwd))
        context['git'] = git_status

        # Get recent issues if available
        issues = get_recent_issues(cwd)
        if issues:
            context['recent_issues'] = issues

    # Load project documentation files
    doc_files = [
        '.claude/CONTEXT.md',
        'TODO.md',
        'ROADMAP.md',
        '.claude/docs/README.md'
    ]

    docs = {}
    for doc_file in doc_files:
        file_path = cwd / doc_file
        content = read_file_safe(file_path, max_chars=1000)
        if content:
            docs[doc_file] = content

    if docs:
        context['documentation'] = docs

    return context


def log_session_start(log_path: Path, session_info: dict, context: dict = None):
    """Log session start event."""
    log_data = {
        'event': 'session_start',
        'session_id': session_info.get('session_id'),
        'source': session_info.get('source', 'unknown'),
        'timestamp': datetime.now().isoformat()
    }

    if context:
        log_data['context_loaded'] = True
        log_data['context_keys'] = list(context.keys())

    log_to_jsonl(log_path, log_data)


def main():
    """Main entry point for session_start hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'session_start.jsonl'

        # Check for flags
        load_context = '--load-context' in sys.argv
        announce = '--announce' in sys.argv

        # Load development context if requested
        context = None
        if load_context:
            context = load_development_context(project_root, hook_input)

        # Log the session start
        log_session_start(log_path, hook_input, context)

        # Prepare output
        output = {}

        if context:
            # Format context for Claude
            context_message = "## Development Context\n\n"

            # Git status
            if 'git' in context:
                git = context['git']
                context_message += f"**Branch:** `{git['branch']}`\n"
                if not git['is_clean']:
                    context_message += f"**Uncommitted changes:** {git['uncommitted_count']} files\n"
                if git['last_commit']:
                    context_message += f"**Last commit:** {git['last_commit']}\n"
                context_message += "\n"

            # Recent issues
            if 'recent_issues' in context:
                issues = context['recent_issues']
                context_message += "**Recent Issues:**\n"
                for issue in issues[:5]:
                    context_message += f"- #{issue['number']}: {issue['title']}\n"
                context_message += "\n"

            # Documentation
            if 'documentation' in context:
                context_message += "**Project Documentation:**\n"
                for doc_name, content in context['documentation'].items():
                    context_message += f"\n### {doc_name}\n{content[:500]}\n"

            output['hookSpecificOutput'] = {
                'hookEventName': 'SessionStart',
                'additionalContext': context_message
            }

        # Announce if requested (optional)
        if announce:
            try:
                session_source = hook_input.get('source', 'unknown')
                subprocess.run(
                    ['say', f'Claude session {session_source}'],
                    timeout=2,
                    check=False
                )
            except:
                pass

        # Output JSON if there's context
        if output:
            print(json.dumps(output))

        sys.exit(0)

    except Exception as e:
        # Don't fail the session on error
        print(f"Warning: session_start hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
