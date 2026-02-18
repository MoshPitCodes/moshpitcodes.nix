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
  | "usage"
  | "create"

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
    "Operate TD task workflow from the agent (status/start/focus/link/log/review/handoff/whoami/usage/create)",
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
        "usage",
        "create",
      ])
      .describe("TD action to execute"),
    task: tool.schema
      .string()
      .optional()
      .describe("Task key/id for start/focus/review/link/handoff, or task title for create"),
    files: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("Files to link for the link action"),
    message: tool.schema
      .string()
      .optional()
      .describe("Log message for the log action"),
    done: tool.schema
      .string()
      .optional()
      .describe("What was completed (for handoff action)"),
    remaining: tool.schema
      .string()
      .optional()
      .describe("What still needs to be done (for handoff action)"),
    decision: tool.schema
      .string()
      .optional()
      .describe("Key decisions made (for handoff action)"),
    uncertain: tool.schema
      .string()
      .optional()
      .describe("Areas of uncertainty or questions (for handoff action)"),
    newSession: tool.schema
      .boolean()
      .optional()
      .describe("Start a new session (for usage action)"),
    type: tool.schema
      .string()
      .optional()
      .describe("Issue type for create action: bug, feature, task, epic, chore"),
    priority: tool.schema
      .string()
      .optional()
      .describe("Priority for create action: P0, P1, P2, P3, P4"),
    labels: tool.schema
      .string()
      .optional()
      .describe("Comma-separated labels for create action"),
    description: tool.schema
      .string()
      .optional()
      .describe("Description text for create action"),
    parent: tool.schema
      .string()
      .optional()
      .describe("Parent issue ID for create action (for subtasks/epics)"),
    minor: tool.schema
      .boolean()
      .optional()
      .describe("Mark as minor task for create action (allows self-review)"),
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
        const args = ["handoff"]
        
        // If task is provided, add it
        if (input.task) {
          args.push(input.task)
        }
        
        // Add optional handoff flags
        if (input.done) {
          args.push("--done", input.done)
        }
        if (input.remaining) {
          args.push("--remaining", input.remaining)
        }
        if (input.decision) {
          args.push("--decision", input.decision)
        }
        if (input.uncertain) {
          args.push("--uncertain", input.uncertain)
        }
        
        const result = await runTD(args)
        return result.exitCode === 0 ? result.stdout || "Handoff captured" : result.stderr
      }

      case "usage": {
        const args = ["usage"]
        
        // Add --new-session flag if requested
        if (input.newSession) {
          args.push("--new-session")
        }
        
        const result = await runTD(args)
        return result.exitCode === 0 ? result.stdout : result.stderr
      }

      case "create": {
        if (!input.task) return "Missing required argument: task (title)"
        
        const args = ["create", input.task]
        
        // Add optional create flags
        if (input.type) {
          args.push("--type", input.type)
        }
        if (input.priority) {
          args.push("--priority", input.priority)
        }
        if (input.labels) {
          args.push("--labels", input.labels)
        }
        if (input.description) {
          args.push("--description", input.description)
        }
        if (input.parent) {
          args.push("--parent", input.parent)
        }
        if (input.minor) {
          args.push("--minor")
        }
        
        const result = await runTD(args)
        if (result.exitCode === 0) {
          // Extract task ID from output (format: "CREATED td-xxxxx")
          const match = result.stdout.match(/CREATED (td-[a-f0-9]+)/)
          if (match) {
            return `Created task: ${match[1]}\n${result.stdout}`
          }
          return result.stdout || "Task created"
        }
        return result.stderr
      }

      default:
        return `Unsupported action: ${action}`
    }
  },
})
