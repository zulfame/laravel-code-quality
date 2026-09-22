# Laravel Code Quality

Baseline **Code Formatter, Linter, Git Hook, VS Code, and GitHub Actions** for Laravel projects.

This repository is designed as **standard development tooling** that can be applied to an existing Laravel project via `install.sh`.

> **Principle:** this repository provides a consistent baseline, not a locked-down configuration. After installation, each project remains free to adjust the rules as needed.

---

## ✨ What's Included

| Tool                    | Role                                                                      |
| ----------------------- | -------------------------------------------------------------------------- |
| **Prettier**            | Formats Blade, Vue, React, JS/TS, CSS, Tailwind, JSON, YAML, and Markdown |
| **Laravel Pint**        | Formats PHP using the Laravel / PSR-12 standard via `pint.json`           |
| **ESLint**              | Detects bugs and logic errors in JavaScript, TypeScript, React, Vue, and Svelte |
| **Husky + lint-staged** | Runs the formatter and linter only on staged files                        |
| **GitHub Actions**      | Validates formatting and linting on push / pull request                   |
| **VS Code**             | Format On Save and recommended extensions                                 |
| **EditorConfig**        | Keeps basic editor rules consistent across developers                     |

---

# 🚀 Installation

The installer accepts the **Laravel project path as an argument**. The `laravel-code-quality` repository does not need to live inside the Laravel project being installed into.

### 1. Clone the repository

```bash
git clone https://github.com/zulfame/laravel-code-quality.git
```

### 2. Run the installer

For example, if the Laravel project lives at:

```text
/Users/username/Projects/laravel12
```

Run:

```bash
./laravel-code-quality/install.sh /Users/username/Projects/laravel12
```

If you are already inside the `laravel-code-quality` repository directory:

```bash
cd laravel-code-quality
./install.sh /Users/username/Projects/laravel12
```

If the repository and the Laravel project sit side by side:

```text
Projects/
├── laravel-code-quality/
└── laravel12/
```

run:

```bash
cd laravel-code-quality
./install.sh ../laravel12
```

### 3. Follow the installation result

The installer checks the target project, installs dependencies, then applies the configuration.

The overall process is:

```text
Validate Laravel Project
        ↓
Install Laravel Pint
        ↓
Install NPM Dependencies
        ↓
Install Code Quality Configuration
        ↓
Configure package.json
        ↓
Configure Husky
        ↓
Configure VS Code
        ↓
Configure GitHub Actions
        ↓
Done
```

The installer **already runs the NPM dependency install**. You **do not need to run `npm install` again** after the process finishes.

---

# 🧪 Verify the Installation

Once the installer finishes, switch to the target Laravel project:

```bash
cd /Users/username/Projects/laravel12
```

Then run the following checks:

```bash
npm run format:check
npm run lint
./vendor/bin/pint --test
```

If all three succeed, the Code Quality baseline is installed correctly.

To test the Git Hook, change a file and then:

```bash
git add .
git commit -m "test: code quality"
```

Husky will run:

```bash
npx lint-staged
```

and will only process the files being committed.

---

# ⚙️ Installer Options

Options are **optional** and used when running the installer. For normal use, you don't need any option at all.

### Default

```bash
./install.sh /path/to/laravel-project
```

The installer **does not overwrite existing configuration files**.

This is the recommended mode for projects that are already up and running.

### `--force`

```bash
./install.sh /path/to/laravel-project --force
```

Overwrites existing Code Quality configuration.

Use this if you actually want to re-align the project's configuration with this repository's baseline.

> **Warning:** manually made project configuration changes may be overwritten.

### `--no-vscode`

```bash
./install.sh /path/to/laravel-project --no-vscode
```

Does not install:

```text
.vscode/settings.json
.vscode/extensions.json
```

Use this if the team doesn't use VS Code or the project doesn't want to keep workspace configuration.

### `--no-github`

```bash
./install.sh /path/to/laravel-project --no-github
```

Does not install:

```text
.github/workflows/code-quality.yml
```

Use this if CI is managed through another platform or workflow.

### Combining options

Options can be used together:

```bash
./install.sh /path/to/laravel-project --force --no-vscode --no-github
```

### Help

```bash
./install.sh --help
```

---

# 📋 Quick Commands

After installation:

| Command                    | Function                                        |
| --------------------------- | ------------------------------------------------ |
| `npm run format`           | Automatically formats files managed by Prettier |
| `npm run format:check`     | Checks formatting without changing files        |
| `npm run lint`              | Runs ESLint on the frontend source in `resources/` |
| `npm run lint:fix`         | Fixes ESLint findings that can be auto-fixed    |
| `./vendor/bin/pint`        | Automatically formats PHP files                 |
| `./vendor/bin/pint --test` | Checks PHP formatting without changing files    |

### Everyday workflow

