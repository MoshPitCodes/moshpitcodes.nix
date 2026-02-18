/**
 * ICM Logger for structured logging
 */

import { writeFile, mkdir } from "fs/promises"
import { join } from "path"
import type { PruneResult, SessionState } from "./config.js"
import { PLUGIN_NAME } from "./config.js"

export class ICMLogger {
  private debug: boolean
  private logDir: string
  private initialized = false

  constructor(debug: boolean, directory: string) {
    this.debug = debug
    this.logDir = join(directory, ".opencode", "logs")
  }

  private async ensureDir() {
    if (!this.initialized) {
      await mkdir(this.logDir, { recursive: true })
      this.initialized = true
    }
  }

  private async log(file: string, data: Record<string, unknown>) {
    try {
      await this.ensureDir()
      const entry = { timestamp: new Date().toISOString(), plugin: PLUGIN_NAME, ...data }
      await writeFile(join(this.logDir, `${file}.jsonl`), JSON.stringify(entry) + "\n", { flag: "a" })
    } catch {
      // Fail silently to avoid disrupting plugin operation
    }
  }

  async info(message: string, data?: Record<string, unknown>) {
    await this.log("icm", { level: "info", message, ...data })
  }

  async warn(message: string, data?: Record<string, unknown>) {
    await this.log("icm", { level: "warn", message, ...data })
  }

  async error(message: string, data?: Record<string, unknown>) {
    await this.log("icm", { level: "error", message, ...data })
  }

  async debugLog(message: string, data?: Record<string, unknown>) {
    if (this.debug) {
      await this.log("icm_debug", { level: "debug", message, ...data })
    }
  }

  async logPrune(result: PruneResult) {
    await this.log("icm_prune", {
      event: "pruned",
      partId: result.partId,
      tool: result.toolName,
      reason: result.reason,
      tokensSaved: result.tokensSaved,
      strategy: result.strategy,
    })
  }

  async logStats(stats: SessionState["stats"]) {
    await this.log("icm_stats", {
      event: "session_stats",
      ...stats,
      duration: Date.now() - stats.sessionStart,
    })
  }
}
