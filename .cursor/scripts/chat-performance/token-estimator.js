/**
 * Token Estimator
 *
 * Estimates token counts for chat transcripts using tiktoken-compatible encoding.
 * Supports GPT-4, Claude 3.5 Sonnet, and Claude 3 Opus models.
 *
 * @module token-estimator
 */

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

import { getEncoding } from "js-tiktoken";

/**
 * Load model configurations from models.json
 */
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const modelsData = JSON.parse(
  readFileSync(join(__dirname, "models.json"), "utf-8")
);
const MODEL_CONFIGS = modelsData.models;

/**
 * Fallback character-based estimation when tokenizer is unavailable
 * Rule of thumb: ~4 characters per token for English text
 */
function estimateByChars(text) {
  return Math.ceil(text.length / 4);
}

/**
 * Estimate token count for given text using specified model's encoding
 *
 * @param {string} text - Text to tokenize
 * @param {Object} [options] - Options
 * @param {string} [options.model='gpt-4'] - Model ID (e.g., 'gpt-4', 'claude-3-5-sonnet')
 * @returns {Object} Result with tokens, method, and model info
 *
 * @example
 * const result = estimateTokens("Hello world", { model: "gpt-4" });
 * // { tokens: 2, method: "tiktoken", model: "gpt-4", encoding: "cl100k_base" }
 */
export function estimateTokens(text, { model = "gpt-4" } = {}) {
  if (typeof text !== "string") {
    throw new TypeError("text must be a string");
  }

  const config = MODEL_CONFIGS[model];
  if (!config) {
    throw new Error(
      `Unsupported model: ${model}. Supported: ${Object.keys(
        MODEL_CONFIGS
      ).join(", ")}`
    );
  }

  try {
    // Use tiktoken for accurate estimation
    const encoder = getEncoding(config.encoding);
    const tokens = encoder.encode(text);
    const count = tokens.length;

    return {
      tokens: count,
      method: "tiktoken",
      model,
      encoding: config.encoding,
    };
  } catch (error) {
    // Fallback to character-based estimation
    const tokens = estimateByChars(text);
    return {
      tokens,
      method: "fallback-chars",
      model,
      encoding: "char-based",
      warning:
        "Tokenizer unavailable, using character-based estimation (±25% variance expected)",
    };
  }
}

/**
 * Get model configuration including context limits
 *
 * @param {string} model - Model ID
 * @returns {Object} Model configuration
 */
export function getModelConfig(model) {
  const config = MODEL_CONFIGS[model];
  if (!config) {
    throw new Error(`Unsupported model: ${model}`);
  }
  return { ...config, model };
}

/**
 * List all supported models
 *
 * @returns {string[]} Array of supported model IDs
 */
export function getSupportedModels() {
  return Object.keys(MODEL_CONFIGS);
}
