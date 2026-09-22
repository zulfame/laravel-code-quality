#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="."
FORCE=false
INSTALL_VSCODE=true
INSTALL_GITHUB=true

usage() {
    cat <<'EOF'
Laravel Code Quality Installer

Usage:
  ./install.sh <laravel-project-path> [options]

Options:
  --force       Overwrite existing Code Quality configuration files
  --no-vscode   Do not install .vscode configuration
  --no-github   Do not install GitHub Actions workflow
  --help        Show this help

Examples:
  ./install.sh /Users/username/Projects/laravel12
  ./install.sh /Users/username/Projects/laravel12 --force
  ./install.sh /Users/username/Projects/laravel12 --no-vscode --no-github
  ./install.sh .
EOF
}

# First positional argument is the target project. All remaining arguments are options.
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE=true
            ;;
        --no-vscode)
            INSTALL_VSCODE=false
            ;;
        --no-github)
            INSTALL_GITHUB=false
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $arg"
            echo
            usage
            exit 1
            ;;
        *)
            POSITIONAL+=("$arg")
            ;;
    esac
done

if [ "${#POSITIONAL[@]}" -gt 1 ]; then
    echo "Error: only one Laravel project path may be supplied."
    exit 1
fi

if [ "${#POSITIONAL[@]}" -eq 1 ]; then
    TARGET_DIR="${POSITIONAL[0]}"
fi

# Resolve target path.
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target directory does not exist:"
    echo "  $TARGET_DIR"
    exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo
echo "Laravel Code Quality Installer"
echo "────────────────────────────────────────"
echo "Source:"
echo "  $SCRIPT_DIR"
echo
echo "Target:"
echo "  $TARGET_DIR"
echo

# Validate Laravel project.
if [ ! -f "$TARGET_DIR/artisan" ]; then
    echo "Error: Laravel artisan file was not found in:"
    echo "  $TARGET_DIR"
    exit 1
fi

if [ ! -f "$TARGET_DIR/composer.json" ]; then
    echo "Error: composer.json was not found in:"
    echo "  $TARGET_DIR"
    exit 1
fi

if [ ! -f "$TARGET_DIR/package.json" ]; then
    echo "Error: package.json was not found in:"
    echo "  $TARGET_DIR"
    exit 1
fi

copy_file() {
    local source="$1"
    local destination="$2"

    if [ ! -f "$source" ]; then
        echo "  ✗ Source file not found: $source"
        exit 1
    fi

    if [ -e "$destination" ] && [ "$FORCE" = false ]; then
        echo "  ⚠ Skipped (already exists): ${destination#$TARGET_DIR/}"
        return
    fi

    mkdir -p "$(dirname "$destination")"
    cp "$source" "$destination"
    echo "  ✓ ${destination#$TARGET_DIR/}"
}

echo "Installing Laravel Pint..."
(
    cd "$TARGET_DIR"
    composer require laravel/pint --dev
)

echo
echo "Detecting frontend stack..."
FRONTEND_DEPS="$(TARGET_DIR="$TARGET_DIR" node <<'NODE'
const fs = require('fs');
const path = require('path');
const pkg = JSON.parse(fs.readFileSync(path.join(process.env.TARGET_DIR, 'package.json'), 'utf8'));
const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
const has = (names) => names.some((name) => Object.prototype.hasOwnProperty.call(deps, name));
const detected = [];
if (has(['vue', '@inertiajs/vue3'])) detected.push('vue');
if (has(['react', 'react-dom', '@inertiajs/react'])) detected.push('react');
if (has(['svelte', '@sveltejs/kit', '@inertiajs/svelte'])) detected.push('svelte');
if (has(['typescript', 'tsx', '@typescript-eslint/parser'])) detected.push('typescript');
if (has(['tailwindcss'])) detected.push('tailwind');
if (detected.length === 0) detected.push('javascript');
process.stdout.write(detected.join(' '));
NODE
)"

echo "  Detected: $FRONTEND_DEPS"

echo

