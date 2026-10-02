# CatetKeun 💰

**Catetan Keuangan** pribadi berbasis Flutter dengan Material Design 3.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)

## ✨ Fitur

### Fitur Utama
- ✅ **CRUD Transaksi** - Tambah, ubah, hapus catatan pemasukan/pengeluaran
- ✅ **15 Kategori Bawaan** - 8 kategori pengeluaran + 7 kategori pemasukan
- ✅ **Kategori Kustom** - CRUD kategori sendiri (nama, ikon, warna); diblokir jika masih dipakai transaksi
- ✅ **Filter & Pencarian** - Filter berdasarkan tipe, cari berdasarkan judul/catatan/kategori
- ✅ **Navigasi Bulan** - Lihat transaksi berdasarkan periode bulanan
- ✅ **Statistik Kategori** - Rincian per kategori dengan persentase dan progress bar
- ✅ **Grafik Visual** - Donut chart proporsi kategori + bar chart tren 6 bulan (toggle Daftar/Grafik)
- ✅ **Anggaran (Budget)** - Batas pengeluaran bulanan global & per kategori dengan 3 level status (pemilih kategori saat menambah)
- ✅ **Ekspor/Impor Data** - Export JSON/CSV + share, import dengan preview & 3 strategi (merge/skip/replace); JSON juga memuat anggaran & kategori custom
- ✅ **Multi-bahasa (i18n)** - Indonesia (default) & English, dengan persistensi pilihan bahasa
- ✅ **Tema Terang/Gelap** - Dengan persistensi (tersimpan antar sesi)
- ✅ **Data Persistence** - Tersimpan otomatis via SharedPreferences
- ✅ **Sample Data** - Data contoh untuk pengalaman pertama pengguna (ikut berbahasa)

### Planned Features (Roadmap)
- 🔲 Cloud sync & backup
- 🔲 Notifikasi pengingat budget
- 🔲 Enkripsi data lokal

## 🏗️ Arsitektur

### Struktur Proyek

```
lib/
├── l10n/
│   ├── app_id.arb                # Sumber teks bahasa Indonesia (template)
│   ├── app_en.arb                # Terjemahan bahasa Inggris
│   ├── category_l10n.dart        # Helper nama kategori & pesan error sesuai bahasa
│   └── generated/                # Hasil flutter gen-l10n (jangan diedit manual)
├── models/
│   ├── budget.dart               # Model anggaran + progress & status
│   ├── category.dart             # Model kategori, enum TransactionType, error bertipe
│   └── transaction.dart          # Model transaksi dengan JSON serialization
├── providers/
│   └── finance_provider.dart     # State management (ChangeNotifier): transaksi, kategori, budget, tema, bahasa
├── services/
│   ├── budget_repository.dart    # Persistensi anggaran
│   ├── category_repository.dart  # Persistensi kategori custom
│   ├── export_import_service.dart# Ekspor/Impor JSON & CSV
│   └── transaction_repository.dart # Data persistence + proteksi kehilangan data
├── utils/
│   ├── currency_helper.dart      # Format mata uang (sadar locale)
│   └── date_helper.dart          # Format tanggal & utilitas waktu (sadar locale)
├── views/
│   ├── home_screen.dart          # Screen utama dengan tab navigation
│   ├── statistics_screen.dart    # Statistik: list/chart + ringkasan anggaran
│   ├── add_edit_transaction_screen.dart # Form tambah/ubah transaksi
│   ├── budget_screen.dart        # Kelola anggaran bulanan
│   ├── category_management_screen.dart  # Kelola kategori (CRUD)
│   └── widgets/
│       ├── app_logo.dart             # Logo aplikasi seragam (dari ikon launcher)
│       ├── balance_card.dart         # Kartu saldo bulanan
│       ├── category_pie_chart.dart   # Donut chart proporsi kategori
│       ├── empty_state.dart          # Empty state widget
│       ├── export_import_sheet.dart  # Bottom sheet ekspor/impor
│       ├── filter_bar.dart           # Filter bulan & tipe
│       ├── monthly_trend_chart.dart  # Bar chart tren 6 bulan
│       └── transaction_item_tile.dart # Item transaksi dengan swipe-to-delete
└── main.dart                    # Entry point, tema, & localizations delegates
```

Konfigurasi generasi lokalitas ada di `l10n.yaml` (root proyek).

### Arsitektur Data

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface                         │
│  (HomeScreen, StatisticsScreen, AddEditTransactionScreen)   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   FinanceProvider                           │
│  • State management (ChangeNotifier)                        │
│  • Business logic (filter, search, aggregation)             │
│  • Theme persistence                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              TransactionRepository                          │
│  • JSON serialization/deserialization                       │
│  • Per-record parsing (error handling)                      │
│  • Automatic backup untuk data corrupt                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 SharedPreferences                           │
│  • Local storage (key-value)                                │
│  • Theme persistence                                        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x atau lebih baru
- Dart SDK 3.x
- IDE (VS Code / Android Studio)

