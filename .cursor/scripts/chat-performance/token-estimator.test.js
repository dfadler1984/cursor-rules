/**
 * Tests for token-estimator.js
 */

import { test } from "node:test";
import assert from "node:assert";
import {
  estimateTokens,
  getModelConfig,
  getSupportedModels,
} from "./token-estimator.js";

test("estimateTokens - basic functionality", () => {
  const result = estimateTokens("Hello world", { model: "gpt-4" });

  assert.ok(result.tokens > 0, "Should return positive token count");
  assert.ok(
    ["tiktoken", "fallback-chars"].includes(result.method),
    "Should use valid method"
  );
  assert.strictEqual(result.model, "gpt-4");
});

test("estimateTokens - longer text", () => {
  const text =
    "This is a longer piece of text that should be tokenized. ".repeat(10);
  const result = estimateTokens(text, { model: "gpt-4" });

  assert.ok(
    result.tokens > 10,
    "Should return reasonable token count for longer text"
  );
});

test("estimateTokens - different models", () => {
  const text = "Test tokenization";

  const gpt4Result = estimateTokens(text, { model: "gpt-4" });
  const claudeResult = estimateTokens(text, { model: "claude-3-5-sonnet" });

  assert.ok(gpt4Result.tokens > 0);
  assert.ok(claudeResult.tokens > 0);
  assert.strictEqual(gpt4Result.model, "gpt-4");
  assert.strictEqual(claudeResult.model, "claude-3-5-sonnet");
});

test("estimateTokens - empty string", () => {
  const result = estimateTokens("", { model: "gpt-4" });
  assert.strictEqual(result.tokens, 0);
});

test("estimateTokens - unsupported model throws", () => {
  assert.throws(
    () => estimateTokens("test", { model: "invalid-model" }),
    /Unsupported model/
  );
});

test("estimateTokens - non-string input throws", () => {
  // @ts-expect-error - Testing invalid input type
  assert.throws(() => estimateTokens(123, { model: "gpt-4" }), TypeError);
});

test("getModelConfig - returns config for valid model", () => {
  const config = getModelConfig("gpt-4");

  assert.strictEqual(config.model, "gpt-4");
  assert.strictEqual(config.encoding, "cl100k_base");
  assert.strictEqual(config.maxContext, 8192);
  assert.strictEqual(config.maxOutput, 4096);
});

test("getModelConfig - throws for invalid model", () => {
  assert.throws(() => getModelConfig("invalid"), /Unsupported model/);
});

test("getSupportedModels - returns array of models", () => {
  const models = getSupportedModels();

  assert.ok(Array.isArray(models));
  assert.ok(models.length > 0);
  assert.ok(models.includes("gpt-4"));
  assert.ok(models.includes("claude-3-5-sonnet"));
});

test("estimateTokens - consistency check", () => {
  const text = "Consistent tokenization test";

  const result1 = estimateTokens(text, { model: "gpt-4" });
  const result2 = estimateTokens(text, { model: "gpt-4" });

  assert.strictEqual(
    result1.tokens,
    result2.tokens,
    "Should return same token count for same input"
  );
});