echo "Installing NPM dependencies..."
(
    cd "$TARGET_DIR"

    BASE_NPM_DEPS=(
        prettier
        @shufo/prettier-plugin-blade
        prettier-plugin-organize-imports
        eslint
        @eslint/js
        eslint-config-prettier
        globals
        typescript-eslint
        husky
        lint-staged
    )

    if [[ "$FRONTEND_DEPS" == *"tailwind"* ]]; then
        BASE_NPM_DEPS+=(prettier-plugin-tailwindcss)
    fi

    if [[ "$FRONTEND_DEPS" == *"vue"* ]]; then
        BASE_NPM_DEPS+=(eslint-plugin-vue)
    fi

    if [[ "$FRONTEND_DEPS" == *"svelte"* ]]; then
        BASE_NPM_DEPS+=(prettier-plugin-svelte eslint-plugin-svelte)
    fi

    if [[ "$FRONTEND_DEPS" == *"react"* ]]; then
        # eslint-plugin-react currently declares a peer range ending below ESLint 10.
        # Prefer the modern ESLint React implementation when the target uses ESLint 10+.
        ESLINT_MAJOR="$(node -p "const v=require('./node_modules/eslint/package.json').version; v.split('.')[0]" 2>/dev/null || true)"
        if [ -z "$ESLINT_MAJOR" ]; then
            ESLINT_MAJOR="$(npm view eslint version 2>/dev/null | cut -d. -f1 || true)"
        fi
        if [ "${ESLINT_MAJOR:-0}" -ge 10 ]; then
            BASE_NPM_DEPS+=("@eslint-react/eslint-plugin")
        else
            BASE_NPM_DEPS+=(eslint-plugin-react eslint-plugin-react-hooks)
        fi
    fi

    npm install -D "${BASE_NPM_DEPS[@]}"
)

echo
echo "Installing configuration..."

copy_file "$SCRIPT_DIR/config/.editorconfig" "$TARGET_DIR/.editorconfig"
copy_file "$SCRIPT_DIR/config/.prettierignore" "$TARGET_DIR/.prettierignore"

# Generate a Prettier configuration that only references plugins actually installed
# for the detected frontend stack. This avoids errors such as
# "Cannot find package prettier-plugin-svelte" in Vue/React-only projects.
TARGET_DIR="$TARGET_DIR" FRONTEND_DEPS="$FRONTEND_DEPS" SCRIPT_DIR="$SCRIPT_DIR" FORCE="$FORCE" node <<'NODE'
const fs = require('fs');
const path = require('path');

const target = process.env.TARGET_DIR;
const source = path.join(process.env.SCRIPT_DIR, 'config', '.prettierrc');
const destination = path.join(target, '.prettierrc');
const force = process.env.FORCE === 'true';

if (fs.existsSync(destination) && !force) {
   console.log('  ⚠ Skipped .prettierrc (already exists)');
   process.exit(0);
}

const detected = new Set((process.env.FRONTEND_DEPS || '').split(/\s+/).filter(Boolean));
const base = JSON.parse(fs.readFileSync(source, 'utf8'));

base.plugins = [
   '@shufo/prettier-plugin-blade',
   'prettier-plugin-organize-imports',
];

if (detected.has('tailwind')) {
   base.plugins.push('prettier-plugin-tailwindcss');
   base.tailwindStylesheet = './resources/css/app.css';
} else {
   delete base.tailwindStylesheet;
}

if (detected.has('svelte')) {
   base.plugins.push('prettier-plugin-svelte');
}

fs.writeFileSync(destination, JSON.stringify(base, null, 3) + '\n');
console.log('  ✓ .prettierrc');
NODE

copy_file "$SCRIPT_DIR/config/eslint.config.js" "$TARGET_DIR/eslint.config.js"
copy_file "$SCRIPT_DIR/config/pint.json" "$TARGET_DIR/pint.json"

if [ "$INSTALL_VSCODE" = true ]; then
    copy_file "$SCRIPT_DIR/templates/.vscode/settings.json" "$TARGET_DIR/.vscode/settings.json"
    copy_file "$SCRIPT_DIR/templates/.vscode/extensions.json" "$TARGET_DIR/.vscode/extensions.json"
fi

