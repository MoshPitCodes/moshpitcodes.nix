# TD Task Management Integration

The **TD Task Enforcement Plugin** (`td-enforcer.ts`) integrates OpenCode with the [TD](https://github.com/marcus/td) task-management CLI. It enforces task-driven development by gating file writes, auto-tracking changes, and monitoring review status.

## Prerequisites

1. **TD CLI** installed and on your `PATH`:
   ```bash
   td version          # should print version info
   ```
2. **Initialised TD project** in the repository root:
   ```bash
   td init
   ```

The plugin auto-loads from `.opencode/plugins/`. If TD is not installed, the plugin silently disables itself with a console warning.

## How It Works

### Permission Gate

When the OpenCode agent attempts a `write` or `edit` and there is **no focused TD task**, the plugin changes the permission status to `"ask"`. This surfaces the standard OpenCode permission dialog so you can:

1. Switch to another terminal and run `td start TASK-123`.
2. Return to OpenCode and approve the operation.

If a task **is** focused the write proceeds without interruption.

### Auto-Tracking

After every successful `write` or `edit` the plugin:

- Runs `td link <task-key> <file>` to associate the file with the focused task.
- Runs `td log "<tool>: <filename>"` to append a change-log entry.

Only files with tracked extensions are linked (see list below). Files inside excluded directories (e.g. `node_modules`) are ignored.

### Review Monitoring

The plugin watches `.todos/db.sqlite` for changes. When a task transitions to `in_review`:

- A **toast notification** appears in the TUI suggesting you run a `code-review` or `architecture-review` agent.
- **Session isolation** is enforced: the session that submitted the task cannot review it.

### Session Lifecycle

| Event              | Action                                            |
|--------------------|---------------------------------------------------|
| `session.created`  | Runs `td session --new` to register a new session |
| `session.idle`     | Prints reminder to run `td handoff`               |
| `session.error`    | Cleans up database watcher                        |

The `session-context` plugin also displays the focused TD task key in its session summary.

## Typical Workflow

```bash
# 1. Create or start a task
td create "Implement auth middleware" --start
# or: td start TASK-42

# 2. Launch OpenCode and work normally
opencode

# 3. Agent writes code -> plugin auto-links files, auto-logs changes

# 4. Submit for review when done
td review TASK-42

# 5. Plugin shows toast: "TASK-42 ready for review"

# 6. In a NEW OpenCode session, run a validator agent

# 7. End session
td handoff        # capture working state
```

## File Tracking

### Tracked Extensions

`.ts` `.tsx` `.js` `.jsx` `.go` `.py` `.java` `.kt` `.rs` `.c` `.cpp` `.h` `.hpp` `.rb` `.php` `.swift` `.vue` `.svelte` `.md` `.sql` `.graphql` `.proto` `.css` `.scss` `.html` `.yaml` `.yml` `.toml` `.json` `.sh`

### Excluded Directories

`node_modules` `dist` `build` `.git` `target` `vendor` `.next` `.nuxt` `.svelte-kit` `out` `coverage` `__pycache__` `.opencode/logs` `.opencode/data`

## Multi-Task Work Sessions

TD supports work sessions (`td ws`) for juggling multiple tasks. The plugin always tracks files to the **focused** task (set via `td focus <key>`). Switch focus to redirect tracking to a different task.

## Logs

All plugin events are written to `.opencode/logs/td_enforcer.jsonl` in structured JSONL format:

```jsonl
{"timestamp":"...","event":"plugin_loaded"}
{"timestamp":"...","event":"auto_tracked","taskKey":"TASK-42","file":"src/auth.ts","tool":"write"}
{"timestamp":"...","event":"permission_gate_no_task","permissionType":"edit","title":"..."}
{"timestamp":"...","event":"review_prompt_sent","taskID":"abc","taskKey":"TASK-42"}
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "TD not installed" warning | `td` not on PATH or not installed | Install TD, ensure it's in PATH |
| Files not auto-linking | Extension not tracked or path excluded | Check tracked extensions list above |
| No review toast | `.todos/db.sqlite` missing | Run `td init` in project root |
| Permission dialog on every write | No task focused | Run `td start <key>` or `td focus <key>` |
