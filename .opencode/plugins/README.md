# OpenCode Native Plugins

This directory contains TypeScript plugins for the OpenCode AI coding assistant. These plugins use OpenCode's native plugin system to extend functionality with security controls, logging, validation, and session management.

## Overview

OpenCode plugins are TypeScript modules that hook into the OpenCode event system to provide custom functionality. Unlike the previous Python hooks system, OpenCode plugins:

- **Native Integration**: Built directly into OpenCode's event loop
- **Type Safety**: Full TypeScript support with type checking
- **Better Performance**: No subprocess overhead
- **Cross-Platform**: Works identically on macOS, Linux, and Windows
- **Event-Driven**: React to session lifecycle, tool execution, and file changes

## Installed Plugins

### 1. Security Plugin (`security.ts`)

**Purpose**: Prevents dangerous operations and protects sensitive files.

**Features**:
- Blocks dangerous `rm -rf` commands (comprehensive pattern matching)
- Prevents access to `.env` files (allows `.env.sample`, `.env.example`)
- Protects credential files (`.key`, `.pem`, `credentials.json`, etc.)
- Blocks system file modifications (`/etc/`, `/usr/`, `/var/`)
- Logs all blocked operations to `logs/security.jsonl`

**Hook**: `"tool.execute.before"` (typed hook)

**Example Blocks**:
```bash
# These will be blocked:
rm -rf /
rm -rf .
cat .env
vim credentials.json
nano ~/.ssh/id_rsa
```

**Log Output** (`logs/security.jsonl`):
```json
{"event":"security_block","timestamp":"2026-02-09T12:34:56.789Z","reason":"dangerous_rm_command","tool":"bash","command":"rm -rf /tmp/important"}
```

---

### 2. Logging Plugin (`logging.ts`)

**Purpose**: Comprehensive JSONL event tracking for all OpenCode operations.

**Features**:
- Tool execution logging (before/after)
- Session lifecycle events (created, idle, error, compacted)
- File modification tracking
- Message and conversation flow tracking
- Permission requests logging
- Command execution logging
- Auto-truncates large outputs (500-1000 char limits)

**Hooks**: `"tool.execute.before"`, `"tool.execute.after"` (typed), `event` (generic)

**Log Files Created**:
- `logs/tool_use.jsonl` - Tool execution events
- `logs/session.jsonl` - Session lifecycle events
- `logs/files.jsonl` - File modification events
- `logs/messages.jsonl` - Message flow tracking
- `logs/permissions.jsonl` - Permission requests
- `logs/commands.jsonl` - Command execution

**Example Log Entry** (`logs/tool_use.jsonl`):
```json
{"timestamp":"2026-02-09T12:34:56.789Z","event":"before","tool":"bash","sessionID":"abc123","args":{"command":"npm install"}}
{"timestamp":"2026-02-09T12:35:02.123Z","event":"after","tool":"bash","sessionID":"abc123","title":"npm install","output":"added 142 packages in 5s"}
```

---

### 3. Markdown Validator Plugin (`markdown-validator.ts`)

**Purpose**: Validates agent, skill, command, and documentation files for proper structure.

**Features**:
- Validates agent frontmatter (required fields: name, description, type, model)
- Validates skill documentation (SKILL.md files)
- Validates command files (optional frontmatter)
- Validates documentation structure
- **Warn-only mode**: Logs warnings but doesn't block operations

**Hook**: `event` (generic), filters `event.type === "file.edited"`

**Validation Rules**:

**Agent Files** (`.opencode/agents/*.md`):
```yaml
---
name: agent-name          # Required
description: Use when...  # Required
type: subagent            # Required (primary or subagent)
model: anthropic/...      # Required
---
```

**Skill Files** (`.opencode/skills/*/SKILL.md`):
```yaml
---
name: skill-name          # Required
description: Skill desc   # Required
---
```

**Command Files** (`.opencode/commands/*.md`):
```yaml
---
allowed-tools: Read, Write  # Optional
argument-hint: [args]       # Optional
description: Command desc   # Optional
---
```

