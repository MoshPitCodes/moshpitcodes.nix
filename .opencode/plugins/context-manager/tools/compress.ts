/**
 * ICM Compress tool - collapse a range of conversation into a single summary
 */

import { tool } from "@opencode-ai/plugin"
import type { ICMConfig, SessionState } from "../config.js"
import type { ICMLogger } from "../logger.js"

/**
 * Create the icm_compress tool
 * Allows the LLM to compress a series of exploratory steps
 * (reading files, running commands) into what was learned
 */
// eslint-disable-next-line @typescript-eslint/explicit-function-return-type
export function createCompressTool(state: SessionState, logger: ICMLogger, config: ICMConfig): ReturnType<typeof tool> {
  return tool({
    description:
      "Compress a range of conversation content into a single summary. " +
      "Use this when a series of exploratory steps (reading files, running commands) can be " +
      "condensed into what was learned. Specify the part IDs to compress and provide a summary.",
    args: {
      summary: tool.schema
        .string()
        .describe("Concise summary of the compressed conversation range"),
      partIds: tool.schema
        .array(tool.schema.string())
        .describe("IDs of message parts to compress"),
      focus: tool.schema
        .string()
        .optional()
        .describe("Optional focus area for the compression"),
    },
    async execute(input) {
      let tokensSaved = 0
      let compressCount = 0

      for (const id of input.partIds) {
        if (state.prunedIds.has(id)) continue
        state.prunedIds.add(id)
        const node = state.dependencies.get(id)
        if (node) {
          node.pruned = true
          tokensSaved += node.estimatedTokens
        }
        compressCount++
      }

      state.stats.totalTokensSaved += tokensSaved
      state.stats.pruneCount += compressCount
      state.stats.compressCount += compressCount

      await logger.info("Compress executed", {
        compressCount,
        tokensSaved,
        summaryLength: input.summary.length,
      })

      return `Compressed ${compressCount} items (~${tokensSaved} tokens freed). Summary:\n${input.summary}`
    },
  })
}
