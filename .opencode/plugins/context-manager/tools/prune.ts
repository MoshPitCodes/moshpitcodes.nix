/**
 * ICM Prune tool - remove completed or noisy tool content from context
 */

import { tool } from "@opencode-ai/plugin"
import type { ICMConfig, SessionState } from "../config.js"
import { isProtectedTool } from "../config.js"
import type { ICMLogger } from "../logger.js"

/**
 * Create the icm_prune tool
 * Allows the LLM to remove tool outputs that are no longer needed
 */
// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
export function createPruneTool(state: SessionState, logger: ICMLogger, config: ICMConfig): ReturnType<typeof tool> {
  return tool({
    description:
      "Remove completed or noisy tool content from context. " +
      "Use this for tool outputs that are no longer needed (completed tasks, " +
      "exploratory reads that have been superseded, etc.).",
    args: {
      partIds: tool.schema
        .array(tool.schema.string())
        .describe("IDs of tool call parts to prune"),
      reason: tool.schema
        .string()
        .optional()
        .describe("Brief reason for pruning"),
    },
    async execute(input) {
      let tokensSaved = 0
      let pruneCount = 0

      for (const id of input.partIds) {
        if (state.prunedIds.has(id)) continue
        if (isProtectedTool(id, config)) continue
        state.prunedIds.add(id)
        const node = state.dependencies.get(id)
        if (node) {
          node.pruned = true
          tokensSaved += node.estimatedTokens
        }
        pruneCount++
      }

      state.stats.totalTokensSaved += tokensSaved
      state.stats.pruneCount += pruneCount

      await logger.info("Prune executed", {
        pruneCount,
        tokensSaved,
        reason: input.reason,
      })

      return `Pruned ${pruneCount} items (~${tokensSaved} tokens freed)${input.reason ? `. Reason: ${input.reason}` : ""}`
    },
  })
}