**Log Output** (`logs/validation.jsonl`):
```json
{"event":"validation_warning","timestamp":"2026-02-09T12:34:56.789Z","file":".opencode/agents/my-agent.md","warnings":["Missing required field: model"]}
{"event":"validation_error","timestamp":"2026-02-09T12:35:00.123Z","file":".opencode/agents/broken.md","errors":["Invalid frontmatter: YAML parse error"]}
```

---

### 4. Post-Stop Detector Plugin (`post-stop-detector.ts`)

**Purpose**: Detects files created or modified after a session completes (orphaned changes).

**Features**:
- Captures filesystem snapshot when `session.idle` fires
- Monitors for 30 seconds post-session
- Detects new, modified, and deleted files
- Logs orphaned changes to `logs/post_stop.jsonl`
- Stores snapshots in `.opencode/data/sessions/{session-id}-snapshot.json`

**Hook**: `event` (generic), filters `event.type === "session.idle"`

**How It Works**:
1. When session goes idle, captures SHA-256 hash of all project files
2. Waits 30 seconds
3. Re-captures filesystem state
4. Compares snapshots to detect orphaned changes
5. Logs any files that changed after session ended

**Example Use Case**: Detects background processes (like linters, formatters, or build watchers) that modify files after OpenCode finishes.

**Log Output** (`logs/post_stop.jsonl`):
```json
{"event":"snapshot_captured","sessionId":"abc123","timestamp":"2026-02-09T12:34:56.789Z","fileCount":142,"snapshotPath":".opencode/data/sessions/abc123-snapshot.json"}
{"event":"post_stop_detection","sessionId":"abc123","timestamp":"2026-02-09T12:35:26.789Z","monitorDuration":"30s","orphanedChanges":true,"summary":{"newFiles":2,"modifiedFiles":1,"deletedFiles":0},"details":{"newFiles":["dist/bundle.js","dist/bundle.js.map"],"modifiedFiles":["package-lock.json"]}}
```

---

### 5. Notifications Plugin (`notifications.ts`)

**Purpose**: Tracks session statistics and sends completion notifications with rich session summaries.

**Features**:
- Tracks git branch and uncommitted changes on session start
- Counts tools used, files modified, and tokens consumed during session
- Calculates session duration
- Fetches current TD task (if available)
- Sends TUI toast notifications for all session events
- Sends rich TUI toast notifications for session lifecycle events
- Works consistently in terminal-only, headless, and SSH environments

**Hooks**: `"tool.execute.after"` (typed), `"chat.message"` (typed), `event` (generic, filters `session.created`, `session.idle`, `session.error`, `file.edited`)

**Toast Notification Example** (on session completion):
```
Session Completed
⏱️ 15m 42s • 🔧 37 tools • 📝 8 files • 🎯 42.5k tokens • 🌿 feature/new-plugin • 📋 TASK-123
```

---

### 6. Context Manager Plugin (`context-manager/`)

**Purpose**: Proactively manages context size in long sessions via pruning/compression strategies.

**Features**:
- Deduplicates repeated tool outputs
- Supersedes stale writes with later reads
- Purges resolved error context
- Smart compression of large outputs
- Adds ICM tools (`icm_prune`, `icm_distill`, etc.) when enabled

**Hooks**: `event`, `tool.execute.after`, and other internal context-management hooks

---

### 7. TD Task Enforcement Plugin (`td-enforcer.ts`)

