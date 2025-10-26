module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/src/coordination/**/*.test.ts'],
  collectCoverageFrom: [
    'src/coordination/**/*.ts',
    '!src/coordination/**/*.test.ts',
    '!src/coordination/**/*.spec.ts'
  ],
  coverageDirectory: 'coverage/coordination',
  verbose: true
};

