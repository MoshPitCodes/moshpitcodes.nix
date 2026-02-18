# Claude Code Hooks

This directory contains hooks that automate workflows and enforce policies in Claude Code sessions.

## Overview

Claude Code hooks are shell commands or LLM prompts that execute automatically at specific points in the lifecycle:

- **PreToolUse**: Before a tool executes - can block, modify, or allow
- **PostToolUse**: After a tool succeeds - can provide feedback
- **Stop**: When Claude finishes responding - can continue the conversation
- **SessionStart**: When a session begins - can inject context
- **Notification**: When Claude Code sends notifications

See the [official hooks documentation](https://code.claude.com/docs/en/hooks) for complete reference.

## Installed Hooks

### Lifecycle Hooks

#### Session Start (`session_start.py`)
**Event:** SessionStart
**Purpose:** Loads development context when starting a new Claude Code session

**Features:**
- Git status (branch, uncommitted changes, last commit)
- Recent GitHub issues (via `gh` CLI if available)
- Project documentation (CONTEXT.md, TODO.md, ROADMAP.md)

**Flags:**
- `--load-context`: Enable context loading (included by default)
- `--announce`: Text-to-speech announcement (optional)

**Logs:** `.claude/logs/session_start.jsonl`

#### Session End (`session_end.py`)
**Event:** SessionEnd
**Purpose:** Logs session completion and performs cleanup

**Logs:** `.claude/logs/session_end.jsonl`

#### User Prompt Submit (`user_prompt_submit.py`)
**Event:** UserPromptSubmit (async)
**Purpose:** Logs user prompts for auditing and stores last prompt

**Flags:**
- `--store-last-prompt`: Save last prompt to `.claude/data/last_prompt.txt`

**Logs:** `.claude/logs/user_prompts.jsonl`

### Tool Hooks

#### Security Check (`security_check.py`)
**Event:** PreToolUse (Bash, Read, Edit, Write)
**Purpose:** Blocks dangerous operations and protects sensitive files

**Blocks:**
- `rm -rf` commands
- System file modifications (`/etc/`, `/usr/`, `/var/`, `/System/`)
- `.env` file access (allows `.env.example`, `.env.sample`)
- Credential files (`.key`, `.pem`, `credentials.json`)

**Logs:** `.claude/logs/security_blocks.jsonl`

#### Tool Logger (`tool_logger.py`)
**Event:** PostToolUse (all tools, async)
**Purpose:** Logs all tool usage for auditing and debugging

**Logs:** `.claude/logs/tool_use.jsonl`

#### Post Tool Use Failure (`post_tool_use_failure.py`)
**Event:** PostToolUseFailure
**Purpose:** Handles tool execution failures with debugging context

**Features:**
- Logs all tool failures
- Provides tool-specific debugging tips
- Adds error context for Claude

**Logs:** `.claude/logs/tool_failures.jsonl`

#### Markdown Validator (`markdown_validator.py`)
**Event:** PostToolUse (Edit, Write)
**Purpose:** Validates markdown files after changes

**Checks:**
- Empty headings
- Unclosed code blocks
- Broken links

**Provides feedback** to Claude when issues are found.

### Development Workflow Hooks

#### TD Enforcer (`td_enforcer.py`)
**Event:** PreToolUse (Edit, Write)
**Purpose:** Enforces task-driven development with TD CLI

**Behavior:**
- Checks if TD is installed and initialized
- Blocks code changes when no active task exists
- Auto-links files to current task
- Only applies to code files (`.ts`, `.js`, `.py`, etc.)
- Gracefully degrades if TD is not available

**Prerequisites:** [TD CLI](https://github.com/marcus/td) installed

#### Idle Detector (`idle_detector.py`)
**Event:** Stop
**Purpose:** Prevents Claude from stopping with incomplete work

**Checks for:**
- TODO/FIXME comments
- ERROR messages
- Failed operations
- Incomplete work mentions

**Blocks stopping** if issues are detected, prompts Claude to complete work.

### Advanced Hooks

#### Pre-Compact (`pre_compact.py`)
**Event:** PreCompact
**Purpose:** Backs up transcripts before compaction operations

**Features:**
- Automatic transcript backup
- Timestamped backup files
- Preserves full conversation history

**Backup Location:** `.claude/logs/transcript_backups/`

#### Subagent Start (`subagent_start.py`)
**Event:** SubagentStart (async)
**Purpose:** Tracks when subagents spawn

**Flags:**
- `--notify`: Print notification to stderr

**Logs:** `.claude/logs/subagents.jsonl`

#### Subagent Stop (`subagent_stop.py`)
**Event:** SubagentStop (async)
**Purpose:** Tracks when subagents complete

**Flags:**
- `--notify`: Print notification to stderr

**Logs:** `.claude/logs/subagents.jsonl`

#### Notification (`notification.py`)
**Event:** Notification (async)
**Purpose:** Processes and logs Claude Code notifications

**Logs:** `.claude/logs/notifications.jsonl`

## Configuration

Hooks are configured in `claude.json` at the project root:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Read|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scripts/security_check.py",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Hook Configuration Fields

- **matcher**: Regex pattern to filter events (tool names, trigger reasons, etc.)
- **type**: `"command"`, `"prompt"`, or `"agent"`
- **command**: Path to the script (use `$CLAUDE_PROJECT_DIR` for portability)
- **timeout**: Seconds before canceling (default varies by event)
- **async**: Run in background without blocking (command hooks only)

## Writing Custom Hooks

### Command Hook Structure

```python
#!/usr/bin/env python3
import json
import sys

def main():
    # Read JSON input from stdin
    hook_input = json.load(sys.stdin)

    # Extract relevant data
    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    # Your logic here

    # Exit codes:
    # 0 = success (allow)
    # 2 = blocking error (deny)
    # other = non-blocking error

    sys.exit(0)

if __name__ == "__main__":
    main()
```

### Block an Action

Exit with code 2 and write reason to stderr:

```python
print("Action blocked: reason here", file=sys.stderr)
sys.exit(2)
```

### Provide Feedback (JSON output)

Print JSON to stdout with exit code 0:

```python
output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",  # or "allow", "ask"
        "permissionDecisionReason": "Explanation here"
    }
}
print(json.dumps(output))
sys.exit(0)
```

### Add Context

```python
output = {
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": "Additional info for Claude"
    }
}
print(json.dumps(output))
```

## Hook Input Schema

All hooks receive these common fields:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse"
}
```

### PreToolUse/PostToolUse Input

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run tests"
  },
  "tool_use_id": "toolu_123..."
}
```

Tool input fields vary by tool. See [hooks reference](https://code.claude.com/docs/en/hooks#hook-events) for complete schemas.

## Debugging Hooks

### Enable Debug Mode

```bash
claude --debug
```

### Toggle Verbose Output

Press `Ctrl+O` during a session to see hook execution details.

### Test a Hook Manually

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | \
  .claude/hooks/scripts/security_check.py
```

## Disable Hooks

### Temporarily Disable All Hooks

Add to `claude.json`:

```json
{
  "disableAllHooks": true
}
```

Or use the `/hooks` menu in Claude Code.

### Remove Specific Hook

Delete the hook configuration from `claude.json` or use `/hooks` menu.

## Best Practices

1. **Keep hooks fast** - They run on every event, slow hooks degrade UX
2. **Use async for heavy operations** - Logging, external API calls
3. **Provide clear feedback** - Error messages should be actionable
4. **Test thoroughly** - Use debug mode and test with various inputs
5. **Quote paths** - Use `"$CLAUDE_PROJECT_DIR"` for portability
6. **Handle errors gracefully** - Exit 0 if unsure, don't break the session

## Security Considerations

⚠️ **Hooks run with your full user permissions**

- Review all hook scripts before running
- Validate and sanitize inputs
- Quote shell variables
- Block path traversal (`..`)
- Use absolute paths
- Skip sensitive files

## Hook Architecture & Patterns

This project implements comprehensive hook coverage:

### The 13 Hook Types

Claude Code provides 13 distinct lifecycle events for comprehensive control:

**Session Management (3 hooks):**
- **SessionStart** - Initialize context, load documentation
- **SessionEnd** - Cleanup, logging, statistics
- **Setup** - Repository initialization, ensure log directories

**Main Conversation Loop (10 hooks):**
- **UserPromptSubmit** - Validate/log user input
- **PreToolUse** - Security checks, TD enforcement before execution
- **PostToolUse** - Logging, monitoring after success
- **PostToolUseFailure** - Error handling, debugging context
- **PermissionRequest** - Audit permission dialogs
- **PreCompact** - Transcript backups before compaction
- **Notification** - Process Claude Code alerts
- **Stop** - Prevent incomplete work
- **SubagentStart** - Track agent spawning
- **SubagentStop** - Track agent completion

### Hook Execution Flow

Hooks use exit codes to control execution:
- **0**: Success (allow operation)
- **2**: Blocking error (deny operation, feed reason to Claude)
- **Other**: Non-blocking error (show to user)

### Shared Utilities

All hooks leverage a common utilities module (`.claude/hooks/utils/`):
- **logging.py** - JSONL logging, structured logging
- **git_utils.py** - Git status, branch info, uncommitted counts
- **file_utils.py** - Safe file reading, project root detection

### Best Practices Applied

1. **Graceful Degradation** - Hooks never fail sessions
2. **Async Operations** - Heavy operations (logging, notifications) run async
3. **Structured Logging** - All events logged as JSONL for analysis
4. **Context Loading** - SessionStart provides development context
5. **Error Handling** - PostToolUseFailure provides debugging help
6. **Security First** - PreToolUse blocks dangerous operations
7. **Audit Trail** - Comprehensive logging of all operations


## Extending the Hook System

### Adding a New Hook

1. Create hook script in `.claude/hooks/scripts/`
2. Import utilities from `.claude/hooks/utils/`
3. Make script executable (`chmod +x`)
4. Add configuration to `claude.json`
5. Test with `--debug` mode

### Example: Custom Hook Template

```python
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent.parent / "utils"))
from file_utils import get_project_root
from logging import log_to_jsonl

def main():
    try:
        hook_input = json.load(sys.stdin)
        project_root = get_project_root()

        # Your logic here

        # Optional: provide output to Claude
        output = {
            'hookSpecificOutput': {
                'hookEventName': 'YourHook',
                'additionalContext': 'Your message'
            }
        }
        print(json.dumps(output))

        sys.exit(0)
    except Exception as e:
        print(f"Warning: hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == "__main__":
    main()
```

## Resources

- [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Example Hooks](https://github.com/anthropics/claude-code/tree/main/examples/hooks)
- [TD CLI](https://github.com/marcus/td) for task-driven development

---

**Last Updated:** 2025-02-11
**Maintained By:** Development Team
