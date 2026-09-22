# Changelog

## Unreleased

- Updated `install.sh` to accept the Laravel project path as a positional argument.
- Added support for `./install.sh <project-path> [options]`.
- Updated README installation examples to match the installer.
- Preserved the source project's formatter, linter, Git Hook, VS Code, and CI baseline.
- Fixed Prettier/ESLint rule conflicts in `eslint.config.js`, verified against fresh
  Blade, Livewire, Vue, React, and Svelte Laravel starters:
  - `.vue` and `.svelte` files written with `<script setup lang="ts">` / `<script lang="ts">`
    (including Svelte 5 `*.svelte.ts` rune modules) now wire `typescript-eslint`'s parser
    into `vue-eslint-parser` / `svelte-eslint-parser`. Previously ESLint fell back to
    `espree` on every TS-flavored SFC and failed with `Parsing error: Unexpected token`.
  - Added `eslint-config-prettier` as a new dependency and appended it as the last entry
    in the flat config so it can turn off ESLint core, Vue, and React stylistic rules
    (`vue/html-indent`, `vue/max-attributes-per-line`, `vue/singleline-html-element-content-newline`,
    etc.) that duplicated and disagreed with what Prettier already formats.
  - Spread `eslint-plugin-svelte`'s bundled `flat/prettier` config (`svelte/indent`,
    `svelte/html-quotes`, `svelte/max-attributes-per-line`, ...) since
    `eslint-config-prettier` does not cover the Svelte plugin.
  - `no-duplicate-imports` now sets `allowSeparateTypeImports: true`, so the type/value
    import split produced by `prettier-plugin-organize-imports` under `isolatedModules`
    (e.g. `import type { X } from 'y'` + `import { y } from 'y'`) no longer fails lint.
