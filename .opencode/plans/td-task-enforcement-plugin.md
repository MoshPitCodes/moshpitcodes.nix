# TD Task Enforcement Plugin - Complete Implementation Plan

## Executive Summary

**Plugin**: `.opencode/plugins/td-enforcer.ts`  
**Purpose**: Integrate OpenCode AI assistant with TD task management system to enforce task-driven development workflow  
**Estimated Implementation Time**: 6-10 hours  
**Dependencies**: TD CLI (https://github.com/marcus/td), custom OpenCode `td.ts` tool

**Core Features**:
1. ✅ Pre-write permission check (permission.ask hook)
2. ✅ Auto-tracking after writes (link files + log changes)
3. ✅ Review workflow monitoring (watch database, toast notifications)
4. ✅ Session isolation enforcement
5. ✅ TD installation validation with graceful degradation
6. ✅ Smart file filtering (track code, exclude build artifacts)

---

## Architecture Overview

### Plugin Hook Strategy

```typescript
{
  "permission.ask": Check for active task before write operations
  "tool.execute.after": Auto-link files and auto-log changes
  "event": {
    "session.created": Initialize TD session, validate installation
    "session.idle": Remind for handoff if task in_progress
    "session.error": Cleanup watchers
  }
}
```

### Data Flow

```
┌─────────────────┐
│ OpenCode Agent  │
│ (write file)    │
└────────┬────────┘
         │
         v
┌─────────────────────────────────────┐
│ permission.ask hook                 │
│ - Check: td usage --json            │
│ - If no task: Modify status to "ask"│
│ - User sees permission dialog       │
└────────┬────────────────────────────┘
         │
         v (approved)
┌─────────────────────────────────────┐
│ tool.execute.after hook             │
│ - Extract modified files            │
│ - Run: td link <taskID> <files>     │
│ - Run: td log "Modified X files"    │
└─────────────────────────────────────┘

                                        ┌──────────────────┐
                                        │ fs.watch()       │
                                        │ .todos/db.sqlite │
                                        └────────┬─────────┘
                                                 │
                                                 v
                                        ┌──────────────────┐
                                        │ Detect in_review │
                                        │ Toast: Run /review│
                                        └──────────────────┘
```

---

## Design Decisions (Approved by User)

1. **Permission System**: Use `permission.ask` hook (Option A) - simplest, cleanest
2. **Auto-tracking**: Link to primary task only, generate file-focused messages
3. **Review prompting**: Toast notification + warn in logs (non-blocking)
4. **File tracking**: Track code files, add .md for docs
5. **TD validation**: Warn + disable (graceful degradation)
6. **Configuration**: Start with hardcoded defaults, add config later if needed

---

## Implementation Phases

### **Phase 1: Foundation** (Est: 1-2 hours)

#### 1.1 TD Installation Check
```typescript
// On session.created event
const checkTDInstalled = async ($): Promise<boolean> => {
  try {
    const result = await $`td version --json`.quiet()
    return result.exitCode === 0
  } catch {
    return false
  }
}

// If not installed: warn + disable plugin gracefully
if (!installed) {
  console.warn("⚠️  TD not installed. TD enforcer plugin disabled.")
  console.warn("   Install: https://github.com/marcus/td")
  return {} // Return empty hooks object
}
```

#### 1.2 TD Usage Parser
```typescript
interface TDUsage {
  focus?: {
    id: string
    title: string
    key: string
  }
  session?: {
    id: string
    name: string
  }
  inProgress: Array<{
    id: string
    key: string
    title: string
  }>
  inReview: Array<{
    id: string
    key: string
    reviewerSessionID?: string
  }>
}

const getTDUsage = async ($): Promise<TDUsage | null> => {
  try {
    const result = await $`td usage --json`.quiet()
    if (result.exitCode !== 0) return null
    return JSON.parse(result.stdout.toString())
  } catch {
    return null
  }
}
```

#### 1.3 File Tracking Logic
```typescript
const TRACKED_EXTENSIONS = [
  ".ts", ".tsx", ".js", ".jsx", ".go", ".py", ".java", ".kt", ".rs",
  ".c", ".cpp", ".h", ".hpp", ".rb", ".php", ".swift", ".vue", 
  ".svelte", ".md", ".sql", ".graphql", ".proto"
]

const EXCLUDED_DIRS = [
  "node_modules", "dist", "build", ".git", "target", "vendor",
  ".next", ".nuxt", ".svelte-kit", "out", "coverage", "__pycache__",
  ".opencode/logs", ".opencode/data"
]

const shouldTrackFile = (filePath: string): boolean => {
  // Check excluded directories
  if (EXCLUDED_DIRS.some(dir => filePath.includes(`/${dir}/`))) {
    return false
  }
  
  // Check file extension
  return TRACKED_EXTENSIONS.some(ext => filePath.endsWith(ext))
}
```

#### 1.4 Logging Infrastructure
```typescript
const logDir = join(directory, ".opencode", "logs")
const logFile = join(logDir, "td_enforcer.jsonl")

const logEvent = async (data: Record<string, unknown>) => {
  try {
    await client.app.log({
      body: {
        service: "td-enforcer",
        level: "info",
        message: String(data.event ?? "td_event"),
        extra: data,
      },
    })
    await appendFile(logFile, JSON.stringify({
      timestamp: new Date().toISOString(),
      ...data
    }) + "\n")
  } catch {
    // Fail silently
  }
}
```

---

### **Phase 2: Permission System** (Est: 1 hour)

#### 2.1 Permission Hook Implementation

**Strategy**: Use `permission.ask` hook to modify permission status when no task is active.

```typescript
"permission.ask": async (input, output) => {
  // Only intercept write/edit operations
  if (!["write", "edit"].includes(input.tool || "")) {
    return // Let other permissions pass through
  }

  // Check for active task
  const usage = await getTDUsage($)
  const hasActiveTask = usage?.focus || (usage?.inProgress.length ?? 0) > 0

  if (!hasActiveTask) {
    // Modify permission status to "ask"
    // This triggers OpenCode's permission dialog
    output.status = "ask"
    
    await logEvent({
      event: "permission_ask_no_task",
      tool: input.tool,
      originalStatus: output.status,
    })
  }
}
```

**Note**: The permission dialog will show OpenCode's default message. The user workflow becomes:
1. Agent attempts write without active task
2. User sees permission request
3. User runs `td start <task-id>` in another terminal
4. User approves permission in OpenCode
5. Write proceeds

**Alternative considered**: Throwing error would break the operation entirely. Permission hook allows user to fix the issue and continue.

---

### **Phase 3: Auto-Tracking** (Est: 1-2 hours)

#### 3.1 Extract Modified Files from Tool Output

```typescript
"tool.execute.after": async (input, output) => {
  // Only track write/edit operations
  if (!["write", "edit"].includes(input.tool)) {
    return
  }

  try {
    const usage = await getTDUsage($)
    if (!usage?.focus) {
      // No focused task - skip auto-tracking
      return
    }

    const taskID = usage.focus.id
    const files: string[] = []

    // Extract file path from tool metadata
    if (input.tool === "write" || input.tool === "edit") {
      const filePath = output.metadata?.filePath
      if (filePath && shouldTrackFile(filePath)) {
        files.push(filePath)
      }
    }

    if (files.length === 0) return

    // Auto-link files to task
    await autoLinkFiles(taskID, files, $)
    
    // Auto-log changes
    await autoLogChanges(taskID, input.tool, files, $)

    await logEvent({
      event: "auto_tracked",
      taskID,
      files,
      tool: input.tool,
    })
  } catch (error) {
    await logEvent({
      event: "auto_track_error",
      error: String(error),
    })
  }
}
```

#### 3.2 Auto-Link Implementation

```typescript
const autoLinkFiles = async (
  taskID: string,
  files: string[],
  $: BunShell
): Promise<void> => {
  try {
    // TD supports linking multiple files at once
    const fileArgs = files.join(" ")
    await $`td link ${taskID} ${fileArgs}`.quiet()
  } catch (error) {
    // Log error but don't fail operation
    console.warn(`Failed to auto-link files: ${error}`)
  }
}
```

#### 3.3 Auto-Log Implementation

```typescript
const autoLogChanges = async (
  taskID: string,
  tool: string,
  files: string[],
  $: BunShell
): Promise<void> => {
  try {
    const message = files.length === 1
      ? `${tool}: ${files[0]}`
      : `${tool}: ${files.length} files (${files.map(f => f.split("/").pop()).join(", ")})`
    
    // td log appends to current focused task
    await $`td log ${message}`.quiet()
  } catch (error) {
    console.warn(`Failed to auto-log changes: ${error}`)
  }
}
```

**Note**: Multi-task scenarios (td ws) are handled by TD's focus mechanism - we always track to the focused task.

---

### **Phase 4: Review Workflow** (Est: 2-3 hours)

#### 4.1 Database Watcher Setup

```typescript
import { watch } from "fs/promises"

let dbWatcher: AsyncIterator<any> | null = null

const startDatabaseWatch = async (directory: string) => {
  const dbPath = join(directory, ".todos", "db.sqlite")
  
  try {
    // Check if database exists
    const { existsSync } = await import("fs")
    if (!existsSync(dbPath)) {
      console.warn("TD database not found - review monitoring disabled")
      return
    }

    dbWatcher = watch(dbPath)
    
    // Poll for changes (debounced)
    let debounceTimer: Timer | null = null
    
    for await (const event of dbWatcher) {
      if (event.eventType === "change") {
        // Debounce rapid changes (SQLite can trigger multiple events)
        if (debounceTimer) clearTimeout(debounceTimer)
        
        debounceTimer = setTimeout(async () => {
          await checkForReviewTasks($, client)
        }, 500)
      }
    }
  } catch (error) {
    console.warn(`Failed to watch TD database: ${error}`)
  }
}
```

#### 4.2 Review Detection

```typescript
const lastSeenReviews = new Set<string>()

const checkForReviewTasks = async ($: BunShell, client: Client) => {
  try {
    const usage = await getTDUsage($)
    if (!usage) return

    const currentSessionID = usage.session?.id
    if (!currentSessionID) return

    // Find new tasks in review
    for (const task of usage.inReview) {
      // Skip if we've already notified about this task
      if (lastSeenReviews.has(task.id)) continue

      // Session isolation: skip if current session created this task
      if (task.reviewerSessionID === currentSessionID) {
        await logEvent({
          event: "review_blocked_same_session",
          taskID: task.id,
          sessionID: currentSessionID,
        })
        continue
      }

      // New task in review - prompt for validation
      await promptForValidation(task, client)
      lastSeenReviews.add(task.id)
    }

    // Clean up completed reviews from tracking
    const currentReviewIDs = new Set(usage.inReview.map(t => t.id))
    for (const id of lastSeenReviews) {
      if (!currentReviewIDs.has(id)) {
        lastSeenReviews.delete(id)
      }
    }
  } catch (error) {
    await logEvent({
      event: "review_check_error",
      error: String(error),
    })
  }
}
```

#### 4.3 Validator Prompting (Toast Notification)

```typescript
const promptForValidation = async (
  task: { id: string; key: string },
  client: Client
) => {
  try {
    // Send toast notification to TUI
    await client.tui.showToast({
      body: {
        title: "Task Ready for Review",
        message: `${task.key} is ready for review. Run agent with code-review or architecture-review to validate.`,
        level: "info",
      },
    })

    await logEvent({
      event: "review_prompt_sent",
      taskID: task.id,
      taskKey: task.key,
    })
  } catch (error) {
    // Fallback to console if toast fails
    console.log(`\n📋 Task ${task.key} ready for review - run validator agent\n`)
  }
}
```

**Design Decision**: Toast notification instead of auto-launching agents. Reasons:
- User maintains control over when to review
- Avoids interrupting current work
- Non-blocking workflow
- User can batch reviews

---

### **Phase 5: Integration & Lifecycle** (Est: 1 hour)

#### 5.1 Session Lifecycle Hooks

```typescript
event: async ({ event }) => {
  switch (event.type) {
    case "session.created": {
      const sessionID = event.properties.info.id
      
      // Check TD installation
      const installed = await checkTDInstalled($)
      if (!installed) {
        console.warn("⚠️  TD not installed. Plugin disabled.")
        return
      }

      // Initialize new TD session
      try {
        await $`td usage --new-session`.quiet()
        await logEvent({
          event: "session_initialized",
          sessionID,
        })
      } catch (error) {
        console.warn("Failed to initialize TD session")
      }

      // Start database watcher
      await startDatabaseWatch(directory)
      break
    }

    case "session.idle": {
      // Check if user has task in_progress
      const usage = await getTDUsage($)
      if (usage?.focus || (usage?.inProgress.length ?? 0) > 0) {
        console.log("\n💡 Tip: Run 'td handoff' to capture working state before ending session\n")
      }
      
      // Stop database watcher
      if (dbWatcher) {
        try {
          await dbWatcher.return?.()
        } catch {
          // Ignore cleanup errors
        }
      }
      break
    }

    case "session.error": {
      // Cleanup on error
      if (dbWatcher) {
        try {
          await dbWatcher.return?.()
        } catch {
          // Ignore cleanup errors
        }
      }
      break
    }
  }
}
```

#### 5.2 Coordination with session-context Plugin

Update `session-context.ts` to include TD task in summary:

```typescript
// In finalizeSession function (session-context.ts)
// Add TD task information to summary

const getTDTask = async (): Promise<string | null> => {
  try {
    const result = await $`td usage --json`.quiet()
    if (result.exitCode !== 0) return null
    const usage = JSON.parse(result.stdout.toString())
    return usage?.focus?.key ?? null
  } catch {
    return null
  }
}

// In console.log section:
const tdTask = await getTDTask()
if (tdTask) {
  console.log(`   TD task: ${tdTask}`)
}
```

**Note**: Both plugins operate independently - no shared state needed. They both listen to events and act accordingly.

---

### **Phase 6: Documentation** (Est: 30 min)

#### 6.1 Update Plugin README

Add section to `.opencode/plugins/README.md`:

````markdown
### TD Task Enforcement Plugin

**Purpose**: Integrates with TD task management system to enforce task-driven development workflow.

**Features**:
- ✅ Permission check before writes if no active task
- ✅ Auto-link modified files to tasks
- ✅ Auto-log changes to task log
- ✅ Monitor for tasks entering review
- ✅ Prompt for validator agents (non-blocking)
- ✅ Session isolation enforcement

**Requirements**:
- TD CLI installed (https://github.com/marcus/td)
- Initialized TD project (`td init` in project root)

**Configuration**: Hardcoded defaults (planned: `.opencode/config/td-enforcer.json`)

**Workflow**:
1. Start task: `td start <task-id>` or `td focus <task-id>`
2. OpenCode agent makes changes - auto-tracked to task
3. Submit for review: `td review <task-id>`
4. Plugin detects review state, shows toast notification
5. Run validator agent in new session to review

**Logs**: `.opencode/logs/td_enforcer.jsonl`
````

#### 6.2 Create User Guide

Create `.opencode/docs/td-integration.md`:

````markdown
# TD Task Management Integration Guide

## Overview

The TD Task Enforcement plugin integrates OpenCode AI assistant with the TD task management system to enforce task-driven development workflows.

## Setup

1. **Install TD CLI**:
   ```bash
   # See: https://github.com/marcus/td
   ```

2. **Initialize TD project**:
   ```bash
   cd /path/to/project
   td init
   ```

3. **Plugin auto-loads** - no configuration needed!

## Workflow

### Starting Work

```bash
# Option 1: Start existing task
td start TASK-123

# Option 2: Create and start new task
td create "Implement feature X" --start
```

Once a task is focused, the plugin automatically:
- Tracks all file modifications to the task
- Logs changes to task log

### During Development

OpenCode agent makes changes normally. Plugin handles:
- Auto-linking modified files
- Auto-logging with descriptive messages
- Permission checks if no task is active

### Submitting for Review

```bash
# Submit task for review
td review TASK-123

# Capture working state for next session
td handoff
```

Plugin detects review status and shows toast notification.

### Reviewing Work

```bash
# In NEW OpenCode session (different session ID)
# Run validator agent manually
```

Plugin enforces session isolation - same session cannot review its own work.

## Troubleshooting

**Plugin disabled message**:
- TD not installed or not in PATH
- Run `td version` to verify installation

**Files not auto-linking**:
- Check file extension is tracked (see TRACKED_EXTENSIONS)
- Check directory not excluded (see EXCLUDED_DIRS)
- Check `td focus` shows active task

**Review notifications not appearing**:
- Check `.todos/db.sqlite` exists
- Check TD database permissions
- See logs: `.opencode/logs/td_enforcer.jsonl`

## Advanced

### File Tracking

**Tracked extensions**: .ts, .tsx, .js, .jsx, .go, .py, .java, .kt, .rs, .c, .cpp, .h, .hpp, .rb, .php, .swift, .vue, .svelte, .md, .sql, .graphql, .proto

**Excluded directories**: node_modules, dist, build, .git, target, vendor, .next, .nuxt, .svelte-kit, out, coverage, __pycache__, .opencode/logs, .opencode/data

### Multi-Task Work Sessions

Use `td ws` (work session) to work on multiple tasks simultaneously. Plugin tracks files to the **focused task** (set via `td focus`).

### Session Management

TD assigns unique session IDs to isolate review work. Plugin:
- Initializes new session on `session.created`
- Enforces different session must review tasks
- Reminds for handoff on `session.idle`

## Future Enhancements

- Configuration file for customizing tracked extensions
- Auto-create task from agent prompts
- Integration with Linear/GitHub issues via TD
- Review agent auto-invocation (opt-in)
````

#### 6.3 Update Main Documentation

Update `AGENTS.md` and `README.md` to mention TD integration:

```markdown
**TD Task Enforcement Plugin**:
- Enforces task-driven development workflow
- Auto-tracks file changes to TD tasks
- Monitors review status and prompts validators
- Session isolation for code review integrity
```

---

## Testing Strategy

### Manual Testing Checklist

**Phase 1**:
- [ ] TD not installed: Plugin disables gracefully with warning
- [ ] TD installed but not initialized: Plugin warns about missing database
- [ ] `getTDUsage()` parses JSON correctly
- [ ] `shouldTrackFile()` filters correctly

**Phase 2**:
- [ ] Write operation with no task: Permission dialog appears
- [ ] Write operation with focused task: Permission granted automatically
- [ ] Permission logs recorded correctly

**Phase 3**:
- [ ] File write auto-links to focused task
- [ ] File edit auto-links to focused task
- [ ] Auto-log message format is correct
- [ ] Multiple files tracked in single operation
- [ ] Excluded files (node_modules, etc.) not tracked

**Phase 4**:
- [ ] Database watcher starts successfully
- [ ] Task entering review triggers toast notification
- [ ] Same session blocked from reviewing own work
- [ ] Different session can review
- [ ] Completed reviews removed from tracking

**Phase 5**:
- [ ] Session initialization creates new TD session
- [ ] Session idle shows handoff reminder if task in progress
- [ ] Session error cleans up watcher
- [ ] Session context plugin shows TD task in summary

**Phase 6**:
- [ ] Documentation accurate and complete
- [ ] Examples work as written

### Unit Test Plan (Future)

```typescript
// Test file: .opencode/plugins/__tests__/td-enforcer.test.ts

describe("TD Enforcer Plugin", () => {
  describe("shouldTrackFile", () => {
    it("tracks TypeScript files", () => {
      expect(shouldTrackFile("src/foo.ts")).toBe(true)
    })
    
    it("excludes node_modules", () => {
      expect(shouldTrackFile("node_modules/foo/bar.ts")).toBe(false)
    })
  })

  describe("getTDUsage", () => {
    it("parses valid JSON", async () => {
      // Mock $ command
      const usage = await getTDUsage(mockShell)
      expect(usage).toHaveProperty("focus")
    })
  })

  // ... more tests
})
```

---

## File Structure

```
.opencode/
├── plugins/
│   ├── td-enforcer.ts           # NEW: Main plugin (600-800 lines)
│   ├── session-context.ts       # MODIFIED: Add TD task to summary
│   └── README.md                # MODIFIED: Add TD enforcer section
├── docs/
│   └── td-integration.md        # NEW: User guide
├── logs/
│   └── td_enforcer.jsonl        # NEW: Auto-created log file
└── data/
    └── sessions/                # Existing: Session snapshots
```

**Main file**: `.opencode/plugins/td-enforcer.ts`

**Estimated lines of code**: 600-800 lines (including comments and types)

---

## Dependencies

**NPM packages** (already installed):
- `@opencode-ai/plugin` - Plugin SDK
- `@opencode-ai/sdk` - Client SDK

**No additional dependencies needed** - uses Node.js built-ins:
- `fs/promises` - File operations and watching
- `path` - Path manipulation

**External dependencies**:
- TD CLI (user must install separately)
- OpenCode custom TD tool (`.opencode/tools/td.ts`)

---

## Configuration (Future Enhancement)

**Planned**: `.opencode/config/td-enforcer.json`

```json
{
  "strictMode": true,
  "autoLink": true,
  "autoLog": true,
  "validatorAgents": ["architecture-review", "code-review"],
  "fileTracking": {
    "trackedExtensions": [".ts", ".js", ".go", ".py", ...],
    "excludedDirs": ["node_modules", "dist", ".git", ...]
  },
  "notifications": {
    "reviewToast": true,
    "handoffReminder": true
  }
}
```

**Phase 1 implementation**: Hardcode defaults, skip configuration file.

---

## Error Handling

### Graceful Degradation

```typescript
// TD not installed
if (!installed) {
  console.warn("⚠️  TD not installed - plugin disabled")
  return {} // Return empty hooks
}

// TD command failures
try {
  await $`td link ...`
} catch (error) {
  // Log error but don't crash
  console.warn(`TD command failed: ${error}`)
  await logEvent({ event: "td_command_error", error })
}

// Database watch failures
try {
  dbWatcher = watch(dbPath)
} catch (error) {
  console.warn("Failed to watch database - review monitoring disabled")
  // Continue without watch
}
```

### Error Logging

All errors logged to:
- `.opencode/logs/td_enforcer.jsonl` (file log)
- OpenCode's internal log system (via `client.app.log()`)

---

## Performance Considerations

1. **Database watching**: Uses `fs/promises.watch()` (efficient, event-driven)
2. **Debouncing**: 500ms debounce on database changes to avoid spam
3. **Async operations**: All TD commands use `.quiet()` and run async
4. **Graceful failures**: Never block OpenCode operations on TD failures

---

## Security Considerations

1. **No credential exposure**: TD database contains only task data
2. **File path validation**: Use `shouldTrackFile()` to avoid tracking secrets
3. **Command injection**: TD CLI called via Bun's `$` (shell escaping handled)
4. **Database access**: Read-only watch, no direct SQLite access

---

## Open Questions for User

1. **File tracking extensions** - Should I add/remove any from this list?
   - Current: .ts, .tsx, .js, .jsx, .go, .py, .java, .kt, .rs, .c, .cpp, .h, .hpp, .rb, .php, .swift, .vue, .svelte, .md, .sql, .graphql, .proto

2. **Toast notification content** - Is this message clear enough?
   > "Task ABC-123 is ready for review. Run agent with code-review or architecture-review to validate."

3. **TD database location** - I assumed `.todos/db.sqlite` - is that correct?

4. **Session initialization** - Should I run `td usage --new-session` or just let TD auto-detect?

---

## Implementation Checklist

- [x] Phase 1: Foundation (TD check, usage parser, file tracking, logging)
- [x] Phase 2: Permission system (permission.ask hook)
- [x] Phase 3: Auto-tracking (link files, log changes)
- [x] Phase 4: Review workflow (database watch, toast notifications)
- [x] Phase 5: Integration & lifecycle hooks
- [x] Phase 6: Documentation (README, user guide, AGENTS.md)
- [ ] Testing: Manual testing checklist execution
- [ ] Code review and refinement
- [ ] User acceptance testing

**Status**: Implemented. TypeScript compiles with strict:true, zero errors.

**Last Updated**: 2026-02-09
