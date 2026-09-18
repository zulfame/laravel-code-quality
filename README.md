# Laravel Code Quality

Standar **Code Formatter, Linter, Git Hook, VS Code, dan GitHub Actions** untuk project Laravel.

Repository ini sengaja dibuat sebagai **configuration installer**, bukan Composer package. Tujuannya agar setup Code Quality yang sama dapat dipasang ke banyak project Laravel tanpa mengambil alih `composer.json` atau `package.json` project.

## Tooling

- Laravel Pint — PHP
- Prettier — Blade, JavaScript, Vue, CSS, JSON, YAML, Markdown
- Prettier Blade plugin
- Prettier import organizer
- Prettier Tailwind CSS plugin
- ESLint — JavaScript
- Husky — Git hooks
- lint-staged — format/lint file yang sedang di-commit
- VS Code settings & extension recommendations
- GitHub Actions — CI Code Quality

## Requirements

- Laravel project dengan Composer
- Node.js 20+ direkomendasikan
- npm
- Git
- Bash / shell environment

> Installer tidak memasang ulang dependency aplikasi Laravel/Vite yang sudah ada. Installer hanya menambahkan tooling Code Quality yang dibutuhkan.

## Installation

Installer harus dijalankan dari **root project Laravel tujuan**, sedangkan repository `laravel-code-quality` dapat berada di directory mana pun.

### 1. Clone repository

```bash
git clone https://github.com/zulfame/laravel-code-quality.git
```

### 2. Jalankan installer dari project Laravel

```bash
cd /path/to/my-laravel-project
/path/to/laravel-code-quality/install.sh
```

Contoh:

```text
workspace/
├── my-laravel-project/
└── laravel-code-quality/
```

```bash
cd my-laravel-project
../laravel-code-quality/install.sh
```

Installer akan:

1. Memeriksa bahwa `artisan`, `composer.json`, dan `package.json` tersedia.
2. Memasang `laravel/pint` sebagai Composer dev dependency.
3. Memasang dependency Prettier, ESLint, Husky, dan lint-staged sebagai NPM dev dependency.
4. Menyalin baseline konfigurasi Code Quality.
5. Menambahkan script dan `lint-staged` ke `package.json` tanpa menghapus konfigurasi project yang lain.
6. Membuat atau memperbarui `.husky/pre-commit`.
7. Menambahkan konfigurasi VS Code, kecuali `--no-vscode` digunakan.
8. Menambahkan GitHub Actions workflow, kecuali `--no-github` digunakan.

> **Catatan:** installer tidak menggantikan dependency aplikasi Laravel/Vite yang sudah ada. Ia hanya menambahkan tooling Code Quality yang dibutuhkan.

## Installer Options

Default:

```bash
./install.sh
```

Timpa file konfigurasi yang sudah ada:

```bash
./install.sh --force
```

Lewati VS Code:

```bash
./install.sh --no-vscode
```

Lewati GitHub Actions:

```bash
./install.sh --no-github
```

Gabungkan opsi:

```bash
./install.sh --force --no-vscode --no-github
```

### Prettier Baseline

- Indentasi default: **3 spasi**
- `singleQuote`: `true`
- `semi`: `true`
- `printWidth`: `140`
- `trailingComma`: `es5`
- `useTabs`: `false`
- `endOfLine`: `lf`
- YAML: 2 spasi
- Blade, Vue, JSX/TSX: 3 spasi

Plugin:

```text
@shufo/prettier-plugin-blade
prettier-plugin-organize-imports
prettier-plugin-tailwindcss
```

### Laravel Pint Baseline

Preset:

```json
"preset": "laravel"
```

Dengan rules tambahan untuk ordered imports, unused imports, trailing comma multiline, operator spacing, blank line before selected statements, method chaining indentation, single quotes, dan short array syntax.

### ESLint Baseline

Menggunakan ESLint 9 dengan `@eslint/js` dan `globals`, termasuk browser/ES2021 globals serta globals untuk `axios`, `route`, dan `Alpine`.

Rule utama mencakup:

```text
no-unused-vars       warning
no-console           warning
no-debugger          error
no-duplicate-imports error
no-var               error
prefer-const         warning
prefer-arrow-callback warning
prefer-template      warning
eqeqeq               error
```

## Compatibility With the Source Project

Repository ini mempertahankan standar utama dari project sumber:

- Prettier + `@shufo/prettier-plugin-blade`
- Tailwind class sorting
- import organization
- ESLint
- Laravel Pint
- Husky + lint-staged
- VS Code Format On Save
- VS Code extension recommendations
- GitHub Actions untuk Prettier, ESLint, dan Pint
- `.editorconfig`
- `.prettierignore`
- aturan `.gitignore` untuk mempertahankan `.vscode/settings.json` dan `.vscode/extensions.json`

Perbedaannya hanya pada **cara distribusi**. Project sumber menyimpan konfigurasi langsung di root project, sedangkan repository ini menyimpan konfigurasi sebagai baseline di `config/` dan `templates/`, lalu `install.sh` memasangnya ke project Laravel tujuan.

## Commands

Setelah instalasi:

```bash
npm run format
```

Format semua file yang dikelola Prettier.

```bash
npm run format:check
```

Memeriksa formatting tanpa mengubah file.

```bash
npm run lint
```

Menjalankan ESLint pada `resources/js`.

```bash
npm run lint:fix
```

Memperbaiki masalah ESLint yang dapat diperbaiki otomatis.

```bash
./vendor/bin/pint
```

Memformat PHP menggunakan Laravel Pint.

```bash
./vendor/bin/pint --test
```

Memeriksa PHP tanpa mengubah file.

## Git Hook

Setelah instalasi, setiap `git commit` akan menjalankan `lint-staged`.

File yang berubah akan diproses sesuai jenisnya:

| File                                    | Tool              |
| --------------------------------------- | ----------------- |
| `.js`, `.ts`, `.jsx`, `.tsx`, `.vue`    | ESLint + Prettier |
| `.blade.php`                            | Prettier          |
| `.css`, `.json`, `.yml`, `.yaml`, `.md` | Prettier          |
| `.php`                                  | Laravel Pint      |

## Customization

Konfigurasi yang dipasang ke project adalah **milik project tersebut**. Setelah installer selesai, Anda bebas menyesuaikannya.

File utama:

```text
pint.json
.prettierrc
.prettierignore
eslint.config.js
.editorconfig
.vscode/settings.json
.vscode/extensions.json
.husky/pre-commit
.github/workflows/code-quality.yml
package.json
```

### Mengubah aturan PHP

Edit:

```text
pint.json
```

Contoh:

```json
{
   "preset": "laravel",
   "rules": {
      "single_quote": true
   }
}
```

### Mengubah aturan Prettier

Edit:

```text
.prettierrc
```

Misalnya mengubah:

```json
"printWidth": 140
```

menjadi:

```json
"printWidth": 120
```

### Mengubah ESLint

Edit:

```text
eslint.config.js
```

Aturan project-specific dapat ditambahkan tanpa mengubah repository installer.

### Mengubah file yang diabaikan

Edit:

```text
.prettierignore
```

### Mengubah Git Hook

Edit:

```text
.husky/pre-commit
```

### Mengubah CI

Edit:

```text
.github/workflows/code-quality.yml
```

## Prinsip Configuration Ownership

Repository ini menyediakan **baseline**, bukan konfigurasi yang terkunci.

```text
Repository ini
      │
      │ baseline
      ▼
Laravel Project
      │
      ├── boleh menambah aturan
      ├── boleh mengubah aturan
      └── boleh mengecualikan aturan tertentu
```

Jika sebuah project membutuhkan aturan khusus, ubah konfigurasi di project tersebut. Jangan membuat perubahan project-specific di repository ini kecuali perubahan tersebut memang dimaksudkan menjadi standar baru.

## Updating the Standard

Repository ini tidak dirancang untuk melakukan auto-update konfigurasi secara paksa pada project yang sudah terpasang.

Jika standar berubah:

1. Update file di repository ini.
2. Uji installer pada Laravel project baru.
3. Dokumentasikan perubahan di `CHANGELOG.md`.
4. Untuk project lama, lakukan update konfigurasi secara sadar agar perubahan project-specific tidak tertimpa.

## Recommended Git Workflow

```bash
git add .
git commit -m "your message"
```

Git hook akan menjalankan `lint-staged` sebelum commit.

CI GitHub juga akan menjalankan pemeriksaan saat push atau pull request ke branch `main`, `master`, atau `develop`.

## Repository Structure

```text
laravel-code-quality/
├── config/
│   ├── .editorconfig
│   ├── .prettierignore
│   ├── .prettierrc
│   ├── eslint.config.js
│   └── pint.json
├── templates/
│   ├── .github/workflows/code-quality.yml
│   ├── .husky/pre-commit
│   └── .vscode/
│       ├── extensions.json
│       └── settings.json
├── install.sh
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## License

MIT
