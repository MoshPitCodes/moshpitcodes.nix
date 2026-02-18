# Claude Code Configuration

This directory contains the complete Claude Code configuration including agents, commands, hooks, and status lines.

## Directory Structure

```
.claude/
├── agents/              # 34 specialized agents
│   ├── team/           # Team workflow agents
│   │   ├── builder.md         # Task execution agent
│   │   └── validator.md       # QA validation agent
│   ├── [32 other agents]      # Domain specialists
│   └── HOOKS_INTEGRATION.md   # Agent hooks documentation
├── commands/           # 16 workflow commands
│   ├── plan.md               # Planning
│   ├── build.md              # Implementation
│   ├── cook.md               # Parallel execution
│   └── [13 more commands]
├── hooks/              # Lifecycle hooks system
│   ├── scripts/       # 13 hook scripts
│   │   ├── session_start.py       # Context loading
│   │   ├── session_end.py         # Session cleanup
│   │   ├── user_prompt_submit.py  # Prompt logging
│   │   ├── pre_compact.py         # Transcript backup
│   │   ├── post_tool_use_failure.py # Error handling
│   │   ├── subagent_start.py      # Subagent tracking
│   │   ├── subagent_stop.py       # Subagent tracking
│   │   ├── notification.py        # Notification logging
│   │   ├── security_check.py      # Security validation
│   │   ├── tool_logger.py         # Tool usage logging
│   │   ├── markdown_validator.py  # Markdown validation
│   │   ├── idle_detector.py       # Completion check
│   │   └── td_enforcer.py         # Task enforcement
│   ├── utils/         # 4 utility modules
│   │   ├── logging.py        # JSONL logging
│   │   ├── git_utils.py      # Git operations
│   │   ├── file_utils.py     # File operations
│   │   └── __init__.py
│   ├── README.md              # Hooks usage guide
│   └── IMPLEMENTATION_SUMMARY.md # Hooks documentation
├── status_lines/       # 10 status line versions
│   ├── status_line.py         # Base implementation
│   ├── status_line_v1.py      # Version 1
│   ├── ...
│   └── status_line_v9.py      # Latest version
├── docs/               # Documentation
│   └── td-integration.md      # TD CLI integration
├── logs/               # Runtime logs (auto-created)
│   ├── session_start.jsonl
│   ├── session_end.jsonl
│   ├── user_prompts.jsonl
│   ├── tool_use.jsonl
│   ├── tool_failures.jsonl
│   ├── security.jsonl
│   ├── subagents.jsonl
│   ├── notifications.jsonl
│   └── transcript_backups/
└── data/               # Runtime data (auto-created)
    └── last_prompt.txt
```

## Quick Start

### Using Team Agents

```bash
# Builder executes tasks
@builder implement user authentication

# Validator verifies work
@validator check authentication implementation
```

### Using Commands

```bash
/plan "implement feature"     # Create implementation plan
/build                        # Execute the plan
/cook "complex feature"       # Parallel execution
/git_status                   # Check git state
```

### Generate Custom Agents

```bash
@meta-agent create an agent for database migrations
```

## Agents (34 Total)

### Team Agents (2)
- **builder** - Single-task execution agent
- **validator** - Read-only QA agent

### Specialized Agents (32)
Including but not limited to:
- **product-manager** - Product strategy and prioritization
- **staff-engineer** - Technical architecture and leadership
- **database-specialist** - Database design and optimization
- **devops-infrastructure** - Infrastructure and deployment
- **testing-engineer** - Test strategy and implementation
- **security-engineer** - Security architecture and compliance
- **nextjs-fullstack** - Next.js full-stack development
- **typescript-backend** - TypeScript backend services
- **react-typescript** - React frontend development
- **git-flow-manager** - Git workflow management
- **error-detective** - Log analysis and debugging
- **code-review** - Code quality review
- **architecture-review** - Architecture validation
- And 19 more specialized agents...

See `AGENTS_INDEX.md` for complete list.

## Commands (16 Total)

### Workflow Commands
- **plan** - Create implementation plans
- **plan_w_team** - Team-based planning
- **build** - Execute implementation
- **cook** - Parallel multi-task execution
- **cook_research_only** - Research-only parallel tasks

