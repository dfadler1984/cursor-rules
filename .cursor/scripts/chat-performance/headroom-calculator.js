/**
 * Headroom Calculator
 *
 * Calculates remaining token capacity (headroom) for chat contexts.
 * Formula: headroom = max_context - (estimated_tokens + planned_completion + buffer)
 *
 * @module headroom-calculator
 */

import { getModelConfig } from "./token-estimator.js";

/**
 * Status thresholds for headroom assessment
 */
const STATUS_THRESHOLDS = {
  ok: 0.2, // >20% headroom
  warning: 0.1, // 10-20% headroom
  critical: 0.1, // <10% headroom
};

/**
 * Compute headroom for a chat context
 *
 * @param {Object} params - Parameters
 * @param {number} params.estimatedTokens - Current estimated token count
 * @param {string} params.model - Model ID
 * @param {number} [params.plannedCompletion=2000] - Expected completion tokens
 * @param {number} [params.bufferPct=10] - Safety buffer percentage (0-100)
 * @returns {Object} Headroom calculation result
 *
 * @example
 * const result = computeHeadroom({
 *   estimatedTokens: 32500,
 *   model: "gpt-4-turbo",
 *   plannedCompletion: 2000,
 *   bufferPct: 10
 * });
 * // {
 * //   headroom: 80700,
 * //   headroomPct: 0.63,
 * //   status: "ok",
 * //   recommendation: "Headroom sufficient; continue",
 * //   ...
 * // }
 */
export function computeHeadroom({
  estimatedTokens,
  model,
  plannedCompletion = 2000,
  bufferPct = 10,
}) {
  if (typeof estimatedTokens !== "number" || estimatedTokens < 0) {
    throw new TypeError("estimatedTokens must be a non-negative number");
  }
  if (typeof plannedCompletion !== "number" || plannedCompletion < 0) {
    throw new TypeError("plannedCompletion must be a non-negative number");
  }
  if (typeof bufferPct !== "number" || bufferPct < 0 || bufferPct > 100) {
    throw new TypeError("bufferPct must be a number between 0 and 100");
  }

  const config = getModelConfig(model);
  const maxContext = config.maxContext;
  const bufferTokens = Math.ceil((maxContext * bufferPct) / 100);

  const used = estimatedTokens + plannedCompletion + bufferTokens;
  const headroom = maxContext - used;
  const headroomPct = headroom / maxContext;

  // Determine status
  let status;
  let recommendation;
  if (headroomPct > STATUS_THRESHOLDS.ok) {
    status = "ok";
    recommendation = "Headroom sufficient; continue";
  } else if (headroomPct > STATUS_THRESHOLDS.warning) {
    status = "warning";
    recommendation =
      "Approaching limit; consider summarizing or narrowing scope";
  } else {
    status = "critical";
    recommendation = "Low headroom; recommend starting new chat";
  }

  return {
    headroom,
    headroomPct,
    status,
    recommendation,
    breakdown: {
      maxContext,
      estimatedTokens,
      plannedCompletion,
      bufferTokens,
      bufferPct,
      used,
    },
    model,
  };
}

/**
 * Get recommendation text based on status
 *
 * @param {string} status - Status level (ok, warning, critical)
 * @returns {string} Recommendation text
 */
export function getRecommendation(status) {
  switch (status) {
    case "ok":
      return "Headroom sufficient; continue";
    case "warning":
      return "Approaching limit; consider summarizing or narrowing scope";
    case "critical":
      return "Low headroom; recommend starting new chat";
    default:
      throw new Error(`Unknown status: ${status}`);
  }
}

/**
 * Format headroom result as human-readable text
 *
 * @param {Object} result - Result from computeHeadroom
 * @returns {string} Formatted text
 */
export function formatHeadroomText(result) {
  const pctStr = (result.headroomPct * 100).toFixed(1);
  return [
    `Headroom: ${result.headroom} tokens (${pctStr}%)`,
    `Status: ${result.status}`,
    `Recommendation: ${result.recommendation}`,
    ``,
    `Breakdown:`,
    `  Max context: ${result.breakdown.maxContext}`,
    `  Current estimate: ${result.breakdown.estimatedTokens}`,
    `  Planned completion: ${result.breakdown.plannedCompletion}`,
    `  Safety buffer (${result.breakdown.bufferPct}%): ${result.breakdown.bufferTokens}`,
    `  Total used: ${result.breakdown.used}`,
  ].join("\n");
}
