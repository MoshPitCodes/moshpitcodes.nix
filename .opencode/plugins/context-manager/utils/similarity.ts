/**
 * Similarity computation using character trigrams with LRU caching
 */

/** Maximum cache size to prevent unbounded growth */
const MAX_CACHE_SIZE = 1000

/** Similarity cache (LRU with size limit) */
const similarityCache = new Map<string, number>()

/**
 * Generate cache key for similarity comparison (bidirectional)
 * @param a - First string
 * @param b - Second string
 * @returns Cache key ensuring (a,b) === (b,a)
 */
function getCacheKey(a: string, b: string): string {
  // Sort to ensure cache hits for (a,b) and (b,a)
  return a < b ? `${a}::${b}` : `${b}::${a}`
}

/**
 * Compute similarity between two strings using character trigrams
 * Results are cached for performance (LRU eviction when cache full)
 * 
 * @param a - First string
 * @param b - Second string
 * @returns Similarity score between 0.0 (no similarity) and 1.0 (identical)
 */
export function computeSimilarity(a: string, b: string): number {
  if (a === b) return 1.0
  if (!a || !b) return 0
  
  // Check cache first
  const cacheKey = getCacheKey(a, b)
  if (similarityCache.has(cacheKey)) {
    return similarityCache.get(cacheKey)!
  }

  // For very long strings, sample to keep performance reasonable
  const maxLen = 2000
  const sa = a.length > maxLen ? a.substring(0, maxLen) : a
  const sb = b.length > maxLen ? b.substring(0, maxLen) : b

  // Build trigram sets
  const trigramsA = new Set<string>()
  const trigramsB = new Set<string>()
  for (let i = 0; i < sa.length - 2; i++) trigramsA.add(sa.substring(i, i + 3))
  for (let i = 0; i < sb.length - 2; i++) trigramsB.add(sb.substring(i, i + 3))

  if (trigramsA.size === 0 || trigramsB.size === 0) return 0

  // Calculate Dice coefficient
  let intersection = 0
  for (const t of trigramsA) {
    if (trigramsB.has(t)) intersection++
  }

  const result = (2 * intersection) / (trigramsA.size + trigramsB.size)
  
  // Cache result with simple LRU eviction
  if (similarityCache.size >= MAX_CACHE_SIZE) {
    // Evict oldest entry (first key in insertion order)
    const firstKey = similarityCache.keys().next().value as string | undefined
    if (firstKey) similarityCache.delete(firstKey)
  }
  similarityCache.set(cacheKey, result)
  
  return result
}

/**
 * Clear the similarity cache (useful for testing or memory management)
 */
export function clearSimilarityCache(): void {
  similarityCache.clear()
}

/**
 * Get current cache statistics
 * @returns Cache size and max size
 */
export function getCacheStats(): { size: number; maxSize: number } {
  return {
    size: similarityCache.size,
    maxSize: MAX_CACHE_SIZE,
  }
}
