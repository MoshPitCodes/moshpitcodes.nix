import type { Plugin } from "@opencode-ai/plugin"
import { mkdir, appendFile, watch } from "fs/promises"
import { existsSync } from "fs"
import { join, extname } from "path"

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface TDFocus {
  id: string
  key: string
  title: string
}

interface TDSession {
  id: string
  name: string
}

interface TDInProgressItem {
  id: string
  key: string
  title: string
}

interface TDInReviewItem {
  id: string
  key: string
  title: string
  sessionID?: string
}

interface TDStatus {
  focus?: TDFocus
  session?: TDSession
  inProgress: TDInProgressItem[]
  inReview: TDInReviewItem[]
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const TRACKED_EXTENSIONS = new Set([
  ".ts",
  ".tsx",
  ".js",
  ".jsx",
  ".go",
  ".py",
  ".java",
  ".kt",
  ".rs",
  ".c",
  ".cpp",
  ".h",
  ".hpp",
  ".rb",
  ".php",
  ".swift",
  ".vue",
  ".svelte",
  ".md",
  ".sql",
  ".graphql",
  ".proto",
  ".css",
  ".scss",
  ".html",
  ".yaml",
  ".yml",
  ".toml",
  ".json",
  ".sh",
])

const EXCLUDED_DIR_SEGMENTS = new Set([
  "node_modules",
  "dist",
  "build",
  ".git",
  "target",
  "vendor",
  ".next",
  ".nuxt",
  ".svelte-kit",
  "out",
  "coverage",
  "__pycache__",
  ".opencode/logs",
  ".opencode/data",
])

/** Tools that modify files on disk. */
const WRITE_TOOLS = new Set(["write", "edit"])

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Check whether a file path should be tracked by TD.
 *
 * Tracked means the file extension is in `TRACKED_EXTENSIONS` and no segment
 * of the path matches `EXCLUDED_DIR_SEGMENTS`.
 */
function shouldTrackFile(filePath: string): boolean {
  const ext = extname(filePath)
  if (!TRACKED_EXTENSIONS.has(ext)) return false

  for (const segment of EXCLUDED_DIR_SEGMENTS) {
    if (filePath.includes(`/${segment}/`) || filePath.includes(`/${segment}`)) {
      return false
    }
  }

  return true
}

// ---------------------------------------------------------------------------
// Plugin
// ---------------------------------------------------------------------------

/**
 * TD Task Enforcement Plugin
 *
 * Integrates OpenCode with the TD task-management CLI
 * (https://github.com/marcus/td) to enforce task-driven development:
 *
 * 1. **Permission gate** – intercepts write/edit operations and asks the user
 *    for permission when there is no active (focused) TD task.
 * 2. **Auto-tracking** – automatically links modified files to the focused
 *    task and appends a change-log entry after every write/edit.
 * 3. **Review monitoring** – watches the TD database for tasks that enter the
 *    `in_review` state and sends a non-blocking toast notification
 *    suggesting to run a validator agent.
 * 4. **Session lifecycle** – initialises a TD session on start, reminds about
 *    `td handoff` on idle, and cleans up on error.
 * 5. **Graceful degradation** – if TD is not installed the plugin disables
 *    itself with a console warning instead of crashing.
 */
export const TDEnforcerPlugin: Plugin = async ({ directory, client, $ }) => {
  // -----------------------------------------------------------------------
  // Pre-flight: check that TD is installed
  // -----------------------------------------------------------------------

  let tdInstalled = false
  try {
    const r = await $`td version`.nothrow().quiet()
    tdInstalled = r.exitCode === 0
  } catch {
    tdInstalled = false
  }

  if (!tdInstalled) {
    console.warn(
      "TD not installed or not initialised. TD enforcer plugin disabled.",
    )
    console.warn("   Install: https://github.com/marcus/td")
    return {}
  }

  // -----------------------------------------------------------------------
  // Logging infrastructure
  // -----------------------------------------------------------------------

  const logDir = join(directory, ".opencode", "logs")
  await mkdir(logDir, { recursive: true })
  const logFile = join(logDir, "td_enforcer.jsonl")

  const logEvent = async (data: Record<string, unknown>): Promise<void> => {
    try {
      await client.app.log({
        body: {
          service: "td-enforcer",
          level: "info",
          message: String(data.event ?? "td_event"),
          extra: data,
        },
      })
      const entry = { timestamp: new Date().toISOString(), ...data }
      await appendFile(logFile, JSON.stringify(entry) + "\n")
    } catch {
      // Fail silently – never crash the agent.
    }
  }

  // -----------------------------------------------------------------------
  // TD CLI wrappers
  // -----------------------------------------------------------------------

  /**
   * Retrieve current TD status (focus, session, in-progress, in-review).
   *
   * Falls back to a simpler `td status --json` parse if `td usage --json`
   * is not available (varies by TD version).
   */
  const getTDStatus = async (): Promise<TDStatus | null> => {
    try {
      const result = await $`td status --json`.nothrow().quiet()
      if (result.exitCode !== 0) return null
      const raw = result.json()
      // Normalise: TD may use slightly different shapes across versions.
      return {
        focus: raw.focus ?? undefined,
        session: raw.session ?? undefined,
        inProgress: Array.isArray(raw.inProgress) ? raw.inProgress : [],
        inReview: Array.isArray(raw.inReview) ? raw.inReview : [],
      } satisfies TDStatus
    } catch {
      return null
    }
  }

  /**
   * Link one or more files to the focused task.
   */
  const linkFiles = async (
    taskKey: string,
    files: string[],
  ): Promise<void> => {
    if (files.length === 0) return
    try {
      for (const file of files) {
        await $`td link ${taskKey} ${file}`.nothrow().quiet()
      }
    } catch {
      // Non-fatal
    }
  }

  /**
   * Append a log entry to the focused task.
   */
  const logToTask = async (message: string): Promise<void> => {
    try {
      await $`td log ${message}`.nothrow().quiet()
    } catch {
      // Non-fatal
    }
  }

  // -----------------------------------------------------------------------
  // Review monitoring (database watcher)
  // -----------------------------------------------------------------------

  const lastSeenReviews = new Set<string>()
  let watchAbort: AbortController | null = null
  let debounceTimer: ReturnType<typeof setTimeout> | null = null

  const checkForReviewTasks = async (): Promise<void> => {
    try {
      const status = await getTDStatus()
      if (!status) return

      const currentSessionID = status.session?.id
      if (!currentSessionID) return

      for (const task of status.inReview) {
        // Skip already-notified tasks.
        if (lastSeenReviews.has(task.id)) continue

        // Session isolation: same session shouldn't review its own work.
        if (task.sessionID === currentSessionID) {
          await logEvent({
            event: "review_blocked_same_session",
            taskID: task.id,
            taskKey: task.key,
            sessionID: currentSessionID,
          })
          continue
        }

        // Notify via toast.
        try {
          await client.tui.showToast({
            body: {
              title: `Task ${task.key} ready for review`,
              message: `"${task.title}" is in review. Run a code-review or architecture-review agent to validate.`,
              variant: "info",
              duration: 10_000,
            },
          })
        } catch {
          // Fallback to console.
          console.log(
            `\nTask ${task.key} is ready for review – run a validator agent.\n`,
          )
        }

        await logEvent({
          event: "review_prompt_sent",
          taskID: task.id,
          taskKey: task.key,
        })

        lastSeenReviews.add(task.id)
      }

      // Prune tasks no longer in review.
      const currentIDs = new Set(status.inReview.map((t) => t.id))
      for (const id of lastSeenReviews) {
        if (!currentIDs.has(id)) lastSeenReviews.delete(id)
      }
    } catch (error) {
      await logEvent({
        event: "review_check_error",
        error: String(error),
      })
    }
  }

  /**
   * Start watching `.todos/issues.db` for changes.
   * Uses `fs/promises.watch()` with an AbortController for cleanup.
   */
  const startDatabaseWatch = async (): Promise<void> => {
    // TD uses "issues.db" as the database filename
    const dbPath = join(directory, ".todos", "issues.db")
    if (!existsSync(dbPath)) {
      console.warn("⚠️  TD database not found. Run 'td init' to initialize TD in this project.")
      console.warn(`   Expected: ${dbPath}`)
      await logEvent({ event: "db_not_found", path: dbPath })
      return
    }

    watchAbort = new AbortController()

    try {
      const watcher = watch(dbPath, { signal: watchAbort.signal })
      for await (const event of watcher) {
        if (event.eventType === "change") {
          if (debounceTimer) clearTimeout(debounceTimer)
          debounceTimer = setTimeout(() => {
            void checkForReviewTasks()
          }, 500)
        }
      }
    } catch (error: unknown) {
      // AbortError is expected when we stop the watcher.
      if (error instanceof Error && error.name === "AbortError") return
      await logEvent({ event: "db_watch_error", error: String(error) })
    }
  }

  const stopDatabaseWatch = (): void => {
    // Clear debounce timer to prevent memory leak
    if (debounceTimer) {
      clearTimeout(debounceTimer)
      debounceTimer = null
    }
    
    if (watchAbort) {
      watchAbort.abort()
      watchAbort = null
    }
  }

  // -----------------------------------------------------------------------
  // State
  // -----------------------------------------------------------------------

  /** Tracks files modified per session for summary purposes. */
  const sessionFiles = new Map<string, Set<string>>()

  // -----------------------------------------------------------------------
  // Kick off the database watcher in the background (non-blocking).
  // -----------------------------------------------------------------------
  void startDatabaseWatch()

  await logEvent({ event: "plugin_loaded" })

  // -----------------------------------------------------------------------
  // Hooks
  // -----------------------------------------------------------------------

  return {
    // -------------------------------------------------------------------
    // Permission gate
    // -------------------------------------------------------------------
    "permission.ask": async (input, output) => {
      // Only gate write/edit operations.
      if (!input.type || !["edit", "write"].includes(input.type)) return

      const status = await getTDStatus()
      const hasActiveTask =
        !!status?.focus || (status?.inProgress?.length ?? 0) > 0

      if (!hasActiveTask) {
        // The permission hook output supports allow/ask/deny.
        // We use `ask` to surface the permission dialog and prevent silent writes.
        output.status = "ask"
        
        console.warn("⚠️  TD Enforcer: No active task found!")
        console.warn("   Use TD Tool: TD(action: 'start', task: 'TASK-ID')")
        console.warn("   Or check status: TD(action: 'status')")

        await logEvent({
          event: "permission_blocked_no_task",
          permissionType: input.type,
          title: input.title,
        })
      }
    },

    // -------------------------------------------------------------------
    // Auto-tracking after writes
    // -------------------------------------------------------------------
    "tool.execute.after": async (input, output) => {
      if (!WRITE_TOOLS.has(input.tool)) return

      try {
        const status = await getTDStatus()
        if (!status?.focus) return

        const taskKey = status.focus.key

        // Extract file path from tool metadata.
        const filePath: string | undefined = output.metadata?.filePath
        if (!filePath || !shouldTrackFile(filePath)) return

        // Auto-link
        await linkFiles(taskKey, [filePath])

        // Auto-log (file-focused message)
        const shortPath = filePath.split("/").pop() ?? filePath
        const logMessage = `${input.tool}: ${shortPath}`
        await logToTask(logMessage)

        // Track for session summary.
        let files = sessionFiles.get(input.sessionID)
        if (!files) {
          files = new Set()
          sessionFiles.set(input.sessionID, files)
        }
        files.add(filePath)

        await logEvent({
          event: "auto_tracked",
          taskKey,
          file: filePath,
          tool: input.tool,
        })
      } catch (error) {
        await logEvent({
          event: "auto_track_error",
          error: String(error),
        })
      }
    },

    // -------------------------------------------------------------------
    // Session lifecycle & review monitoring
    // -------------------------------------------------------------------
    event: async ({ event }) => {
      switch (event.type) {
        case "session.created": {
          const sessionID = event.properties.info.id

          // Initialise TD session (best-effort).
          try {
            await $`td session --new`.nothrow().quiet()
          } catch {
            // Non-fatal
          }

          await logEvent({
            event: "session_initialized",
            sessionID,
          })
          break
        }

        case "session.idle": {
          const sessionID = event.properties.sessionID

          // Remind user about handoff if a task is in progress.
          const status = await getTDStatus()
          if (
            status?.focus ||
            (status?.inProgress && status.inProgress.length > 0)
          ) {
            console.log(
              "\nTip: Use TD(action: 'handoff', task: 'TASK-ID', ...) to capture working state before ending your session.\n",
            )
          }

          // Print tracked-files summary.
          const files = sessionFiles.get(sessionID)
          if (files && files.size > 0) {
            console.log(
              `TD tracked ${files.size} file(s) during this session.`,
            )
          }
          sessionFiles.delete(sessionID)

          // Stop database watcher.
          stopDatabaseWatch()

          await logEvent({ event: "session_idle", sessionID })
          break
        }

        case "session.error": {
          stopDatabaseWatch()

          const sessionID = event.properties.sessionID
          if (sessionID) {
            sessionFiles.delete(sessionID)
          }

          await logEvent({
            event: "session_error",
            sessionID: event.properties.sessionID,
          })
          break
        }
      }
    },
  }
}

export default TDEnforcerPlugin
