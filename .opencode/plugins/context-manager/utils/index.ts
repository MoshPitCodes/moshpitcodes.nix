/**
 * Utility module exports
 */

export { estimateTokens, truncate, CHARS_PER_TOKEN } from "./tokens.js"
export { computeSimilarity, clearSimilarityCache, getCacheStats } from "./similarity.js"
export {
  extractFilePath,
  isFileReadTool,
  isFileWriteTool,
  isProtectedFile,
  simpleGlobMatch,
} from "./file-patterns.js"