### Utility Commands
- **prime** - Load session context
- **question** - Answer questions without coding
- **git_status** - Git repository state
- **all_tools** - List available tools
- **update_status_line** - Update status line data
- **sentient** - Manage and ship codebase

### Advanced Commands
- **ultrathink** - Deep analysis
- **structured-thinking** - Reflection and contemplation
- **create-architecture** - Architecture documentation
- **refactor-code** - Intelligent refactoring
- **task-with-td** - TD-enforced sub-agent

## Hooks System

### Lifecycle Hooks (8)
- **SessionStart** - Load development context
- **SessionEnd** - Session cleanup
- **UserPromptSubmit** - Prompt logging
- **PreCompact** - Transcript backup
- **SubagentStart** - Track agent spawning
- **SubagentStop** - Track agent completion
- **Notification** - Log system notifications
- **Stop** - Prevent incomplete work

### Tool Hooks (4)
- **PreToolUse** - Security and validation
- **PostToolUse** - Logging and validation
- **PostToolUseFailure** - Error handling

All hooks log to `.claude/logs/` in JSONL format for easy analysis.

## Status Lines (10 Versions)

Real-time session information display:
- Session duration
- Token usage and cost
- Current task/agent
- Git status
- Custom metadata

**Recommended:** v6 or v9

Configure in `claude.json`:
```json
{
  "statusLine": {
    "command": "python3 $CLAUDE_PROJECT_DIR/.claude/status_lines/status_line_v6.py",
    "refreshInterval": 1000
  }
}
```

## Key Features

### 1. Context Loading
SessionStart hook automatically provides:
- Git status (branch, uncommitted changes, last commit)
- Recent GitHub issues (via gh CLI)
- Project documentation (TODO.md, ROADMAP.md, CONTEXT.md)

### 2. Quality Assurance Pattern
```
@builder → implement → @validator → verify → ship
```

### 3. Parallel Execution
```
/cook → spawn multiple builders → parallel work → consolidate
```

### 4. Comprehensive Logging
All events logged to `.claude/logs/`:
- Session lifecycle
- User prompts
- Tool usage
- Failures and errors
- Security checks
- Subagent activity

### 5. Security & Validation
- Pre-execution security checks
- Markdown validation
- TD task enforcement
- Idle work detection

## Configuration

All hooks are configured in root `claude.json`. No additional setup required.

Optional enhancements:
- Enable status line (recommended)
- Configure TD enforcement
- Add custom hooks per agent

## Documentation

- **README.md** (this file) - Overview
- **AGENTS_INDEX.md** - Complete agent catalog
- **hooks/README.md** - Hooks usage guide
- **hooks/IMPLEMENTATION_SUMMARY.md** - Hooks architecture
- **agents/HOOKS_INTEGRATION.md** - Agent-specific hooks
- **docs/td-integration.md** - TD CLI integration

## Testing

```bash
# Test builder/validator workflow
@builder create hello world function in hello.py
@validator verify hello.py is valid

# Test parallel execution
/cook "implement shopping cart with tests"

# Test agent generation
@meta-agent create agent for API security testing

# Test context loading
@product-manager analyze feature priorities
```

## Logs & Data

### Logs Directory (.claude/logs/)
Auto-created on first hook execution:
- `session_start.jsonl` - Session initialization
- `session_end.jsonl` - Session completion
- `user_prompts.jsonl` - User input history
- `tool_use.jsonl` - Tool execution log
- `tool_failures.jsonl` - Error debugging
- `security.jsonl` - Security checks
- `subagents.jsonl` - Subagent lifecycle
- `notifications.jsonl` - System notifications
- `transcript_backups/` - Pre-compaction backups

### Data Directory (.claude/data/)
- `last_prompt.txt` - Most recent user prompt

All logs use JSONL format for easy parsing and analysis.

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [Sub-agents Documentation](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
- [TD CLI](https://github.com/marcus/td)

---

**Status:** Production Ready ✅
**Components:** 34 agents, 16 commands, 13 hooks, 10 status lines
**Last Updated:** 2026-02-11
