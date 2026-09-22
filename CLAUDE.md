# CLAUDE.md

Context file for any AI agent (or human) picking up this repository cold. Read this
before touching `install.sh` or anything in `config/`.

## What this repo is

`laravel-code-quality` is **not a Laravel app**. It's an installer/baseline repo that
bolts a standard formatting + linting + CI toolchain onto an *existing* Laravel
project via `install.sh <path-to-laravel-project> [options]`. It copies files from
`config/` and `templates/` into the target project and patches the target's
`package.json`.

See `README.md` for the full user-facing documentation (installation, options,
customization). This file is about how the repo itself works and what to watch out
for when changing it — it deliberately doesn't repeat what's already in the README.

## Layout

```
config/           # Files copied as-is (or lightly templated) into the target project
  .editorconfig
  .prettierignore
  .prettierrc      # install.sh rewrites `plugins` / adds tailwindStylesheet based on detected stack
  eslint.config.js # the important one — see "eslint.config.js" below
  pint.json
templates/
  .github/workflows/code-quality.yml
  .husky/pre-commit
  .vscode/{settings,extensions}.json
install.sh          # the whole installer; bash, no external deps beyond node/composer/npm
README.md           # user docs
CHANGELOG.md         # what changed in the baseline and why
```

## `install.sh` in one paragraph

Takes a Laravel project path as its one positional arg, validates it has
`artisan`/`composer.json`/`package.json`, runs `composer require laravel/pint --dev`,
detects the frontend stack by reading the target's `package.json` deps (`vue`,
`react`, `svelte`, `typescript`, `tailwindcss` → falls back to plain `javascript`),
installs only the npm deps that stack needs, copies the `config/`+`templates/` files
(skipping ones that already exist unless `--force`), then patches `package.json`
scripts + `lint-staged` and sets up Husky. It's idempotent and safe to re-run.

When adding a new npm dependency that `eslint.config.js` needs, add it to
`BASE_NPM_DEPS` in `install.sh` (around line 160) — the config file assumes it's
already installed and does `optionalRequire()` for framework-specific plugins, but a
hard `import` (like `eslint-config-prettier`) must always be present.

## `eslint.config.js` — the file that actually matters here

This is a flat config that conditionally layers in Vue/React/Svelte support based on
what's installed in the target project (via `optionalRequire`, so the same file works
for a Blade-only project and a Vue+Inertia+TS project without erroring on a missing
package). Order in the `config` array matters — later entries override earlier ones
for the same files.

### Why it looks the way it does (fixed 2026-09-22)

Three real Prettier/ESLint conflicts were found by installing this baseline into
fresh Laravel starters (Vue, React, Svelte) and running `npm run lint` after
`npm run format`. All three are now fixed; **don't reintroduce them**:

1. **TypeScript inside `.vue` / `.svelte` files failed to parse at all.**
   `vue-eslint-parser` and `svelte-eslint-parser` default to `espree` for the
   `<script>` block unless you hand them a TS sub-parser. Without it, every SFC using
   `<script setup lang="ts">` or `<script lang="ts">` threw
   `Parsing error: Unexpected token`. Fix: `scriptParserOptions = { parserOptions: {
   parser: tseslint.parser } }`, merged into the `languageOptions` for `*.vue` and
   `*.svelte` files. Svelte 5 rune modules (`*.svelte.ts` / `*.svelte.js`) need this
   **again**, separately — `eslint-plugin-svelte`'s own base config also claims those
   files and points them at the parser with no sub-parser, and it runs *after* the
   generic TS block, so a second explicit block for `resources/**/*.svelte.{js,ts}`
   has to come after the Svelte push to win.

2. **Formatting-rule duplication between ESLint and Prettier.**
   `eslint-plugin-vue`'s and `eslint-plugin-react`'s recommended configs include
   stylistic rules (`vue/html-indent`, `vue/max-attributes-per-line`,
   `vue/singleline-html-element-content-newline`, etc.) that disagree with what
   Prettier already formats (this baseline uses 3-space indent). Fix: `eslint-config-prettier`
   pushed as the **last** entry in the config array — it already ships overrides for
   ESLint core + `vue/*` + `react/*` rules, so one dependency covers both frameworks.
   It does **not** cover `eslint-plugin-svelte`, which instead ships its own
   `flat/prettier` config — spread that in right after Svelte's `flat/recommended`.

