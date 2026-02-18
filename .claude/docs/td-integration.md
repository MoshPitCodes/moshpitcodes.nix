# TD Task Management Integration

The **TD Task Enforcement Hook** (`td_enforcer.py`) integrates Claude Code with the [TD](https://github.com/marcus/td) task-management CLI. It enforces task-driven development by gating file writes, auto-tracking changes, and monitoring review status.

## Prerequisites

1. **TD CLI** installed and on your `PATH`:
   ```bash
   td version          # should print version info
   ```
2. **Initialised TD project** in the repository root:
   ```bash
   td init
   ```

The hook is configured in `claude.json`. If TD is not installed, the hook silently exits with a warning.

## How It Works

### Permission Gate

When the Claude Code agent attempts a `write` or `edit` and there is **no focused TD task**, the hook changes the permission status to `"ask"`. This surfaces the standard Claude Code permission dialog so you can:

1. Switch to another terminal and run `td start TASK-123`.
2. Return to Claude Code and approve the operation.

If a task **is** focused the write proceeds without interruption.

### Auto-Tracking

After every successful `write` or `edit` the hook:

- Runs `td link <task-key> <file>` to associate the file with the focused task.
- Runs `td log "<tool>: <filename>"` to append a change-log entry.

Only files with tracked extensions are linked (see list below). Files inside excluded directories (e.g. `node_modules`) are ignored.

### Review Monitoring

The hook watches `.todos/db.sqlite` for changes. When a task transitions to `in_review`:

- A **toast notification** appears in the TUI suggesting you run a `code-review` or `architecture-review` agent.
- **Session isolation** is enforced: the session that submitted the task cannot review it.

### Session Lifecycle

| Event              | Action                                            |
|--------------------|---------------------------------------------------|
| `session.created`  | Runs `td session --new` to register a new session |
| `session.idle`     | Prints reminder to run `td handoff`               |
| `session.error`    | Cleans up database watcher                        |

The `session-context` hook also displays the focused TD task key in its session summary.

## Typical Workflow

```bash
# 1. Create or start a task
td create "Implement auth middleware" --start
# or: td start TASK-42

# 2. Launch Claude Code and work normally
claude

# 3. Agent writes code -> hook auto-links files, auto-logs changes

# 4. Submit for review when done
td review TASK-42

# 5. Hook shows toast: "TASK-42 ready for review"

# 6. In a NEW Claude Code session, run a validator agent

# 7. End session
td handoff        # capture working state
```

## File Tracking

### Tracked Extensions

`.ts` `.tsx` `.js` `.jsx` `.go` `.py` `.java` `.kt` `.rs` `.c` `.cpp` `.h` `.hpp` `.rb` `.php` `.swift` `.vue` `.svelte` `.md` `.sql` `.graphql` `.proto` `.css` `.scss` `.html` `.yaml` `.yml` `.toml` `.json` `.sh`

### Excluded Directories

`node_modules` `dist` `build` `.git` `target` `vendor` `.next` `.nuxt` `.svelte-kit` `out` `coverage` `__pycache__` `.claude/logs` `.claude/data`

## Multi-Task Work Sessions

TD supports work sessions (`td ws`) for juggling multiple tasks. The hook always tracks files to the **focused** task (set via `td focus <key>`). Switch focus to redirect tracking to a different task.

## Logs

All hook events are written to `.claude/logs/td_enforcer.jsonl` in structured JSONL format:

```jsonl
{"timestamp":"...","event":"hook_loaded"}
{"timestamp":"...","event":"auto_tracked","taskKey":"TASK-42","file":"src/auth.ts","tool":"write"}
{"timestamp":"...","event":"permission_gate_no_task","permissionType":"edit","title":"..."}
{"timestamp":"...","event":"review_prompt_sent","taskID":"abc","taskKey":"TASK-42"}
```

## TD MCP Server Tools for Agents

Claude Code agents can use the TD MCP server to programmatically manage tasks. This is especially useful for product-manager, staff-engineer, and other planning agents.

### Available TD MCP Tools

**Task Management:**
- `mcp__td-sidecar__td_get_status` - Check current task status and context
- `mcp__td-sidecar__td_start_task` - Start working on a task
- `mcp__td-sidecar__td_focus_task` - Focus on a task without changing status
- `mcp__td-sidecar__td_log_entry` - Add timestamped log entries to track progress
- `mcp__td-sidecar__td_submit_review` - Submit task for review when work is complete
- `mcp__td-sidecar__td_approve_task` - Approve a task in review (transitions to done)
- `mcp__td-sidecar__td_handoff` - Record structured handoff context for continuity

**Issue/Project Management:**
- `mcp__td-sidecar__td_create_issue` - Create new issues/tasks for backlog items
- `mcp__td-sidecar__td_show_issue` - View issue details
- `mcp__td-sidecar__td_list_issues` - List issues with filters (status, type, priority)
- `mcp__td-sidecar__td_query_issues` - Query issues using TDQ expressions
- `mcp__td-sidecar__td_update_issue` - Update issue fields (priority, labels, title)
- `mcp__td-sidecar__td_delete_issue` - Delete an issue (DESTRUCTIVE)

**Dependencies & Planning:**
- `mcp__td-sidecar__td_add_dependency` - Add dependency (from depends on to)
- `mcp__td-sidecar__td_remove_dependency` - Remove dependency
- `mcp__td-sidecar__td_get_critical_path` - Calculate critical path through dependencies
- `mcp__td-sidecar__td_show_tree` - Show task tree hierarchy

**Boards & Stats:**
- `mcp__td-sidecar__td_list_boards` - List saved boards
- `mcp__td-sidecar__td_create_board` - Create named board with TDQ query
- `mcp__td-sidecar__td_get_stats` - Get project statistics
- `mcp__td-sidecar__td_search` - Full-text search across issues

**Session & Identity:**
- `mcp__td-sidecar__td_get_usage` - Get usage context (new_session option)
- `mcp__td-sidecar__td_whoami` - Get session identity

### Agent Workflow Pattern

**1. Initialize Session - Check Status:**
```json
mcp__td-sidecar__td_get_status({})
```
Returns current focused task, in-progress tasks, and recent activity.

**2. Create Task for Trackable Work:**
```json
mcp__td-sidecar__td_create_issue({
  "title": "Create authentication PRD",
  "type": "task",
  "priority": "P1",
  "description": "Product planning for OAuth2 authentication system including user stories, acceptance criteria, and success metrics"
})
```

**3. Start the Task:**
```json
mcp__td-sidecar__td_start_task({
  "task": "TASK-123"
})
```

**4. Log Progress at Milestones:**
```json
mcp__td-sidecar__td_log_entry({
  "message": "Completed PRD draft - included 5 user stories and RICE scoring"
})
```

**5. Submit for Review:**
```json
mcp__td-sidecar__td_submit_review({
  "task": "TASK-123"
})
```

**6. Record Handoff (when pausing work):**
```json
mcp__td-sidecar__td_handoff({
  "done": "Completed feature prioritization using RICE framework",
  "remaining": "Need stakeholder review of prioritization results",
  "decision": "Chose RICE over MoSCoW due to quantitative scoring needs",
  "uncertain": "Should we include technical debt items in this prioritization?"
})
```

### Creating Planning Tasks with Dependencies

For complex initiatives, create hierarchical tasks with dependencies:

```json
// Create parent epic
mcp__td-sidecar__td_create_issue({
  "title": "Implement OAuth2 authentication",
  "type": "epic",
  "priority": "P0",
  "description": "Complete OAuth2 authentication system with Google and GitHub providers"
})

// Create subtasks
mcp__td-sidecar__td_create_issue({
  "title": "Design OAuth database schema",
  "type": "task",
  "priority": "P1",
  "parent": "EPIC-1"
})

mcp__td-sidecar__td_create_issue({
  "title": "Implement OAuth2 backend API",
  "type": "task",
  "priority": "P1",
  "parent": "EPIC-1"
})

// Add dependency: API depends on schema
mcp__td-sidecar__td_add_dependency({
  "from": "TASK-2",
  "to": "TASK-1"
})
```

### Querying and Managing Backlog

```json
// Find all P0 features
mcp__td-sidecar__td_query_issues({
  "query": "type:feature AND priority:P0",
  "limit": 20
})

// Update issue after review
mcp__td-sidecar__td_update_issue({
  "task": "FEAT-123",
  "priority": "P1",
  "labels": "approved, Q2-committed"
})

// Search for related work
mcp__td-sidecar__td_search({
  "query": "authentication OAuth"
})
```

### Important Notes for Agents

- **Always use MCP tools, not bash** - Use `mcp__td-sidecar__td_*` functions, never `td` CLI via Bash
- **Check status first** - Call `td_get_status` at session start to understand context
- **Log frequently** - Document decisions and progress for continuity
- **Create tasks for trackable work** - PRDs, plans, implementations should have TD tasks
- **Use handoff for continuity** - Record what's done, what's remaining, and key decisions

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "TD not installed" warning | `td` not on PATH or not installed | Install TD, ensure it's in PATH |
| Files not auto-linking | Extension not tracked or path excluded | Check tracked extensions list above |
| No review toast | `.todos/db.sqlite` missing | Run `td init` in project root |
| Permission dialog on every write | No task focused | Run `td start <key>` or `td focus <key>` |
| MCP tools not available | TD MCP server not configured | Check `.claude/settings.json` for td-sidecar MCP server |
