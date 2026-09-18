# Laravel Code Quality

Baseline **Code Formatter, Linter, Git Hook, VS Code, dan GitHub Actions** untuk project Laravel.

Repository ini dirancang sebagai **standard development tooling** yang dapat diterapkan ke project Laravel yang sudah ada melalui `install.sh`.

> **Prinsip:** repository ini menyediakan baseline yang konsisten, bukan konfigurasi yang terkunci. Setelah instalasi, setiap project tetap dapat menyesuaikan aturan sesuai kebutuhan.

---

## ✨ Yang Disediakan

| Tool                    | Peran                                                                    |
| ----------------------- | ------------------------------------------------------------------------ |
| **Prettier**            | Format Blade, Vue, React, JS/TS, CSS, Tailwind, JSON, YAML, dan Markdown |
| **Laravel Pint**        | Format PHP menggunakan standar Laravel / PSR-12 melalui `pint.json`      |
| **ESLint**              | Deteksi bug dan error logika pada JavaScript                             |
| **Husky + lint-staged** | Menjalankan formatter dan linter hanya pada file yang akan di-commit     |
| **GitHub Actions**      | Validasi format dan lint pada push / pull request                        |
| **VS Code**             | Format On Save dan rekomendasi extension                                 |
| **EditorConfig**        | Menyamakan aturan dasar editor antar-developer                           |

---

# 🚀 Installation

Installer menerima **path project Laravel sebagai argument**. Repository `laravel-code-quality` tidak perlu berada di dalam project Laravel yang akan dipasang.

### 1. Clone repository

```bash
git clone https://github.com/zulfame/laravel-code-quality.git
```

### 2. Jalankan installer

Misalnya project Laravel berada di:

```text
/Users/username/Projects/laravel12
```

Jalankan:

```bash
./laravel-code-quality/install.sh /Users/username/Projects/laravel12
```

Jika Anda sedang berada di directory repository `laravel-code-quality`:

```bash
cd laravel-code-quality
./install.sh /Users/username/Projects/laravel12
```

Jika repository dan project Laravel berada berdampingan:

```text
Projects/
├── laravel-code-quality/
└── laravel12/
```

jalankan:

```bash
cd laravel-code-quality
./install.sh ../laravel12
```

### 3. Ikuti hasil instalasi

Installer akan memeriksa project tujuan, memasang dependency, kemudian menerapkan konfigurasi.

Secara umum prosesnya adalah:

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

Installer **sudah menjalankan instalasi dependency NPM**. Anda **tidak perlu menjalankan `npm install` lagi** setelah proses selesai.

---

# 🧪 Verify the Installation

Setelah installer selesai, pindah ke project Laravel tujuan:

```bash
cd /Users/username/Projects/laravel12
```

Kemudian jalankan pemeriksaan berikut:

```bash
npm run format:check
npm run lint
./vendor/bin/pint --test
```

Jika ketiganya berhasil, baseline Code Quality sudah terpasang dengan benar.

Untuk menguji Git Hook, lakukan perubahan pada file lalu:

```bash
git add .
git commit -m "test: code quality"
```

Husky akan menjalankan:

```bash
npx lint-staged
```

dan hanya memproses file yang akan di-commit.

---

# ⚙️ Installer Options

Option bersifat **opsional** dan digunakan saat menjalankan installer. Untuk penggunaan normal, Anda tidak perlu menggunakan option apa pun.

### Default

```bash
./install.sh /path/to/laravel-project
```

Installer **tidak menimpa file konfigurasi yang sudah ada**.

Ini adalah mode yang direkomendasikan untuk project yang sudah berjalan.

### `--force`

```bash
./install.sh /path/to/laravel-project --force
```

Menimpa konfigurasi Code Quality yang sudah ada.

Gunakan jika Anda memang ingin menyamakan kembali konfigurasi project dengan baseline repository ini.

> **Perhatian:** perubahan konfigurasi project yang sebelumnya dibuat secara manual dapat tertimpa.

### `--no-vscode`

```bash
./install.sh /path/to/laravel-project --no-vscode
```

Tidak memasang:

```text
.vscode/settings.json
.vscode/extensions.json
```

Gunakan jika tim tidak menggunakan VS Code atau project tidak ingin menyimpan workspace configuration.

### `--no-github`

