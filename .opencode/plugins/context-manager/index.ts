/**
 * Intelligent Context Manager (ICM) Plugin
 * 
 * Automatically manages context size through intelligent pruning strategies:
 * - Deduplication (exact and fuzzy)
 * - Superseding writes with subsequent reads
 * - Error purging after resolution
 * - Smart compression of large outputs
 * 
 * Modular architecture:
 * - config.ts    - Types, interfaces, constants, defaults
 * - logger.ts    - Structured JSONL logging
 * - state.ts     - Session state and config loading
 * - scoring.ts   - Semantic scoring and dependency graph
 * - strategies/  - Pruning strategy implementations
 * - tools/       - LLM-facing tool implementations
 * - utils/       - Pure utility functions
 * 
 * @module context-manager
 */

import type { Plugin, Hooks } from "@opencode-ai/plugin"
import type {
  Message,
  Part,
  ToolPart,
  TextPart,
  Config,
} from "@opencode-ai/sdk"
import { writeFile, readFile, mkdir } from "fs/promises"
import { join } from "path"

// Core modules
import type { ICMConfig, SessionState, PruneResult } from "./config.js"
import {
  PLUGIN_VERSION,
  PRUNE_PLACEHOLDER,
  DEDUP_PLACEHOLDER,
  SUPERSEDE_PLACEHOLDER,
  ERROR_PURGE_PLACEHOLDER,
  DEFAULT_PROTECTED_TOOLS,
  resolveContextLimit,
  isProtectedTool,
} from "./config.js"
import { ICMLogger } from "./logger.js"
import { createSessionState, loadConfig } from "./state.js"
import { estimateTokens } from "./utils/tokens.js"
import { extractFilePath, isFileReadTool, isFileWriteTool } from "./utils/file-patterns.js"

// Scoring and dependency graph
import { addDependencyNode } from "./scoring.js"

// Strategies
import {
  findDuplicates,
  findFuzzyDuplicates,
  findSupersededWrites,
  findPurgeableErrors,
  findSmartCompressible,
  generateSmartSummary,
} from "./strategies/index.js"

// Tools
import { createDistillTool, createCompressTool, createPruneTool } from "./tools/index.js"

// ============================================================================
// CACHE-AWARE PRUNING
// ============================================================================

function filterForCacheAwareness(
  results: PruneResult[],
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
  config: ICMConfig,
): PruneResult[] {
  if (!config.cacheAwareness.enabled || config.cacheAwareness.provider === "none") {
    return results
  }

  // For cache-aware pruning, we prefer to prune from the end of the conversation
  // rather than the beginning, to preserve cached prefixes.
  const partPositions = new Map<string, number>()
  let position = 0
  for (const msg of messages) {
    for (const part of msg.parts) {
      partPositions.set(part.id, position++)
    }
  }

  // Filter out results where savings don't meet threshold
  const filtered = results.filter((r) => r.tokensSaved >= config.cacheAwareness.minNetSavings)

  // Sort so we prune later items first (preserve cache prefix)
  filtered.sort((a, b) => {
    const posA = partPositions.get(a.partId) ?? 0
    const posB = partPositions.get(b.partId) ?? 0
    return posB - posA // Later items first
  })

  return filtered
}

// ============================================================================
// MESSAGE TRANSFORMATION
// ============================================================================

