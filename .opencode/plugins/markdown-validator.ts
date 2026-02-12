import type { Plugin } from "@opencode-ai/plugin"
import { readFile, writeFile, mkdir } from "fs/promises"
import { join } from "path"
import matter from "gray-matter"

/**
 * Markdown Validator Plugin
 *
 * Enforces structure and quality for markdown files:
 * - Validates agent frontmatter and structure
 * - Validates skill documentation format
 * - Checks command file structure
 * - Logs warnings for violations to logs/validation.jsonl
 */
export const MarkdownValidatorPlugin: Plugin = async ({
  client,
  directory,
}) => {
  const logDir = join(directory, ".opencode", "logs")
  await mkdir(logDir, { recursive: true })
  const logFile = join(logDir, "validation.jsonl")

  const logValidation = async (data: {
    file: string
    valid: boolean
    errors?: string[]
    warnings?: string[]
  }) => {
    try {
      const level =
        data.errors && data.errors.length > 0
          ? "warn"
          : data.warnings && data.warnings.length > 0
            ? "info"
            : "debug"

      await client.app.log({
        body: {
          service: "markdown-validator",
          level,
          message: data.valid
            ? `Valid: ${data.file}`
            : `Issues in: ${data.file}`,
          extra: data,
        },
      })

      const entry = { timestamp: new Date().toISOString(), ...data }
      await writeFile(logFile, JSON.stringify(entry) + "\n", { flag: "a" })
    } catch {
      // Fail silently
    }
  }

  const validateAgentFile = (
    filePath: string,
    content: string,
  ): { valid: boolean; errors: string[]; warnings: string[] } => {
    const errors: string[] = []
    const warnings: string[] = []

    try {
      const { data: frontmatter } = matter(content)

      const requiredFields = ["name", "description", "type", "model"]
      for (const field of requiredFields) {
        if (!frontmatter[field]) {
          errors.push(`Missing required field: ${field}`)
        }
      }

      if (
        frontmatter.type &&
        !["primary", "subagent"].includes(frontmatter.type)
      ) {
        warnings.push(
          `Unexpected type value: "${frontmatter.type}" (expected "primary" or "subagent")`,
        )
      }

      if (frontmatter.name && /[A-Z]/.test(frontmatter.name)) {
        warnings.push(
          `Agent name should be kebab-case: "${frontmatter.name}"`,
        )
      }

      if (
        frontmatter.description &&
        typeof frontmatter.description === "string" &&
        frontmatter.description.length < 20
      ) {
        warnings.push("Description is very short (< 20 chars)")
      }
    } catch (err) {
      errors.push(
        `Invalid frontmatter: ${err instanceof Error ? err.message : String(err)}`,
      )
    }

    return { valid: errors.length === 0, errors, warnings }
  }

  const validateSkillFile = (
    filePath: string,
    content: string,
  ): { valid: boolean; errors: string[]; warnings: string[] } => {
    const errors: string[] = []
    const warnings: string[] = []

    try {
      const { data: frontmatter, content: body } = matter(content)

      if (!frontmatter.name) {
        errors.push("Missing required field: name")
      }
      if (!frontmatter.description) {
        errors.push("Missing required field: description")
      }

      if (!body || body.trim().length < 50) {
        warnings.push("Skill documentation is very short (< 50 chars)")
      }
    } catch (err) {
      errors.push(
        `Invalid frontmatter: ${err instanceof Error ? err.message : String(err)}`,
      )
    }

    return { valid: errors.length === 0, errors, warnings }
  }

  const validateCommandFile = (
    filePath: string,
    content: string,
  ): { valid: boolean; errors: string[]; warnings: string[] } => {
    const errors: string[] = []
    const warnings: string[] = []

    try {
      const { content: body } = matter(content)

      if (!body || body.trim().length < 10) {
        warnings.push("Command content is very short (< 10 chars)")
      }
    } catch (err) {
      errors.push(
        `Invalid frontmatter: ${err instanceof Error ? err.message : String(err)}`,
      )
    }

    return { valid: errors.length === 0, errors, warnings }
  }

  return {
    event: async ({ event }) => {
      if (event.type !== "file.edited") return

      const filePath = event.properties.file

      // Only validate .md files in .opencode/ directories
      if (!filePath.endsWith(".md")) return
      if (!filePath.includes(".opencode/")) return

      let content: string
      try {
        const fullPath = join(directory, filePath)
        content = await readFile(fullPath, "utf-8")
      } catch {
        return // File might have been deleted
      }

      let result: {
        valid: boolean
        errors: string[]
        warnings: string[]
      } | null = null

      if (filePath.includes("/agents/")) {
        result = validateAgentFile(filePath, content)
      } else if (filePath.includes("/skills/") && filePath.endsWith("SKILL.md")) {
        result = validateSkillFile(filePath, content)
      } else if (filePath.includes("/commands/")) {
        result = validateCommandFile(filePath, content)
      }

      if (result) {
        await logValidation({
          file: filePath,
          valid: result.valid,
          errors: result.errors.length > 0 ? result.errors : undefined,
          warnings: result.warnings.length > 0 ? result.warnings : undefined,
        })
      }
    },
  }
}

export default MarkdownValidatorPlugin
