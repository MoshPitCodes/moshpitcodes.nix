/**
 * Deduplication strategy - finds and removes duplicate tool outputs
 * Supports both exact and fuzzy (trigram-based) deduplication
 */

import type { Part, ToolPart, Message } from "@opencode-ai/sdk"
import type { ICMConfig, SessionState, PruneResult } from "../config.js"
import { isProtectedTool, isTurnProtected } from "../config.js"
import { estimateTokens } from "../utils/tokens.js"
import { computeSimilarity } from "../utils/similarity.js"

/**
 * Find exact duplicate tool calls (same tool + same arguments)
 * Keeps the latest instance, prunes earlier duplicates
 */
export function findDuplicates(
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
  config: ICMConfig,
): PruneResult[] {
  if (!config.strategies.deduplication.enabled) return []
  const results: PruneResult[] = []

  // Build a map of tool signature -> list of part IDs (in order)
  const toolSignatures = new Map<string, { partId: string; turn: number; tokens: number }[]>()

  const dedupeProtected = new Set([
    ...config.strategies.deduplication.protectedTools,
    ...config.tools.settings.protectedTools,
  ])

  for (const msg of messages) {
    for (const part of msg.parts) {
      if (part.type !== "tool") continue
      const tp = part as ToolPart
      if (tp.state.status !== "completed") continue
      if (isProtectedTool(tp.tool, config)) continue
      if (dedupeProtected.has(tp.tool)) continue
      if (state.prunedIds.has(tp.id)) continue

      const sig = `${tp.tool}::${JSON.stringify(tp.state.input)}`
      if (!toolSignatures.has(sig)) {
        toolSignatures.set(sig, [])
      }
      const tokens = estimateTokens(tp.state.output)
      toolSignatures.get(sig)!.push({ partId: tp.id, turn: state.turnCount, tokens })
    }
  }

  // For each signature with duplicates, prune all but the last
  for (const [_sig, instances] of toolSignatures) {
    if (instances.length <= 1) continue
    for (let i = 0; i < instances.length - 1; i++) {
      const inst = instances[i]
      if (isTurnProtected(inst.turn, state.turnCount, config)) continue
      results.push({
        partId: inst.partId,
        toolName: _sig.split("::")[0],
        reason: "Duplicate tool call with identical arguments",
        tokensSaved: inst.tokens,
        strategy: "deduplication",
      })
    }
  }

  return results
}

/**
 * Find fuzzy duplicate tool calls (similar outputs above threshold)
 * Uses trigram similarity to detect near-identical outputs
 */
export function findFuzzyDuplicates(
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
  config: ICMConfig,
): PruneResult[] {
  if (!config.strategies.deduplication.enabled || config.strategies.deduplication.fuzzyThreshold >= 1.0) return []
  const results: PruneResult[] = []
  const threshold = config.strategies.deduplication.fuzzyThreshold

  // Group by tool name, then compare outputs
  const toolOutputs = new Map<string, { partId: string; output: string; turn: number; tokens: number }[]>()

  for (const msg of messages) {
    for (const part of msg.parts) {
      if (part.type !== "tool") continue
      const tp = part as ToolPart
      if (tp.state.status !== "completed") continue
      if (isProtectedTool(tp.tool, config)) continue
      if (state.prunedIds.has(tp.id)) continue

      if (!toolOutputs.has(tp.tool)) toolOutputs.set(tp.tool, [])
      toolOutputs.get(tp.tool)!.push({
        partId: tp.id,
        output: tp.state.output,
        turn: state.turnCount,
        tokens: estimateTokens(tp.state.output),
      })
    }
  }

  for (const [toolName, outputs] of toolOutputs) {
    if (outputs.length <= 1) continue
    for (let i = 0; i < outputs.length - 1; i++) {
      for (let j = i + 1; j < outputs.length; j++) {
        const similarity = computeSimilarity(outputs[i].output, outputs[j].output)
        if (similarity >= threshold) {
          const older = outputs[i]
          if (!isTurnProtected(older.turn, state.turnCount, config)) {
            results.push({
              partId: older.partId,
              toolName,
              reason: `Near-duplicate output (${(similarity * 100).toFixed(0)}% similar)`,
              tokensSaved: older.tokens,
              strategy: "deduplication",
            })
          }
        }
      }
    }
  }

  return results
}
