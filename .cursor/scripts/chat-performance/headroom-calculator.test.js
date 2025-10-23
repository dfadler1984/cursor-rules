/**
 * Tests for headroom-calculator.js
 */

import { test } from "node:test";
import assert from "node:assert";
import {
  computeHeadroom,
  getRecommendation,
  formatHeadroomText,
} from "./headroom-calculator.js";

test("computeHeadroom - ok status (>20% headroom)", () => {
  const result = computeHeadroom({
    estimatedTokens: 1000,
    model: "gpt-4",
    plannedCompletion: 500,
    bufferPct: 10,
  });

  assert.strictEqual(result.status, "ok");
  assert.ok(result.headroom > 0);
  assert.ok(result.headroomPct > 0.2);
  assert.strictEqual(result.recommendation, "Headroom sufficient; continue");
  assert.strictEqual(result.model, "gpt-4");
});

test("computeHeadroom - warning status (10-20% headroom)", () => {
  // gpt-4 has 8192 max context
  // Need 10-20% headroom: 819-1638 tokens remaining
  // Set up: maxContext=8192, want ~15% headroom (1229 tokens)
  // headroom = 8192 - (tokens + planned + buffer)
  // 1229 = 8192 - (tokens + 500 + 819)
  // tokens = 8192 - 500 - 819 - 1229 = 5644
  const result = computeHeadroom({
    estimatedTokens: 5644,
    model: "gpt-4",
    plannedCompletion: 500,
    bufferPct: 10,
  });

  assert.strictEqual(result.status, "warning");
  assert.ok(result.headroomPct > 0.1);
  assert.ok(result.headroomPct <= 0.2);
  assert.strictEqual(
    result.recommendation,
    "Approaching limit; consider summarizing or narrowing scope"
  );
});

test("computeHeadroom - critical status (<10% headroom)", () => {
  // gpt-4 has 8192 max context
  // Want <10% headroom: <819 tokens
  // Set up: want ~5% headroom (410 tokens)
  // 410 = 8192 - (tokens + 500 + 819)
  // tokens = 8192 - 500 - 819 - 410 = 6463
  const result = computeHeadroom({
    estimatedTokens: 6463,
    model: "gpt-4",
    plannedCompletion: 500,
    bufferPct: 10,
  });

  assert.strictEqual(result.status, "critical");
  assert.ok(result.headroomPct <= 0.1);
  assert.strictEqual(
    result.recommendation,
    "Low headroom; recommend starting new chat"
  );
});

test("computeHeadroom - different models", () => {
  const gpt4Result = computeHeadroom({
    estimatedTokens: 1000,
    model: "gpt-4",
  });

  const gpt4TurboResult = computeHeadroom({
    estimatedTokens: 1000,
    model: "gpt-4-turbo",
  });

  assert.ok(
    gpt4TurboResult.headroom > gpt4Result.headroom,
    "GPT-4 Turbo should have more headroom than GPT-4 for same tokens"
  );
  assert.strictEqual(gpt4Result.model, "gpt-4");
  assert.strictEqual(gpt4TurboResult.model, "gpt-4-turbo");
});

test("computeHeadroom - custom buffer percentage", () => {
  const result5 = computeHeadroom({
    estimatedTokens: 1000,
    model: "gpt-4",
    bufferPct: 5,
  });

  const result15 = computeHeadroom({
    estimatedTokens: 1000,
    model: "gpt-4",
    bufferPct: 15,
  });

  assert.ok(
    result5.headroom > result15.headroom,
    "Lower buffer should yield more headroom"
  );
  assert.strictEqual(result5.breakdown.bufferPct, 5);
  assert.strictEqual(result15.breakdown.bufferPct, 15);
});

test("computeHeadroom - zero estimated tokens", () => {
  const result = computeHeadroom({
    estimatedTokens: 0,
    model: "gpt-4",
  });

  assert.ok(result.headroom > 0);
  assert.strictEqual(result.status, "ok");
});

test("computeHeadroom - breakdown accuracy", () => {
  const result = computeHeadroom({
    estimatedTokens: 3000,
    model: "gpt-4",
    plannedCompletion: 1000,
    bufferPct: 10,
  });

  const expectedUsed = 3000 + 1000 + result.breakdown.bufferTokens;
  assert.strictEqual(result.breakdown.used, expectedUsed);
  assert.strictEqual(
    result.headroom,
    result.breakdown.maxContext - expectedUsed
  );
});

test("computeHeadroom - invalid estimatedTokens throws", () => {
  assert.throws(
    () =>
      computeHeadroom({
        estimatedTokens: -100,
        model: "gpt-4",
      }),
    TypeError
  );

  assert.throws(
    () =>
      computeHeadroom({
        estimatedTokens: "not a number",
        model: "gpt-4",
      }),
    TypeError
  );
});

test("computeHeadroom - invalid bufferPct throws", () => {
  assert.throws(
    () =>
      computeHeadroom({
        estimatedTokens: 1000,
        model: "gpt-4",
        bufferPct: -5,
      }),
    TypeError
  );

  assert.throws(
    () =>
      computeHeadroom({
        estimatedTokens: 1000,
        model: "gpt-4",
        bufferPct: 150,
      }),
    TypeError
  );
});

test("computeHeadroom - unsupported model throws", () => {
  assert.throws(
    () =>
      computeHeadroom({
        estimatedTokens: 1000,
        model: "invalid-model",
      }),
    /Unsupported model/
  );
});

test("getRecommendation - returns correct text", () => {
  assert.strictEqual(getRecommendation("ok"), "Headroom sufficient; continue");
  assert.strictEqual(
    getRecommendation("warning"),
    "Approaching limit; consider summarizing or narrowing scope"
  );
  assert.strictEqual(
    getRecommendation("critical"),
    "Low headroom; recommend starting new chat"
  );
});

test("getRecommendation - unknown status throws", () => {
  assert.throws(() => getRecommendation("unknown"), /Unknown status/);
});

test("formatHeadroomText - produces readable output", () => {
  const result = computeHeadroom({
    estimatedTokens: 1000,
    model: "gpt-4",
    plannedCompletion: 500,
    bufferPct: 10,
  });

  const formatted = formatHeadroomText(result);

  assert.ok(formatted.includes("Headroom:"));
  assert.ok(formatted.includes("Status:"));
  assert.ok(formatted.includes("Recommendation:"));
  assert.ok(formatted.includes("Breakdown:"));
  assert.ok(formatted.includes("Max context:"));
});