3. **`no-duplicate-imports` flagged `prettier-plugin-organize-imports`'s own output.**
   That Prettier plugin splits a module's type-only and value imports into two
   statements when `isolatedModules`/`verbatimModuleSyntax` requires it, e.g.:
   ```ts
   import type { ClassValue } from 'clsx';
   import { clsx } from 'clsx';
   ```
   ESLint's core `no-duplicate-imports` rule saw two imports from `'clsx'` and
   errored. Fix: `'no-duplicate-imports': ['error', { allowSeparateTypeImports: true }]`.

### Rule of thumb for future conflicts

If ESLint complains about something Prettier just produced, it's almost always
either (a) a stylistic rule that belongs in `eslint-config-prettier`'s job, not a
custom override here, or (b) a rule that has a documented option for the exact
Prettier-plugin output causing it (like `allowSeparateTypeImports`). Prefer the
upstream "disable formatting rules" config over hand-picking individual rules to
turn off — it's what caught 39 vue/react rules and stayed in sync with the plugins.

## How to test a change to this repo

There is no test suite. Validate by actually installing into a real Laravel project
and running the three checks the README tells users to run:

```bash
./install.sh /path/to/some/laravel/project --force --no-github --no-vscode
cd /path/to/some/laravel/project
npm run format        # write mode first, so lint runs against realistic formatted code
npm run lint
./vendor/bin/pint --test
```

`--force` re-copies config even if the target already has it (needed when iterating).
`npm run format:check` should report zero issues after `npm run format`; if it
doesn't, something in `config/` — most often `eslint.config.js` itself — isn't
Prettier-formatted to this baseline's own rules (3-space indent, single quotes, etc).

**Gotcha (bit us once, 2026-09-22):** don't hand-format `eslint.config.js` by copying
it into one project, running `npx prettier --write`, and copying that back as the new
baseline, unless you're certain that project's copy already has every pending edit.
Doing this with a stale copy silently reverted the Svelte rune-module fix above. If
you need to reformat, format the copy you just edited directly, or run Prettier via
a project directory and diff the result against your intended source before copying
it back over `config/eslint.config.js`.

### Which stack exercises which part of the config

- **Blade / Livewire only** (no `vue`/`react`/`svelte` in `package.json`) exercises
  `install.sh`'s stack detection fallback and the base JS/TS block only — no
  framework-specific ESLint plugin gets installed or loaded.
- **Vue** exercises the `vue-eslint-parser` + TS sub-parser wiring and the
  `eslint-config-prettier` vue/* overrides.
- **React** exercises `eslint-plugin-react` + `eslint-plugin-react-hooks` (or
  `@eslint-react/eslint-plugin` on ESLint ≥10) and the `no-duplicate-imports` /
  `allowSeparateTypeImports` fix (React/Inertia starters lean heavily on
  `import type`).
- **Svelte** exercises `svelte-eslint-parser` + TS sub-parser wiring, the
  Svelte 5 rune-module (`*.svelte.ts`) double-fix, and `eslint-plugin-svelte`'s
  `flat/prettier` config.

Remaining lint output after a clean install (`no-unused-vars`, `@typescript-eslint/no-explicit-any`,
`vue/multi-word-component-names`, `vue/attributes-order`, `vue/require-default-prop`, ...)
is **expected** — those are real code-quality findings in the starter apps' own
source, not Prettier/ESLint conflicts, and are out of scope for this repo to silence.

## Language convention

Everything in this repo — code, comments, `README.md`, `CHANGELOG.md` — is written in
English so the tooling is usable outside an Indonesian-speaking team. Keep it that
way; don't reintroduce Indonesian text here even if the surrounding conversation is
in Indonesian.

## Out of scope / don't do this

- Don't edit the standard baseline to satisfy one specific downstream project's
  preferences (see README § "Project-Specific Configuration"). If a rule only makes
  sense for one stack, it belongs in that project's own `eslint.config.js` /
  `.prettierrc` after installation, not here.
- Don't silence legitimate ESLint findings (unused vars, `any`, Vue naming rules) to
  make a demo stack lint-clean — that's not what this repo is for.
- Don't add `--no-verify` / skip hooks to work around a failing `lint-staged` run;
  fix the underlying rule conflict instead (see the three fixes above for the
  pattern to follow).
