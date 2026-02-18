# OpenCode Native Plugins Implementation Plan

**Date:** 2026-02-09  
**Status:** 📋 PLANNING  
**Type:** Infrastructure Enhancement

---

## Executive Summary

Implement **OpenCode's native TypeScript plugin system** to replace/enhance the current hook-based architecture with event-driven plugins. This provides better integration with OpenCode's ecosystem, type safety, performance improvements, and access to 30+ event types.

### Key Goals

1. ✅ **Security Validation** - Block dangerous commands and sensitive file access
2. ✅ **Comprehensive Logging** - Track all events in structured JSONL format
3. ✅ **Markdown Validation** - Enforce structure for agents, skills, and documentation
4. ✅ **Post-Stop File Detection** - Detect files created after session completion
5. ✅ **Session Context Tracking** - Git status, project context, session analytics
6. ✅ **System Notifications** - Alert on session completion and errors
7. ✅ **Cleanup** - Remove all OpenCode references and consolidate to OpenCode

---

## Architecture Overview

### Current State
```
.opencode/
├── agents/              # 23+ specialized agents
├── commands/            # 6 slash commands
├── skills/              # 8 bundled skills
├── settings/            # Environment configurations
├── logs/                # Existing log files (from previous system)
└── (82 Claude references to remove)
```

### Target State
```
.opencode/
├── plugins/             # NEW - TypeScript event plugins
│   ├── security.ts
│   ├── logging.ts
│   ├── markdown-validator.ts
│   ├── post-stop-detector.ts
│   ├── session-context.ts
│   └── notifications.ts
├── logs/                # Enhanced JSONL event logs
│   ├── tool_use.jsonl
│   ├── session.jsonl
│   ├── files.jsonl
│   ├── security.jsonl
│   ├── validation.jsonl
│   └── post_stop.jsonl
├── package.json         # Plugin dependencies
├── tsconfig.json        # TypeScript configuration
└── (All cleaned up - OpenCode only)
```

**Root Level:**
```
opencode.json            # NEW - OpenCode configuration
```

---

## Phase 1: Foundation Setup

### 1.1 Create OpenCode Configuration