For normal work, developers don't need to run every command manually.

```text
Edit Code
   ↓
Save
   ↓
VS Code Format On Save
   ↓
git add
   ↓
git commit
   ↓
Husky
   ↓
lint-staged
   ↓
Prettier / ESLint / Pint
```

Use the manual commands mainly when:

- checking before a commit;
- fixing formatting across the whole project;
- troubleshooting;
- validating CI locally.

---

# 📦 Supported Languages & Formats

### Blade & Livewire

Files:

```text
*.blade.php
```

Formatted using `@shufo/prettier-plugin-blade`, including:

- Blade directives such as `@if`, `@foreach`, `@extends`, and `@yield`;
- Blade components;
- Livewire components;
- `wire:model`;
- `wire:click`;
- `wire:loading`;
- `@php`.

### Tailwind CSS

Tailwind class sorting is handled by:

```text
prettier-plugin-tailwindcss
```

### Laravel Frontend: Vue, React, and Svelte

ESLint supports the following Laravel frontend sources:

```text
*.js
*.ts
*.jsx
*.tsx
*.vue
*.svelte
```

Supported stacks:

- Vue 3 / Inertia Vue via `eslint-plugin-vue`;
- React / Inertia React via `eslint-plugin-react` and `eslint-plugin-react-hooks`;
- Svelte via `eslint-plugin-svelte`;
- JavaScript and TypeScript via ESLint + `typescript-eslint`.

Prettier also handles formatting for Vue, React/JSX, and Svelte.

`<script setup lang="ts">` / `<script lang="ts">` blocks in `.vue` and `.svelte`
files — including Svelte 5 `*.svelte.ts` rune modules — are parsed with the
`typescript-eslint` parser, so TypeScript syntax inside single-file components
lints correctly instead of failing with a parsing error.

`eslint-config-prettier` is appended as the last entry in `eslint.config.js` so
that ESLint's own formatting-related rules (indentation, attribute wrapping,
quote style, etc. from ESLint core, `eslint-plugin-vue`, and `eslint-plugin-react`)
never disagree with what Prettier already formats. `eslint-plugin-svelte`'s
bundled `flat/prettier` config does the same job for `svelte/*` rules.

> **Note:** Blade and Livewire are not an ESLint target. `*.blade.php` files and
> Livewire's Blade-based components are formatted with Prettier +
> `@shufo/prettier-plugin-blade`, while PHP is still validated using Laravel Pint.

### JavaScript & TypeScript

Supported:

```text
*.js
*.ts
```

Baseline formatter:

- 3 spaces;
- single quotes;
- semicolons;
- trailing comma `es5`;
- print width 140.

Imports are auto-organized by `prettier-plugin-organize-imports`, which may
split a module's type-only and value imports into two statements under
`isolatedModules` (e.g. `import type { X } from 'y'` followed by
`import { y } from 'y'`). ESLint's `no-duplicate-imports` rule is configured
with `allowSeparateTypeImports: true` so this pattern is not flagged as an error.

### Data & Configuration

Supported:

```text
*.json
*.yml
*.yaml
*.md
```

YAML uses 2-space indentation.

### PHP

Files:

```text
*.php
```

Managed by **Laravel Pint** via:

```text
pint.json
```

---

# ⚠️ JavaScript Inside Blade

Prettier Blade works with the Blade parser. Because of that, JavaScript written directly in Blade needs to follow a few rules so Blade data doesn't produce invalid JavaScript.

## 1. Use `@js()` to Send Data from Blade

Avoid:

```blade
const user = JSON.parse('{{ json_encode($user) }}');
const token = "{{ csrf_token() }}";
```

Use Laravel's official directive:

```blade
<script>
   const user = @js($user);
   const token = @js(csrf_token());
   const apiUrl = @js(route('dashboard'));
</script>
```

## 2. Use `prettier-ignore` for Complex Scripts

If a `<script>` block mixes many Blade directives and shouldn't be touched by Prettier:

```blade
{{-- prettier-ignore --}}
<script>
   // This entire block will not be formatted by Prettier.
   const myCustomConfig = { ... };
</script>
```

Use this exception only when it's actually needed.

## 3. Move JavaScript to `resources/js/`

For more complex JavaScript, it's better to use a separate JavaScript file bundled via Vite.

Example:

```blade
<div
   id="app-data"
   data-user='@json($user)'
   data-endpoint="{{ route('api.save') }}"
></div>
```

Then:

```javascript
const el = document.getElementById("app-data");
const user = JSON.parse(el.dataset.user);
const endpoint = el.dataset.endpoint;
```

## 4. Alpine.js Events in Blade

If you run into parsing or formatting conflicts with the Blade parser, use:

```blade
x-on:click="..."
```

instead of:

```blade
@click="..."
```

---

# 💻 VS Code Integration

