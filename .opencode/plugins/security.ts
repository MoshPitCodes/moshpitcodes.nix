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

        const envAccessPattern =
          /(^|[^\w.-])\.env(?!\.(example|sample|template)\b)(\.[\w.-]+)?(\b|$)/i
        const credentialAccessPatterns = [
          /(^|\s|['"`])[^\s'"`]*\.pem(\b|['"`])/i,
          /(^|\s|['"`])[^\s'"`]*\.key(\b|['"`])/i,
          /credentials\.json(\b|['"`])/i,
          /id_rsa(\b|['"`])/i,
          /id_ed25519(\b|['"`])/i,
          /\.aws\/credentials(\b|['"`])/i,
          /serviceAccount[^\s'"`]*\.json(\b|['"`])/i,
          /gcloud[^\s'"`]*\.json(\b|['"`])/i,
        ]

        const accessesSecretPath =
          envAccessPattern.test(command) ||
          credentialAccessPatterns.some((pattern) => pattern.test(command))

        if (accessesSecretPath) {
          await logSecurityEvent({
            event: "security_block",
            reason: "bash_secret_file_access",
            tool: "bash",
            command: command.substring(0, 200),
          })
          throw new Error("Blocked bash access to sensitive file for security")
        }

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

        // Block modifications targeting sensitive system paths while allowing read-only inspection.
        const systemPathPattern = /(^|\s|['"`])(\/etc\/|\/usr\/|\/var\/|\/System\/)/
        const mutatingCommandPattern =
          /\b(rm|mv|cp|install|chmod|chown|chgrp|tee|truncate|dd|vi|vim|nano)\b|>>?|\bsed\s+-i\b|\bperl\s+-i\b/i

        if (
          systemPathPattern.test(command) &&
          mutatingCommandPattern.test(command)
        ) {
          await logSecurityEvent({
            event: "security_block",
            reason: "system_file_modification",
            tool: "bash",
            command: command.substring(0, 200),
          })
          throw new Error("Blocked system file modification for security")
        }
      }

      // Block .env file access (but allow .env.example, .env.sample, etc.)
      if (
        input.tool === "read" ||
        input.tool === "edit" ||
        input.tool === "write"
      ) {
        const filePath: string = output.args.filePath ?? ""

        const envFilePattern = /(^|\/)\.env(\.[^\/]*)?$/i
        const envAllowlistPattern =
          /(^|\/)\.env\.(example|sample|template)$/i

        if (envFilePattern.test(filePath) && !envAllowlistPattern.test(filePath)) {
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
          /\.aws\/credentials$/i,
          /\.keystore$/i,
          /\.jks$/i,
          /serviceAccount.*\.json$/i,
          /gcloud.*\.json$/i,
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
