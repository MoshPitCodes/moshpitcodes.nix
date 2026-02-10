import { tool } from "@opencode-ai/plugin"

type TDAction =
  | "status"
  | "start"
  | "focus"
  | "link"
  | "log"
  | "review"
  | "handoff"
  | "whoami"

async function runTD(args: string[]) {
  const cmd = Bun.$`td ${args}`.nothrow().quiet()
  const result = await cmd
  return {
    exitCode: result.exitCode,
    stdout: result.stdout.toString().trim(),
    stderr: result.stderr.toString().trim(),
  }
}

export default tool({
  description:
    "Operate TD task workflow from the agent (status/start/focus/link/log/review/handoff/whoami)",
  args: {
    action: tool.schema
      .enum([
        "status",
        "start",
        "focus",
        "link",
        "log",
        "review",
        "handoff",
        "whoami",
      ])
      .describe("TD action to execute"),
    task: tool.schema
      .string()
      .optional()
      .describe("Task key/id for start/focus/review/link"),
    files: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Files to link for the link action"),
    message: tool.schema
      .string()
      .optional()
      .describe("Log message for the log action"),
  },
  async execute(input, context) {
    const action = input.action as TDAction

    const version = await runTD(["version"])
    if (version.exitCode !== 0) {
      return "TD is not available in this environment. Install from https://github.com/marcus/td"
    }

    switch (action) {
      case "status": {
        const result = await runTD(["status", "--json"])
        if (result.exitCode !== 0) return result.stderr || "Failed to read TD status"
        return result.stdout
      }

      case "whoami": {
        const result = await runTD(["whoami", "--json"])
        if (result.exitCode !== 0) return result.stderr || "Failed to read TD session identity"
        return result.stdout
      }

      case "start": {
        if (!input.task) return "Missing required argument: task"
        const result = await runTD(["start", input.task])
        return result.exitCode === 0 ? result.stdout || `Started ${input.task}` : result.stderr
      }

      case "focus": {
        if (!input.task) return "Missing required argument: task"
        const result = await runTD(["focus", input.task])
        return result.exitCode === 0 ? result.stdout || `Focused ${input.task}` : result.stderr
      }

      case "link": {
        if (!input.task) return "Missing required argument: task"
        const files = (input.files ?? []).filter(Boolean)
        if (files.length === 0) return "Missing required argument: files"

        const relativeFiles = files.map((file) => {
          if (file.startsWith("/")) {
            if (file.startsWith(context.worktree)) {
              return file.slice(context.worktree.length + 1)
            }
            return file
          }
          return file
        })

        const result = await runTD(["link", input.task, ...relativeFiles])
        return result.exitCode === 0 ? result.stdout || "Linked files" : result.stderr
      }

      case "log": {
        if (!input.message) return "Missing required argument: message"
        const result = await runTD(["log", input.message])
        return result.exitCode === 0 ? result.stdout || "Log entry added" : result.stderr
      }

      case "review": {
        if (!input.task) return "Missing required argument: task"
        const result = await runTD(["review", input.task])
        return result.exitCode === 0 ? result.stdout || `Submitted ${input.task} for review` : result.stderr
      }

      case "handoff": {
        const result = await runTD(["handoff"])
        return result.exitCode === 0 ? result.stdout || "Handoff captured" : result.stderr
      }

      default:
        return `Unsupported action: ${action}`
    }
  },
})
