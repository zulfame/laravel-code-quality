import js from '@eslint/js';
import eslintConfigPrettier from 'eslint-config-prettier';
import { defineConfig } from 'eslint/config';
import globals from 'globals';
import { createRequire } from 'node:module';
import tseslint from 'typescript-eslint';

const require = createRequire(import.meta.url);

function optionalRequire(name) {
   try {
      return require(name);
   } catch {
      return null;
   }
}

const react = optionalRequire('eslint-plugin-react');
const reactHooks = optionalRequire('eslint-plugin-react-hooks');
const reactModern = optionalRequire('@eslint-react/eslint-plugin');
const svelte = optionalRequire('eslint-plugin-svelte');
const vue = optionalRequire('eslint-plugin-vue');

// Vue and Svelte SFCs written with `<script setup lang="ts">` / `<script lang="ts">`
// need the TypeScript parser explicitly wired into the block parser, otherwise
// vue-eslint-parser / svelte-eslint-parser fall back to espree and fail on TS syntax.
const scriptParserOptions = { parserOptions: { parser: tseslint.parser } };

const browserGlobals = {
   ...globals.browser,
   ...globals.es2021,
   axios: 'readonly',
   route: 'readonly',
   Alpine: 'readonly',
};

const config = [
   {
      ignores: [
         'node_modules/**',
         'vendor/**',
         'public/build/**',
         'public/assets/vendor/**',
         'storage/**',
         'bootstrap/cache/**',
         '*.min.js',
         'bootstrap/app.php',
      ],
   },

   {
      files: ['resources/**/*.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
      extends: [js.configs.recommended, ...tseslint.configs.recommended],
      languageOptions: {
         ecmaVersion: 'latest',
         sourceType: 'module',
         globals: browserGlobals,
         parserOptions: {
            ecmaFeatures: { jsx: true },
         },
      },
      rules: {
         'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
         'no-console': ['warn', { allow: ['warn', 'error'] }],
         'no-debugger': 'error',
         // `allowSeparateTypeImports` avoids false positives when
         // prettier-plugin-organize-imports splits a module's type-only and
         // value imports into two statements (required under isolatedModules).
         'no-duplicate-imports': ['error', { allowSeparateTypeImports: true }],
         'no-var': 'error',
         'prefer-const': 'warn',
         'prefer-arrow-callback': 'warn',
         'prefer-template': 'warn',
         eqeqeq: ['error', 'always', { null: 'ignore' }],
      },
   },
];

// React / Inertia React. The classic plugin is used where its peer range permits it;
// ESLint 10 projects can use @eslint-react/eslint-plugin instead.
if (react) {
   config.push(
      {
         files: ['resources/**/*.{jsx,tsx}'],
         ...react.configs.flat.recommended,
         settings: { react: { version: 'detect' } },
      },
      {
         files: ['resources/**/*.{jsx,tsx}'],
         ...react.configs.flat['jsx-runtime'],
      }
   );
}

if (reactHooks) {
   config.push({
      files: ['resources/**/*.{jsx,tsx}'],
      plugins: { 'react-hooks': reactHooks },
      rules: {
         ...(reactHooks.configs.flat?.recommended?.rules ?? {}),
      },
   });
}

if (reactModern) {
   const recommended = reactModern.configs?.recommended;
   if (recommended) {
      const entries = Array.isArray(recommended) ? recommended : [recommended];
      config.push(
         ...entries.map((entry) => ({
            ...entry,
            files: entry.files ?? ['resources/**/*.{jsx,tsx}'],
         }))
      );
   }
}

// Vue / Inertia Vue.
if (vue) {
   config.push(
      ...vue.configs['flat/recommended'].map((entry) => ({
         ...entry,
         files: entry.files ?? ['resources/**/*.vue'],
      })),
      {
         files: ['resources/**/*.vue'],
         languageOptions: { globals: browserGlobals, ...scriptParserOptions },
      }
   );
}

// Svelte.
if (svelte) {
   config.push(
      ...svelte.configs['flat/recommended'].map((entry) => ({
         ...entry,
         files: entry.files ?? ['resources/**/*.svelte'],
      })),
      // Turns off svelte/* stylistic rules (indent, quotes, attribute wrapping, ...)
      // that duplicate and disagree with prettier-plugin-svelte's output.
      ...(svelte.configs['flat/prettier'] ?? []).map((entry) => ({
         ...entry,
         files: entry.files ?? ['resources/**/*.svelte'],
      })),
      {
         files: ['resources/**/*.svelte'],
         languageOptions: { globals: browserGlobals, ...scriptParserOptions },
      },
      // eslint-plugin-svelte's own base config also claims *.svelte.js / *.svelte.ts
      // (Svelte 5 rune modules) and points them at svelte-eslint-parser without a
      // TS sub-parser; re-assert it here since this runs after that base config.
      {
         files: ['resources/**/*.svelte.{js,ts}'],
         languageOptions: { globals: browserGlobals, ...scriptParserOptions },
      }
   );
}

// Turns off ESLint core + react/vue stylistic rules that duplicate or disagree
// with what Prettier already formats (indentation, quotes, spacing, wrapping).
// Must stay last so it overrides the framework configs pushed above.
config.push({
   ...eslintConfigPrettier,
   name: 'code-quality/prettier-compat',
});

export default defineConfig(config);