function applyPruneResults(
  messages: { info: Message; parts: Part[] }[],
  results: PruneResult[],
  state: SessionState,
  config: ICMConfig,
): { info: Message; parts: Part[] }[] {
  const prunedPartIds = new Set(results.map((r) => r.partId))

  return messages.map((msg) => ({
    info: msg.info,
    parts: msg.parts.map((part) => {
      if (part.type !== "tool") return part
      const tp = part as ToolPart
      if (!prunedPartIds.has(tp.id)) return part
      if (tp.state.status !== "completed" && tp.state.status !== "error") return part

      const result = results.find((r) => r.partId === tp.id)
      if (!result) return part

      // Mark as pruned in state
      state.prunedIds.add(tp.id)
      const depNode = state.dependencies.get(tp.id)
      if (depNode) depNode.pruned = true

      // Update stats
      state.stats.totalTokensSaved += result.tokensSaved
      state.stats.pruneCount++

      switch (result.strategy) {
        case "deduplication": state.stats.deduplicationCount++; break
        case "supersede": state.stats.supersedeCount++; break
        case "error-purge": state.stats.errorPurgeCount++; break
        case "smart-compression": state.stats.smartCompressionCount++; break
        case "distill": state.stats.distillCount++; break
        case "compress": state.stats.compressCount++; break
      }

      // Apply the prune
      if (tp.state.status === "completed") {
        let replacement: string
        switch (result.strategy) {
          case "deduplication":
            replacement = DEDUP_PLACEHOLDER
            break
          case "supersede":
            replacement = SUPERSEDE_PLACEHOLDER
            break
          case "smart-compression":
            replacement = generateSmartSummary(tp.tool, tp.state.output, tp.state.input as Record<string, unknown>)
            break
          default:
            replacement = PRUNE_PLACEHOLDER
        }

        return {
          ...tp,
          state: {
            ...tp.state,
            output: replacement,
          },
        } as Part
      }

      if (tp.state.status === "error") {
        return {
          ...tp,
          state: {
            ...tp.state,
            input: { _pruned: true, _reason: ERROR_PURGE_PLACEHOLDER } as any,
          },
        } as Part
      }

      return part
    }),
  }))
}

// ============================================================================
// SYSTEM PROMPT & NUDGING
// ============================================================================

function buildSystemPromptAddition(state: SessionState, config: ICMConfig): string {
  const parts: string[] = []

  if (!config.manualMode.enabled && !state.manualMode) {
    parts.push(`<icm-context-management>`)
    parts.push(`You have context management tools available to optimize token usage:`)

    if (config.tools.distill.permission !== "deny") {
      parts.push(`- **icm_distill**: Extract key findings from tool outputs before removing the raw content. Use when tool output contains important information that should be preserved in summary form.`)
    }
    if (config.tools.compress.permission !== "deny") {
      parts.push(`- **icm_compress**: Collapse a range of conversation into a concise summary. Use when a series of exploration steps can be condensed.`)
    }
    if (config.tools.prune.permission !== "deny") {
      parts.push(`- **icm_prune**: Remove completed or noisy tool content from context. Use for tool outputs no longer needed.`)
    }

    parts.push(``)
    parts.push(`Guidelines:`)
    parts.push(`- Proactively manage context when working on long tasks`)
    parts.push(`- Distill important findings before they get pruned`)
    parts.push(`- Prune exploratory tool calls once you have the information you need`)
    parts.push(`- Never prune tool outputs that contain information you still need`)
    parts.push(`</icm-context-management>`)
  }

  return parts.join("\n")
}

function buildNudgeMessage(state: SessionState, config: ICMConfig): string | undefined {
  if (!config.tools.settings.nudgeEnabled) return undefined
  if (config.manualMode.enabled || state.manualMode) return undefined
  if (state.toolResultsSinceNudge < config.tools.settings.nudgeFrequency) return undefined

  state.toolResultsSinceNudge = 0
  state.stats.nudgesSent++

  const contextLimit = resolveContextLimit(config, state.currentModel)
  const estimatedUsage = estimateCurrentTokenUsage(state)

  if (estimatedUsage > contextLimit * 0.8) {
    return `[ICM] Context usage is high (~${Math.round(estimatedUsage / 1000)}k tokens). Consider using icm_distill or icm_prune to free up context for better response quality.`
  }

  return `[ICM] Consider pruning completed tool outputs to maintain context quality. Use icm_prune for outputs no longer needed, or icm_distill to preserve key findings.`
}

function estimateCurrentTokenUsage(state: SessionState): number {
  let total = 0
  for (const [, node] of state.dependencies) {
    if (!node.pruned) {
      total += node.estimatedTokens
    }
  }
  return total
}

// ============================================================================
// SESSION MEMORY
// ============================================================================

interface SessionMemory {
  /** Files that are frequently read and re-read */
  hotFiles: Record<string, number>
  /** Tools that commonly produce pruneable output */
  frequentlyPruned: Record<string, number>
  /** Average session stats */
  sessionCount: number
  avgTokensSaved: number
  avgPruneCount: number
  lastUpdated: string
}

