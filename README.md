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

Repository ini digunakan sebagai **baseline Code Quality** untuk project Laravel lain.

Installer menerima path project Laravel sebagai argument, sehingga repository installer tidak perlu berada di dalam project target.

### 1. Clone repository

```bash
git clone https://github.com/USERNAME/laravel-code-quality.git
cd laravel-code-quality
```

### 2. Jalankan installer

Misalnya project Laravel berada di:

```text
/Users/username/Projects/laravel12
```

Jalankan:

```bash
./install.sh /Users/username/Projects/laravel12
```

Atau jika project Laravel berada satu directory dengan repository ini:

```text
Projects/
├── laravel-code-quality/
└── laravel12/
```

jalankan:

```bash
./install.sh ../laravel12
```

Installer akan:

1. Memeriksa `artisan`, `composer.json`, dan `package.json`.
2. Memasang `laravel/pint` sebagai Composer dev dependency.
3. Memasang Prettier, Blade plugin, Tailwind plugin, organize imports, ESLint, Husky, dan lint-staged.
4. Memasang konfigurasi formatter dan linter.
5. Menambahkan scripts dan `lint-staged` ke `package.json`.
6. Membuat `.husky/pre-commit`.
7. Memasang konfigurasi VS Code.
8. Memasang GitHub Actions workflow.

> **Penting:** installer bekerja pada project yang diberikan sebagai argument. Repository `laravel-code-quality` sendiri tidak akan dimodifikasi.

### 3. Setelah instalasi

Masuk ke project:

```bash
cd /Users/username/Projects/laravel12
```

Kemudian:

```bash
npm install
```

Untuk memeriksa hasil setup:

```bash
npm run format:check
npm run lint
./vendor/bin/pint --test
```

## Installer Options

### Default

```bash
./install.sh /path/to/laravel-project
```

File konfigurasi yang sudah ada **tidak akan ditimpa**.

### Force

```bash
./install.sh /path/to/laravel-project --force
```

Menimpa konfigurasi Code Quality yang sudah ada.

### Tanpa VS Code

```bash
./install.sh /path/to/laravel-project --no-vscode
```

### Tanpa GitHub Actions

```bash
./install.sh /path/to/laravel-project --no-github
```

### Kombinasi

```bash
./install.sh /path/to/laravel-project --force --no-vscode --no-github
```

### Project saat ini

Jika installer dijalankan dari root project Laravel:

```bash
./install.sh .
```

### Bantuan

```bash
./install.sh --help
```

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

| File | Tool |
|---|---|
| `.js`, `.ts`, `.jsx`, `.tsx`, `.vue` | ESLint + Prettier |
| `.blade.php` | Prettier |
| `.css`, `.json`, `.yml`, `.yaml`, `.md` | Prettier |
| `.php` | Laravel Pint |

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
