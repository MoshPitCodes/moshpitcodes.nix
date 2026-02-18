import type { Plugin } from "@opencode-ai/plugin"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"

/**
 * Logging Plugin
 *
 * Comprehensive event tracking in structured JSONL format:
 * - Tool execution (before/after)
 * - Session lifecycle events (created, idle, error, compacted)
 * - File modifications
 * - Message flow
 * - Permission requests
 * - Command execution
 */
export const LoggingPlugin: Plugin = async ({ directory }) => {
  const logDir = join(directory, ".opencode", "logs")
  await mkdir(logDir, { recursive: true })

  const logEvent = async (file: string, data: Record<string, unknown>) => {
    try {
      const logPath = join(logDir, `${file}.jsonl`)
      const entry = { timestamp: new Date().toISOString(), ...data }
      await writeFile(logPath, JSON.stringify(entry) + "\n", { flag: "a" })
    } catch {
      // Fail silently - don't disrupt operations due to logging errors
    }
  }

  const truncate = (value: unknown, maxLength: number = 500): unknown => {
    if (typeof value === "string") {
      return value.length > maxLength
        ? value.substring(0, maxLength) +
            `... (truncated ${value.length - maxLength} chars)`
        : value
    }
    if (typeof value === "object" && value !== null) {
      const str = JSON.stringify(value)
      if (str.length > maxLength) {
        return str.substring(0, maxLength) + "... (truncated)"
      }
      return value
    }
    return value
  }

  return {
    "tool.execute.before": async (input, output) => {
      await logEvent("tool_use", {
        event: "before",
        tool: input.tool,
        sessionID: input.sessionID,
        args: truncate(output.args, 1000),
      })
    },

    "tool.execute.after": async (input, output) => {
      await logEvent("tool_use", {
        event: "after",
        tool: input.tool,
        sessionID: input.sessionID,
        title: output.title,
        output: truncate(output.output, 500),
      })
    },

     event: async ({ event }) => {
       const type = (event as any).type as string
       const props = (event as any).properties ?? {}
       switch (type) {
         case "session.created":
           await logEvent("session", {
             event: "created",
             sessionID: props.info?.id,
             title: props.info?.title,
           })
           break

         case "session.idle":
           await logEvent("session", {
             event: "idle",
             sessionID: props.sessionID,
           })
           break

         case "session.error":
           await logEvent("session", {
             event: "error",
             sessionID: props.sessionID,
             error: truncate(props.error, 1000),
           })
           break

         case "session.compacted":
           await logEvent("session", {
             event: "compacted",
             sessionID: props.sessionID,
           })
           break

         case "file.edited":
           await logEvent("files", {
             event: "edited",
             file: props.file,
           })
           break

         case "file.watcher.updated":
           await logEvent("files", {
             event: "watcher_updated",
             file: props.file,
             action: props.event,
           })
           break

         case "message.updated":
           await logEvent("messages", {
             event: "message_updated",
             messageID: props.info?.id,
             role: props.info?.role,
           })
           break

         case "message.part.updated":
           await logEvent("messages", {
             event: "part_updated",
             partType: props.part?.type,
           })
           break

        // OpenCode docs: permission.asked / permission.replied.
        // Older versions may use permission.updated.
         case "permission.asked":
         case "permission.updated":
           await logEvent("permissions", {
             event: "asked",
             sessionID: props.sessionID,
             tool: props.title,
           })
           break

         case "permission.replied":
           await logEvent("permissions", {
             event: "replied",
             sessionID: props.sessionID,
             permissionID: props.permissionID,
             response: props.response,
           })
           break

         case "command.executed":
           await logEvent("commands", {
             event: "executed",
             name: props.name,
             sessionID: props.sessionID,
             arguments: props.arguments,
           })
           break
       }
     },
  }
}

export default LoggingPlugin
