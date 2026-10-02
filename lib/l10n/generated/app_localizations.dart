import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'CatetKeun'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get add;

  /// No description provided for @done.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get done;

  /// No description provided for @continueBtn.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueBtn;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @income.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expense;

  /// No description provided for @incomeShort.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get incomeShort;

  /// No description provided for @expenseShort.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get expenseShort;

  /// No description provided for @previousMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Sebelumnya'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Berikutnya'**
  String get nextMonth;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterday;

  /// No description provided for @searchTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari Transaksi'**
  String get searchTitle;

  /// No description provided for @closeSearchTitle.
  ///
  /// In id, this message translates to:
  /// **'Tutup Pencarian'**
  String get closeSearchTitle;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari transaksi...'**
  String get searchHint;

  /// No description provided for @moreMenu.
  ///
  /// In id, this message translates to:
  /// **'Menu Lainnya'**
  String get moreMenu;

  /// No description provided for @manageBudgetMenu.
  ///
  /// In id, this message translates to:
  /// **'Kelola Anggaran'**
  String get manageBudgetMenu;

  /// No description provided for @manageCategoryMenu.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get manageCategoryMenu;

  /// No description provided for @exportImportMenu.
  ///
  /// In id, this message translates to:
  /// **'Ekspor/Impor Data'**
  String get exportImportMenu;

  /// No description provided for @lightMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @navTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get navTransactions;

  /// No description provided for @navStatistics.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get navStatistics;

  /// No description provided for @navAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get navAbout;

  /// No description provided for @addTransaction.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get addTransaction;

  /// No description provided for @transactionHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get transactionHistory;

  /// No description provided for @transactionCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String transactionCount(int count);

  /// No description provided for @emptyTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Transaksi'**
  String get emptyTransactionsTitle;

  /// No description provided for @emptySearchMessage.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan transaksi yang cocok dengan kata kunci \"{query}\".'**
  String emptySearchMessage(String query);

  /// No description provided for @emptyPeriodMessage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan keuangan pada periode {period}.'**
  String emptyPeriodMessage(String period);

  /// No description provided for @addNewRecord.
  ///
  /// In id, this message translates to:
  /// **'Tambah Catatan Baru'**
  String get addNewRecord;

  /// No description provided for @transactionDeleted.
  ///
  /// In id, this message translates to:
  /// **'Catatan \"{title}\" dihapus'**
  String transactionDeleted(String title);

  /// No description provided for @undo.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get undo;

  /// No description provided for @monthlyBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Bulan Ini'**
  String get monthlyBalance;

  /// No description provided for @totalBalance.
  ///
  /// In id, this message translates to:
  /// **'Total: {amount}'**
  String totalBalance(String amount);

  /// No description provided for @allFilter.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get allFilter;

  /// No description provided for @statisticsTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan & Statistik'**
  String get statisticsTitle;

  /// No description provided for @listViewTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tampilan Daftar'**
  String get listViewTooltip;

  /// No description provided for @chartViewTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tampilan Grafik'**
  String get chartViewTooltip;

  /// No description provided for @totalThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Total {type} Bulan Ini'**
  String totalThisMonth(String type);

  /// No description provided for @categoriesRecorded.
  ///
  /// In id, this message translates to:
  /// **'{count} Kategori tercatat'**
  String categoriesRecorded(int count);

  /// No description provided for @budgetThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Anggaran Bulan Ini'**
  String get budgetThisMonth;

  /// No description provided for @setBudget.
  ///
  /// In id, this message translates to:
  /// **'Atur'**
  String get setBudget;

  /// No description provided for @categoryBreakdown.
  ///
  /// In id, this message translates to:
  /// **'Rincian per Kategori'**
  String get categoryBreakdown;

  /// No description provided for @emptyDataTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Data'**
  String get emptyDataTitle;

  /// No description provided for @emptyStatsMessage.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada catatan {type} pada periode {period}.'**
  String emptyStatsMessage(String type, String period);

  /// No description provided for @proportionPerCategory.
  ///
  /// In id, this message translates to:
  /// **'Proporsi per Kategori'**
  String get proportionPerCategory;

  /// No description provided for @trendTitle.
  ///
  /// In id, this message translates to:
  /// **'Tren 6 Bulan Terakhir'**
  String get trendTitle;

  /// No description provided for @trendSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Perbandingan pemasukan vs pengeluaran'**
  String get trendSubtitle;

  /// No description provided for @categoryTransactionCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String categoryTransactionCount(int count);

  /// No description provided for @chartTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get chartTotalLabel;

  /// No description provided for @compactBillion.
  ///
  /// In id, this message translates to:
  /// **'M'**
  String get compactBillion;

  /// No description provided for @compactMillion.
  ///
  /// In id, this message translates to:
  /// **'Jt'**
  String get compactMillion;

  /// No description provided for @compactThousand.
  ///
  /// In id, this message translates to:
  /// **'K'**
  String get compactThousand;

  /// No description provided for @addRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Catatan Baru'**
  String get addRecordTitle;

  /// No description provided for @editRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Catatan'**
  String get editRecordTitle;

  /// No description provided for @updateRecord.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Catatan'**
  String get updateRecord;

  /// No description provided for @saveTransaction.
  ///
  /// In id, this message translates to:
  /// **'Simpan Transaksi'**
  String get saveTransaction;

  /// No description provided for @amountLabel.
  ///
  /// In id, this message translates to:
  /// **'Nominal'**
  String get amountLabel;

  /// No description provided for @amountRequired.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nominal transaksi'**
  String get amountRequired;

  /// No description provided for @amountMustBePositive.
  ///
  /// In id, this message translates to:
  /// **'Nominal harus lebih dari 0'**
  String get amountMustBePositive;

  /// No description provided for @transactionTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul Transaksi'**
  String get transactionTitleLabel;

  /// No description provided for @transactionTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Judul transaksi wajib diisi'**
  String get transactionTitleRequired;

  /// No description provided for @transactionTitleHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: Makan Siang, Gaji Kantor, dll.'**
  String get transactionTitleHint;

  /// No description provided for @categoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get categoryLabel;

  /// No description provided for @dateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get dateLabel;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan Tambahan (Opsional)'**
  String get noteOptionalLabel;

  /// No description provided for @noteHint.
  ///
  /// In id, this message translates to:
  /// **'Keterangan atau rincian tambahan...'**
  String get noteHint;

  /// No description provided for @deleteRecordAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus Catatan'**
  String get deleteRecordAction;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Catatan?'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordMessage.
  ///
  /// In id, this message translates to:
  /// **'Catatan ini akan dihapus secara permanen.'**
  String get deleteRecordMessage;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus catatan \"{title}\"?'**
  String deleteTransactionConfirm(String title);

  /// No description provided for @manageCategoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get manageCategoryTitle;

  /// No description provided for @yourCategories.
  ///
  /// In id, this message translates to:
  /// **'Kategori Kamu ({count})'**
  String yourCategories(int count);

  /// No description provided for @defaultCategories.
  ///
  /// In id, this message translates to:
  /// **'Kategori Bawaan ({count})'**
  String defaultCategories(int count);

  /// No description provided for @addCategory.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori'**
  String get addCategory;

  /// No description provided for @categoryAdded.
  ///
  /// In id, this message translates to:
  /// **'Kategori \"{name}\" ditambahkan'**
  String categoryAdded(String name);

  /// No description provided for @categoryUpdated.
  ///
  /// In id, this message translates to:
  /// **'Kategori \"{name}\" diperbarui'**
  String categoryUpdated(String name);

  /// No description provided for @categoryDeleted.
  ///
  /// In id, this message translates to:
  /// **'Kategori \"{name}\" dihapus'**
  String categoryDeleted(String name);

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In id, this message translates to:
  /// **'Kategori \"{name}\" akan dihapus permanen.'**
  String deleteCategoryMessage(String name);

  /// No description provided for @deleteCategoryUnusedInfo.
  ///
  /// In id, this message translates to:
  /// **'Kategori ini tidak digunakan oleh transaksi mana pun.'**
  String get deleteCategoryUnusedInfo;

  /// No description provided for @deleteCategoryFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal hapus: {error}'**
  String deleteCategoryFailed(String error);

  /// No description provided for @categoryInUseTooltip.
  ///
  /// In id, this message translates to:
  /// **'Masih dipakai'**
  String get categoryInUseTooltip;

  /// No description provided for @notUsed.
  ///
  /// In id, this message translates to:
  /// **'Tidak digunakan'**
  String get notUsed;

  /// No description provided for @editCategoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Kategori'**
  String get editCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Kategori'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameMax30.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 30 karakter'**
  String get categoryNameMax30;

  /// No description provided for @categoryNameHint.
  ///
  /// In id, this message translates to:
  /// **'Misal: Kopi, Hewan Peliharaan, dll.'**
  String get categoryNameHint;

  /// No description provided for @pickIcon.
  ///
  /// In id, this message translates to:
  /// **'Pilih Icon'**
  String get pickIcon;

  /// No description provided for @pickColor.
  ///
  /// In id, this message translates to:
  /// **'Pilih Warna'**
  String get pickColor;

  /// No description provided for @customBadge.
  ///
  /// In id, this message translates to:
  /// **'Custom'**
  String get customBadge;

  /// No description provided for @categoryEditInfo.
  ///
  /// In id, this message translates to:
  /// **'Perubahan akan diterapkan ke semua transaksi yang menggunakan kategori ini.'**
  String get categoryEditInfo;

  /// No description provided for @actionFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal: {error}'**
  String actionFailed(String error);

  /// No description provided for @categoryDefaultCannotDelete.
  ///
  /// In id, this message translates to:
  /// **'Kategori bawaan tidak dapat dihapus'**
  String get categoryDefaultCannotDelete;

  /// No description provided for @categoryDefaultCannotEdit.
  ///
  /// In id, this message translates to:
  /// **'Kategori default tidak bisa diubah'**
  String get categoryDefaultCannotEdit;

  /// No description provided for @categoryStillUsed.
  ///
  /// In id, this message translates to:
  /// **'Kategori masih digunakan oleh {count} transaksi'**
  String categoryStillUsed(int count);

  /// No description provided for @categoryNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kategori tidak ditemukan'**
  String get categoryNotFound;

  /// No description provided for @manageBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Anggaran'**
  String get manageBudgetTitle;

  /// No description provided for @budgetIntro.
  ///
  /// In id, this message translates to:
  /// **'Tetapkan batas pengeluaran bulanan untuk total atau per kategori.'**
  String get budgetIntro;

  /// No description provided for @totalMonthlyExpense.
  ///
  /// In id, this message translates to:
  /// **'Total Pengeluaran Bulanan'**
  String get totalMonthlyExpense;

  /// No description provided for @totalExpenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Pengeluaran'**
  String get totalExpenseLabel;

  /// No description provided for @totalBudgetCard.
  ///
  /// In id, this message translates to:
  /// **'Anggaran Total'**
  String get totalBudgetCard;

  /// No description provided for @perExpenseCategory.
  ///
  /// In id, this message translates to:
  /// **'Per Kategori Pengeluaran'**
  String get perExpenseCategory;

  /// No description provided for @noCategoryBudget.
  ///
  /// In id, this message translates to:
  /// **'Belum ada anggaran per kategori. Tap tombol + untuk menambah.'**
  String get noCategoryBudget;

  /// No description provided for @notSetTapToSet.
  ///
  /// In id, this message translates to:
  /// **'Belum diatur - tap untuk atur anggaran'**
  String get notSetTapToSet;

  /// No description provided for @addCategoryBudget.
  ///
  /// In id, this message translates to:
  /// **'Tambah Anggaran Kategori'**
  String get addCategoryBudget;

  /// No description provided for @globalBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggaran Total Bulanan'**
  String get globalBudgetTitle;

  /// No description provided for @categoryBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {name}'**
  String categoryBudgetTitle(String name);

  /// No description provided for @globalBudgetDesc.
  ///
  /// In id, this message translates to:
  /// **'Batas total pengeluaran semua kategori per bulan.'**
  String get globalBudgetDesc;

  /// No description provided for @categoryBudgetDesc.
  ///
  /// In id, this message translates to:
  /// **'Batas pengeluaran kategori ini per bulan.'**
  String get categoryBudgetDesc;

  /// No description provided for @enterZeroToDelete.
  ///
  /// In id, this message translates to:
  /// **'Masukkan 0 untuk menghapus anggaran'**
  String get enterZeroToDelete;

  /// No description provided for @currentBudget.
  ///
  /// In id, this message translates to:
  /// **'Saat ini: {amount}/bulan'**
  String currentBudget(String amount);

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Anggaran?'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetMessage.
  ///
  /// In id, this message translates to:
  /// **'Anggaran \"{title}\" akan dihapus.'**
  String deleteBudgetMessage(String title);

  /// No description provided for @invalidAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal tidak valid'**
  String get invalidAmount;

  /// No description provided for @budgetSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String budgetSaveFailed(String error);

  /// No description provided for @budgetSpent.
  ///
  /// In id, this message translates to:
  /// **'Terpakai {amount}'**
  String budgetSpent(String amount);

  /// No description provided for @ofLimit.
  ///
  /// In id, this message translates to:
  /// **'dari {amount}'**
  String ofLimit(String amount);

  /// No description provided for @overBudgetBy.
  ///
  /// In id, this message translates to:
  /// **'Melebihi anggaran {amount}'**
  String overBudgetBy(String amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In id, this message translates to:
  /// **'Tersisa {amount}'**
  String budgetRemaining(String amount);

  /// No description provided for @moreBudgets.
  ///
  /// In id, this message translates to:
  /// **'+{count} anggaran lainnya'**
  String moreBudgets(int count);

  /// No description provided for @exportImportTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor & Impor Data'**
  String get exportImportTitle;

  /// No description provided for @exportImportSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Backup data kamu atau pindahkan ke perangkat lain'**
  String get exportImportSubtitle;

  /// No description provided for @storedTransactions.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi tersimpan'**
  String storedTransactions(int count);

  /// No description provided for @exportSection.
  ///
  /// In id, this message translates to:
  /// **'EKSPOR'**
  String get exportSection;

  /// No description provided for @jsonFormat.
  ///
  /// In id, this message translates to:
  /// **'JSON'**
  String get jsonFormat;

  /// No description provided for @jsonFormatDesc.
  ///
  /// In id, this message translates to:
  /// **'Format lengkap'**
  String get jsonFormatDesc;

  /// No description provided for @csvFormat.
  ///
  /// In id, this message translates to:
  /// **'CSV'**
  String get csvFormat;

  /// No description provided for @csvFormatDesc.
  ///
  /// In id, this message translates to:
  /// **'Untuk Excel'**
  String get csvFormatDesc;

  /// No description provided for @importSection.
  ///
  /// In id, this message translates to:
  /// **'IMPOR'**
  String get importSection;

  /// No description provided for @pickFile.
  ///
  /// In id, this message translates to:
  /// **'Pilih File'**
  String get pickFile;

  /// No description provided for @jsonOrCsv.
  ///
  /// In id, this message translates to:
  /// **'JSON atau CSV'**
  String get jsonOrCsv;

  /// No description provided for @exportSuccess.
  ///
  /// In id, this message translates to:
  /// **'File {format} berhasil dibuat'**
  String exportSuccess(String format);

  /// No description provided for @exportFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal ekspor: {error}'**
  String exportFailed(String error);

  /// No description provided for @importFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal impor: {error}'**
  String importFailed(String error);

  /// No description provided for @pickFileFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memilih file: {error}'**
  String pickFileFailed(String error);

  /// No description provided for @noDataToExport.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data untuk diekspor'**
  String get noDataToExport;

  /// No description provided for @noValidTransactions.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi valid di file'**
  String get noValidTransactions;

  /// No description provided for @errFileReadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membaca file'**
  String get errFileReadFailed;

  /// No description provided for @errInvalidJson.
  ///
  /// In id, this message translates to:
  /// **'Format JSON tidak valid'**
  String get errInvalidJson;

  /// No description provided for @errEmptyCsv.
  ///
  /// In id, this message translates to:
  /// **'CSV kosong atau tidak ada data'**
  String get errEmptyCsv;

  /// No description provided for @importSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Impor Berhasil'**
  String get importSuccessTitle;

  /// No description provided for @importPreviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Preview Impor'**
  String get importPreviewTitle;

  /// No description provided for @importStrategyTitle.
  ///
  /// In id, this message translates to:
  /// **'Strategi Impor'**
  String get importStrategyTitle;

  /// No description provided for @chooseStrategy.
  ///
  /// In id, this message translates to:
  /// **'Pilih cara data dari file diimpor:'**
  String get chooseStrategy;

  /// No description provided for @mergeStrategy.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan (Merge)'**
  String get mergeStrategy;

  /// No description provided for @mergeStrategyDesc.
  ///
  /// In id, this message translates to:
  /// **'Data lama dipertahankan, yang sama diperbarui'**
  String get mergeStrategyDesc;

  /// No description provided for @skipStrategy.
  ///
  /// In id, this message translates to:
  /// **'Tambah Baru Saja'**
  String get skipStrategy;

  /// No description provided for @skipStrategyDesc.
  ///
  /// In id, this message translates to:
  /// **'Skip transaksi yang ID-nya sudah ada'**
  String get skipStrategyDesc;

  /// No description provided for @replaceStrategy.
  ///
  /// In id, this message translates to:
  /// **'Ganti Semua (Replace)'**
  String get replaceStrategy;

  /// No description provided for @replaceStrategyDesc.
  ///
  /// In id, this message translates to:
  /// **'Hapus data lama, ganti dengan file'**
  String get replaceStrategyDesc;

  /// No description provided for @recommended.
  ///
  /// In id, this message translates to:
  /// **'Disarankan'**
  String get recommended;

  /// No description provided for @transactionsFound.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi ditemukan'**
  String transactionsFound(int count);

  /// No description provided for @budgetsFound.
  ///
  /// In id, this message translates to:
  /// **'{count} anggaran ditemukan'**
  String budgetsFound(int count);

  /// No description provided for @customCategoriesFound.
  ///
  /// In id, this message translates to:
  /// **'{count} kategori custom ditemukan'**
  String customCategoriesFound(int count);

  /// No description provided for @exampleData.
  ///
  /// In id, this message translates to:
  /// **'Contoh data:'**
  String get exampleData;

  /// No description provided for @andMore.
  ///
  /// In id, this message translates to:
  /// **'... dan {count} lainnya'**
  String andMore(int count);

  /// No description provided for @backupShareText.
  ///
  /// In id, this message translates to:
  /// **'Backup data CatetKeun'**
  String get backupShareText;

  /// No description provided for @backupShareWithCount.
  ///
  /// In id, this message translates to:
  /// **'Backup CatetKeun - {count} transaksi ({format})'**
  String backupShareWithCount(int count, String format);

  /// No description provided for @importSummary.
  ///
  /// In id, this message translates to:
  /// **'{total} transaksi diimpor ({added} baru, {updated} diperbarui, {skipped} dilewati)'**
  String importSummary(int total, int added, int updated, int skipped);

  /// No description provided for @importReplaceDesc.
  ///
  /// In id, this message translates to:
  /// **'Semua data lama diganti dengan data dari file'**
  String get importReplaceDesc;

  /// No description provided for @importMergeDesc.
  ///
  /// In id, this message translates to:
  /// **'Data digabung - yang sudah ada diperbarui, yang baru ditambahkan'**
  String get importMergeDesc;

  /// No description provided for @importSkipDesc.
  ///
  /// In id, this message translates to:
  /// **'Hanya transaksi baru yang ditambahkan'**
  String get importSkipDesc;

  /// No description provided for @catExpFood.
  ///
  /// In id, this message translates to:
  /// **'Makanan & Minuman'**
  String get catExpFood;

  /// No description provided for @catExpTransport.
  ///
  /// In id, this message translates to:
  /// **'Transportasi'**
  String get catExpTransport;

  /// No description provided for @catExpShopping.
  ///
  /// In id, this message translates to:
  /// **'Belanja'**
  String get catExpShopping;

  /// No description provided for @catExpBills.
  ///
  /// In id, this message translates to:
  /// **'Tagihan & Utilitas'**
  String get catExpBills;

  /// No description provided for @catExpEntertainment.
  ///
  /// In id, this message translates to:
  /// **'Hiburan'**
  String get catExpEntertainment;

  /// No description provided for @catExpHealth.
  ///
  /// In id, this message translates to:
  /// **'Kesehatan'**
  String get catExpHealth;

  /// No description provided for @catExpEducation.
  ///
  /// In id, this message translates to:
  /// **'Pendidikan'**
  String get catExpEducation;

  /// No description provided for @catExpOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catExpOther;

  /// No description provided for @catIncSalary.
  ///
  /// In id, this message translates to:
  /// **'Gaji Pokok'**
  String get catIncSalary;

  /// No description provided for @catIncBonus.
  ///
  /// In id, this message translates to:
  /// **'Bonus & THR'**
  String get catIncBonus;

  /// No description provided for @catIncInvestment.
  ///
  /// In id, this message translates to:
  /// **'Investasi'**
  String get catIncInvestment;

  /// No description provided for @catIncBusiness.
  ///
  /// In id, this message translates to:
  /// **'Usaha / Bisnis'**
  String get catIncBusiness;

  /// No description provided for @catIncSale.
  ///
  /// In id, this message translates to:
  /// **'Penjualan Barang'**
  String get catIncSale;

  /// No description provided for @catIncGift.
  ///
  /// In id, this message translates to:
  /// **'Hadiah & Hibah'**
  String get catIncGift;

  /// No description provided for @catIncOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catIncOther;

  /// No description provided for @languageSetting.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageSetting;

  /// No description provided for @languageNameId.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get languageNameId;

  /// No description provided for @languageNameEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// No description provided for @aboutTagline.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi Catetan Keuangan membantu Anda mencatat, mengelola, dan menganalisis pengeluaran serta pemasukan secara mudah dan intuitif.'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get aboutVersion;

  /// No description provided for @aboutDeveloper.
  ///
  /// In id, this message translates to:
  /// **'Pengembang'**
  String get aboutDeveloper;

  /// No description provided for @aboutDeveloperName.
  ///
  /// In id, this message translates to:
  /// **'Leona Dev'**
  String get aboutDeveloperName;

  /// No description provided for @aboutEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get aboutEmail;

  /// No description provided for @aboutWebsite.
  ///
  /// In id, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutLicense.
  ///
  /// In id, this message translates to:
  /// **'Lisensi'**
  String get aboutLicense;

  /// No description provided for @aboutCopyright.
  ///
  /// In id, this message translates to:
  /// **'Hak Cipta'**
  String get aboutCopyright;

  /// No description provided for @aboutCopyrightValue.
  ///
  /// In id, this message translates to:
  /// **'© 2026 Leona'**
  String get aboutCopyrightValue;

  /// No description provided for @aboutThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih kepada semua library dan framework open‑source yang digunakan dalam pengembangan aplikasi ini, termasuk Flutter, Provider, dan lainnya.'**
  String get aboutThanks;

  /// No description provided for @aboutPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get aboutPrivacy;

  /// No description provided for @aboutTerms.
  ///
  /// In id, this message translates to:
  /// **'Syarat Penggunaan'**
  String get aboutTerms;

  /// No description provided for @aboutPrivacyPending.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan privasi sedang disiapkan. Data Anda tetap tersimpan hanya di perangkat ini.'**
  String get aboutPrivacyPending;

  /// No description provided for @aboutTermsPending.
  ///
  /// In id, this message translates to:
  /// **'Syarat penggunaan sedang disiapkan.'**
  String get aboutTermsPending;

  /// No description provided for @sampleSalaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Gaji Bulanan'**
  String get sampleSalaryTitle;

  /// No description provided for @sampleSalaryNote.
  ///
  /// In id, this message translates to:
  /// **'Transfer gaji kantor'**
  String get sampleSalaryNote;

  /// No description provided for @sampleShoppingTitle.
  ///
  /// In id, this message translates to:
  /// **'Belanja Mingguan'**
  String get sampleShoppingTitle;

  /// No description provided for @sampleShoppingNote.
  ///
  /// In id, this message translates to:
  /// **'Supermarket'**
  String get sampleShoppingNote;

  /// No description provided for @sampleFuelTitle.
  ///
  /// In id, this message translates to:
  /// **'Bensin & Tol'**
  String get sampleFuelTitle;

  /// No description provided for @sampleFuelNote.
  ///
  /// In id, this message translates to:
  /// **'Isi Pertamax'**
  String get sampleFuelNote;

  /// No description provided for @sampleLunchTitle.
  ///
  /// In id, this message translates to:
  /// **'Makan Siang & Kopi'**
  String get sampleLunchTitle;

  /// No description provided for @sampleLunchNote.
  ///
  /// In id, this message translates to:
  /// **'Kafe dekat kantor'**
  String get sampleLunchNote;

  /// No description provided for @sampleSideJobTitle.
  ///
  /// In id, this message translates to:
  /// **'Project Sampingan'**
  String get sampleSideJobTitle;

  /// No description provided for @sampleSideJobNote.
  ///
  /// In id, this message translates to:
  /// **'Desain UI freelance'**
  String get sampleSideJobNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
