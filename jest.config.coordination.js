module.exports = {
  testEnvironment: "node",
  roots: ["<rootDir>/src/coordination"],
  testMatch: ["**/src/coordination/**/*.test.ts"],
  transform: {
    "^.+\\.ts$": ["ts-jest", {
      tsconfig: "tsconfig.json",
    }],
  },
  moduleFileExtensions: ["ts", "js", "json"],
  collectCoverageFrom: [
    "src/coordination/**/*.ts",
    "!src/coordination/**/*.test.ts",
    "!src/coordination/**/*.spec.ts",
  ],
  coverageDirectory: "coverage/coordination",
  verbose: true,
};
