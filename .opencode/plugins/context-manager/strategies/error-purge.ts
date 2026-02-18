/**
 * Error purge strategy - removes input content for tools that errored after N turns
 * Once errors are resolved, their verbose input is no longer needed
 */

import type { Part, ToolPart, Message } from "@opencode-ai/sdk"
import type { ICMConfig, SessionState, PruneResult } from "../config.js"
import { isProtectedTool } from "../config.js"
import { estimateTokens } from "../utils/tokens.js"

/**
 * Find error inputs that can be safely purged (enough turns have passed)
 */
export function findPurgeableErrors(
  messages: { info: Message; parts: Part[] }[],
  state: SessionState,
  config: ICMConfig,
): PruneResult[] {
  if (!config.strategies.purgeErrors.enabled) return []
  const results: PruneResult[] = []
  const turnsThreshold = config.strategies.purgeErrors.turns
  const errorProtected = new Set(config.strategies.purgeErrors.protectedTools)

  for (const msg of messages) {
    for (const part of msg.parts) {
      if (part.type !== "tool") continue
      const tp = part as ToolPart
      if (tp.state.status !== "error") continue
      if (isProtectedTool(tp.tool, config)) continue
      if (errorProtected.has(tp.tool)) continue
      if (state.prunedIds.has(tp.id)) continue

      // Check if enough turns have passed
      const toolEntry = state.toolCalls.get(tp.callID)
      if (!toolEntry) continue
      const turnAge = state.turnCount - toolEntry.turn
      if (turnAge < turnsThreshold) continue

      const inputTokens = estimateTokens(JSON.stringify(tp.state.input))
      if (inputTokens > 50) { // Only worth pruning if input is substantial
        results.push({
          partId: tp.id,
          toolName: tp.tool,
          reason: `Error input pruned after ${turnAge} turns`,
          tokensSaved: inputTokens,
          strategy: "error-purge",
        })
      }
    }
  }

  return results
}
