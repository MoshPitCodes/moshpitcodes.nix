import type { Plugin } from "@opencode-ai/plugin"
import { writeFile, mkdir } from "fs/promises"
import { join } from "path"

/**
 * Security Plugin
 *
 * Blocks dangerous operations and protects sensitive files:
 * - Blocks `rm -rf` commands
 * - Prevents access to .env files (allows .env.example, .env.sample)
 * - Protects credential files (.key, .pem, credentials.json)
 * - Blocks system file modifications (/etc/, /usr/, /var/)
 */
export const SecurityPlugin: Plugin = async ({ directory, client }) => {
  const logDir = join(directory, ".opencode", "logs")
  await mkdir(logDir, { recursive: true })
  const logFile = join(logDir, "security.jsonl")

  const logSecurityEvent = async (data: Record<string, unknown>) => {
    try {
      await client.app.log({
        body: {
          service: "security-plugin",
          level: "warn",
          message: String(data.reason ?? "security_block"),
          extra: data,
        },
      })

      const entry = { timestamp: new Date().toISOString(), ...data }
      await writeFile(logFile, JSON.stringify(entry) + "\n", { flag: "a" })
    } catch {
      // Fail silently - don't disrupt operations due to logging errors
    }
  }

  return {
    "tool.execute.before": async (input, output) => {
      // Block dangerous rm commands
      if (input.tool === "bash") {
        const command: string = output.args.command ?? ""

        const dangerousPatterns = [
          /rm\s+(-[a-z]*r[a-z]*f|--recursive.*--force|-[a-z]*f[a-z]*r|--force.*--recursive)/i,
          /rm\s+-rf\s+\//,
          /rm\s+-rf\s+\./,
          /rm\s+-rf\s+\*/,
        ]

        for (const pattern of dangerousPatterns) {
          if (pattern.test(command)) {
            await logSecurityEvent({
              event: "security_block",
              reason: "dangerous_rm_command",
              tool: "bash",
              command: command.substring(0, 200),
            })
            throw new Error("Blocked dangerous rm -rf command for security")
          }
        }

        // Block system file modifications
        const systemPaths = ["/etc/", "/usr/", "/var/", "/System/"]
        for (const sysPath of systemPaths) {
          if (command.includes(sysPath)) {
            await logSecurityEvent({
              event: "security_block",
              reason: "system_file_modification",
              tool: "bash",
              command: command.substring(0, 200),
              path: sysPath,
            })
            throw new Error(`Blocked system file modification: ${sysPath}`)
          }
        }
      }

      // Block .env file access (but allow .env.example, .env.sample, etc.)
      if (
        input.tool === "read" ||
        input.tool === "edit" ||
        input.tool === "write"
      ) {
        const filePath: string = output.args.filePath ?? ""

        if (
          filePath.includes(".env") &&
          !filePath.match(/\.env\.(example|sample|template)/i)
        ) {
          await logSecurityEvent({
            event: "security_block",
            reason: "env_file_access",
            tool: input.tool,
            filePath,
          })
          throw new Error("Blocked access to .env file for security")
        }

        // Block credential files
        const credentialPatterns = [
          /\.key$/i,
          /\.pem$/i,
          /credentials\.json$/i,
          /\.p12$/i,
          /\.pfx$/i,
          /id_rsa$/i,
          /id_ed25519$/i,
        ]

        for (const pattern of credentialPatterns) {
          if (pattern.test(filePath)) {
            await logSecurityEvent({
              event: "security_block",
              reason: "credential_file_access",
              tool: input.tool,
              filePath,
            })
            throw new Error(
              "Blocked access to credential file for security",
            )
          }
        }
      }
    },
  }
}

export default SecurityPlugin
