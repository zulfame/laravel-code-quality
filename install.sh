#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
NO_VSCODE=false
NO_GITHUB=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --no-vscode) NO_VSCODE=true ;;
    --no-github) NO_GITHUB=true ;;
    -h|--help)
      cat <<USAGE
Laravel Code Quality Installer

Usage:
  ./install.sh [options]

Options:
  --force       Overwrite existing configuration files.
  --no-vscode   Do not install VS Code configuration.
  --no-github   Do not install GitHub Actions workflow.
  -h, --help    Show this help.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

log() { printf '\033[1;32m✓\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$1"; }
fail() { printf '\033[1;31m✗\033[0m %s\n' "$1" >&2; exit 1; }

[ -f "artisan" ] || fail "artisan tidak ditemukan. Jalankan installer dari root project Laravel."
[ -f "composer.json" ] || fail "composer.json tidak ditemukan."
[ -f "package.json" ] || fail "package.json tidak ditemukan. Jalankan installer setelah npm init / setup frontend project."
command -v composer >/dev/null 2>&1 || fail "Composer tidak ditemukan."
command -v npm >/dev/null 2>&1 || fail "npm tidak ditemukan."
command -v node >/dev/null 2>&1 || fail "Node.js tidak ditemukan."

copy_config() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ] && [ "$FORCE" != true ]; then
    warn "$dst sudah ada — dilewati. Gunakan --force untuk menimpa."
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$REPO_ROOT/$src" "$dst"
  log "$dst"
}

echo
printf '\033[1mLaravel Code Quality Installer\033[0m\n'
echo

printf '\033[1m[1/5] Composer dependencies\033[0m\n'
composer require laravel/pint --dev --no-interaction
log "laravel/pint"

echo
printf '\033[1m[2/5] NPM dependencies\033[0m\n'
npm install --save-dev \
  prettier \
  @shufo/prettier-plugin-blade \
  prettier-plugin-tailwindcss \
  prettier-plugin-organize-imports \
  eslint \
  @eslint/js \
  globals \
  husky \
  lint-staged
log "NPM Code Quality dependencies"

echo
printf '\033[1m[3/5] Configuration files\033[0m\n'
copy_config "config/.editorconfig" ".editorconfig"
copy_config "config/.prettierrc" ".prettierrc"
copy_config "config/.prettierignore" ".prettierignore"
copy_config "config/eslint.config.js" "eslint.config.js"
copy_config "config/pint.json" "pint.json"

if [ "$NO_VSCODE" = false ]; then
  copy_config "templates/.vscode/settings.json" ".vscode/settings.json"
  copy_config "templates/.vscode/extensions.json" ".vscode/extensions.json"
fi

if [ "$NO_GITHUB" = false ]; then
  copy_config "templates/.github/workflows/code-quality.yml" ".github/workflows/code-quality.yml"
fi

echo
printf '\033[1m[4/5] package.json scripts & lint-staged\033[0m\n'
export CODE_QUALITY_FORCE="$FORCE"
node <<'NODE'
const fs = require('fs');
const path = 'package.json';
const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
pkg.scripts ??= {};
const scripts = {
  format: 'prettier --write .',
  'format:check': 'prettier --check .',
  lint: 'eslint resources/js --max-warnings=0',
  'lint:fix': 'eslint resources/js --fix',
  prepare: 'husky',
};
for (const [key, value] of Object.entries(scripts)) {
  if (!(key in pkg.scripts) || process.env.CODE_QUALITY_FORCE === 'true') pkg.scripts[key] = value;
}
pkg['lint-staged'] ??= {};
const rules = {
  '*.{js,ts,jsx,tsx,vue}': ['eslint --fix --max-warnings=0', 'prettier --write'],
  '*.blade.php': ['prettier --write'],
  '*.{css,json,yml,yaml,md}': ['prettier --write'],
  '*.php': ['./vendor/bin/pint'],
};
for (const [key, value] of Object.entries(rules)) {
  if (!(key in pkg['lint-staged']) || process.env.CODE_QUALITY_FORCE === 'true') pkg['lint-staged'][key] = value;
}
fs.writeFileSync(path, JSON.stringify(pkg, null, 3) + '\n');
NODE
log "package.json updated"

echo
printf '\033[1m[5/5] Husky & Git ignore\033[0m\n'
mkdir -p .husky
if [ -f .husky/pre-commit ] && [ "$FORCE" != true ]; then
  warn ".husky/pre-commit sudah ada — dilewati."
else
  cp "$REPO_ROOT/templates/.husky/pre-commit" .husky/pre-commit
  chmod +x .husky/pre-commit
  log ".husky/pre-commit"
fi

# Ensure Husky's prepare script runs after npm install.
npm run prepare >/dev/null 2>&1 || true

# Keep VS Code settings committed even when the project's .gitignore ignores .vscode.
if [ "$NO_VSCODE" = false ]; then
  touch .gitignore
  if ! grep -Fqx '/.vscode/*' .gitignore; then
    cat >> .gitignore <<'GITIGNORE'

# VS Code project settings — keep shared Code Quality settings tracked
/.vscode/*
!/.vscode/settings.json
!/.vscode/extensions.json
GITIGNORE
    log ".gitignore updated"
  else
    log ".gitignore already contains VS Code rules"
  fi
fi

echo
echo "Code Quality setup selesai."
echo
echo "Next steps:"
echo "  npm run format:check"
echo "  npm run lint"
echo "  ./vendor/bin/pint --test"
echo "  git add ."
echo "  git commit"
echo
