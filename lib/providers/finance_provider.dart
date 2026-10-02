import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/budget_repository.dart';
import '../services/category_repository.dart';
import '../services/transaction_repository.dart';
import '../utils/currency_helper.dart';
import '../utils/date_helper.dart';

class CategoryStat {
  final TransactionCategory category;
  final int totalAmount;
  final int count;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.totalAmount,
    required this.count,
    required this.percentage,
  });
}

/// Data tren bulanan untuk chart
class MonthlyTrendData {
  final DateTime month;
  final int income;
  final int expense;

  const MonthlyTrendData({
    required this.month,
    required this.income,
    required this.expense,
  });

  int get balance => income - expense;
}

class FinanceProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final BudgetRepository _budgetRepository = BudgetRepository();
  static const String _themeKey = 'app_theme_mode';
  static const String _localeKey = 'app_locale';

  List<Transaction> _transactions = [];
  List<TransactionCategory> _customCategories = [];
  List<Budget> _budgets = [];
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  TransactionType? _selectedTypeFilter;
  String _searchQuery = '';
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('id');

  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  DateTime get selectedMonth => _selectedMonth;
  TransactionType? get selectedTypeFilter => _selectedTypeFilter;
  String get searchQuery => _searchQuery;
  List<Transaction> get allTransactions => _transactions;
  List<TransactionCategory> get customCategories => _customCategories;
  List<Budget> get budgets => List.unmodifiable(_budgets);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load tema dan bahasa yang tersimpan
    await _loadPreferences();

    // Kategori custom wajib dimuat DULU: transaksi hanya menyimpan
    // `categoryId`, sehingga tanpa daftar kategori kustom transaksi yang
    // memakai kategori buatan user akan jatuh ke "Lainnya" saat di-parse.
    // Anggaran tidak bergantung pada keduanya, jadi boleh paralel.
    _customCategories = await _categoryRepository.loadCustomCategories();
    final results = await Future.wait([
      _repository.loadTransactions(customCategories: _customCategories),
      _budgetRepository.loadBudgets(),
    ]);

    _transactions = results[0] as List<Transaction>;
    _budgets = results[1] as List<Budget>;

    // Data contoh (sample) ditulis dalam bahasa Indonesia oleh repository.
    // Lokalisasi sesuai bahasa aktif - hanya berlaku saat user belum
    // punya data sendiri.
    await _localizeSampleData();

    _isLoading = false;
    notifyListeners();
  }

  /// Muat ulang data transaksi, kategori custom, dan anggaran dari storage.
  ///
  /// Dipakai setelah impor/ekspor yang menulis langsung ke repository
  /// (bukan lewat provider), supaya state provider sinkron tanpa harus
  /// mengulang langkah first-run (`_loadPreferences`, `_localizeSampleData`).
  Future<void> reloadData() async {
    // Kategori custom dulu (transaksi hanya menyimpan categoryId).
    _customCategories = await _categoryRepository.loadCustomCategories();
    final results = await Future.wait([
      _repository.loadTransactions(customCategories: _customCategories),
      _budgetRepository.loadBudgets(),
    ]);

    _transactions = results[0] as List<Transaction>;
    _budgets = results[1] as List<Budget>;
    notifyListeners();
  }

  /// Ganti judul/catatan data contoh sesuai bahasa aktif.
  Future<void> _localizeSampleData() async {
    if (_transactions.isEmpty) return;
    final isSampleOnly =
        _transactions.every((t) => t.id.startsWith('sample_'));
    if (!isSampleOnly) return;

    final AppLocalizations l10n;
    try {
      l10n = await AppLocalizations.delegate.load(_locale);
    } catch (_) {
      return;
    }

    final Map<String, (String, String)> localized = {
      'sample_1': (l10n.sampleSalaryTitle, l10n.sampleSalaryNote),
      'sample_2': (l10n.sampleShoppingTitle, l10n.sampleShoppingNote),
      'sample_3': (l10n.sampleFuelTitle, l10n.sampleFuelNote),
      'sample_4': (l10n.sampleLunchTitle, l10n.sampleLunchNote),
      'sample_5': (l10n.sampleSideJobTitle, l10n.sampleSideJobNote),
    };

    bool changed = false;
    for (int i = 0; i < _transactions.length; i++) {
      final pair = localized[_transactions[i].id];
      if (pair == null) continue;
      if (_transactions[i].title == pair.$1 &&
          _transactions[i].note == pair.$2) {
        continue;
      }
      _transactions[i] = _transactions[i].copyWith(
        title: pair.$1,
        note: pair.$2,
      );
      changed = true;
    }

    if (changed) notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeString = prefs.getString(_themeKey);
    if (themeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == themeString,
        orElse: () => ThemeMode.system,
      );
    }

    final localeString = prefs.getString(_localeKey);
    if (localeString != null) {
      _locale = Locale(localeString);
    }

    // Sinkronkan helper format (mata uang, tanggal, label hari)
    await _syncLocaleHelpers();
  }

  /// Samakan helper format mata uang/tanggal dengan [_locale] yang aktif.
  Future<void> _syncLocaleHelpers() async {
    final code = _locale.languageCode;
    CurrencyHelper.locale = code;
    DateHelper.locale = code;

    try {
      final l10n = await AppLocalizations.delegate.load(_locale);
      DateHelper.todayLabel = l10n.today;
      DateHelper.yesterdayLabel = l10n.yesterday;
    } catch (_) {
      // Fallback ke default Indonesia
    }
  }

  /// Ganti bahasa aplikasi ('id' atau 'en').
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);

    // Sinkronkan locale untuk format mata uang & tanggal + label hari
    await _syncLocaleHelpers();

    // Data contoh juga ikut berganti bahasa
    await _localizeSampleData();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);

    notifyListeners();
  }

  /// Set theme mode and persist preference
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }

  /// Toggle between light and dark themes. If system mode, default to dark.
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    if (_themeMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.dark;
    }
    await setTheme(newMode);
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // Daftar transaksi bulan terpilih
  List<Transaction> get currentMonthTransactions {
    return _transactions.where((t) {
      return DateHelper.isSameMonth(t.date, _selectedMonth);
    }).toList();
  }

  // Transaksi yang difilter untuk ditampilkan di list
  List<Transaction> get filteredTransactions {
    final list = currentMonthTransactions.where((t) {
      final matchesType = _selectedTypeFilter == null || t.type == _selectedTypeFilter;
      final matchesQuery = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          t.category.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesQuery;
    }).toList();

    // Urutkan dari yang paling baru
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Total Pemasukan bulan ini
  int get currentMonthIncome {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Total Pengeluaran bulan ini
  int get currentMonthExpense {
    return currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Saldo bersih bulan ini
  int get currentMonthBalance => currentMonthIncome - currentMonthExpense;

  // Total saldo keseluruhan sepanjang waktu
  int get totalBalance {
    final totalInc = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
    final totalExp = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
    return totalInc - totalExp;
  }

  // Statistik Kategori untuk Pengeluaran bulan ini
  List<CategoryStat> getExpenseCategoryStats() {
    return _calculateCategoryStats(TransactionType.expense);
  }

  // Statistik Kategori untuk Pemasukan bulan ini
  List<CategoryStat> getIncomeCategoryStats() {
    return _calculateCategoryStats(TransactionType.income);
  }

  /// Data tren N bulan terakhir (untuk bar chart)
  /// Returns list of {month, income, expense} dari yang paling lama ke terbaru
  List<MonthlyTrendData> getMonthlyTrend({int months = 6}) {
    final now = DateTime.now();
    final result = <MonthlyTrendData>[];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthTx = _transactions.where((t) => DateHelper.isSameMonth(t.date, month));

      int income = 0;
      int expense = 0;
      for (final t in monthTx) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }

      result.add(MonthlyTrendData(
        month: month,
        income: income,
        expense: expense,
      ));
    }

    return result;
  }

  List<CategoryStat> _calculateCategoryStats(TransactionType type) {
    final targetTransactions = currentMonthTransactions.where((t) => t.type == type).toList();
    final total = targetTransactions.fold(0, (sum, t) => sum + t.amount);

    if (total == 0) return [];

    final Map<String, List<Transaction>> grouped = {};
    for (final t in targetTransactions) {
      grouped.putIfAbsent(t.category.id, () => []).add(t);
    }

    final stats = grouped.entries.map((entry) {
      final category = entry.value.first.category;
      final catTotal = entry.value.fold(0, (sum, t) => sum + t.amount);
      final count = entry.value.length;
      final percentage = (catTotal / total) * 100.0;

      return CategoryStat(
        category: category,
        totalAmount: catTotal,
        count: count,
        percentage: percentage,
      );
    }).toList();

    // Urutkan dari nominal pengeluaran/pemasukan terbesar
    stats.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return stats;
  }

  // ==================== KATEGORI ====================

  /// Semua kategori (default + custom) berdasarkan tipe
  List<TransactionCategory> getCategoriesByType(TransactionType type) {
    final defaults = type == TransactionType.income
        ? TransactionCategory.defaultIncomeCategories
        : TransactionCategory.defaultExpenseCategories;
    
    final customs = _customCategories.where((c) => c.type == type).toList();
    
    return [...defaults, ...customs];
  }

  /// Dapatkan kategori by ID (termasuk custom)
  TransactionCategory getCategoryById(String id) {
    return TransactionCategory.getById(id, customCategories: _customCategories);
  }

  /// Hitung jumlah transaksi yang menggunakan kategori tertentu
  int getCategoryUsageCount(String categoryId) {
    return _transactions.where((t) => t.category.id == categoryId).length;
  }

  /// Cek apakah kategori bisa dihapus
  /// Returns: [CategoryDeleteCheck] dengan `error == null` jika boleh dihapus.
  CategoryDeleteCheck canDeleteCategory(TransactionCategory category) {
    // Kategori default tidak bisa dihapus
    if (!category.isCustom) {
      return const CategoryDeleteCheck(
        error: CategoryError.defaultCategoryCannotDelete,
      );
    }

    // Cek apakah masih dipakai
    final usageCount = getCategoryUsageCount(category.id);
    if (usageCount > 0) {
      return CategoryDeleteCheck(
        error: CategoryError.inUse,
        usageCount: usageCount,
      );
    }

    return const CategoryDeleteCheck(); // Bisa dihapus
  }

  /// Tambah kategori custom baru
  Future<TransactionCategory> addCategory({
    required String name,
    required IconData icon,
    required Color color,
    required TransactionType type,
  }) async {
    final id = _categoryRepository.generateId(type);
    final newCategory = TransactionCategory(
      id: id,
      name: name.trim(),
      icon: icon,
      color: color,
      type: type,
      isCustom: true,
    );

    _customCategories.add(newCategory);
    await _categoryRepository.saveCustomCategories(_customCategories);
    notifyListeners();

    return newCategory;
  }

  /// Update kategori custom yang sudah ada
  Future<void> updateCategory(TransactionCategory category) async {
    if (!category.isCustom) {
      throw const CategoryException(CategoryError.defaultCategoryCannotEdit);
    }

    final index = _customCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _customCategories[index] = category;
      await _categoryRepository.saveCustomCategories(_customCategories);

      // Update transaksi yang menggunakan kategori ini
      bool hasChanges = false;
      for (int i = 0; i < _transactions.length; i++) {
        if (_transactions[i].category.id == category.id) {
          _transactions[i] = _transactions[i].copyWith(category: category);
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _repository.saveTransactions(_transactions);
      }

      notifyListeners();
    }
  }

  /// Hapus kategori custom (hanya jika tidak dipakai)
  Future<void> deleteCategory(String categoryId) async {
    TransactionCategory? found;
    for (final c in _customCategories) {
      if (c.id == categoryId) {
        found = c;
        break;
      }
    }
    final category = found ??
        (throw const CategoryException(CategoryError.notFound));

    // Validasi: cek bisa dihapus
    final check = canDeleteCategory(category);
    if (!check.canDelete) {
      throw CategoryException(check.error!, usageCount: check.usageCount);
    }

    _customCategories.removeWhere((c) => c.id == categoryId);
    await _categoryRepository.saveCustomCategories(_customCategories);

    // Anggaran kategori yang dihapus ikut dibuang agar tidak
    // menyisakan anggaran yatim yang tampil menyesatkan.
    final hadBudget = _budgets.any((b) => b.categoryId == categoryId);
    _budgets.removeWhere((b) => b.categoryId == categoryId);
    if (hadBudget) {
      await _budgetRepository.saveBudgets(_budgets);
    }

    notifyListeners();
  }

  /// Cari kategori (default maupun custom) berdasarkan ID.
  /// Return null jika ID sudah tidak dikenal.
  TransactionCategory? _findCategoryOrNull(String id) {
    for (final c in _customCategories) {
      if (c.id == id) return c;
    }
    for (final c in TransactionCategory.allDefaultCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Apakah kategori dengan [id] masih ada?
  bool hasCategory(String id) => _findCategoryOrNull(id) != null;

  // ==================== ANGGARAN (BUDGET) ====================

  /// Total pengeluaran bulan terpilih (atau bulan berjalan untuk budget).
  int _spentInMonth(DateTime month, {String? categoryId}) {
    int total = 0;
    for (final t in _transactions) {
      if (t.type != TransactionType.expense) continue;
      if (!DateHelper.isSameMonth(t.date, month)) continue;
      if (categoryId != null && t.category.id != categoryId) continue;
      total += t.amount;
    }
    return total;
  }

  /// Progress budget global (total pengeluaran bulan berjalan).
  BudgetProgress? getGlobalBudgetProgress() {
    final global = getGlobalBudget();
    if (global == null) return null;

    final now = DateTime.now();
    final spent = _spentInMonth(DateTime(now.year, now.month));
    return BudgetProgress(
      budget: global,
      spent: spent,
      limit: global.monthlyLimit,
    );
  }

  /// Progress semua budget per kategori untuk bulan berjalan.
  ///
  /// Anggaran milik kategori yang sudah dihapus atau kategori non-
  /// pengeluaran dilewati agar tidak muncul kartu "Lainnya" palsu.
  List<BudgetProgress> getCategoryBudgetProgress() {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final result = <BudgetProgress>[];

    for (final b in _budgets) {
      if (b.isGlobal) continue;
      final categoryId = b.categoryId;
      if (categoryId == null) continue;

      final category = _findCategoryOrNull(categoryId);
      if (category == null || category.type != TransactionType.expense) {
        continue;
      }

      final spent = _spentInMonth(month, categoryId: categoryId);
      result.add(BudgetProgress(
        budget: b,
        spent: spent,
        limit: b.monthlyLimit,
      ));
    }

    // Urutkan: over dulu, lalu warning, lalu safe, lalu berdasarkan % tertinggi
    result.sort((a, b) {
      final statusOrder = {
        BudgetStatus.over: 0,
        BudgetStatus.warning: 1,
        BudgetStatus.safe: 2,
      };
      final cmp = statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
      if (cmp != 0) return cmp;
      return b.percentage.compareTo(a.percentage);
    });

    return result;
  }

  /// Budget total pengeluaran bulanan (null jika belum diatur).
  Budget? getGlobalBudget() {
    for (final b in _budgets) {
      if (b.isGlobal) return b;
    }
    return null;
  }

  /// Budget milik [categoryId] (null jika belum diatur).
  Budget? getBudgetForCategory(String categoryId) {
    for (final b in _budgets) {
      if (b.categoryId == categoryId) return b;
    }
    return null;
  }

  /// Set/update budget. Jika monthlyLimit <= 0, budget dihapus.
  Future<void> setBudget({
    String? categoryId, // null = global
    required int monthlyLimit,
  }) async {
    final id = categoryId ?? 'global';

    // Hapus budget lama dengan ID sama
    _budgets.removeWhere((b) => b.id == id);

    // Tambah jika limit valid
    if (monthlyLimit > 0) {
      _budgets.add(Budget(
        id: id,
        categoryId: categoryId,
        monthlyLimit: monthlyLimit,
      ));
    }

    await _budgetRepository.saveBudgets(_budgets);
    notifyListeners();
  }

  /// Hapus budget.
  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _budgetRepository.saveBudgets(_budgets);
    notifyListeners();
  }

  // Aksi CRUD
  Future<void> addTransaction(Transaction tx) async {
    _transactions.insert(0, tx);
    await _repository.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction tx) async {
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      await _repository.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _repository.saveTransactions(_transactions);
    notifyListeners();
  }
}