The installer can install:

```text
.vscode/settings.json
.vscode/extensions.json
```

## Format On Save

The workspace uses:

```json
"editor.formatOnSave": true
```

File types formatted with Prettier include:

- Blade;
- JavaScript;
- CSS;
- JSON;
- Vue.

Default indentation:

```text
3 spaces
```

## Recommended Extensions

VS Code will recommend:

- Prettier;
- Tailwind CSS IntelliSense;
- Laravel Blade;
- ESLint.

If you use a different editor, `.editorconfig` can still be used as a baseline.

---

# 🪝 Husky + lint-staged

Husky runs:

```bash
npx lint-staged
```

when a developer runs:

```bash
git commit
```

`lint-staged` configuration:

| File                                                  | Tool              |
| ------------------------------------------------------ | ----------------- |
| `*.js`, `*.ts`, `*.jsx`, `*.tsx`, `*.vue`, `*.svelte` | ESLint + Prettier |
| `*.blade.php`                                         | Prettier          |
| `*.css`, `*.json`, `*.yml`, `*.yaml`, `*.md`          | Prettier          |
| `*.php`                                                | Laravel Pint      |

With this approach, only the files being committed are processed.

---

# 🤖 GitHub Actions

The installer installs:

```text
.github/workflows/code-quality.yml
```

The workflow runs the following checks:

### Prettier

```bash
npm run format:check
```

### ESLint

```bash
npm run lint
```

### Laravel Pint

```bash
./vendor/bin/pint --test
```

The workflow can run on:

- push;
- pull request.

GitHub Actions acts as an **additional quality gate** after local validation and the Git Hook.

---

# 🔧 Customization

Files installed by the installer become **property of the target project**.

After installation, developers are free to adjust the rules as the project needs.

Main files:

```text
.editorconfig
.prettierignore
.prettierrc
eslint.config.js
pint.json
.vscode/settings.json
.vscode/extensions.json
.husky/pre-commit
.github/workflows/code-quality.yml
package.json
```

## Baseline, not a locked configuration

This repository provides:

```text
Standard Baseline
      ↓
Laravel Project
      ↓
Project-specific adjustment
```

A project is free to:

- add rules;
- change rules;
- add ignored files;
- customize ESLint;
- customize Pint;
- customize the Git Hook;
- customize the CI workflow.

### Changing Prettier

Edit:

```text
.prettierrc
```

Example:

```json
{
   "printWidth": 120
}
```

### Changing ESLint

Edit:

```text
eslint.config.js
```

Add whatever rule the project actually needs.

### Changing Pint

Edit:

```text
pint.json
```

Example:

```json
{
   "preset": "laravel",
   "rules": {
      "single_quote": true
   }
}
```

### Changing the files Prettier ignores

Edit:

```text
.prettierignore
```

### Changing the Git Hook

Edit:

```text
.husky/pre-commit
```

### Changing GitHub Actions

Edit:

```text
.github/workflows/code-quality.yml
```

---

# 🧩 Project-Specific Configuration

Not every Laravel project uses the same stack.

Example:

```text
Project A
├── Blade
└── Alpine.js

Project B
├── Blade
└── Vue

Project C
├── Inertia
└── React
```

The baseline can be used by all of them.

If a project has special needs, make the change in that project. **Don't change the baseline repository just to satisfy one project's needs**, unless that change is actually meant to become a new standard.

---

# 🔄 Updating the Standard

This repository does not force-auto-update project configuration.

If the baseline changes:

```text
Update Baseline
      ↓
Test Installer
      ↓
Update CHANGELOG.md
      ↓
Commit & Release
      ↓
Apply to New Projects
```

Projects already on a previous version can review the changes and apply them manually.

Avoid using:

```bash
--force
```

on a project with a lot of customization without first reviewing the files that will be overwritten.

---

# 📁 Repository Structure

```text
laravel-code-quality/
├── config/
│   ├── .editorconfig
│   ├── .prettierignore
│   ├── .prettierrc
│   ├── eslint.config.js
│   └── pint.json
│
├── templates/
│   ├── .github/
│   │   └── workflows/
│   │       └── code-quality.yml
│   ├── .husky/
│   │   └── pre-commit
│   └── .vscode/
│       ├── extensions.json
│       └── settings.json
│
├── install.sh
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

---

# 🔐 Git & Secret Safety

This repository must not contain:

```text
.env
.env.*
vendor/
node_modules/
credential
API key
private key
certificate private key
database password
```

The installer does not need any application secrets.

---

# 📝 Changelog

Baseline changes are recorded in:

```text
CHANGELOG.md
```

Use the changelog for changes such as:

- Prettier rules;
- ESLint rules;
- Pint rules;
- dependencies;
- Git Hook;
- GitHub Actions;
- installer;
- documentation.

---

# 📜 License

MIT
