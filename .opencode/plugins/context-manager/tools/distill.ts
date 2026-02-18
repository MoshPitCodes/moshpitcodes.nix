/**
 * ICM Distill tool - extract key findings from tool outputs before pruning
 */

import { tool } from "@opencode-ai/plugin"
import type { ICMConfig, SessionState } from "../config.js"
import { isProtectedTool } from "../config.js"
import type { ICMLogger } from "../logger.js"

/**
 * Create the icm_distill tool
 * Allows the LLM to preserve important information as a summary
 * while freeing the original verbose tool output
 */
// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
export function createDistillTool(state: SessionState, logger: ICMLogger, config: ICMConfig): ReturnType<typeof tool> {
  return tool({
    description:
      "Distill key findings from tool outputs into a concise summary, then mark the original content for pruning. " +
      "Use this to preserve important information while freeing context space. " +
      "Provide a summary of the key findings and specify which tool call IDs to prune.",
    args: {
      summary: tool.schema
        .string()
        .describe("Concise summary of the key findings to preserve"),
      toolCallIds: tool.schema
        .array(tool.schema.string())
        .describe("IDs of tool call parts to prune after distillation"),
      focus: tool.schema
        .string()
        .optional()
        .describe("Optional focus area for the distillation"),
    },
    async execute(input) {
      const pruneCount = input.toolCallIds.length
      let tokensSaved = 0

      for (const id of input.toolCallIds) {
        if (isProtectedTool(id, config)) continue
        state.prunedIds.add(id)
        const node = state.dependencies.get(id)
        if (node) {
          node.pruned = true
          tokensSaved += node.estimatedTokens
        }
        state.stats.distillCount++
      }

      state.stats.totalTokensSaved += tokensSaved
      state.stats.pruneCount += pruneCount

      await logger.info("Distill executed", {
        pruneCount,
        tokensSaved,
        summaryLength: input.summary.length,
      })

      return `Distilled ${pruneCount} tool outputs (~${tokensSaved} tokens freed). Summary preserved:\n${input.summary}`
    },
  })
}