if [ "$INSTALL_GITHUB" = true ]; then
    copy_file "$SCRIPT_DIR/templates/.github/workflows/code-quality.yml" "$TARGET_DIR/.github/workflows/code-quality.yml"
fi

echo
echo "Updating package.json..."

export CODE_QUALITY_FORCE="$FORCE"
TARGET_DIR="$TARGET_DIR" node <<'NODE'
const fs = require('fs');
const path = require('path');

const target = process.env.TARGET_DIR;
const force = process.env.CODE_QUALITY_FORCE === 'true';
const packagePath = path.join(target, 'package.json');
const pkg = JSON.parse(fs.readFileSync(packagePath, 'utf8'));

pkg.scripts = pkg.scripts || {};
const scripts = {
  "format": "prettier --write .",
  "format:check": "prettier --check .",
  "lint": "eslint \"resources/**/*.{js,mjs,cjs,ts,mts,cts,jsx,tsx,vue,svelte}\" --max-warnings=0",
  "lint:fix": "eslint \"resources/**/*.{js,mjs,cjs,ts,mts,cts,jsx,tsx,vue,svelte}\" --fix",
  "prepare": "husky"
};

for (const [key, value] of Object.entries(scripts)) {
  if (!(key in pkg.scripts) || force) {
    pkg.scripts[key] = value;
    console.log(`  ✓ scripts.${key}`);
  } else {
    console.log(`  ⚠ Skipped scripts.${key} (already exists)`);
  }
}

const lintStaged = {
  "*.{js,ts,jsx,tsx,vue}": [
    "eslint --fix --max-warnings=0",
    "prettier --write"
  ],
  "*.blade.php": [
    "prettier --write"
  ],
  "*.{css,json,yml,yaml,md}": [
    "prettier --write"
  ],
  "*.php": [
    "./vendor/bin/pint"
  ]
};

pkg["lint-staged"] = pkg["lint-staged"] || {};
for (const [key, value] of Object.entries(lintStaged)) {
  if (!(key in pkg["lint-staged"]) || force) {
    pkg["lint-staged"][key] = value;
    console.log(`  ✓ lint-staged.${key}`);
  } else {
    console.log(`  ⚠ Skipped lint-staged.${key} (already exists)`);
  }
}

fs.writeFileSync(packagePath, JSON.stringify(pkg, null, 2) + '\n');
NODE

echo
echo "Configuring Husky..."

mkdir -p "$TARGET_DIR/.husky"
if [ -e "$TARGET_DIR/.husky/pre-commit" ] && [ "$FORCE" = false ]; then
    echo "  ⚠ Skipped .husky/pre-commit (already exists)"
else
    cat > "$TARGET_DIR/.husky/pre-commit" <<'EOF'
npx lint-staged
EOF
    chmod +x "$TARGET_DIR/.husky/pre-commit"
    echo "  ✓ .husky/pre-commit"
fi

echo
echo "Ensuring VS Code files are not ignored..."

if [ "$INSTALL_VSCODE" = true ]; then
    GITIGNORE="$TARGET_DIR/.gitignore"

    if [ -f "$GITIGNORE" ]; then
        if ! grep -qF '/.vscode/*' "$GITIGNORE"; then
            {
                echo
                echo "# Allow shared Code Quality VS Code configuration"
                echo "/.vscode/*"
                echo "!/.vscode/settings.json"
                echo "!/.vscode/extensions.json"
            } >> "$GITIGNORE"
            echo "  ✓ Updated .gitignore"
        else
            echo "  ⚠ .gitignore already contains VS Code rules"
        fi
    else
        {
            echo "# Allow shared Code Quality VS Code configuration"
            echo "/.vscode/*"
            echo "!/.vscode/settings.json"
            echo "!/.vscode/extensions.json"
        } > "$GITIGNORE"
        echo "  ✓ Created .gitignore"
    fi
fi

echo
echo "Code Quality setup completed."
echo
echo "Target:"
echo "  $TARGET_DIR"
echo
echo "Next steps:"
echo "  cd \"$TARGET_DIR\""
echo "  npm install"
echo "  npm run format:check"
echo "  npm run lint"
echo "  ./vendor/bin/pint --test"
echo
