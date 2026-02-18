#!/usr/bin/env python3
"""
User Prompt Submit Hook

Logs and validates user prompts before processing.
Can be used for:
- Input sanitization
- Prompt logging/auditing
- Custom prompt transformations
- Usage tracking
"""

import json
import sys
from datetime import datetime
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))

from file_utils import get_project_root
from log_utils import log_to_jsonl


def log_prompt_submission(log_path: Path, prompt_info: dict):
    """Log user prompt submission."""
    log_data = {
        'event': 'user_prompt_submit',
        'session_id': prompt_info.get('session_id'),
        'prompt_length': len(prompt_info.get('content', '')),
        'timestamp': datetime.now().isoformat()
    }

    # Don't log the actual prompt content for privacy
    # If you need full logging, uncomment:
    # log_data['content'] = prompt_info.get('content', '')

    log_to_jsonl(log_path, log_data)


def main():
    """Main entry point for user_prompt_submit hook."""
    try:
        # Read input from stdin
        hook_input = json.load(sys.stdin)

        # Get project root
        project_root = get_project_root()
        log_path = project_root / '.claude' / 'logs' / 'user_prompts.jsonl'

        # Log the prompt submission
        log_prompt_submission(log_path, hook_input)

        # Check for --store-last-prompt flag
        if '--store-last-prompt' in sys.argv:
            last_prompt_file = project_root / '.claude' / 'data' / 'last_prompt.txt'
            last_prompt_file.parent.mkdir(parents=True, exist_ok=True)
            with open(last_prompt_file, 'w') as f:
                f.write(hook_input.get('content', ''))

        # Could add validation here:
        # - Check for sensitive data
        # - Validate prompt format
        # - Transform prompts
        # - etc.

        sys.exit(0)

    except Exception as e:
        # Don't fail on error
        print(f"Warning: user_prompt_submit hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
