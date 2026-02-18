/**
 * Token estimation utilities for context management
 */

/** Estimated tokens per character (rough heuristic) */
export const CHARS_PER_TOKEN = 4

/**
 * Estimate token count for a given text string
 * @param text - The text to estimate tokens for
 * @returns Estimated token count
 */
export function estimateTokens(text: string): number {
  if (!text) return 0
  return Math.ceil(text.length / CHARS_PER_TOKEN)
}

/**
 * Truncate a value for logging/display purposes
 * @param value - Value to truncate (string or object)
 * @param maxLength - Maximum length before truncation
 * @returns Truncated value with indication of truncation
 */
export function truncate(value: unknown, maxLength: number = 500): unknown {
  if (typeof value === "string") {
    return value.length > maxLength
      ? value.substring(0, maxLength) + `... (truncated ${value.length - maxLength} chars)`
      : value
  }
  if (typeof value === "object" && value !== null) {
    const str = JSON.stringify(value)
    if (str.length > maxLength) {
      return str.substring(0, maxLength) + "... (truncated)"
    }
    return value
  }
  return value
}
