// jest.config.js

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      tsconfig: './tsconfig.json',
      diagnostics: false
    }]
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testMatch: ['**/__tests__/**/*.(ts|tsx|js)', '**/?(*.)+(spec|test).(ts|tsx|js)'],
  moduleNameMapper: {
    '^@streamingappazure/shared-auth/(.*)$': '<rootDir>/libs/shared-auth/src/$1',
    '^@streamingappazure/shared-json/(.*)$': '<rootDir>/libs/shared-json/src/$1',
  }
};
