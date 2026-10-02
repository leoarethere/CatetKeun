import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'budget_repository.dart';
import 'category_repository.dart';
import 'transaction_repository.dart';

/// Jenis kegagalan layanan ekspor/impor.
/// Dipakai agar pesan error bisa diterjemahkan UI (l10n).
enum ExportImportErrorKind {
  /// File tidak bisa dibaca.
  fileReadFailed,

  /// Struktur JSON tidak dikenali.
  invalidJson,

  /// CSV kosong / tidak punya baris data.
  emptyCsv,

  /// Tidak ada transaksi valid di file.
  noValidTransactions,
}

/// Exception ber-tipe untuk layanan ekspor/impor.
class ExportImportException implements Exception {
  final ExportImportErrorKind kind;
  const ExportImportException(this.kind);

  @override
  String toString() => 'ExportImportException(${kind.name})';
}

/// Hasil operasi impor
class ImportResult {
  final int totalImported;
  final int added;
  final int updated;
  final int skipped;

  /// Anggaran yang benar-benar ikut dipulihkan dari file.
  final int budgetsImported;

  /// Kategori custom yang benar-benar ikut dipulihkan dari file.
  final int categoriesImported;
  final List<ExportImportErrorKind> errors;
  final bool success;

  const ImportResult({
    required this.totalImported,
    required this.added,
    required this.updated,
    required this.skipped,
    this.budgetsImported = 0,
    this.categoriesImported = 0,
    this.errors = const [],
    this.success = true,
  });
}

/// Preview data sebelum import
class ImportPreview {
  final String fileName;
  final String format; // 'json' atau 'csv'
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final List<TransactionCategory> customCategories;
  final int incomeCount;
  final int incomeTotal;
  final int expenseCount;
  final int expenseTotal;

  const ImportPreview({
    required this.fileName,
    required this.format,
    required this.transactions,
    this.budgets = const [],
    this.customCategories = const [],
    required this.incomeCount,
    required this.incomeTotal,
    required this.expenseCount,
    required this.expenseTotal,
  });

  /// File tidak berisi data apa pun yang bisa diimpor.
  bool get isEmpty =>
      transactions.isEmpty && budgets.isEmpty && customCategories.isEmpty;
}

/// Strategi impor
enum ImportStrategy {
  /// Ganti seluruh data dengan data dari file
  replace,

  /// Tambah data baru, update yang ID-nya sudah ada
  merge,

  /// Tambah data baru, skip jika ID sudah ada
  skipExisting,
}

/// Service untuk ekspor dan impor data transaksi.
class ExportImportService {
  final TransactionRepository _repository;
  final BudgetRepository _budgetRepository;
  final CategoryRepository _categoryRepository;

  ExportImportService({
    TransactionRepository? repository,
    BudgetRepository? budgetRepository,
    CategoryRepository? categoryRepository,
  })  : _repository = repository ?? TransactionRepository(),
        _budgetRepository = budgetRepository ?? BudgetRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository();

  // ==================== EXPORT ====================

  /// Ekspor transaksi (plus anggaran & kategori custom) ke format JSON
  Future<File> exportToJson(
    List<Transaction> transactions, {
    List<Budget> budgets = const [],
    List<TransactionCategory> customCategories = const [],
  }) async {
    // Selalu lewat buildExportJson supaya format file produksi identik
    // dengan yang diuji (tidak ada dua sumber kebenaran).
    final jsonString = buildExportJson(
      transactions,
      budgets: budgets,
      customCategories: customCategories,
    );
    return _writeToFile(jsonString, 'catatkeun_export.json');
  }