**File:** `opencode.json` (project root)

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [],
  "permissions": {
    "allow": [
      "bash:mkdir:*",
      "bash:find:*",
      "bash:mv:*",
      "bash:grep:*",
      "bash:npm:*",
      "bash:bun:*",
      "bash:ls:*",
      "bash:cp:*",
      "bash:chmod:*",
      "bash:touch:*",
      "bash:git:*",
      "write",
      "edit"
    ],
    "deny": [
      "bash:rm:-rf*",
      "bash:rm:--recursive*"
    ]
  }
}
```

**Purpose:**
- Configure OpenCode for the project
- Set global permissions policy
- Auto-load plugins from `.opencode/plugins/`

---

### 1.2 Initialize Plugin Infrastructure

**File:** `.opencode/package.json`

```json
{
  "name": "opencode-template-plugins",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "description": "OpenCode native plugins for template-opencode project",
  "dependencies": {
    "@opencode-ai/plugin": "latest",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0"
  }
}
```

**Purpose:**
- Manage plugin dependencies
- Enable TypeScript support
- Use Zod for schema validation

---

### 1.3 TypeScript Configuration

**File:** `.opencode/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./plugins"
  },
  "include": ["plugins/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Purpose:**
- Type-safe plugin development
- Modern ES2022 features
- Strict type checking

---

## Phase 2: Core Plugins Implementation

### 2.1 Security Plugin

**File:** `.opencode/plugins/security.ts`

**Purpose:** Block dangerous operations and protect sensitive files

**Features:**
1. **Dangerous Command Detection**
   - Block `rm -rf` in all variations
   - Block `rm --recursive --force`
   - Block recursive deletes targeting dangerous paths (/, ~, *, etc.)
   
2. **Sensitive File Protection**
   - Block access to `.env` files (allow `.env.sample`, `.env.example`)
   - Block access to credential files (`credentials.json`, `*.key`, `*.pem`)
   - Block system file modifications (`/etc/*`, `/usr/*`, `/var/*`)

3. **Logging**
   - Log all blocked operations to `logs/security.jsonl`
   - Include timestamp, tool, args, reason, and session ID

**Event Hooks:**
- `tool.execute.before` - Validate before execution
- `file.edited` - Check file paths on edits

**Implementation Outline:**
```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const SecurityPlugin: Plugin = async ({ client, directory }) => {
  const logSecurity = async (event: any) => {
    // Write to logs/security.jsonl
  }
  
  return {
    "tool.execute.before": async (input, output) => {
      // 1. Check bash commands for rm -rf patterns
      // 2. Check file operations for .env, credentials, system paths
      // 3. Throw error to block if dangerous
      // 4. Log blocked operations
    }
  }
}
```

**Exit Behavior:**
- Throw `Error` to block tool execution
- Error message shown to AI and user

---

### 2.2 Logging Plugin

**File:** `.opencode/plugins/logging.ts`

**Purpose:** Comprehensive event tracking in structured JSONL format

**Features:**
1. **Tool Execution Logging**
   - Log `tool.execute.before` with tool name and arguments
   - Log `tool.execute.after` with results (truncated to 500 chars)
   - Log errors separately with full stack traces

2. **Session Event Logging**
   - `session.created` - Track new sessions with model, timestamp
   - `session.idle` - Track completion with duration
   - `session.error` - Track errors with context
   - `session.compacted` - Track context compactions

3. **File Change Logging**
   - `file.edited` - Track file modifications with paths, changes
   - `file.watcher.updated` - Track watched file changes

4. **Message Logging**
   - `message.updated` - Track conversation flow
   - `message.part.updated` - Track streaming updates

**Log Structure:**
```typescript
interface LogEntry {
  timestamp: string        // ISO 8601 format
  sessionId: string
  event: string           // Event type
  tool?: string           // Tool name (if applicable)
  success?: boolean       // Success/failure
  data: Record<string, any>  // Event-specific data
}
```

**Log Files:**
- `logs/tool_use.jsonl` - All tool executions
- `logs/session.jsonl` - Session lifecycle events
- `logs/files.jsonl` - File operations
- `logs/messages.jsonl` - Conversation flow

**Implementation Outline:**
```typescript
import type { Plugin } from "@opencode-ai/plugin"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"

export const LoggingPlugin: Plugin = async ({ directory }) => {
  const logEvent = async (file: string, data: any) => {
    const logDir = join(directory, ".opencode", "logs")
    await mkdir(logDir, { recursive: true })
    const logPath = join(logDir, `${file}.jsonl`)
    const line = JSON.stringify({
      ...data,
      timestamp: new Date().toISOString()
    })
    await writeFile(logPath, line + "\n", { flag: "a" })
  }
  
  return {
    "tool.execute.before": async (input, output) => {
      // Log tool execution start
    },
    "tool.execute.after": async (input, output) => {
      // Log tool execution completion
    },
    "session.created": async (input) => {
      // Log session start
    },
    "session.idle": async (input) => {
      // Log session completion
    },
    "file.edited": async (input) => {
      // Log file changes
    }
    // ... more event handlers
  }
}
```

---

### 2.3 Markdown Validator Plugin

**File:** `.opencode/plugins/markdown-validator.ts`

**Purpose:** Enforce structure and quality for markdown files in specific directories

**Validation Rules by File Type:**

#### A. Agent Files (`.opencode/agents/*.md`)
```yaml
Required Frontmatter:
  - name: string (kebab-case, matches filename)
  - description: string (multi-line, with examples)
  - type: "primary" | "subagent"
  - model: string (provider/model-name format)
  - tools: object (write, edit booleans)
  - permission: object (bash permissions)

Required Sections:
  - Persona/Role description
  - Core principles or focus areas
  - Code examples or workflows

Structure Validation:
  - Frontmatter must be first
  - No duplicate headings
  - Heading hierarchy (no skipping levels)
  - Examples must have proper XML tags
```

#### B. Skill Files (`.opencode/skills/*/SKILL.md`)
```yaml
Required Frontmatter:
  - name: string (kebab-case)
  - description: string (when to use)
  - license: string (optional)

Required Sections:
  - # Skill Name (H1)
  - ## Overview
  - ## [Workflow/Tasks/Guidelines section]
  - ## Examples or Usage

Structure Validation:
  - Must start with frontmatter
  - Exactly one H1 heading
  - Logical section progression
  - Code blocks must have language identifiers
```

#### C. Command Files (`.opencode/commands/*.md`)
```yaml
Optional Frontmatter:
  - allowed-tools: string (comma-separated)
  - argument-hint: string
  - description: string

Required Structure:
  - Clear workflow steps
  - Numbered or bulleted procedures
  - No frontmatter violations

Structure Validation:
  - Proper heading hierarchy
  - Consistent list formatting
  - No broken markdown syntax
```

#### D. Documentation Files (`.opencode/docs/*.md`)
```yaml
Required Structure:
  - Proper heading hierarchy
  - Table of contents (for long docs)
  - No broken links
  - Code blocks with language identifiers

Optional Frontmatter:
  - title: string
  - date: string
  - status: string
```

**Validation Process:**
1. Detect file type by path pattern
2. Parse frontmatter (if required)
3. Validate frontmatter schema
4. Parse markdown structure
5. Check heading hierarchy
6. Validate required sections exist
7. Check code block formatting
8. Log warnings/errors to `logs/validation.jsonl`

**Implementation Outline:**
```typescript
import type { Plugin } from "@opencode-ai/plugin"
import { readFile } from "fs/promises"
import matter from "gray-matter"  // Parse frontmatter
import { remark } from "remark"   // Parse markdown AST

interface ValidationRule {
  pattern: RegExp
  requiredFrontmatter?: string[]
  requiredSections?: string[]
  validate: (content: string, frontmatter: any) => ValidationResult
}

const VALIDATION_RULES: ValidationRule[] = [
  {
    pattern: /\.opencode\/agents\/.*\.md$/,
    requiredFrontmatter: ["name", "description", "type", "model"],
    requiredSections: ["Persona", "Principles", "Examples"],
    validate: validateAgentFile
  },
  {
    pattern: /\.opencode\/skills\/.*\/SKILL\.md$/,
    requiredFrontmatter: ["name", "description"],
    requiredSections: ["Overview", "Usage"],
    validate: validateSkillFile
  }
  // ... more rules
]

export const MarkdownValidatorPlugin: Plugin = async ({ client, directory }) => {
  return {
    "file.edited": async (input) => {
      if (!input.path.endsWith(".md")) return
      
      // 1. Find matching validation rule
      // 2. Read file content
      // 3. Parse frontmatter
      // 4. Validate structure
      // 5. Log warnings if violations found
      // 6. Optionally throw error to block (configurable)
    }
  }
}
```

**Behavior:**
- **Warn Mode** (default): Log violations, don't block
- **Strict Mode** (optional): Throw error to block saves with violations

---

### 2.4 Post-Stop File Detector Plugin

**File:** `.opencode/plugins/post-stop-detector.ts`

**Purpose:** Detect files created/modified after session stop event (potential orphaned files)

**Use Case:**
When a session ends but background processes or async operations create files afterward, these orphaned files should be tracked and reported.

**Features:**
1. **Snapshot on Stop**
   - Capture file tree state when `session.idle` fires
   - Store in `.opencode/data/sessions/{session-id}-snapshot.json`

2. **Post-Stop Monitoring**
   - Watch filesystem for 30 seconds after stop
   - Detect any new files created during grace period

3. **Detection & Reporting**
   - Compare current state to snapshot
   - Log orphaned files to `logs/post_stop.jsonl`
   - Generate report with file paths, sizes, timestamps

4. **Notification**
   - Alert user if orphaned files detected
   - Suggest cleanup actions

**Implementation Outline:**
```typescript
import type { Plugin } from "@opencode-ai/plugin"
import { watch } from "fs/promises"
import { readdir, stat } from "fs/promises"

export const PostStopDetectorPlugin: Plugin = async ({ directory, $ }) => {
  let sessionSnapshot: Set<string> | null = null
  let monitoringActive = false
  
  const captureSnapshot = async (): Promise<Set<string>> => {
    const files = await $`find ${directory} -type f`.text()
    return new Set(files.split("\n").filter(Boolean))
  }
  
  const startMonitoring = async (sessionId: string) => {
    monitoringActive = true
    
    // Monitor for 30 seconds
    setTimeout(async () => {
      if (!sessionSnapshot) return
      
      const currentFiles = await captureSnapshot()
      const orphanedFiles = [...currentFiles].filter(
        f => !sessionSnapshot.has(f)
      )
      
      if (orphanedFiles.length > 0) {
        // Log orphaned files
        await logOrphanedFiles(sessionId, orphanedFiles)
        // Notify user
        await notifyOrphanedFiles(orphanedFiles)
      }
      
      monitoringActive = false
      sessionSnapshot = null
    }, 30000)
  }
  
  return {
    "session.idle": async (input) => {
      // Capture snapshot of current files
      sessionSnapshot = await captureSnapshot()
      // Start 30-second monitoring period
      await startMonitoring(input.session.id)
    }
  }
}
```

**Log Format:**
```jsonl
{"timestamp":"2026-02-09T10:30:00Z","sessionId":"abc123","orphanedFiles":["/path/to/file1.txt","/path/to/file2.log"],"count":2}
```

---

### 2.5 Session Context Plugin

**File:** `.opencode/plugins/session-context.ts`

**Purpose:** Track session lifecycle with git status and project context

**Features:**
1. **Session Start Context**
   - Git branch, uncommitted changes count
   - Working directory
   - Model being used
   - Timestamp

2. **Session Completion Summary**
   - Duration
   - Tools used count
   - Files modified count
   - Success/error status

3. **Session History**
   - Store in `.opencode/data/sessions/{session-id}.json`
   - Include full timeline of events

**Implementation Outline:**
```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const SessionContextPlugin: Plugin = async ({ directory, $ }) => {
  let sessionStats = {
    toolsUsed: 0,
    filesModified: new Set<string>(),
    startTime: Date.now()
  }
  
  return {
    "session.created": async (input) => {
      // Get git status
      const branch = await $`git rev-parse --abbrev-ref HEAD`.quiet()
      const status = await $`git status --porcelain`.quiet()
      const uncommitted = status.stdout.toString().split("\n").filter(Boolean).length
      
      // Log session start with context
      await logSessionStart({
        sessionId: input.session.id,
        model: input.session.model,
        branch: branch.stdout.toString().trim(),
        uncommittedChanges: uncommitted,
        directory: directory
      })
    },
    
    "tool.execute.after": async (input) => {
      sessionStats.toolsUsed++
    },
    
    "file.edited": async (input) => {
      sessionStats.filesModified.add(input.path)
    },
    
    "session.idle": async (input) => {
      const duration = Date.now() - sessionStats.startTime
      
      // Log session completion with stats
      await logSessionEnd({
        sessionId: input.session.id,
        duration: duration,
        toolsUsed: sessionStats.toolsUsed,
        filesModified: sessionStats.filesModified.size
      })
    }
  }
}
```

---

### 2.6 Notifications Plugin

**File:** `.opencode/plugins/notifications.ts`

**Purpose:** System notifications for session events (cross-platform)

**Features:**
1. **Session Completion Notification**
   - "OpenCode session completed!"
   - Includes duration

2. **Session Error Notification**
   - "OpenCode session error occurred"
   - Includes error summary

3. **Cross-Platform Support**
   - macOS: `osascript` (AppleScript)
   - Linux: `notify-send`
   - Windows: `msg` (WSL) or skip

**Implementation Outline:**
```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const NotificationsPlugin: Plugin = async ({ $ }) => {
  const sendNotification = async (title: string, message: string) => {
    try {
      // Try macOS first
      await $`osascript -e 'display notification "${message}" with title "${title}"'`.quiet()
    } catch {
      try {
        // Try Linux
        await $`notify-send "${title}" "${message}"`.quiet()
      } catch {
        // Skip on Windows or if neither available
      }
    }
  }
  
  return {
    "session.idle": async (input) => {
      const duration = Math.floor(input.session.duration / 1000)
      await sendNotification(
        "OpenCode",
        `Session completed in ${duration}s`
      )
    },
    
    "session.error": async (input) => {
      await sendNotification(
        "OpenCode Error",
        "Session encountered an error"
      )
    }
  }
}
```

---

## Phase 3: Cleanup - Remove Claude References

### 3.1 Scope of Cleanup

**Files to Update:** 82 files containing "Claude" references

**Directories to Clean:**
- `.opencode/agents/` - Agent definitions
- `.opencode/commands/` - Slash commands
- `.opencode/skills/` - Skill documentation
- `.opencode/docs/` - Documentation files
- `AGENTS.md` - Main documentation
- `README.md` - Project readme
- `docs/` - Migration and setup docs

**Replacement Strategy:**
```
OpenCode  → OpenCode
opencode  → opencode
.opencode/     → .opencode/
OPENCODE_*     → OPENCODE_* (environment variables)
```

**Files to Review Manually:**
- Git history references (keep as-is for attribution)
- External links to OpenCode docs (mark as "reference only")
- Comparisons between systems (update to clarify OpenCode focus)

### 3.2 Automated Cleanup Script

**File:** `.opencode/scripts/cleanup-claude-refs.sh`

```bash
#!/bin/bash
# Cleanup script to remove OpenCode references

set -e

echo "🧹 Cleaning up OpenCode references..."

# Define replacements
declare -A REPLACEMENTS=(
  ["OpenCode"]="OpenCode"
  ["opencode"]="opencode"
  [".opencode/"]="\.opencode/"
  ["OPENCODE_PROJECT_DIR"]="OPENCODE_PROJECT_DIR"
  ["OPENCODE_SESSION_ID"]="OPENCODE_SESSION_ID"
)

# Directories to process
DIRS=(".opencode" "docs" "AGENTS.md" "README.md")

# Perform replacements
for dir in "${DIRS[@]}"; do
  if [[ -f "$dir" ]]; then
    # Single file
    for old in "${!REPLACEMENTS[@]}"; do
      new="${REPLACEMENTS[$old]}"
      sed -i "s/$old/$new/g" "$dir"
    done
  elif [[ -d "$dir" ]]; then
    # Directory
    find "$dir" -type f \( -name "*.md" -o -name "*.ts" -o -name "*.json" \) | while read file; do
      for old in "${!REPLACEMENTS[@]}"; do
        new="${REPLACEMENTS[$old]}"
        sed -i "s/$old/$new/g" "$file"
      done
    done
  fi
done

echo "✅ Cleanup complete!"
echo "📊 Summary:"
grep -r "Claude" .opencode docs AGENTS.md README.md --include="*.md" --include="*.ts" --include="*.json" 2>/dev/null | wc -l | xargs echo "Remaining references:"
```

**Execution:**
```bash
chmod +x .opencode/scripts/cleanup-claude-refs.sh
./.opencode/scripts/cleanup-claude-refs.sh
```

### 3.3 Manual Review Checklist

After automated cleanup, manually review:

- [ ] `AGENTS.md` - Verify all hook examples use OpenCode paths
- [ ] `README.md` - Update installation and usage sections
- [ ] `.opencode/docs/` - Remove Claude-specific documentation
- [ ] `.opencode/agents/` - Verify agent descriptions are accurate
- [ ] `.opencode/skills/` - Update skill documentation
- [ ] `docs/migration-guide.md` - Remove or archive
- [ ] Environment variable examples - Use `OPENCODE_*` prefix

---

## Phase 4: Testing & Validation

### 4.1 Plugin Testing Strategy

**Unit Tests (Optional):**
```typescript
// .opencode/plugins/__tests__/security.test.ts
import { SecurityPlugin } from "../security"

describe("SecurityPlugin", () => {
  it("blocks rm -rf commands", async () => {
    // Test dangerous command detection
  })
  
  it("blocks .env file access", async () => {
    // Test sensitive file protection
  })
})
```

**Integration Tests:**
1. **Security Plugin**
   - Try to read `.env` → should block
   - Try to run `rm -rf /tmp/test` → should block
   - Try to read `.env.sample` → should allow

2. **Logging Plugin**
   - Run session → check `logs/session.jsonl` exists
   - Execute tool → check `logs/tool_use.jsonl` has entry

3. **Markdown Validator**
   - Create invalid agent file → check validation warning
   - Create valid skill file → no warnings

4. **Post-Stop Detector**
   - Stop session → wait 10s → create file → check detection

### 4.2 Manual Testing Checklist

- [ ] Install plugins: `cd .opencode && bun install`
- [ ] Start OpenCode session: `opencode`
- [ ] Verify security blocks: Try `Read .env`
- [ ] Verify logging: Check `.opencode/logs/*.jsonl` files
- [ ] Verify notifications: Complete session, check system notification
- [ ] Verify markdown validation: Edit agent file with invalid structure
- [ ] Verify cleanup: Search for "Claude" in codebase (should be 0)

### 4.3 Performance Validation

**Metrics to Monitor:**
- Plugin load time: < 500ms
- Event handler latency: < 50ms per event
- Log write performance: < 10ms per entry
- Memory usage: < 50MB for all plugins

**Profiling:**
```typescript
// Add timing to critical paths
const start = performance.now()
await logEvent("tool_use", data)
const duration = performance.now() - start
if (duration > 10) {
  console.warn(`Slow log write: ${duration}ms`)
}
```

---

## Phase 5: Documentation & Finalization

### 5.1 Update AGENTS.md

**Section to Update:**
```markdown
## Hooks Infrastructure

OpenCode supports lifecycle plugins that execute at key moments during AI assistant sessions. 
Plugins enable custom automation, logging, notifications, and workflow integration.

### Available Plugins

This project includes 6 core plugins:

1. **Security** - Blocks dangerous commands and protects sensitive files
2. **Logging** - Comprehensive event tracking in JSONL format
3. **Markdown Validator** - Enforces structure for agents, skills, docs
4. **Post-Stop Detector** - Detects orphaned files after session completion
5. **Session Context** - Tracks git status and session analytics
6. **Notifications** - System alerts for session events

### Plugin Architecture

Plugins are TypeScript modules in `.opencode/plugins/` that export a plugin function:

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async (ctx) => {
  return {
    "event.name": async (input, output) => {
      // Event handler logic
    }
  }
}
```

### Available Events

OpenCode provides 30+ event types:
- Tool events: `tool.execute.before`, `tool.execute.after`
- Session events: `session.created`, `session.idle`, `session.error`
- File events: `file.edited`, `file.watcher.updated`
- Permission events: `permission.asked`, `permission.replied`
- And more...

See [OpenCode Plugin Docs](https://opencode.ai/docs/plugins) for complete reference.
```

### 5.2 Create Plugin README

**File:** `.opencode/plugins/README.md`

```markdown
# OpenCode Plugins

This directory contains TypeScript plugins that extend OpenCode's functionality through event-driven hooks.

## Available Plugins

### 1. Security (`security.ts`)
Blocks dangerous operations and protects sensitive files.

**Features:**
- Blocks `rm -rf` commands in all variations
- Prevents `.env` file access (allows `.env.sample`)
- Protects system files and credential files
- Logs all blocked operations

**Events:** `tool.execute.before`

### 2. Logging (`logging.ts`)
Comprehensive event tracking in structured JSONL format.

**Features:**
- Logs all tool executions (before/after)
- Tracks session lifecycle events
- Records file modifications
- Monitors conversation flow

**Events:** `tool.execute.before`, `tool.execute.after`, `session.*`, `file.edited`

### 3. Markdown Validator (`markdown-validator.ts`)
Enforces structure and quality for markdown files.

**Features:**
- Validates agent frontmatter and structure
- Validates skill documentation format
- Checks command file structure
- Logs warnings for violations

**Events:** `file.edited`

### 4. Post-Stop Detector (`post-stop-detector.ts`)
Detects files created after session completion.

**Features:**
- Captures filesystem snapshot on session stop
- Monitors for 30 seconds post-stop
- Detects orphaned files
- Generates cleanup reports

**Events:** `session.idle`

### 5. Session Context (`session-context.ts`)
Tracks session lifecycle with git status and analytics.

**Features:**
- Captures git branch and uncommitted changes
- Tracks tools used and files modified
- Calculates session duration
- Stores session history

**Events:** `session.created`, `session.idle`, `tool.execute.after`, `file.edited`

### 6. Notifications (`notifications.ts`)
System notifications for session events.

**Features:**
- Session completion alerts
- Error notifications
- Cross-platform support (macOS, Linux)

**Events:** `session.idle`, `session.error`

## Development

### Installing Dependencies

```bash
cd .opencode
bun install
```

### TypeScript Compilation

```bash
bun run tsc
```

### Testing Plugins

Start an OpenCode session and monitor logs:

```bash
opencode
# In another terminal:
tail -f .opencode/logs/*.jsonl
```

## Configuration

Plugins are auto-loaded from this directory. To disable a plugin, rename it with `.disabled` extension:

```bash
mv security.ts security.ts.disabled
```

## Resources

- [OpenCode Plugin Docs](https://opencode.ai/docs/plugins)
- [Plugin API Reference](https://opencode.ai/docs/sdk)
- [Event Types](https://opencode.ai/docs/plugins#events)
```

### 5.3 Update Root README.md

**Section to Add:**

```markdown
## 🔌 Plugin System

This template includes 6 TypeScript plugins that extend OpenCode with event-driven automation:

- **Security** - Blocks dangerous commands (rm -rf, .env access)
- **Logging** - Comprehensive JSONL event tracking
- **Markdown Validator** - Enforces structure for agents/skills
- **Post-Stop Detector** - Detects orphaned files
- **Session Context** - Git status and analytics tracking
- **Notifications** - System alerts for session events

Plugins are auto-loaded from `.opencode/plugins/`. See [Plugin Documentation](.opencode/plugins/README.md) for details.
```

---

## Implementation Timeline

### Week 1: Foundation (Phase 1 + 2.1-2.2)
- Day 1: Create `opencode.json`, `.opencode/package.json`, `tsconfig.json`
- Day 2: Implement Security Plugin
- Day 3: Implement Logging Plugin
- Day 4: Test security and logging
- Day 5: Buffer for issues

### Week 2: Validation & Detection (Phase 2.3-2.4)
- Day 1-2: Implement Markdown Validator Plugin
- Day 3: Implement Post-Stop Detector Plugin
- Day 4: Test validation and detection
- Day 5: Buffer for issues

### Week 3: Context & Notifications (Phase 2.5-2.6 + 3)
- Day 1: Implement Session Context Plugin
- Day 2: Implement Notifications Plugin
- Day 3-4: Claude Cleanup (automated + manual)
- Day 5: Integration testing

### Week 4: Documentation & Finalization (Phase 4-5)
- Day 1-2: Write comprehensive tests
- Day 3: Update all documentation
- Day 4: Performance validation
- Day 5: Final review and deployment

---

## Success Criteria

### Functional Requirements
- ✅ Security plugin blocks all dangerous commands and sensitive files
- ✅ Logging plugin captures all events in structured JSONL
- ✅ Markdown validator enforces structure for all file types
- ✅ Post-stop detector identifies orphaned files
- ✅ Session context tracks git status and analytics
- ✅ Notifications work on macOS and Linux
- ✅ Zero OpenCode references remain in codebase

### Performance Requirements
- ✅ Plugin load time < 500ms
- ✅ Event handler latency < 50ms
- ✅ Log write operations < 10ms
- ✅ Memory usage < 50MB total

### Quality Requirements
- ✅ Full TypeScript type coverage
- ✅ No runtime errors in normal usage
- ✅ Graceful degradation (missing tools, permissions)
- ✅ Comprehensive documentation
- ✅ Clear error messages

---

## Risk Assessment

### High Risk
**Risk:** Plugin system incompatibility with OpenCode version
**Mitigation:** Test with latest OpenCode version, check ecosystem plugins for patterns

### Medium Risk
**Risk:** Performance degradation from excessive logging
**Mitigation:** Implement log rotation, truncate large outputs, async writes

**Risk:** Markdown validation false positives
**Mitigation:** Extensive test cases, configurable strictness, warn-only mode

### Low Risk
**Risk:** Cross-platform notification failures
**Mitigation:** Graceful fallback, silent failure for missing tools

**Risk:** Post-stop detection race conditions
**Mitigation:** Grace period (30s), debouncing, snapshot comparison

---

## Dependencies

### Required
- **OpenCode** - Latest version (>= 1.0.0)
- **Bun** - JavaScript runtime (for plugin system)
- **@opencode-ai/plugin** - Plugin SDK
- **TypeScript** - Type system
- **Zod** - Schema validation

### Optional
- **gray-matter** - Frontmatter parsing (for markdown validator)
- **remark** - Markdown AST parsing (for markdown validator)
- **notify-send** - Linux notifications
- **osascript** - macOS notifications

---

## Migration Path (Existing Hooks to Plugins)

If any Python hooks currently exist and need migration:

### Wrapper Plugin Approach

```typescript
// .opencode/plugins/python-hooks-wrapper.ts
import type { Plugin } from "@opencode-ai/plugin"

export const PythonHooksWrapper: Plugin = async ({ directory, $ }) => {
  return {
    "tool.execute.before": async (input, output) => {
      const hookPath = `${directory}/.opencode/hooks/pre_tool_use.py`
      const payload = JSON.stringify({
        tool_name: input.tool,
        tool_input: output.args
      })
      
      try {
        const result = await $`echo ${payload} | uv run ${hookPath}`.quiet()
        if (result.exitCode !== 0) {
          throw new Error("Python hook blocked execution")
        }
      } catch (error) {
        // Hook failed, log but don't block
        console.warn(`Python hook error: ${error}`)
      }
    }
  }
}
```

This allows gradual migration while maintaining existing Python hooks.

---

## Future Enhancements

### Phase 2 (Post-MVP)
1. **Custom Tool Plugin** - Add domain-specific tools
2. **Code Quality Plugin** - Integrate ESLint, Prettier, Ruff
3. **Git Flow Plugin** - Automated branching and PR creation
4. **Telemetry Plugin** - Usage analytics and metrics
5. **Backup Plugin** - Automated session backups

### Plugin Marketplace
- Publish plugins to npm for reuse
- Contribute to OpenCode ecosystem
- Share with community

---

## Questions & Decisions

### Resolved
1. ✅ **Approach:** OpenCode native plugins (TypeScript) instead of Python hooks
2. ✅ **Features:** Security, Logging, Markdown Validation, Post-Stop Detection, Session Context, Notifications
3. ✅ **Language:** TypeScript for type safety
4. ✅ **Log Format:** JSONL (one JSON per line)
5. ✅ **Python Validator:** Not needed (no Python code in project)
6. ✅ **Cleanup:** Remove all Claude references

### Pending
1. **Markdown Validation Mode:** Warn-only or strict (block on errors)?
   - **Recommendation:** Warn-only by default, strict mode via config flag

2. **Log Retention:** How long to keep log files?
   - **Recommendation:** Rotate logs weekly, keep last 4 weeks

3. **Notification Frequency:** Notify on every session or configurable?
   - **Recommendation:** Configurable in `opencode.json`

---

## Appendix: Event Reference

### Tool Events
- `tool.execute.before` - Before tool execution (can block)
- `tool.execute.after` - After successful execution

### Session Events
- `session.created` - New session started
- `session.idle` - Session completed (stopped)
- `session.error` - Session encountered error
- `session.compacted` - Context window compacted
- `session.updated` - Session state changed

### File Events
- `file.edited` - File was modified
- `file.watcher.updated` - Watched file changed

### Permission Events
- `permission.asked` - Permission request made
- `permission.replied` - Permission granted/denied

### Message Events
- `message.updated` - New message in conversation
- `message.part.updated` - Streaming message update

### Command Events
- `command.executed` - Slash command run

### TUI Events
- `tui.prompt.append` - Text appended to prompt
- `tui.toast.show` - Toast notification shown

---

## References

- [OpenCode Plugin Documentation](https://opencode.ai/docs/plugins)
- [OpenCode SDK Reference](https://opencode.ai/docs/sdk)
- [Bun Shell API](https://bun.sh/docs/runtime/shell)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Zod Documentation](https://zod.dev/)
- [JSONL Format](https://jsonlines.org/)

---

**End of Plan**

*Last Updated: 2026-02-09*  
*Status: Ready for Implementation*  
*Estimated Effort: 4 weeks (1 developer)*