### Installation

1. **Clone repository:**
   ```bash
   git clone https://github.com/username/catat_keuangan.git
   cd catat_keuangan
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi:**
   ```bash
   flutter run
   ```

### Ikon Aplikasi

Ikon disumberkan dari satu file saja: `assets/icon/icon.webp`, sehingga tampilan
ikon sama di semua platform (Android, iOS, Web, Windows, macOS, Linux).

```bash
dart run flutter_launcher_icons
```

Perintah di atas menulis: ikon Android (default + adaptive), iOS, Web
(`web/favicon.png`, `web/icons/*.png`, `manifest.json`), Windows
(`windows/runner/resources/app_icon.ico`) dan macOS (`AppIcon.appiconset`).

Catatan:
- Linux tidak didukung `flutter_launcher_icons`. Ikonya adalah salinan
  `linux/runner/resources/app_icon.png` (PNG 512×512 hasil dari
  `macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png`) yang
  di-copy ke bundle lewat `linux/CMakeLists.txt`. Jika `icon.webp` berubah,
  perbarui juga file tersebut.
- Latar adaptive icon Android & ikon iOS memakai warna `#00796B`.

### Build untuk Production

**Android:**
```bash
flutter build apk --release
# atau
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Framework utama |
| `flutter_localizations` | SDK | Delegates lokalitas Material/Cupertino |
| `intl` | ^0.20.3 | Format mata uang & tanggal (sadar locale) |
| `shared_preferences` | ^2.5.5 | Local storage |
| `fl_chart` | ^0.70.2 | Donut chart & bar chart |
| `share_plus` | ^11.0.0 | Share file hasil ekspor |
| `file_picker` | ^8.0.0 | Pilih file saat impor |
| `path_provider` | ^2.1.0 | Lokasi file ekspor sementara |
| `cupertino_icons` | ^2.0.0 | Icons iOS style |
| `flutter_lints` | ^6.0.0 | Linting rules (dev) |
| `flutter_launcher_icons` | ^0.14.4 | Generate icons (dev) |

### Localization (i18n)

Menggunakan **`flutter gen-l10n`** dengan `l10n.yaml`:

```bash
flutter gen-l10n   # regenerate setelah mengubah file .arb
```

- Template: `lib/l10n/app_id.arb` (Indonesia, locale default)
- Terjemahan: `lib/l10n/app_en.arb` (English)
- Output: `lib/l10n/generated/` — semua kode mengimpor dari sini
  (`package:catat_keuangan/l10n/generated/app_localizations.dart`).
 Jangan pernah mengedit file di folder itu secara manual.
- Nama kategori bawaan diterjemahkan lewat `CategoryL10n.localized(context)`
- Format mata uang/tanggal mengikuti `CurrencyHelper.locale` & `DateHelper.locale`
- Pilihan bahasa disimpan di SharedPreferences key `app_locale`

## 🎨 Design System

### Color Palette

**Primary Color:** Teal (`#00796B`)
- Financial green/teal yang seimbang dan tenang
- Seed color untuk Material Design 3 color scheme

**Semantic Colors:**
- **Income/Pemasukan:** Teal (`Colors.teal`)
- **Expense/Pengeluaran:** Red Accent (`Colors.redAccent`)
- **Balance Positive:** On Surface (default)
- **Balance Negative:** Red Accent

### Typography
- Menggunakan Material Design 3 typography scale
- Bold untuk amount dan headings
- Regular untuk body text

## 📊 Kategori

### Kategori Pengeluaran (8)
1. 🍔 Makanan & Minuman
2. 🚗 Transportasi
3. 🛍️ Belanja
4. 📄 Tagihan & Utilitas
5. 🎮 Hiburan
6. 🏥 Kesehatan
7. 🎓 Pendidikan
8. ⋯ Lainnya

### Kategori Pemasukan (7)
1. 👛 Gaji Pokok
2. 🎁 Bonus & THR
3. 📈 Investasi
4. 🏪 Usaha / Bisnis
5. 🏷️ Penjualan Barang
6. 🎀 Hadiah & Hibah
7. 💵 Lainnya

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **State Management:** ChangeNotifier (Provider pattern)
- **Storage:** SharedPreferences (JSON serialization)
- **UI:** Material Design 3
- **Architecture:** Layered (Models → Providers → Services → Views)

## 📈 Performance Notes

### Current Implementation
- **Storage:** SharedPreferences dengan JSON string
- **Write pattern:** Full list rewrite setiap perubahan
- **Scalability:** Optimal untuk < 1000 transaksi

### Future Optimization (Issue #5)
Jika dataset membesar, pertimbangkan migrasi ke:
- **SQLite/Drift:** Query efisien, indexing, ACID transaction
- **Isar:** NoSQL high-performance mobile database
- **Hive:** Lightweight key-value dengan complex object support

**Indikasi perlu migrasi:**
- Save time > 100ms
- Memory usage meningkat signifikan
- Perlu query/filter kompleks
- Butuh cloud sync

## 🧪 Testing

```bash
flutter analyze          # static analysis
flutter test             # seluruh unit & widget test
flutter test test/budget_test.dart   # hanya test fitur anggaran
```

`test/budget_test.dart` memuat test untuk: formatting/pemarsian nominal
(`CurrencyHelper`), CRUD anggaran & progress (`FinanceProvider`), lifecycle
anggaran terhadap penghapusan kategori, round-trip backup JSON v2, dan widget
test yang memastikan tombol "Tambah Anggaran Kategori" membuka pemilih kategori
(bukan dialog anggaran total) serta validasi inputnya bekerja.

`test/budget_layout_test.dart` menyisir 27 kombinasi ukuran layar (320×568,
360×480, 411×914) × skala teks (1.0, 1.5, 2.0) untuk halaman anggaran, dialog
nominal, dan pemilih kategori. Flutter menandai overflow saat test memproses
frame, jadi file ini otomatis gagal bila ada `Row`/`Column` yang melebihi
ruangnya — itulah yang mencegah yellow-and-black striped warning kembali muncul.

## 🤝 Contributing

1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

## 📝 Changelog

### [1.0.0] - Unreleased

**Added:**
- CRUD transaksi lengkap
- 15 kategori default
- Filter & pencarian
- Statistik per kategori
- Tema terang/gelap dengan persistensi
- Sample data untuk first-run experience (ikut berbahasa)
- Kategori kustom (CRUD) — penghapusan diblokir jika masih dipakai transaksi (Issue #6)
- Ekspor/Impor data: JSON & CSV, share, preview + 3 strategi import (Issue #7a)
- Grafik: donut chart proporsi kategori & bar chart tren 6 bulan (Issue #7b)
- Anggaran bulanan: total & per kategori, 3 level status (Issue #7c)
- Multi-bahasa Indonesia/English dengan pemilih bahasa + persistensi (Issue #9)
- Ikon aplikasi (`assets/icon/icon.webp`) seragam di semua platform: Android (adaptive icon), iOS, Web, Windows, macOS & Linux
- Logo aplikasi seragam di seluruh UI lewat widget `AppLogo`

**Fixed:**
- Tombol "Tambah Anggaran Kategori" membuka dialog anggaran total, sehingga anggaran per kategori tidak pernah bisa dibuat
- Input kosong/bukan angka di dialog anggaran diubah jadi 0 (anggaran terhapus senyap) dan pesan "Nominal tidak valid" tidak pernah muncul
- Anggaran kategori tersisa (yatim) setelah kategori dihapus dan tampil sebagai "Lainnya" yang menyesatkan
- Anggaran & kategori custom tidak ikut ekspor/backup JSON
- Blok anggaran di layar Statistik tetap tampil saat membuka bulan lain (angka dihitung dari bulan berjalan)
- Menu ⋮ di layar Statistik hardcoded bahasa Inggris
- BudgetScreen tidak bereaksi saat data anggaran berubah dari layar lain (sekarang dibungkus `ListenableBuilder`)
- Layar "Kelola Anggaran" tidak ikut me-refresh dari provider
- Saldo input anggaran tidak memakai pemisah ribuan
- RenderFlex overflow "BOTTOM OVERFLOWED" pada dialog nominal anggaran (dialog melebihi tinggi layar, terutama saat keyboard terbuka atau teks diperbesar)
- RenderFlex overflow pada kartu anggaran & kartu mini di Statistik saat nominalnya panjang (angka terpotong di tepi kartu)
- `l10n.yaml` belum ada sehingga `flutter gen-l10n` menulis file duplikat yang tidak terpakai di `lib/l10n/` (sekarang output diarahkan ke `lib/l10n/generated/`)
- Risiko kehilangan data (per-record parsing & backup)
- copyWith tidak bisa mengosongkan note
- Tema tidak tersimpan antar sesi
- Amount menggunakan int (bukan double)
- Skalabilitas repository (Issue #5)

**Changed:**
- Package name: `flutter_project` → `catat_keuangan`
- Nama aplikasi: `CatatKeun!` → `CatetKeun`

## 📄 License

MIT License - Lihat [LICENSE](LICENSE) untuk detail

## 👥 Authors

- **Your Name** - [your.email@example.com](mailto:your.email@example.com)

## 🙏 Acknowledgments

- Material Design 3 untuk design system
- Flutter team untuk framework yang luar biasa
- Semua kontributor yang membantu improve aplikasi ini

---

**Made with ❤️ in Indonesia** 🇮🇩