  /// Susun JSON backup (murni, tanpa I/O) - dipakai juga oleh pengujian.
  ///
  /// Versi 2 menambahkan `budgets` dan `customCategories`; file versi 1
  /// tetap bisa diimpor karena kedua field bersifat opsional.
  String buildExportJson(
    List<Transaction> transactions, {
    List<Budget> budgets = const [],
    List<TransactionCategory> customCategories = const [],
  }) {
    final data = {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactionCount': transactions.length,
      'budgetCount': budgets.length,
      'customCategoryCount': customCategories.length,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
      'customCategories': customCategories.map((c) => c.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Ekspor transaksi ke format CSV (untuk Excel/Google Sheets)
  Future<File> exportToCsv(List<Transaction> transactions) async {
    return _writeToFile(buildExportCsv(transactions), 'catatkeun_export.csv');
  }

  /// Susun isi CSV (murni, tanpa I/O) - dipakai juga oleh pengujian.
  ///
  /// Kolom Tipe ditulis sebagai `income` / `expense` (kode stabil) agar
  /// file hasil ekspor selalu bisa diimpor kembali, apa pun bahasa aktif
  /// saat mengekspor. Parser ([_parseCsvRow]) tetap menerima label lokal
  /// lama (`Pemasukan`/`Pengeluaran`) demi kompatibilitas mundur.
  String buildExportCsv(List<Transaction> transactions) {
    final buffer = StringBuffer();

    // Header CSV
    buffer.writeln('ID,Judul,Nominal,Tipe,Kategori,Tanggal,Catatan');

    // Data rows
    for (final tx in transactions) {
      final row = [
        _escapeCsv(tx.id),
        _escapeCsv(tx.title),
        tx.amount.toString(),
        tx.type.name,
        _escapeCsv(tx.category.name),
        tx.date.toIso8601String(),
        _escapeCsv(tx.note ?? ''),
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Share file ke aplikasi lain (WhatsApp, Email, dll)
  Future<void> shareFile(File file, {String? text}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: text ?? 'Backup data CatetKeun',
      ),
    );
  }

  // ==================== IMPORT ====================

  /// Pilih file untuk import (tanpa apply) - return null jika dibatalkan.
  ///
  /// [customCategories] adalah kategori custom milik aplikasi saat ini, yang
  /// dipakai untuk me-resolve nama kategori di file CSV (CSV hanya menyimpan
  /// nama, bukan ID). Tanpa ini, kategori custom akan jatuh ke "Lainnya".
  Future<ImportPreview?> pickFileForImport({
    List<TransactionCategory> customCategories = const [],
  }) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
    );

    if (files.isEmpty) {
      // User membatalkan
      return null;
    }

    final file = files.first;

    final Uint8List bytes;
    final String content;
    try {
      bytes = await file.readAsBytes();
      content = utf8.decode(bytes);
    } catch (_) {
      throw const ExportImportException(ExportImportErrorKind.fileReadFailed);
    }

    final format = file.name.toLowerCase().endsWith('.json') ? 'json' : 'csv';

    // Kategori custom dipakai untuk me-resolve kategori transaksi
    // (JSON: dari file itu sendiri; CSV: dari app), supaya tidak jatuh
    // ke "Lainnya".
    final parsed = format == 'json'
        ? _parseJsonBackup(content)
        : _ParsedBackup(
            transactions: _parseCsv(
              content,
              customCategories: customCategories,
            ),
          );

    return _buildPreview(
      fileName: file.name,
      format: format,
      parsed: parsed,
    );
  }

  /// Parse konten CSV backup menjadi preview impor (tanpa I/O).
  /// Dipublikasikan untuk keperluan pengujian.
  ImportPreview parseCsvBackup(
    String content, {
    String fileName = 'backup.csv',
    List<TransactionCategory> customCategories = const [],
  }) {
    return _buildPreview(
      fileName: fileName,
      format: 'csv',
      parsed: _ParsedBackup(
        transactions: _parseCsv(
          content,
          customCategories: customCategories,
        ),
      ),
    );
  }
  /// Parse konten JSON backup menjadi preview impor (tanpa I/O).
  /// Dipublikasikan untuk keperluan pengujian.
  ImportPreview parseJsonBackup(
    String content, {
    String fileName = 'backup.json',
    List<TransactionCategory> customCategories = const [],
  }) {
    return _buildPreview(
      fileName: fileName,
      format: 'json',
      parsed: _parseJsonBackup(content, customCategories: customCategories),
    );
  }

  ImportPreview _buildPreview({
    required String fileName,
    required String format,
    required _ParsedBackup parsed,
  }) {
    // Hitung statistik
    int incomeCount = 0;
    int incomeTotal = 0;
    int expenseCount = 0;
    int expenseTotal = 0;

    for (final tx in parsed.transactions) {
      if (tx.type == TransactionType.income) {
        incomeCount++;
        incomeTotal += tx.amount;
      } else {
        expenseCount++;
        expenseTotal += tx.amount;
      }
    }

    return ImportPreview(
      fileName: fileName,
      format: format,
      transactions: parsed.transactions,
      budgets: parsed.budgets,
      customCategories: parsed.customCategories,
      incomeCount: incomeCount,
      incomeTotal: incomeTotal,
      expenseCount: expenseCount,
      expenseTotal: expenseTotal,
    );
  }

  /// Apply import dengan strategi yang dipilih
  Future<ImportResult> applyImport({
    required ImportPreview preview,
    required List<Transaction> currentTransactions,
    required ImportStrategy strategy,
  }) async {
    final hasTransactions = preview.transactions.isNotEmpty;
    final hasBudgets = preview.budgets.isNotEmpty;
    final hasCategories = preview.customCategories.isNotEmpty;

    if (!hasTransactions && !hasBudgets && !hasCategories) {
      return const ImportResult(
        totalImported: 0,
        added: 0,
        updated: 0,
        skipped: 0,
        success: false,
        errors: [ExportImportErrorKind.noValidTransactions],
      );
    }

    int added = 0;
    int updated = 0;
    int skipped = 0;

    // File tanpa transaksi (mis. hanya berisi anggaran): data transaksi
    // lama dipertahankan, termasuk saat strategi "replace" dipilih.
    if (hasTransactions) {
      List<Transaction> finalList;

      switch (strategy) {
        case ImportStrategy.replace:
          // Ganti seluruh data
          finalList = List.from(preview.transactions);
          added = preview.transactions.length;
          break;

        case ImportStrategy.merge:
          // Merge: update jika ID sama, tambah jika baru
          final merged = <String, Transaction>{};
          for (final tx in currentTransactions) {
            merged[tx.id] = tx;
          }

          for (final tx in preview.transactions) {
            if (merged.containsKey(tx.id)) {
              merged[tx.id] = tx;
              updated++;
            } else {
              merged[tx.id] = tx;
              added++;
            }
          }

          finalList = merged.values.toList();
          break;

        case ImportStrategy.skipExisting:
          // Skip jika ID sudah ada
          final existingIds = currentTransactions.map((t) => t.id).toSet();
          finalList = List.from(currentTransactions);

          for (final tx in preview.transactions) {
            if (existingIds.contains(tx.id)) {
              skipped++;
            } else {
              finalList.add(tx);
              added++;
            }
          }
          break;
      }

      // Sort by date descending
      finalList.sort((a, b) => b.date.compareTo(a.date));

      // Save
      await _repository.saveTransactions(finalList);
    }

    // Anggaran & kategori custom (hanya ada di file JSON hasil ekspor
    // versi 2; file lama tidak membawanya sehingga bagian ini dilewati).
    int budgetsImported = 0;
    int categoriesImported = 0;
    if (hasCategories) {
      categoriesImported = await _importCustomCategories(
        preview.customCategories,
        strategy,
      );
    }
    if (hasBudgets) {
      budgetsImported = await _importBudgets(preview.budgets, strategy);
    }

    return ImportResult(
      totalImported: preview.transactions.length,
      added: added,
      updated: updated,
      skipped: skipped,
      budgetsImported: budgetsImported,
      categoriesImported: categoriesImported,
    );
  }

  /// Impor anggaran, me-return jumlah anggaran efektif setelah impor.
  Future<int> _importBudgets(
    List<Budget> imported,
    ImportStrategy strategy,
  ) async {
    switch (strategy) {
      case ImportStrategy.replace:
        await _budgetRepository.saveBudgets(imported);
        return imported.length;

      case ImportStrategy.merge:
        final current = await _budgetRepository.loadBudgets();
        final byId = <String, Budget>{for (final b in current) b.id: b};
        for (final b in imported) {
          byId[b.id] = b; // data dari file menang
        }
        final merged = byId.values.toList();
        await _budgetRepository.saveBudgets(merged);
        return merged.length;

      case ImportStrategy.skipExisting:
        final current = await _budgetRepository.loadBudgets();
        final existingIds = current.map((b) => b.id).toSet();
        final merged = [
          ...current,
          ...imported.where((b) => !existingIds.contains(b.id)),
        ];
        await _budgetRepository.saveBudgets(merged);
        return merged.length;
    }
  }

  /// Impor kategori custom, me-return jumlah kategori efektif setelah impor.
  Future<int> _importCustomCategories(
    List<TransactionCategory> imported,
    ImportStrategy strategy,
  ) async {
    // Hanya kategori custom yang bisa disimpan repository.
    final incoming = imported.where((c) => c.isCustom).toList();
    if (incoming.isEmpty) return 0;

    switch (strategy) {
      case ImportStrategy.replace:
        await _categoryRepository.saveCustomCategories(incoming);
        return incoming.length;

      case ImportStrategy.merge:
        final current = await _categoryRepository.loadCustomCategories();
        final byId = <String, TransactionCategory>{
          for (final c in current) c.id: c
        };
        for (final c in incoming) {
          byId[c.id] = c; // data dari file menang
        }
        final merged = byId.values.toList();
        await _categoryRepository.saveCustomCategories(merged);
        return merged.length;

      case ImportStrategy.skipExisting:
        final current = await _categoryRepository.loadCustomCategories();
        final existingIds = current.map((c) => c.id).toSet();
        final merged = [
          ...current,
          ...incoming.where((c) => !existingIds.contains(c.id)),
        ];
        await _categoryRepository.saveCustomCategories(merged);
        return merged.length;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<File> _writeToFile(String content, String fileName) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}${Platform.pathSeparator}${timestamp}_$fileName';
    final file = File(path);
    await file.writeAsString(content);
    return file;
  }

  String _escapeCsv(String value) {
    // Jika mengandung comma, quote, atau newline, bungkus dengan quote
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  _ParsedBackup _parseJsonBackup(
    String content, {
    List<TransactionCategory> customCategories = const [],
  }) {
    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw const ExportImportException(ExportImportErrorKind.invalidJson);
    }

    // Handle format baru (dengan wrapper)
    if (decoded is Map<String, dynamic> &&
        (decoded.containsKey('transactions') ||
            decoded.containsKey('budgets') ||
            decoded.containsKey('customCategories'))) {
      final categories = _parseCategoryList(decoded['customCategories']);
      final effectiveCustoms =
          customCategories.isEmpty ? categories : customCategories;
      return _ParsedBackup(
        transactions: decoded['transactions'] is List
            ? _parseTransactionList(
                decoded['transactions'] as List<dynamic>,
                customCategories: effectiveCustoms,
              )
            : const [],
        budgets: _parseBudgetList(decoded['budgets']),
        customCategories: categories,
      );
    }

    // Handle format lama (plain array)
    if (decoded is List<dynamic>) {
      return _ParsedBackup(
        transactions: _parseTransactionList(
          decoded,
          customCategories: customCategories,
        ),
      );
    }

    throw const ExportImportException(ExportImportErrorKind.invalidJson);
  }

  List<Transaction> _parseTransactionList(
    List<dynamic> list, {
    List<TransactionCategory> customCategories = const [],
  }) {
    final transactions = <Transaction>[];
    for (final item in list) {
      try {
        transactions.add(
          Transaction.fromJson(
            item as Map<String, dynamic>,
            customCategories: customCategories,
          ),
        );
      } catch (e) {
        debugPrint('Skip record rusak: $e');
        // Continue - skip record yang rusak
      }
    }
    return transactions;
  }

  List<Budget> _parseBudgetList(dynamic raw) {
    if (raw is! List) return const [];
    final budgets = <Budget>[];
    for (final item in raw) {
      try {
        budgets.add(Budget.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skip anggaran rusak: $e');
      }
    }
    return budgets;
  }

  List<TransactionCategory> _parseCategoryList(dynamic raw) {
    if (raw is! List) return const [];
    final categories = <TransactionCategory>[];
    for (final item in raw) {
      try {
        categories.add(
          TransactionCategory.fromJson(item as Map<String, dynamic>),
        );
      } catch (e) {
        debugPrint('Skip kategori rusak: $e');
      }
    }
    return categories;
  }

  List<Transaction> _parseCsv(
    String content, {
    List<TransactionCategory> customCategories = const [],
  }) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) {
      throw const ExportImportException(ExportImportErrorKind.emptyCsv);
    }

    // Skip header
    final transactions = <Transaction>[];
    for (int i = 1; i < lines.length; i++) {
      try {
        final tx = _parseCsvRow(
          lines[i],
          customCategories: customCategories,
        );
        if (tx != null) {
          transactions.add(tx);
        }
      } catch (e) {
        debugPrint('Skip CSV row $i: $e');
      }
    }

    return transactions;
  }

  Transaction? _parseCsvRow(
    String line, {
    List<TransactionCategory> customCategories = const [],
  }) {
    final columns = _parseCsvLine(line);
    if (columns.length < 7) return null;

    final id = columns[0];
    final title = columns[1];
    final amount = int.tryParse(columns[2]);
    final typeStr = columns[3];
    final categoryName = columns[4];
    final dateStr = columns[5];
    final note = columns[6].isEmpty ? null : columns[6];

    if (amount == null || title.isEmpty) return null;

    // Terima nilai lokal (id) maupun internasional (en) agar file
    // hasil ekspor lintas bahasa tetap bisa diimpor.
    final normalizedType = typeStr.trim().toLowerCase();
    final isIncome = normalizedType == 'pemasukan' ||
        normalizedType == 'income' ||
        normalizedType == 'in';
    final type =
        isIncome ? TransactionType.income : TransactionType.expense;

    // Cari kategori berdasarkan nama (termasuk kategori custom).
    final category = _findCategoryByName(
      categoryName,
      type,
      customCategories: customCategories,
    );

    return Transaction(
      id: id.isEmpty ? 'imported_${DateTime.now().millisecondsSinceEpoch}' : id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: DateTime.parse(dateStr),
      note: note,
    );
  }

  /// Parse satu baris CSV dengan handling quoted fields
  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    final current = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          current.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());

    return result;
  }

  TransactionCategory _findCategoryByName(
    String name,
    TransactionType type, {
    List<TransactionCategory> customCategories = const [],
  }) {
    // Cari kategori custom dulu (berdasarkan nama), lalu default.
    final candidates = <TransactionCategory>[
      ...customCategories.where((c) => c.type == type),
      ...(type == TransactionType.income
          ? TransactionCategory.defaultIncomeCategories
          : TransactionCategory.defaultExpenseCategories),
    ];

    // Cari exact match dulu (case-insensitive)
    for (final cat in candidates) {
      if (cat.name.toLowerCase() == name.toLowerCase()) {
        return cat;
      }
    }

    // Fallback ke kategori "Lainnya" yang sesuai tipe.
    return candidates.last;
  }
}

/// Hasil parse sebuah file backup sebelum dijadikan [ImportPreview].
class _ParsedBackup {
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final List<TransactionCategory> customCategories;

  const _ParsedBackup({
    this.transactions = const [],
    this.budgets = const [],
    this.customCategories = const [],
  });
}