**Purpose**: Integrates OpenCode with the [TD](https://github.com/marcus/td) task-management CLI to enforce task-driven development workflows.

**Features**:
- Permission gate: prompts before write/edit when no TD task is active
- Auto-links modified files to the focused task (`td link`)
- Auto-logs changes to the task log (`td log`)
- Watches `.todos/db.sqlite` for tasks entering `in_review` state
- Sends toast notifications prompting for code-review / architecture-review agents
- Enforces session isolation (same session cannot review its own work)
- Reminds about `td handoff` when session goes idle with active tasks
- Graceful degradation: disables itself if TD is not installed

**Hooks**: `"permission.ask"` (typed), `"tool.execute.after"` (typed), `event` (generic)

**Requirements**:
- TD CLI installed and in PATH (`td version` must succeed)
- Initialised TD project (`td init` in project root)

**Workflow**:
1. Start a task: `td start TASK-123` or `td create "feature" --start`
2. OpenCode agent writes code -- files are auto-linked and logged
3. Submit for review: `td review TASK-123`
4. Plugin shows toast: "Run code-review agent to validate"
5. A **different** session runs the validator (session isolation enforced)
6. Session ends: reminder to run `td handoff`

**Log Output** (`logs/td_enforcer.jsonl`):
```json
{"timestamp":"2026-02-09T14:00:00.000Z","event":"auto_tracked","taskKey":"TASK-123","file":"src/foo.ts","tool":"write"}
{"timestamp":"2026-02-09T14:05:00.000Z","event":"review_prompt_sent","taskID":"abc","taskKey":"TASK-123"}
```

**File Tracking**:
- Tracked extensions: `.ts`, `.tsx`, `.js`, `.jsx`, `.go`, `.py`, `.java`, `.kt`, `.rs`, `.c`, `.cpp`, `.h`, `.hpp`, `.rb`, `.php`, `.swift`, `.vue`, `.svelte`, `.md`, `.sql`, `.graphql`, `.proto`, `.css`, `.scss`, `.html`, `.yaml`, `.yml`, `.toml`, `.json`, `.sh`
- Excluded directories: `node_modules`, `dist`, `build`, `.git`, `target`, `vendor`, `.next`, `.nuxt`, `.svelte-kit`, `out`, `coverage`, `__pycache__`, `.opencode/logs`, `.opencode/data`

See also: [TD Integration Guide](../docs/td-integration.md)

**Known Limitations**:

- **Sub-Agent Sessions (Critical)**: When using the Task tool to spawn sub-agents (e.g., `use @staff-engineer`), TD enforcement does NOT apply to the sub-agent's file operations. This is an architectural limitation of session-scoped plugins.
  
  **Why**: Sub-agents run in isolated sessions without inheriting parent plugins.
  
  **Impact**: Sub-agents can write files without:
  - Permission gates
  - Active task verification
  - Automatic file linking
  - TD logging
  
  **Workarounds**:
  1. Use `/task-with-td` command instead of direct Task tool
  2. Include explicit TD requirements in sub-agent prompts
  3. Link files manually after sub-agent completes: `td link <task> <files...>`
  4. Use pre-commit hooks as backup enforcement
  
  **Example Safe Usage**:
  ```
  /task-with-td staff-engineer "implement authentication"
  # → Checks TD status first
  # → Passes TD context to sub-agent
  # → Links files after completion
  ```

- **Database File Name**: Fixed in v1.1.0 - plugin now correctly looks for `.todos/issues.db` instead of `.todos/db.sqlite`.

---

## Plugin Configuration

**Local plugins** in `.opencode/plugins/` are **automatically loaded** at startup. No configuration needed.

**npm plugins** are specified in `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-helicone-session", "@my-org/custom-plugin"]
}
```

**Load order** (all hooks run in sequence):

1. Global config (`~/.config/opencode/opencode.json`)
2. Project config (`opencode.json`)
3. Global plugin directory (`~/.config/opencode/plugins/`)
4. Project plugin directory (`.opencode/plugins/`)

Within the project plugin directory, files are loaded alphabetically by filename.

Note: this repository currently uses descriptive plugin filenames (not numeric prefixes), so execution order follows alphabetical filename ordering.

---

## Hook & Event System

OpenCode plugins use two mechanisms: **typed hooks** (with specific `input`/`output` signatures) and a generic **`event` hook** that receives all events.

### Typed Hooks

These are top-level keys in the returned hooks object with strongly-typed `(input, output)` signatures:

| Hook | Input | Output (mutable) |
|------|-------|-------------------|
| `"tool.execute.before"` | `{ tool, sessionID, callID }` | `{ args }` |
| `"tool.execute.after"` | `{ tool, sessionID, callID }` | `{ title, output, metadata }` |
| `"shell.env"` | `{ cwd }` | `{ env: Record<string, string> }` |
| `"permission.ask"` | `Permission` | `{ status: "ask" \| "deny" \| "allow" }` |
| `"command.execute.before"` | `{ command, sessionID, arguments }` | `{ parts }` |
| `"chat.message"` | `{ sessionID, agent?, model? }` | `{ message, parts }` |
| `"chat.params"` | `{ sessionID, agent, model, provider, message }` | `{ temperature, topP, topK, options }` |
| `"chat.headers"` | `{ sessionID, agent, model, provider, message }` | `{ headers }` |

### Generic Event Hook

The `event` hook receives **all** OpenCode events as a discriminated union. Use `event.type` to filter:

```typescript
event: async ({ event }) => {
  if (event.type === "session.idle") {
    console.log("Session idle:", event.properties.sessionID)
  }
}
```

**Available event types** (each has a `properties` object with event-specific data):

| Category | Events |
|----------|--------|
| **Session** | `session.created`, `session.idle`, `session.error`, `session.compacted`, `session.updated`, `session.deleted`, `session.diff`, `session.status` |
| **File** | `file.edited`, `file.watcher.updated` |
| **Message** | `message.updated`, `message.removed`, `message.part.updated`, `message.part.removed` |
| **Permission** | `permission.updated`, `permission.replied` |
| **Command** | `command.executed` |
| **Todo** | `todo.updated` |
| **TUI** | `tui.prompt.append`, `tui.command.execute`, `tui.toast.show` |
| **Shell** | `shell.env` |
| **Server** | `server.connected`, `server.instance.disposed` |
| **Other** | `installation.updated`, `lsp.client.diagnostics`, `lsp.updated`, `vcs.branch.updated` |

**Event Payload Structure** (SDK `Event` type):
```typescript
// Each event has { type, properties }
// Examples:
type EventSessionIdle = {
  type: "session.idle"
  properties: { sessionID: string }
}
type EventSessionCreated = {
  type: "session.created"
  properties: { info: Session }
}
type EventFileEdited = {
  type: "file.edited"
  properties: { file: string }
}
type EventSessionError = {
  type: "session.error"
  properties: { sessionID?: string; error?: ProviderAuthError | UnknownError | ... }
}
```

---

## Log File Formats

All logs use **JSONL** (JSON Lines) format: one JSON object per line.

**Benefits**:
- Easy to parse with streaming JSON parsers
- Append-only (no need to read entire file)
- Each line is a complete, valid JSON object
- Standard format for log analysis tools

**Example JSONL**:
```jsonl
{"event":"session_started","timestamp":"2026-02-09T12:34:56.789Z","sessionId":"abc123"}
{"event":"tool_execute","timestamp":"2026-02-09T12:35:00.123Z","tool":"bash","command":"npm install"}
{"event":"session_ended","timestamp":"2026-02-09T12:50:38.456Z","sessionId":"abc123","duration":942}
```

**Reading JSONL**:
```typescript
import * as fs from 'fs';

const logs = fs.readFileSync('logs/session.jsonl', 'utf-8')
  .split('\n')
  .filter(line => line.trim())
  .map(line => JSON.parse(line));
```

---

## Directory Structure

```
.opencode/
├── plugins/
│   ├── README.md                    # This file
│   ├── security.ts                  # Security controls
│   ├── logging.ts                   # Comprehensive logging
│   ├── markdown-validator.ts        # File validation
│   ├── post-stop-detector.ts        # Orphaned file detection
│   ├── session-context.ts           # Session statistics
│   ├── notifications.ts             # Session analytics + TUI toasts
│   └── td-enforcer.ts              # TD task enforcement
├── logs/                            # Auto-generated log directory
│   ├── security.jsonl               # Security blocks
│   ├── tool_use.jsonl               # Tool execution
│   ├── session.jsonl                # Session lifecycle
│   ├── files.jsonl                  # File modifications
│   ├── messages.jsonl               # Message flow
│   ├── permissions.jsonl            # Permission requests
│   ├── commands.jsonl               # Command execution
│   ├── validation.jsonl             # Validation warnings/errors
│   ├── post_stop.jsonl              # Orphaned file detection
│   └── td_enforcer.jsonl           # TD task tracking
└── data/
    └── sessions/                    # Session data storage
        └── {session-id}-snapshot.json  # Filesystem snapshot (post-stop-detector)
```

---

## Installation & Setup

### 1. Install Dependencies

```bash
cd .opencode
bun install  # or: npm install / pnpm install
```

**Required Packages**:
- `@opencode-ai/plugin` - OpenCode plugin SDK
- `zod` - Schema validation
- `gray-matter` - YAML frontmatter parsing
- `typescript` - TypeScript compiler (dev dependency)
- `@types/node` - Node.js type definitions (dev dependency)

### 2. Compile TypeScript (Optional)

Plugins can run directly as TypeScript files, but you can compile for debugging:

```bash
cd .opencode
bun run tsc  # or: npx tsc
```

### 3. Plugins Auto-Load

All `.ts`/`.js` files in `.opencode/plugins/` are automatically loaded at startup. No additional configuration required.

### 4. Test Plugins

Start an OpenCode session and verify:

1. **Security Plugin**: Try `rm -rf /tmp` (should be blocked)
2. **Logging Plugin**: Check `.opencode/logs/` directory (should contain JSONL files)
3. **Validation Plugin**: Edit an agent file with invalid frontmatter (should log warning)
4. **Session Context**: Check session summary on session end
5. **Notifications**: Verify TUI toast appears on session events

---

## Troubleshooting

### Plugins Not Loading

**Check**:
1. `opencode.json` has correct plugin paths
2. Plugin files exist at specified paths
3. TypeScript syntax is valid (no compile errors)
4. Dependencies are installed (`bun install`)

**Debug**:
```bash
cd .opencode
bun run tsc --noEmit  # Check for TypeScript errors
```

### No Logs Being Written

**Check**:
1. `.opencode/logs/` directory exists (created automatically)
2. File permissions allow writing
3. Events are actually firing (try triggering specific events)

**Debug**:
```typescript
// Add to any plugin:
console.log('Plugin loaded:', plugin.name);
console.log('Event received:', event.type);
```

### Security Plugin Not Blocking Commands

**Check**:
1. Security plugin is listed first in `opencode.json`
2. Command matches a blocked pattern
3. Event type is `tool.execute.before`

**Debug**: Check `logs/security.jsonl` for blocked events.

### Notifications Not Appearing

Notifications are delivered via OpenCode TUI toasts only.

**Check**:
1. Ensure you're running in the OpenCode terminal UI
2. Trigger a session lifecycle event (`session.created`, `session.idle`, or `session.error`)
3. Confirm toast popups are visible in the TUI

### Post-Stop Detector Not Finding Changes

**Check**:
1. Changes actually occurred after session went idle
2. Changed files are not in skip list (`node_modules`, `.git`, etc.)
3. 30-second monitoring window hasn't expired

**Debug**: Check `logs/post_stop.jsonl` for snapshot captures.

---

## Creating Custom Plugins

### Basic Plugin Template

A plugin is a TypeScript/JavaScript module that exports a named async function. The function receives a context object and returns a hooks object.

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  console.log("Plugin initialized for", directory)

  return {
    // Typed hook: runs before every tool execution
    "tool.execute.before": async (input, output) => {
      console.log("Tool:", input.tool, "Args:", output.args)
    },

    // Generic event hook: catches all events
    event: async ({ event }) => {
      if (event.type === "session.created") {
        console.log("Session started:", event.properties.info.id)
      }
    },
  }
}
```

### Plugin Context

The plugin function receives:

| Property | Type | Description |
|----------|------|-------------|
| `project` | `Project` | Current project information |
| `directory` | `string` | Current working directory |
| `worktree` | `string` | Git worktree path |
| `client` | SDK client | OpenCode SDK client for `client.app.log()` etc. |
| `$` | `BunShell` | Bun's shell API for executing commands |

### Structured Logging

Use `client.app.log()` instead of `console.log` for structured logging:

```typescript
await client.app.log({
  body: {
    service: "my-plugin",
    level: "info",    // debug | info | warn | error
    message: "Something happened",
    extra: { key: "value" },
  },
})
```

### Custom Tools

Plugins can register custom tools available to the AI:

```typescript
import { type Plugin, tool } from "@opencode-ai/plugin"

