import js from '@eslint/js';
import prettierConfig from 'eslint-config-prettier';
import i18next from 'eslint-plugin-i18next';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import globals from 'globals';
import tseslint from 'typescript-eslint';

/**
 * `features/<a>` → `features/<b>` importi taqiqlanadi (fe-conventions §2).
 * Ulashiladigan kod `components/` yoki `lib/` ga chiqariladi.
 */
const FEATURES = [
  'auth',
  'audit',
  'chat',
  'dashboard',
  'dvir',
  'fleet',
  'logs',
  'maintenance',
  'reports',
  'routes',
  'settings',
  'support',
  'tracking',
];

const CROSS_FEATURE_MESSAGE =
  'Cross-feature import is forbidden. Move shared code to src/components or src/lib.';

const DATE_FNS_LOCALE_RULE = {
  name: 'date-fns/locale',
  message: 'Import a single locale (e.g. date-fns/locale/en-US) — the barrel bundles all of them.',
};

const featureIsolationConfigs = FEATURES.map((feature) => ({
  files: [`src/features/${feature}/**/*.{ts,tsx}`],
  rules: {
    'no-restricted-imports': [
      'error',
      {
        paths: [DATE_FNS_LOCALE_RULE],
        patterns: [
          {
            group: [
              '@/features/*',
              `!@/features/${feature}`,
              `!@/features/${feature}/**`,
              '../../*/**',
            ],
            message: CROSS_FEATURE_MESSAGE,
          },
        ],
      },
    ],
  },
}));

export default tseslint.config(
  {
    ignores: [
      'dist',
      'coverage',
      'playwright-report',
      'test-results',
      'node_modules',
      'src/api/schema.d.ts',
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      ecmaVersion: 2022,
      globals: { ...globals.browser, ...globals.es2022 },
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    plugins: {
      react,
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
      'jsx-a11y': jsxA11y,
      i18next,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      ...jsxA11y.flatConfigs.recommended.rules,

      // XSS darvozasi (fe-security F210): `dangerouslySetInnerHTML` hozircha
      // ishlatilmagan — bu qoida uni tasodifan qo'shilishidan himoya qiladi.
      'react/no-danger': 'error',

      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
      ],
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      'react-hooks/exhaustive-deps': 'error',
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],

      // Bosqich 1 dan keyin 'error' ga ko'tarildi (fe-conventions §4, i18n-keeper).
      'i18next/no-literal-string': ['error', { markupOnly: true, onlyAttribute: [] }],

      'no-restricted-imports': [
        'error',
        {
          paths: [DATE_FNS_LOCALE_RULE],
          patterns: [
            {
              group: ['../../*/**'],
              message: 'Use the @/ alias instead of deep relative imports.',
            },
          ],
        },
      ],
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      eqeqeq: ['error', 'smart'],
    },
  },
  ...featureIsolationConfigs,
  {
    // Konfiguratsiya va Node skriptlari
    files: ['*.{js,ts}', 'scripts/**/*.{js,mjs}', 'e2e/**/*.ts'],
    languageOptions: {
      globals: { ...globals.node },
    },
    rules: {
      'no-console': 'off',
      'i18next/no-literal-string': 'off',
    },
  },
  {
    files: ['**/*.{test,spec}.{ts,tsx}', 'vitest.setup.ts'],
    rules: {
      'i18next/no-literal-string': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
    },
  },
  {
    files: ['**/*.{js,mjs,cjs}'],
    ...tseslint.configs.disableTypeChecked,
  },
  prettierConfig,
);
