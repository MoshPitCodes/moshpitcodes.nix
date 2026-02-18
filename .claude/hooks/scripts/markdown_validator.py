#!/usr/bin/env python3
"""
Markdown Validator - Validates markdown files after write/edit operations
"""
import json
import sys
import re
from pathlib import Path

def validate_markdown(file_path: str) -> list[str]:
    """Validate markdown file and return list of issues"""
    issues = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check for empty headings
        if re.search(r'^#+\s*$', content, re.MULTILINE):
            issues.append("Empty headings found")

        # Check for unclosed code blocks
        code_blocks = content.count('```')
        if code_blocks % 2 != 0:
            issues.append("Unclosed code blocks")

        # Check for broken links (basic check)
        if re.search(r'\[([^\]]+)\]\(\s*\)', content):
            issues.append("Empty link URLs found")

    except Exception as e:
        issues.append(f"Error reading file: {str(e)}")

    return issues

def main():
    # Read JSON input from stdin
    hook_input = json.load(sys.stdin)

    tool_input = hook_input.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    # Only validate .md files
    if not file_path.endswith('.md'):
        sys.exit(0)

    # Check if file exists
    if not Path(file_path).exists():
        sys.exit(0)

    # Validate the markdown file
    issues = validate_markdown(file_path)

    # If issues found, provide feedback to Claude
    if issues:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PostToolUse",
                "additionalContext": f"Markdown validation issues in {file_path}: {', '.join(issues)}"
            }
        }
        print(json.dumps(output))

    sys.exit(0)

if __name__ == "__main__":
    main()