async function loadSessionMemory(directory: string, config: ICMConfig): Promise<SessionMemory> {
  if (!config.memory.enabled) {
    return { hotFiles: {}, frequentlyPruned: {}, sessionCount: 0, avgTokensSaved: 0, avgPruneCount: 0, lastUpdated: "" }
  }

  const memoryPath = join(directory, config.memory.persistPath, "memory.json")
  try {
    const raw = await readFile(memoryPath, "utf-8")
    return JSON.parse(raw) as SessionMemory
  } catch {
    return { hotFiles: {}, frequentlyPruned: {}, sessionCount: 0, avgTokensSaved: 0, avgPruneCount: 0, lastUpdated: "" }
  }
}

async function saveSessionMemory(
  directory: string,
  config: ICMConfig,
  state: SessionState,
  memory: SessionMemory,
): Promise<void> {
  if (!config.memory.enabled) return

  try {
    const memDir = join(directory, config.memory.persistPath)
    await mkdir(memDir, { recursive: true })

    // Update memory with session data
    memory.sessionCount++
    memory.avgTokensSaved = ((memory.avgTokensSaved * (memory.sessionCount - 1)) + state.stats.totalTokensSaved) / memory.sessionCount
    memory.avgPruneCount = ((memory.avgPruneCount * (memory.sessionCount - 1)) + state.stats.pruneCount) / memory.sessionCount
    memory.lastUpdated = new Date().toISOString()

    // Track hot files
    for (const [fp, history] of state.fileHistory) {
      const accessCount = history.reads.length + history.writes.length + history.edits.length
      memory.hotFiles[fp] = (memory.hotFiles[fp] ?? 0) + accessCount
    }

    // Track frequently pruned tools
    for (const [, node] of state.dependencies) {
      if (node.pruned && node.toolName) {
        memory.frequentlyPruned[node.toolName] = (memory.frequentlyPruned[node.toolName] ?? 0) + 1
      }
    }

    await writeFile(join(memDir, "memory.json"), JSON.stringify(memory, null, 2))
  } catch {
    // Fail silently
  }
}

// ============================================================================
// NOTIFICATION FORMATTING
// ============================================================================

function formatPruneNotification(
  results: PruneResult[],
  config: ICMConfig,
): string | undefined {
  if (config.pruneNotification === "off" || results.length === 0) return undefined

  const totalSaved = results.reduce((sum, r) => sum + r.tokensSaved, 0)

  if (config.pruneNotification === "minimal") {
    return `[ICM] Pruned ${results.length} items, saved ~${totalSaved} tokens`
  }

  // Detailed
  const byStrategy = new Map<string, { count: number; tokens: number }>()
  for (const r of results) {
    const entry = byStrategy.get(r.strategy) ?? { count: 0, tokens: 0 }
    entry.count++
    entry.tokens += r.tokensSaved
    byStrategy.set(r.strategy, entry)
  }

  const lines = [`[ICM] Pruned ${results.length} items, saved ~${totalSaved} tokens:`]
  for (const [strategy, data] of byStrategy) {
    lines.push(`  ${strategy}: ${data.count} items (~${data.tokens} tokens)`)
  }

  return lines.join("\n")
}

function formatContextBreakdown(
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
): string {
  let systemTokens = 0
  let userTokens = 0
  let assistantTokens = 0
  let toolTokens = 0
  let prunedTokens = state.stats.totalTokensSaved

  for (const msg of messages) {
    for (const part of msg.parts) {
      if (part.type === "text") {
        const tp = part as TextPart
        const tokens = estimateTokens(tp.text)
        if (msg.info.role === "user") userTokens += tokens
        else assistantTokens += tokens
      } else if (part.type === "tool") {
        const tp = part as ToolPart
        if (tp.state.status === "completed") {
          toolTokens += estimateTokens(tp.state.output)
          toolTokens += estimateTokens(JSON.stringify(tp.state.input))
        } else if (tp.state.status === "error") {
          toolTokens += estimateTokens(tp.state.error)
        }
      }
    }
  }

  const total = systemTokens + userTokens + assistantTokens + toolTokens
  const lines = [
    `Context Breakdown (estimated):`,
    `  User messages:      ~${userTokens.toLocaleString()} tokens`,
    `  Assistant messages:  ~${assistantTokens.toLocaleString()} tokens`,
    `  Tool I/O:           ~${toolTokens.toLocaleString()} tokens`,
    `  ─────────────────────────────`,
    `  Total active:       ~${total.toLocaleString()} tokens`,
    `  Tokens saved (ICM): ~${prunedTokens.toLocaleString()} tokens`,
    `  Total original:     ~${(total + prunedTokens).toLocaleString()} tokens`,
  ]

  return lines.join("\n")
}

