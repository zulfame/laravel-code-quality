import js from '@eslint/js';
import globals from 'globals';

export default [
   js.configs.recommended,
   {
      languageOptions: {
         ecmaVersion: 'latest',
         sourceType: 'module',
         globals: {
            ...globals.browser,
            ...globals.es2021,
            // Laravel / Axios globals
            axios: 'readonly',
            route: 'readonly',
            // Alpine.js
            Alpine: 'readonly',
         },
      },
      rules: {
         // Mencegah bug umum
         'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
         'no-console': ['warn', { allow: ['warn', 'error'] }],
         'no-debugger': 'error',
         'no-duplicate-imports': 'error',
         'no-var': 'error',

         // Standar penulisan
         'prefer-const': 'warn',
         'prefer-arrow-callback': 'warn',
         'prefer-template': 'warn',
         eqeqeq: ['error', 'always', { null: 'ignore' }],
      },
   },
   {
      // Abaikan file build, vendor, dan config
      ignores: ['node_modules/**', 'vendor/**', 'public/build/**', 'public/assets/vendor/**', '*.min.js', 'bootstrap/app.php'],
   },
];
