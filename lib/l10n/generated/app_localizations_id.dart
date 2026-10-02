// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'CatetKeun';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get add => 'Tambah';

  @override
  String get done => 'Selesai';

  @override
  String get continueBtn => 'Lanjutkan';

  @override
  String get close => 'Tutup';

  @override
  String get income => 'Pemasukan';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get incomeShort => 'Masuk';

  @override
  String get expenseShort => 'Keluar';

  @override
  String get previousMonth => 'Bulan Sebelumnya';

  @override
  String get nextMonth => 'Bulan Berikutnya';

  @override
  String get today => 'Hari ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get searchTitle => 'Cari Transaksi';

  @override
  String get closeSearchTitle => 'Tutup Pencarian';

  @override
  String get searchHint => 'Cari transaksi...';

  @override
  String get moreMenu => 'Menu Lainnya';

  @override
  String get manageBudgetMenu => 'Kelola Anggaran';

  @override
  String get manageCategoryMenu => 'Kelola Kategori';

  @override
  String get exportImportMenu => 'Ekspor/Impor Data';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get navTransactions => 'Transaksi';

  @override
  String get navStatistics => 'Statistik';

  @override
  String get navAbout => 'Tentang';

  @override
  String get addTransaction => 'Catat Transaksi';

  @override
  String get transactionHistory => 'Riwayat Transaksi';

  @override
  String transactionCount(int count) {
    return '$count transaksi';
  }

  @override
  String get emptyTransactionsTitle => 'Belum Ada Transaksi';

  @override
  String emptySearchMessage(String query) {
    return 'Tidak ditemukan transaksi yang cocok dengan kata kunci \"$query\".';
  }

  @override
  String emptyPeriodMessage(String period) {
    return 'Belum ada catatan keuangan pada periode $period.';
  }

  @override
  String get addNewRecord => 'Tambah Catatan Baru';

  @override
  String transactionDeleted(String title) {
    return 'Catatan \"$title\" dihapus';
  }

  @override
  String get undo => 'Urungkan';

  @override
  String get monthlyBalance => 'Saldo Bulan Ini';

  @override
  String totalBalance(String amount) {
    return 'Total: $amount';
  }

  @override
  String get allFilter => 'Semua';

  @override
  String get statisticsTitle => 'Laporan & Statistik';

  @override
  String get listViewTooltip => 'Tampilan Daftar';

  @override
  String get chartViewTooltip => 'Tampilan Grafik';

  @override
  String totalThisMonth(String type) {
    return 'Total $type Bulan Ini';
  }

  @override
  String categoriesRecorded(int count) {
    return '$count Kategori tercatat';
  }

  @override
  String get budgetThisMonth => 'Anggaran Bulan Ini';

  @override
  String get setBudget => 'Atur';

  @override
  String get categoryBreakdown => 'Rincian per Kategori';

  @override
  String get emptyDataTitle => 'Belum Ada Data';

  @override
  String emptyStatsMessage(String type, String period) {
    return 'Tidak ada catatan $type pada periode $period.';
  }

  @override
  String get proportionPerCategory => 'Proporsi per Kategori';

  @override
  String get trendTitle => 'Tren 6 Bulan Terakhir';

  @override
  String get trendSubtitle => 'Perbandingan pemasukan vs pengeluaran';

  @override
  String categoryTransactionCount(int count) {
    return '$count transaksi';
  }

  @override
  String get chartTotalLabel => 'Total';

  @override
  String get compactBillion => 'M';

  @override
  String get compactMillion => 'Jt';

  @override
  String get compactThousand => 'K';

  @override
  String get addRecordTitle => 'Tambah Catatan Baru';

  @override
  String get editRecordTitle => 'Ubah Catatan';

  @override
  String get updateRecord => 'Perbarui Catatan';

  @override
  String get saveTransaction => 'Simpan Transaksi';

  @override
  String get amountLabel => 'Nominal';

  @override
  String get amountRequired => 'Masukkan nominal transaksi';

  @override
  String get amountMustBePositive => 'Nominal harus lebih dari 0';

  @override
  String get transactionTitleLabel => 'Judul Transaksi';

  @override
  String get transactionTitleRequired => 'Judul transaksi wajib diisi';

  @override
  String get transactionTitleHint => 'Misal: Makan Siang, Gaji Kantor, dll.';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get noteOptionalLabel => 'Catatan Tambahan (Opsional)';

  @override
  String get noteHint => 'Keterangan atau rincian tambahan...';

  @override
  String get deleteRecordAction => 'Hapus Catatan';

  @override
  String get deleteRecordTitle => 'Hapus Catatan?';

  @override
  String get deleteRecordMessage => 'Catatan ini akan dihapus secara permanen.';

  @override
  String deleteTransactionConfirm(String title) {
    return 'Apakah Anda yakin ingin menghapus catatan \"$title\"?';
  }

  @override
  String get manageCategoryTitle => 'Kelola Kategori';

  @override
  String yourCategories(int count) {
    return 'Kategori Kamu ($count)';
  }

  @override
  String defaultCategories(int count) {
    return 'Kategori Bawaan ($count)';
  }

  @override
  String get addCategory => 'Tambah Kategori';

  @override
  String categoryAdded(String name) {
    return 'Kategori \"$name\" ditambahkan';
  }

  @override
  String categoryUpdated(String name) {
    return 'Kategori \"$name\" diperbarui';
  }

  @override
  String categoryDeleted(String name) {
    return 'Kategori \"$name\" dihapus';
  }

  @override
  String get deleteCategoryTitle => 'Hapus Kategori?';

  @override
  String deleteCategoryMessage(String name) {
    return 'Kategori \"$name\" akan dihapus permanen.';
  }

  @override
  String get deleteCategoryUnusedInfo =>
      'Kategori ini tidak digunakan oleh transaksi mana pun.';

  @override
  String deleteCategoryFailed(String error) {
    return 'Gagal hapus: $error';
  }

  @override
  String get categoryInUseTooltip => 'Masih dipakai';

  @override
  String get notUsed => 'Tidak digunakan';

  @override
  String get editCategoryTitle => 'Ubah Kategori';

  @override
  String get categoryNameLabel => 'Nama Kategori';

  @override
  String get categoryNameRequired => 'Nama wajib diisi';

  @override
  String get categoryNameMax30 => 'Maksimal 30 karakter';

  @override
  String get categoryNameHint => 'Misal: Kopi, Hewan Peliharaan, dll.';

  @override
  String get pickIcon => 'Pilih Icon';

  @override
  String get pickColor => 'Pilih Warna';

  @override
  String get customBadge => 'Custom';

  @override
  String get categoryEditInfo =>
      'Perubahan akan diterapkan ke semua transaksi yang menggunakan kategori ini.';

  @override
  String actionFailed(String error) {
    return 'Gagal: $error';
  }

  @override
  String get categoryDefaultCannotDelete =>
      'Kategori bawaan tidak dapat dihapus';

  @override
  String get categoryDefaultCannotEdit => 'Kategori default tidak bisa diubah';

  @override
  String categoryStillUsed(int count) {
    return 'Kategori masih digunakan oleh $count transaksi';
  }

  @override
  String get categoryNotFound => 'Kategori tidak ditemukan';

  @override
  String get manageBudgetTitle => 'Kelola Anggaran';

  @override
  String get budgetIntro =>
      'Tetapkan batas pengeluaran bulanan untuk total atau per kategori.';

  @override
  String get totalMonthlyExpense => 'Total Pengeluaran Bulanan';

  @override
  String get totalExpenseLabel => 'Total Pengeluaran';

  @override
  String get totalBudgetCard => 'Anggaran Total';

  @override
  String get perExpenseCategory => 'Per Kategori Pengeluaran';

  @override
  String get noCategoryBudget =>
      'Belum ada anggaran per kategori. Tap tombol + untuk menambah.';

  @override
  String get notSetTapToSet => 'Belum diatur - tap untuk atur anggaran';

  @override
  String get addCategoryBudget => 'Tambah Anggaran Kategori';

  @override
  String get globalBudgetTitle => 'Anggaran Total Bulanan';

  @override
  String categoryBudgetTitle(String name) {
    return 'Anggaran $name';
  }

  @override
  String get globalBudgetDesc =>
      'Batas total pengeluaran semua kategori per bulan.';

  @override
  String get categoryBudgetDesc => 'Batas pengeluaran kategori ini per bulan.';

  @override
  String get enterZeroToDelete => 'Masukkan 0 untuk menghapus anggaran';

  @override
  String currentBudget(String amount) {
    return 'Saat ini: $amount/bulan';
  }

  @override
  String get deleteBudgetTitle => 'Hapus Anggaran?';

  @override
  String deleteBudgetMessage(String title) {
    return 'Anggaran \"$title\" akan dihapus.';
  }

  @override
  String get invalidAmount => 'Nominal tidak valid';

  @override
  String budgetSaveFailed(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String budgetSpent(String amount) {
    return 'Terpakai $amount';
  }

  @override
  String ofLimit(String amount) {
    return 'dari $amount';
  }

  @override
  String overBudgetBy(String amount) {
    return 'Melebihi anggaran $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return 'Tersisa $amount';
  }

  @override
  String moreBudgets(int count) {
    return '+$count anggaran lainnya';
  }

  @override
  String get exportImportTitle => 'Ekspor & Impor Data';

  @override
  String get exportImportSubtitle =>
      'Backup data kamu atau pindahkan ke perangkat lain';

  @override
  String storedTransactions(int count) {
    return '$count transaksi tersimpan';
  }

  @override
  String get exportSection => 'EKSPOR';

  @override
  String get jsonFormat => 'JSON';

  @override
  String get jsonFormatDesc => 'Format lengkap';

  @override
  String get csvFormat => 'CSV';

  @override
  String get csvFormatDesc => 'Untuk Excel';

  @override
  String get importSection => 'IMPOR';

  @override
  String get pickFile => 'Pilih File';

  @override
  String get jsonOrCsv => 'JSON atau CSV';

  @override
  String exportSuccess(String format) {
    return 'File $format berhasil dibuat';
  }

  @override
  String exportFailed(String error) {
    return 'Gagal ekspor: $error';
  }

  @override
  String importFailed(String error) {
    return 'Gagal impor: $error';
  }

  @override
  String pickFileFailed(String error) {
    return 'Gagal memilih file: $error';
  }

  @override
  String get noDataToExport => 'Tidak ada data untuk diekspor';

  @override
  String get noValidTransactions => 'Tidak ada transaksi valid di file';

  @override
  String get errFileReadFailed => 'Gagal membaca file';

  @override
  String get errInvalidJson => 'Format JSON tidak valid';

  @override
  String get errEmptyCsv => 'CSV kosong atau tidak ada data';

  @override
  String get importSuccessTitle => 'Impor Berhasil';

  @override
  String get importPreviewTitle => 'Preview Impor';

  @override
  String get importStrategyTitle => 'Strategi Impor';

  @override
  String get chooseStrategy => 'Pilih cara data dari file diimpor:';

  @override
  String get mergeStrategy => 'Gabungkan (Merge)';

  @override
  String get mergeStrategyDesc =>
      'Data lama dipertahankan, yang sama diperbarui';

  @override
  String get skipStrategy => 'Tambah Baru Saja';

  @override
  String get skipStrategyDesc => 'Skip transaksi yang ID-nya sudah ada';

  @override
  String get replaceStrategy => 'Ganti Semua (Replace)';

  @override
  String get replaceStrategyDesc => 'Hapus data lama, ganti dengan file';

  @override
  String get recommended => 'Disarankan';

  @override
  String transactionsFound(int count) {
    return '$count transaksi ditemukan';
  }

  @override
  String budgetsFound(int count) {
    return '$count anggaran ditemukan';
  }

  @override
  String customCategoriesFound(int count) {
    return '$count kategori custom ditemukan';
  }

  @override
  String get exampleData => 'Contoh data:';

  @override
  String andMore(int count) {
    return '... dan $count lainnya';
  }

  @override
  String get backupShareText => 'Backup data CatetKeun';

  @override
  String backupShareWithCount(int count, String format) {
    return 'Backup CatetKeun - $count transaksi ($format)';
  }

  @override
  String importSummary(int total, int added, int updated, int skipped) {
    return '$total transaksi diimpor ($added baru, $updated diperbarui, $skipped dilewati)';
  }

  @override
  String get importReplaceDesc =>
      'Semua data lama diganti dengan data dari file';

  @override
  String get importMergeDesc =>
      'Data digabung - yang sudah ada diperbarui, yang baru ditambahkan';

  @override
  String get importSkipDesc => 'Hanya transaksi baru yang ditambahkan';

  @override
  String get catExpFood => 'Makanan & Minuman';

  @override
  String get catExpTransport => 'Transportasi';

  @override
  String get catExpShopping => 'Belanja';

  @override
  String get catExpBills => 'Tagihan & Utilitas';

  @override
  String get catExpEntertainment => 'Hiburan';

  @override
  String get catExpHealth => 'Kesehatan';

  @override
  String get catExpEducation => 'Pendidikan';

  @override
  String get catExpOther => 'Lainnya';

  @override
  String get catIncSalary => 'Gaji Pokok';

  @override
  String get catIncBonus => 'Bonus & THR';

  @override
  String get catIncInvestment => 'Investasi';

  @override
  String get catIncBusiness => 'Usaha / Bisnis';

  @override
  String get catIncSale => 'Penjualan Barang';

  @override
  String get catIncGift => 'Hadiah & Hibah';

  @override
  String get catIncOther => 'Lainnya';

  @override
  String get languageSetting => 'Bahasa';

  @override
  String get languageNameId => 'Indonesia';

  @override
  String get languageNameEn => 'English';

  @override
  String get aboutTagline =>
      'Aplikasi Catetan Keuangan membantu Anda mencatat, mengelola, dan menganalisis pengeluaran serta pemasukan secara mudah dan intuitif.';

  @override
  String get aboutVersion => 'Versi';

  @override
  String get aboutDeveloper => 'Pengembang';

  @override
  String get aboutDeveloperName => 'Leona Dev';

  @override
  String get aboutEmail => 'Email';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutLicense => 'Lisensi';

  @override
  String get aboutCopyright => 'Hak Cipta';

  @override
  String get aboutCopyrightValue => '© 2026 Leona';

  @override
  String get aboutThanks =>
      'Terima kasih kepada semua library dan framework open‑source yang digunakan dalam pengembangan aplikasi ini, termasuk Flutter, Provider, dan lainnya.';

  @override
  String get aboutPrivacy => 'Kebijakan Privasi';

  @override
  String get aboutTerms => 'Syarat Penggunaan';

  @override
  String get aboutPrivacyPending =>
      'Kebijakan privasi sedang disiapkan. Data Anda tetap tersimpan hanya di perangkat ini.';

  @override
  String get aboutTermsPending => 'Syarat penggunaan sedang disiapkan.';

  @override
  String get sampleSalaryTitle => 'Gaji Bulanan';

  @override
  String get sampleSalaryNote => 'Transfer gaji kantor';

  @override
  String get sampleShoppingTitle => 'Belanja Mingguan';

  @override
  String get sampleShoppingNote => 'Supermarket';

  @override
  String get sampleFuelTitle => 'Bensin & Tol';

  @override
  String get sampleFuelNote => 'Isi Pertamax';

  @override
  String get sampleLunchTitle => 'Makan Siang & Kopi';

  @override
  String get sampleLunchNote => 'Kafe dekat kantor';

  @override
  String get sampleSideJobTitle => 'Project Sampingan';

  @override
  String get sampleSideJobNote => 'Desain UI freelance';
}
