import type { Plugin } from "@opencode-ai/plugin"
import { writeFile, mkdir, appendFile } from "fs/promises"
import { join } from "path"

interface SessionContext {
  sessionID: string
  startTime: string
  endTime?: string
  duration?: number
  git: {
    branch: string
    uncommittedChanges: boolean
    changedFiles: number
  }
  stats: {
    toolsUsed: number
    filesModified: number
    uniqueTools: string[]
  }
}

const sessions = new Map<string, SessionContext>()

/**
 * Session Context Plugin
 *
 * Tracks session context and statistics:
 * - Git branch and uncommitted changes
 * - Tool usage count and unique tools
 * - Files modified count
 * - Session duration
 * - Prints session summary on completion
 */
export const SessionContextPlugin: Plugin = async ({
  directory,
  client,
  $,
}) => {
  const logDir = join(directory, ".opencode", "logs")
  const dataDir = join(directory, ".opencode", "data", "sessions")
  const logFile = join(logDir, "session_context.jsonl")

  await mkdir(logDir, { recursive: true })
  await mkdir(dataDir, { recursive: true })

  const logEvent = async (data: Record<string, unknown>) => {
    try {
      await client.app.log({
        body: {
          service: "session-context",
          level: "info",
          message: String(data.event ?? "session_context"),
          extra: data,
        },
      })
      const entry = { timestamp: new Date().toISOString(), ...data }
      await appendFile(logFile, JSON.stringify(entry) + "\n")
    } catch {
      // Fail silently
    }
  }

  const getGitInfo = async () => {
    try {
      const branchResult = await $`git -C ${directory} rev-parse --abbrev-ref HEAD`.quiet()
      const branch = branchResult.stdout.toString().trim()

      const statusResult = await $`git -C ${directory} status --porcelain`.quiet()
      const status = statusResult.stdout.toString()

      const lines = status
        .trim()
        .split("\n")
        .filter((l: string) => l.length > 0)
      return {
        branch,
        uncommittedChanges: lines.length > 0,
        changedFiles: lines.length,
      }
    } catch {
      return { branch: "unknown", uncommittedChanges: false, changedFiles: 0 }
    }
  }

  const formatDuration = (seconds: number): string => {
    if (seconds < 60) return `${seconds}s`
    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    if (minutes < 60) return `${minutes}m ${secs}s`
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return `${hours}h ${mins}m ${secs}s`
  }

  const finalizeSession = async (
    sessionID: string,
    type: "idle" | "error",
    errorInfo?: unknown,
  ) => {
    const context = sessions.get(sessionID)
    if (!context) return

    const endTime = new Date()
    const startTime = new Date(context.startTime)
    const duration = Math.round(
      (endTime.getTime() - startTime.getTime()) / 1000,
    )

    context.endTime = endTime.toISOString()
    context.duration = duration

    const sessionFile = join(dataDir, `${sessionID}.json`)
    await writeFile(sessionFile, JSON.stringify(context, null, 2))

    await logEvent({
      event: type === "idle" ? "session_ended" : "session_error",
      sessionID,
      duration,
      ...(errorInfo ? { error: errorInfo } : {}),
      stats: context.stats,
      git: context.git,
    })

    sessions.delete(sessionID)

    if (type === "idle") {
      // Attempt to fetch current TD task (best-effort).
      let tdTask: string | null = null
      try {
        const tdResult = await $`td status --json`.nothrow().quiet()
        if (tdResult.exitCode === 0) {
          const tdStatus = tdResult.json()
          tdTask = tdStatus?.focus?.key ?? null
        }
      } catch {
        // TD not installed or not initialised – skip.
      }

      console.log("\n📊 Session Summary:")
      console.log(`   Duration: ${formatDuration(duration)}`)
      console.log(`   Tools used: ${context.stats.toolsUsed}`)
      console.log(`   Files modified: ${context.stats.filesModified}`)
      console.log(`   Git branch: ${context.git.branch}`)
      if (tdTask) {
        console.log(`   TD task: ${tdTask}`)
      }
      if (context.stats.uniqueTools.length > 0) {
        console.log(`   Tools: ${context.stats.uniqueTools.join(", ")}`)
      }
    }
  }

  return {
    "tool.execute.after": async (input) => {
      const context = sessions.get(input.sessionID)
      if (!context) return

      context.stats.toolsUsed++
      if (!context.stats.uniqueTools.includes(input.tool)) {
        context.stats.uniqueTools.push(input.tool)
      }
    },

    event: async ({ event }) => {
      switch (event.type) {
        case "session.created": {
          const sessionID = event.properties.info.id
          const gitInfo = await getGitInfo()
          const context: SessionContext = {
            sessionID,
            startTime: new Date().toISOString(),
            git: gitInfo,
            stats: { toolsUsed: 0, filesModified: 0, uniqueTools: [] },
          }
          sessions.set(sessionID, context)
          await logEvent({
            event: "session_started",
            sessionID,
            git: gitInfo,
          })
          break
        }

        case "file.edited": {
          // Increment file count for all active sessions
          // (file.edited doesn't carry a sessionID, so track globally)
          for (const context of sessions.values()) {
            context.stats.filesModified++
          }
          break
        }

        case "session.idle": {
          await finalizeSession(event.properties.sessionID, "idle")
          break
        }

        case "session.error": {
          if (event.properties.sessionID) {
            await finalizeSession(
              event.properties.sessionID,
              "error",
              event.properties.error,
            )
          }
          break
        }
      }
    },
  }
}

export default SessionContextPlugin