export const MyToolPlugin: Plugin = async (ctx) => {
  return {
    tool: {
      mytool: tool({
        description: "This is a custom tool",
        args: { foo: tool.schema.string() },
        async execute(args, context) {
          return `Hello ${args.foo} from ${context.directory}`
        },
      }),
    },
  }
}
```

### Best Practices

1. **Fast Execution**: Keep plugins under 100ms (use async for heavy work)
2. **Error Handling**: Catch errors gracefully (don't crash OpenCode)
3. **Use `client.app.log()`**: Structured logging over `console.log`
4. **Type Safety**: Import `Plugin` type from `@opencode-ai/plugin`
5. **Security**: Validate inputs, don't execute untrusted code
6. **Early Exit**: Return early in `event` hook for irrelevant event types
7. **Use `$` for shell**: Bun's shell API with `.quiet()` for silent execution

### Example: Custom Validation Plugin

```typescript
import type { Plugin } from "@opencode-ai/plugin"
import { readFile, appendFile } from "fs/promises"
import { join } from "path"

export const ConsoleLogDetector: Plugin = async ({ directory }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "file.edited") return

      const filePath = event.properties.file
      if (!filePath.endsWith(".ts")) return

      const fullPath = join(directory, filePath)
      const content = await readFile(fullPath, "utf-8")

      if (content.includes("console.log")) {
        console.warn(`⚠️  Found console.log in ${filePath}`)
        await appendFile(
          join(directory, ".opencode/logs/custom_validation.jsonl"),
          JSON.stringify({
            timestamp: new Date().toISOString(),
            file: filePath,
            issue: "Contains console.log",
          }) + "\n",
        )
      }
    },
  }
}
```

---

## Performance Considerations

### Plugin Overhead

- **Security Plugin**: <1ms per tool execution
- **Logging Plugin**: <5ms per event (file I/O)
- **Validation Plugin**: <10ms per file edit (YAML parsing)
- **Post-Stop Detector**: <100ms snapshot capture (once per session)
- **Session Context Plugin**: <1ms per event
- **Notifications Plugin**: <50ms per notification (subprocess call)

### Optimization Tips

1. **Early Exit**: Return early for irrelevant events
2. **Async Work**: Use `setTimeout` for non-blocking operations
3. **Batch Writes**: Buffer logs and write in batches
4. **Skip Large Files**: Don't hash files >10MB for snapshots
5. **Lazy Loading**: Only import heavy modules when needed

---

## Security Considerations

### Plugin Trust

Plugins run with **full access** to:
- Filesystem (read/write)
- Network (HTTP requests)
- Process execution (child processes)
- Environment variables

**Only use trusted plugins!**

### Sensitive Data

Plugins have access to:
- Session messages (may contain API keys, passwords)
- File contents (may contain secrets)
- Tool execution (may reveal infrastructure)

**Best Practices**:
1. Never log sensitive data (redact secrets)
2. Store logs in `.gitignore`d directory
3. Use secure file permissions on log files
4. Rotate logs periodically
5. Review plugin code before using

---

## Migration from Python Hooks

If migrating from Claude Code's Python hooks to OpenCode's native plugins:

| Python Hook | OpenCode Plugin Equivalent |
|-------------|---------------------------|
| `setup.py` | Plugin init function (runs on load) |
| `session_start.py` | `event` hook, filter `event.type === "session.created"` |
| `session_end.py` | `event` hook, filter `event.type === "session.idle"` |
| `user_prompt_submit.py` | `event` hook, filter `event.type === "message.updated"` |
| `pre_tool_use.py` | `"tool.execute.before"` typed hook |
| `post_tool_use.py` | `"tool.execute.after"` typed hook |
| `post_tool_use_failure.py` | Error handling in `"tool.execute.after"` |
| `permission_request.py` | `"permission.ask"` typed hook |

**Benefits of OpenCode Plugins**:
- No subprocess overhead (faster)
- Native TypeScript with full type safety
- Cross-platform (no Python dependency)
- Better error handling (plugins don't crash OpenCode)
- Simpler configuration (plugins auto-load from `.opencode/plugins/`)

---

## Resources

- **OpenCode Documentation**: https://opencode.ai/docs
- **Plugin SDK**: `@opencode-ai/plugin` package
- **TypeScript Handbook**: https://www.typescriptlang.org/docs/
- **JSONL Format**: https://jsonlines.org/

---

## License

These plugins are part of the `template-opencode` repository and follow the repository's license.

---

**Last Updated**: 2026-02-09  
**Plugin System Version**: OpenCode Native Plugins v1.0.0  
**Maintained By**: OpenCode Components Team
