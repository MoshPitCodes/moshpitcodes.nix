import type { Plugin } from "@opencode-ai/plugin"

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
    tokensUsed: number
  }
  tdTask?: string
}

const sessions = new Map<string, SessionContext>()
let currentSessionID: string | null = null

/**
 * Notifications Plugin
 *
 * Tracks session statistics and sends TUI toast notifications for session lifecycle events:
 * - Session created (TUI toast)
 * - Session idle/completed (TUI toast with session stats)
 * - Session errors (TUI toast)
 *
 * Session tracking:
 * - Git branch and uncommitted changes
 * - Tool usage count and unique tools
 * - Files modified count
 * - Token usage estimation
 * - Session duration
 * - TD task context (if available)
 *
 * Notification layer:
 * - TUI toast (always available when OpenCode TUI is running)
 */
export const NotificationsPlugin: Plugin = async ({ $, client, directory }) => {
  /**
   * Get git information for current session
   */
  const getGitInfo = async () => {
    try {
      const branchResult =
        await $`git -C ${directory} rev-parse --abbrev-ref HEAD`.quiet()
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

  /**
   * Get current TD task (best-effort)
   */
  const getTdTask = async (): Promise<string | undefined> => {
    try {
      const tdResult = await $`td status --json`.nothrow().quiet()
      if (tdResult.exitCode === 0) {
        const tdStatus = tdResult.json()
        return tdStatus?.focus?.key ?? undefined
      }
    } catch {
      // TD not installed or not initialized
    }
    return undefined
  }

  /**
   * Estimate token count for a text string (rough heuristic: 4 chars per token)
   */
  const estimateTokens = (text: string): number => {
    return Math.ceil(text.length / 4)
  }

  /**
   * Format session duration as human-readable string.
   */
  const formatDuration = (seconds: number): string => {
    if (seconds < 60) return `${seconds}s`
    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    if (minutes < 60) return `${minutes}m ${secs}s`
    const hours = Math.floor(minutes / 60)
    const mins = minutes % 60
    return `${hours}h ${mins}m ${secs}s`
  }

  /**
   * Send a TUI toast notification (always works when OpenCode TUI is running).
   */
  const sendToast = async (
    title: string,
    message: string,
    variant: "info" | "success" | "warning" | "error",
    duration?: number,
  ) => {
    try {
      await client.tui.showToast({
        body: {
          title,
          message,
          variant,
          duration: duration ?? (variant === "error" ? 8000 : 4000),
        },
      })
    } catch {
      // TUI not available (e.g. headless SDK usage) - skip silently
    }
  }

  /**
   * Extract a human-readable error summary from session error properties.
   */
  const extractErrorSummary = (
    error?: { type?: string; message?: string; code?: string | number },
  ): string => {
    if (!error) return "Unknown error"
    const parts: string[] = []
    if (error.type) parts.push(error.type)
    if (error.message) parts.push(error.message.substring(0, 100))
    if (error.code) parts.push(`(code: ${error.code})`)
    return parts.length > 0 ? parts.join(" - ") : "Unknown error"
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

    "chat.message": async (input) => {
      const context = sessions.get(input.sessionID)
      if (!context) return

      // Track token usage from message content
      const msg = (input as any).message
      if (msg?.content) {
        let messageText = ""
        if (typeof msg.content === "string") {
          messageText = msg.content
        } else if (Array.isArray(msg.content)) {
          // Handle content blocks
          for (const block of msg.content) {
            if (typeof block === "string") {
              messageText += block
            } else if (block && typeof block === "object" && "text" in block) {
              messageText += String(block.text)
            }
          }
        }
        const tokens = estimateTokens(messageText)
        context.stats.tokensUsed += tokens
      }
    },

    event: async ({ event }) => {
      if (event.type === "session.created") {
        const sessionID = event.properties.info.id
        const title = event.properties.info.title || "New Session"
        
        // Clean up previous session if exists (session transitions)
        if (currentSessionID && currentSessionID !== sessionID) {
          sessions.delete(currentSessionID)
        }
        
        // Initialize session context
        const gitInfo = await getGitInfo()
        const context: SessionContext = {
          sessionID,
          startTime: new Date().toISOString(),
          git: gitInfo,
          stats: { toolsUsed: 0, filesModified: 0, uniqueTools: [], tokensUsed: 0 },
        }
        sessions.set(sessionID, context)
        currentSessionID = sessionID // Track as current active session

        await sendToast("Session Started", title, "info", 3000)
      }

      if (event.type === "file.edited") {
        // Increment file count only for the current active session
        // Note: file.edited event doesn't include sessionID, so we track the most recent session
        if (currentSessionID) {
          const context = sessions.get(currentSessionID)
          if (context) {
            context.stats.filesModified++
          }
        }
      }

      if (event.type === "session.idle") {
        const sessionID = event.properties.sessionID
        const shortID = sessionID.substring(0, 8)

        // Get session context from memory
        const context = sessions.get(sessionID)

        if (context) {
          // Calculate session duration
          const endTime = new Date()
          const startTime = new Date(context.startTime)
          const duration = Math.round(
            (endTime.getTime() - startTime.getTime()) / 1000,
          )
          context.duration = duration

          // Get TD task if available
          context.tdTask = await getTdTask()
          // Build rich notification message with session stats
          const parts: string[] = []
          parts.push(`⏱️  ${formatDuration(context.duration)}`)
          parts.push(`🔧 ${context.stats.toolsUsed} tools`)
          parts.push(`📝 ${context.stats.filesModified} files`)
          if (context.stats.tokensUsed) {
            const tokensK = (context.stats.tokensUsed / 1000).toFixed(1)
            parts.push(`🎯 ${tokensK}k tokens`)
          }
          if (context.tdTask) {
            parts.push(`📋 ${context.tdTask}`)
          }

          const toastMessage = parts.join(" • ")
          
          await sendToast(`Session Idle`, toastMessage, "info", 6000)

          // DO NOT clean up session on idle - session.idle fires multiple times during session lifetime
          // Session context should persist until session.error or when explicitly ended
        } else {
          // Fallback if session context not available
          await sendToast(
            "Session Idle",
            `Session ${shortID} is idle`,
            "info",
          )
        }
      }

      if (event.type === "session.error") {
        const sessionID = event.properties.sessionID ?? "unknown"
        const shortID = sessionID.substring(0, 8)
        const errorSummary = extractErrorSummary(
          event.properties.error as
            | { type?: string; message?: string; code?: string | number }
            | undefined,
        )

        await sendToast(
          "Session Error",
          `Session ${shortID}: ${errorSummary}`,
          "error",
        )

        // Clean up session from memory on error (session is terminated)
        if (sessionID !== "unknown") {
          sessions.delete(sessionID)
          if (currentSessionID === sessionID) {
            currentSessionID = null
          }
        }
      }
    },
  }
}

export default NotificationsPlugin
