/**
 * Strategy module exports
 * Re-exports all strategy functions for convenient importing
 */

export { findDuplicates, findFuzzyDuplicates } from "./deduplication.js"
export { findSupersededWrites } from "./supersede.js"
export { findPurgeableErrors } from "./error-purge.js"
export { findSmartCompressible, generateSmartSummary } from "./smart-compression.js"