```bash
./install.sh /path/to/laravel-project --no-github
```

Tidak memasang:

```text
.github/workflows/code-quality.yml
```

Gunakan jika CI dikelola melalui platform atau workflow lain.

### Kombinasi

Option dapat digunakan bersama:

```bash
./install.sh /path/to/laravel-project --force --no-vscode --no-github
```

### Help

```bash
./install.sh --help
```

---

# 📋 Quick Commands

Setelah instalasi:

| Command                    | Fungsi                                          |
| -------------------------- | ----------------------------------------------- |
| `npm run format`           | Format otomatis file yang dikelola Prettier     |
| `npm run format:check`     | Memeriksa formatting tanpa mengubah file        |
| `npm run lint`             | Menjalankan ESLint pada `resources/js/`         |
| `npm run lint:fix`         | Memperbaiki temuan ESLint yang dapat diperbaiki |
| `./vendor/bin/pint`        | Format otomatis file PHP                        |
| `./vendor/bin/pint --test` | Memeriksa formatting PHP tanpa mengubah file    |

### Workflow sehari-hari

Untuk pekerjaan normal, developer tidak perlu menjalankan semua command secara manual.

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

Gunakan command manual terutama ketika:

- melakukan pemeriksaan sebelum commit;
- memperbaiki formatting seluruh project;
- melakukan troubleshooting;
- melakukan validasi CI secara lokal.

---

# 📦 Supported Languages & Formats

### Blade & Livewire

File:

```text
*.blade.php
```

Diformat menggunakan `@shufo/prettier-plugin-blade`, termasuk:

- Blade directives seperti `@if`, `@foreach`, `@extends`, dan `@yield`;
- Blade components;
- Livewire components;
- `wire:model`;
- `wire:click`;
- `wire:loading`;
- `@php`.

### Tailwind CSS

Pengurutan class Tailwind dilakukan menggunakan:

```text
prettier-plugin-tailwindcss
```

### Vue & React

Didukung:

```text
*.vue
*.jsx
*.tsx
```

Konfigurasi dapat digunakan untuk project Laravel yang menggunakan Inertia.js maupun frontend modern lainnya.

### JavaScript & TypeScript

Didukung:

```text
*.js
*.ts
```

Baseline formatter:

- 3 spasi;
- single quotes;
- semicolon;
- trailing comma `es5`;
- print width 140.

### Data & Configuration

Didukung:

```text
*.json
*.yml
*.yaml
*.md
```

YAML menggunakan indentasi 2 spasi.

### PHP

File:

```text
*.php
```

Dikelola oleh **Laravel Pint** melalui:

```text
pint.json
```

---

# ⚠️ JavaScript di Dalam Blade

Prettier Blade bekerja dengan parser Blade. Karena itu, JavaScript yang ditulis langsung di Blade perlu mengikuti beberapa aturan agar data Blade tidak menghasilkan JavaScript yang tidak valid.

## 1. Gunakan `@js()` untuk Mengirim Data dari Blade

Hindari:

```blade
const user = JSON.parse('{{ json_encode($user) }}');
const token = "{{ csrf_token() }}";
```

Gunakan direktif resmi Laravel:

```blade
<script>
   const user = @js($user);
   const token = @js(csrf_token());
   const apiUrl = @js(route('dashboard'));
</script>
```

## 2. Gunakan `prettier-ignore` untuk Script Kompleks

Jika sebuah blok `<script>` menggabungkan banyak Blade directive dan tidak boleh disentuh Prettier:

```blade
{{-- prettier-ignore --}}
<script>
   // Seluruh blok ini tidak akan diformat oleh Prettier.
   const myCustomConfig = { ... };
</script>
```

Gunakan pengecualian ini hanya ketika memang diperlukan.

## 3. Pisahkan JavaScript ke `resources/js/`

Untuk JavaScript yang lebih kompleks, lebih baik gunakan file JavaScript terpisah yang di-bundle melalui Vite.

Contoh:

```blade
<div
   id="app-data"
   data-user='@json($user)'
   data-endpoint="{{ route('api.save') }}"
></div>
```

Kemudian:

```javascript
const el = document.getElementById("app-data");
const user = JSON.parse(el.dataset.user);
const endpoint = el.dataset.endpoint;
```

## 4. Event Alpine.js di Blade

Jika mengalami konflik parsing atau formatting pada parser Blade, gunakan:

```blade
x-on:click="..."
```

daripada:

```blade
@click="..."
```

---

# 💻 VS Code Integration

Installer dapat memasang:

```text
.vscode/settings.json
.vscode/extensions.json
```

## Format On Save

Workspace menggunakan:

```json
"editor.formatOnSave": true
```

File yang didukung dengan Prettier sebagai formatter meliputi:

- Blade;
- JavaScript;
- CSS;
- JSON;
- Vue.

Default indentasi:

```text
3 spaces
```

## Recommended Extensions

VS Code akan merekomendasikan:

- Prettier;
- Tailwind CSS IntelliSense;
- Laravel Blade;
- ESLint.

Jika menggunakan editor lain, `.editorconfig` tetap dapat digunakan sebagai baseline.

---

# 🪝 Husky + lint-staged

Husky menjalankan:

```bash
npx lint-staged
```

ketika developer melakukan:

```bash
git commit
```

Konfigurasi `lint-staged`:

| File                                         | Tool              |
| -------------------------------------------- | ----------------- |
| `*.js`, `*.ts`, `*.jsx`, `*.tsx`, `*.vue`    | ESLint + Prettier |
| `*.blade.php`                                | Prettier          |
| `*.css`, `*.json`, `*.yml`, `*.yaml`, `*.md` | Prettier          |
| `*.php`                                      | Laravel Pint      |

Dengan pendekatan ini, hanya file yang akan di-commit yang diproses.

---

# 🤖 GitHub Actions

Installer memasang:

```text
.github/workflows/code-quality.yml
```

Workflow melakukan pemeriksaan:

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

Workflow dapat berjalan pada:

- push;
- pull request.

GitHub Actions berfungsi sebagai **quality gate tambahan** setelah validasi lokal dan Git Hook.

---

# 🔧 Customization

File yang dipasang installer menjadi **milik project tujuan**.

Setelah instalasi, developer bebas menyesuaikan aturan sesuai kebutuhan project.

File utama:

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

## Baseline, bukan konfigurasi terkunci

Repository ini menyediakan:

```text
Standard Baseline
      ↓
Laravel Project
      ↓
Project-specific adjustment
```

Project boleh:

- menambah rule;
- mengubah rule;
- menambahkan file yang di-ignore;
- menyesuaikan ESLint;
- menyesuaikan Pint;
- menyesuaikan Git Hook;
- menyesuaikan workflow CI.

### Mengubah Prettier

Edit:

```text
.prettierrc
```

Contoh:

```json
{
   "printWidth": 120
}
```

### Mengubah ESLint

Edit:

```text
eslint.config.js
```

Tambahkan rule yang memang diperlukan oleh project.

### Mengubah Pint

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

### Mengubah file yang diabaikan Prettier

Edit:

```text
.prettierignore
```

### Mengubah Git Hook

Edit:

```text
.husky/pre-commit
```

### Mengubah GitHub Actions

Edit:

```text
.github/workflows/code-quality.yml
```

---

# 🧩 Project-Specific Configuration

Tidak semua project Laravel menggunakan stack yang sama.

Contoh:

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

Baseline dapat digunakan oleh semuanya.

Jika sebuah project memiliki kebutuhan khusus, lakukan perubahan pada project tersebut. **Jangan mengubah repository baseline hanya untuk memenuhi kebutuhan satu project**, kecuali perubahan tersebut memang ingin dijadikan standar baru.

---

# 🔄 Updating the Standard

Repository ini tidak melakukan auto-update konfigurasi project secara paksa.

Jika baseline berubah:

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

Project yang sudah menggunakan versi sebelumnya dapat meninjau perubahan dan menerapkannya secara manual.

Hindari penggunaan:

```bash
--force
```

pada project yang memiliki banyak customization tanpa terlebih dahulu meninjau file yang akan ditimpa.

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

Repository ini tidak boleh berisi:

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

Installer tidak membutuhkan secret aplikasi.

---

# 📝 Changelog

Perubahan baseline dicatat pada:

```text
CHANGELOG.md
```

Gunakan changelog untuk perubahan seperti:

- Prettier rules;
- ESLint rules;
- Pint rules;
- dependency;
- Git Hook;
- GitHub Actions;
- installer;
- dokumentasi.

---

# 📜 License

MIT
