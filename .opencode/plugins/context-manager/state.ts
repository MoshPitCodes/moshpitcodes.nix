/**
 * Session state management and config loading
 */

import { join } from "path"
import { readFileSync } from "fs"
import type { SessionState, ICMConfig } from "./config.js"
import { DEFAULT_CONFIG } from "./config.js"

/**
 * Create a new session state object with default values
 * @returns New session state
 */
export function createSessionState(): SessionState {
  return {
    turnCount: 0,
    toolCalls: new Map(),
    dependencies: new Map(),
    prunedIds: new Set(),
    stats: {
      totalTokensSaved: 0,
      pruneCount: 0,
      deduplicationCount: 0,
      supersedeCount: 0,
      errorPurgeCount: 0,
      smartCompressionCount: 0,
      distillCount: 0,
      compressCount: 0,
      nudgesSent: 0,
      sessionStart: Date.now(),
    },
    fileHistory: new Map(),
    manualMode: false,
    toolResultsSinceNudge: 0,
  }
}

/**
 * Load ICM configuration from filesystem
 * Searches multiple locations in priority order:
 * 1. User config: ~/.config/opencode/icm.json
 * 2. Environment config: $OPENCODE_CONFIG_DIR/icm.json
 * 3. Project config: <project>/.opencode/icm.json
 * 
 * @param directory - Project directory
 * @returns Merged configuration with defaults
 */
export function loadConfig(directory: string): ICMConfig {
  const config = structuredClone(DEFAULT_CONFIG)
  const configPaths = [
    join(process.env.HOME ?? "", ".config", "opencode", "icm.json"),
    join(process.env.HOME ?? "", ".config", "opencode", "icm.jsonc"),
  ]

  if (process.env.OPENCODE_CONFIG_DIR) {
    configPaths.push(join(process.env.OPENCODE_CONFIG_DIR, "icm.json"))
    configPaths.push(join(process.env.OPENCODE_CONFIG_DIR, "icm.jsonc"))
  }

  configPaths.push(join(directory, ".opencode", "icm.json"))
  configPaths.push(join(directory, ".opencode", "icm.jsonc"))

  for (const configPath of configPaths) {
    try {
      const raw = readFileSync(configPath, "utf-8")
      // Strip JSONC comments
      const cleaned = raw.replace(/\/\/.*$/gm, "").replace(/\/\*[\s\S]*?\*\//g, "")
      const parsed = JSON.parse(cleaned)
      deepMerge(config, parsed)
    } catch {
      // Config file doesn't exist or is invalid — skip
    }
  }

  return config
}

/**
 * Deep merge source object into target object (mutates target)
 * @param target - Target object to merge into
 * @param source - Source object to merge from
 */
function deepMerge(target: any, source: any): void {
  for (const key of Object.keys(source)) {
    if (
      source[key] &&
      typeof source[key] === "object" &&
      !Array.isArray(source[key]) &&
      target[key] &&
      typeof target[key] === "object" &&
      !Array.isArray(target[key])
    ) {
      deepMerge(target[key], source[key])
    } else {
      target[key] = source[key]
    }
  }
}