function formatStats(state: SessionState): string {
  const duration = Date.now() - state.stats.sessionStart
  const mins = Math.floor(duration / 60000)
  const secs = Math.floor((duration % 60000) / 1000)

  return [
    `ICM Session Statistics:`,
    `  Session duration:      ${mins}m ${secs}s`,
    `  Total tokens saved:    ~${state.stats.totalTokensSaved.toLocaleString()}`,
    `  Total prunes:          ${state.stats.pruneCount}`,
    `    Deduplication:       ${state.stats.deduplicationCount}`,
    `    Supersede writes:    ${state.stats.supersedeCount}`,
    `    Error purges:        ${state.stats.errorPurgeCount}`,
    `    Smart compression:   ${state.stats.smartCompressionCount}`,
    `    Distill:             ${state.stats.distillCount}`,
    `    Compress:            ${state.stats.compressCount}`,
    `  Nudges sent:           ${state.stats.nudgesSent}`,
    `  Tracked tool calls:    ${state.toolCalls.size}`,
    `  Dependency nodes:      ${state.dependencies.size}`,
    `  Files tracked:         ${state.fileHistory.size}`,
  ].join("\n")
}

// ============================================================================
// MAIN PLUGIN
// ============================================================================

export const ICMPlugin: Plugin = async ({ directory, client, $ }) => {
  const config = loadConfig(directory)

  if (!config.enabled) return {}

  const logger = new ICMLogger(config.debug, directory)
  const state = createSessionState()
  state.manualMode = config.manualMode.enabled

  let memory = await loadSessionMemory(directory, config)

  await logger.info("ICM initialized", {
    version: PLUGIN_VERSION,
    strategies: {
      deduplication: config.strategies.deduplication.enabled,
      supersedeWrites: config.strategies.supersedeWrites.enabled,
      purgeErrors: config.strategies.purgeErrors.enabled,
      smartCompression: config.strategies.smartCompression.enabled,
    },
    semantic: config.semantic.enabled,
    memory: config.memory.enabled,
    cacheAwareness: config.cacheAwareness.enabled,
    manualMode: state.manualMode,
  })

  // Build the hooks object
  const hooks: Hooks = {
    // ---- System prompt injection ----
    "experimental.chat.system.transform": async (input, output) => {
      const addition = buildSystemPromptAddition(state, config)
      if (addition) {
        output.system.push(addition)
      }

      // Detect provider/model for cache-awareness
      if (input.model) {
        state.currentModel = {
          providerID: input.model.providerID,
          modelID: input.model.id,
          contextLimit: input.model.limit?.context ?? 200000,
        }
        if (config.cacheAwareness.provider === "auto") {
          state.detectedProvider = input.model.providerID
        }
      }
    },

    // ---- Message transformation (the core pruning engine) ----
    "experimental.chat.messages.transform": async (_input, output) => {
      // Skip if in manual mode with automatic strategies disabled
      if (state.manualMode && !config.manualMode.automaticStrategies) return

      const messages = output.messages

      // Run automatic strategies
      let allResults: PruneResult[] = []

      // 1. Exact deduplication
      const dedupeResults = findDuplicates(messages, state, config)
      allResults.push(...dedupeResults)

      // 2. Fuzzy deduplication
      const fuzzyResults = findFuzzyDuplicates(messages, state, config)
      allResults.push(...fuzzyResults)

      // 3. Supersede writes
      const supersedeResults = findSupersededWrites(messages, state, config)
      allResults.push(...supersedeResults)

      // 4. Purge errors
      const errorResults = findPurgeableErrors(messages, state, config)
      allResults.push(...errorResults)

      // 5. Smart compression (only if not in manual mode)
      if (!state.manualMode) {
        const smartResults = findSmartCompressible(messages, state, config)
        allResults.push(...smartResults)
      }

      // Deduplicate results (same part might be caught by multiple strategies)
      const seenParts = new Set<string>()
      allResults = allResults.filter((r) => {
        if (seenParts.has(r.partId)) return false
        seenParts.add(r.partId)
        return true
      })

      // Apply cache-awareness filtering
      if (config.cacheAwareness.enabled) {
        allResults = filterForCacheAwareness(allResults, messages, state, config)
      }

      // Apply pruning
      if (allResults.length > 0) {
        output.messages = applyPruneResults(messages, allResults, state, config)

        // Log results
        for (const result of allResults) {
          await logger.logPrune(result)
        }

        await logger.debugLog("Transform applied", {
          pruneCount: allResults.length,
          totalTokensSaved: allResults.reduce((s, r) => s + r.tokensSaved, 0),
        })
      }

      // Handle nudge injection
      const nudge = buildNudgeMessage(state, config)
      if (nudge) {
        for (let i = output.messages.length - 1; i >= 0; i--) {
          if (output.messages[i].info.role === "assistant") {
            await logger.debugLog("Nudge triggered", { nudge })
            break
          }
        }
      }
    },

    // ---- Track new messages (turn counting, variant caching) ----
    "chat.message": async (input) => {
      state.turnCount++
      state.variant = input.variant
      state.sessionId = input.sessionID

      if (input.model) {
        state.currentModel = {
          providerID: input.model.providerID,
          modelID: input.model.modelID,
          contextLimit: 200000,
        }
      }

      await logger.debugLog("New turn", { turn: state.turnCount, variant: input.variant })
    },

    // ---- Track tool execution results ----
    "tool.execute.after": async (input, output) => {
      state.toolResultsSinceNudge++

      const toolName = input.tool
      const callId = input.callID

      const args = (output.metadata as Record<string, unknown>) ?? {}

      // Track in tool calls map
      state.toolCalls.set(callId, {
        tool: toolName,
        args,
        output: output.output,
        turn: state.turnCount,
      })

      // Track file access
      const filePath = extractFilePath(toolName, args)
      if (filePath) {
        if (!state.fileHistory.has(filePath)) {
          state.fileHistory.set(filePath, { reads: [], writes: [], edits: [] })
        }
        const history = state.fileHistory.get(filePath)!
        if (isFileReadTool(toolName)) history.reads.push(state.turnCount)
        else if (toolName === "write") history.writes.push(state.turnCount)
        else if (toolName === "edit") history.edits.push(state.turnCount)
      }

      // Add to dependency graph
      addDependencyNode(state, callId, toolName, args, output.output, state.turnCount, config)

      await logger.debugLog("Tool tracked", {
        tool: toolName,
        callId,
        outputLength: output.output?.length ?? 0,
        turn: state.turnCount,
      })
    },

    // ---- Slash command handling ----
    "command.execute.before": async (input, output) => {
      if (input.command !== "icm") return

      const args = input.arguments.trim().split(/\s+/)
      const subcommand = args[0]?.toLowerCase()

      switch (subcommand) {
        case "context": {
          output.parts.push({
            type: "text",
            text: `Show me the ICM context breakdown. The current session stats are:\n${formatStats(state)}`,
          } as any)
          break
        }

        case "stats": {
          output.parts.push({
            type: "text",
            text: formatStats(state),
          } as any)
          break
        }

        case "sweep": {
          const count = parseInt(args[1]) || undefined
          output.parts.push({
            type: "text",
            text: `Use icm_prune to prune ${count ? `the last ${count}` : "all"} completed tool outputs since the last user message. Skip any tools named: ${[...DEFAULT_PROTECTED_TOOLS].join(", ")}`,
          } as any)
          break
        }

        case "manual": {
          const setting = args[1]?.toLowerCase()
          if (setting === "on") {
            state.manualMode = true
          } else if (setting === "off") {
            state.manualMode = false
          } else {
            state.manualMode = !state.manualMode
          }
          output.parts.push({
            type: "text",
            text: `ICM manual mode: ${state.manualMode ? "ON" : "OFF"}. ${state.manualMode ? "Automatic pruning tools disabled. Use /icm sweep or /icm prune to manually trigger." : "Automatic context management re-enabled."}`,
          } as any)
          break
        }

        case "prune": {
          const focus = args.slice(1).join(" ")
          output.parts.push({
            type: "text",
            text: `Use icm_prune to remove completed tool outputs that are no longer needed.${focus ? ` Focus: ${focus}` : ""} Skip protected tools: ${[...DEFAULT_PROTECTED_TOOLS].join(", ")}`,
          } as any)
          break
        }

        case "distill": {
          const focus = args.slice(1).join(" ")
          output.parts.push({
            type: "text",
            text: `Use icm_distill to extract key findings from tool outputs.${focus ? ` Focus: ${focus}` : ""} Summarize important information before pruning.`,
          } as any)
          break
        }

        case "compress": {
          const focus = args.slice(1).join(" ")
          output.parts.push({
            type: "text",
            text: `Use icm_compress to collapse a range of conversation into a summary.${focus ? ` Focus: ${focus}` : ""} Preserve key decisions and findings.`,
          } as any)
          break
        }

        default: {
          output.parts.push({
            type: "text",
            text: [
              "ICM - Intelligent Context Manager",
              "",
              "Available commands:",
              "  /icm context        — Show context token breakdown",
              "  /icm stats          — Show pruning statistics",
              "  /icm sweep [N]      — Prune last N tool outputs (or all since last user msg)",
              "  /icm manual [on|off] — Toggle manual mode",
              "  /icm prune [focus]  — Trigger a prune with optional focus",
              "  /icm distill [focus] — Trigger a distill with optional focus",
              "  /icm compress [focus] — Trigger a compress with optional focus",
              "",
              `Status: ${state.manualMode ? "Manual mode" : "Automatic"} | ${state.stats.pruneCount} prunes | ~${state.stats.totalTokensSaved} tokens saved`,
            ].join("\n"),
          } as any)
        }
      }
    },

    // ---- Event handling (session lifecycle) ----
    event: async ({ event }) => {
      switch (event.type) {
        case "session.created": {
          state.sessionId = event.properties.info.id
          state.stats.sessionStart = Date.now()
          await logger.info("Session started", { sessionId: state.sessionId })
          break
        }

        case "session.idle": {
          // Save session memory and log final stats
          await saveSessionMemory(directory, config, state, memory)
          await logger.logStats(state.stats)

          // Show notification if configured as toast
          if (config.pruneNotificationType === "toast" && state.stats.pruneCount > 0) {
            try {
              const msg = `ICM: ${state.stats.pruneCount} prunes, ~${state.stats.totalTokensSaved} tokens saved`
              await client.tui.showToast({
                body: {
                  message: msg,
                  variant: "info",
                  title: "ICM Stats",
                  duration: 5000,
                },
              })
            } catch {
              // Toast not available
            }
          }
          break
        }

        case "session.compacted": {
          // Reset state after compaction since all messages are replaced
          state.prunedIds.clear()
          state.toolCalls.clear()
          state.dependencies.clear()
          state.fileHistory.clear()
          state.toolResultsSinceNudge = 0
          await logger.info("Session compacted — state reset")
          break
        }
      }
    },

    // ---- Register tools ----
    tool: {
      ...(config.tools.distill.permission !== "deny" && {
        icm_distill: createDistillTool(state, logger, config),
      }),
      ...(config.tools.compress.permission !== "deny" && {
        icm_compress: createCompressTool(state, logger, config),
      }),
      ...(config.tools.prune.permission !== "deny" && {
        icm_prune: createPruneTool(state, logger, config),
      }),
    },

    // ---- Config mutation: register commands and tool permissions ----
    config: async (opencodeConfig: Config) => {
      // Register /icm command
      if (config.commands.enabled) {
        opencodeConfig.command ??= {}
        opencodeConfig.command["icm"] = {
          template: "",
          description: "Intelligent Context Manager — manage context, view stats, and control pruning",
        }
      }

      // Register tools as primary (accessible in main agent context)
      const toolsToAdd: string[] = []
      if (config.tools.distill.permission !== "deny") toolsToAdd.push("icm_distill")
      if (config.tools.compress.permission !== "deny") toolsToAdd.push("icm_compress")
      if (config.tools.prune.permission !== "deny") toolsToAdd.push("icm_prune")

      if (toolsToAdd.length > 0) {
        const existing = opencodeConfig.experimental?.primary_tools ?? []
        opencodeConfig.experimental = {
          ...opencodeConfig.experimental,
          primary_tools: [...existing, ...toolsToAdd],
        }
      }

      // Set tool permissions
      const permission = (opencodeConfig as any).permission ?? {}
      ;(opencodeConfig as any).permission = {
        ...permission,
        icm_distill: config.tools.distill.permission,
        icm_compress: config.tools.compress.permission,
        icm_prune: config.tools.prune.permission,
      }
    },
  }

  return hooks
}

export default ICMPlugin
