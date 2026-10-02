import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/transaction.dart';

/// Repository untuk menyimpan transaksi menggunakan SharedPreferences.
///
/// **Catatan Skalabilitas:**
/// Saat ini seluruh daftar transaksi ditulis ulang sebagai JSON string setiap
/// kali ada perubahan. Ini aman untuk hingga ~1000 transaksi, tetapi jika data
/// membesar pertimbangkan migrasi ke:
/// - **SQLite/Drift**: Query lebih efisien, indexing, transaction ACID
/// - **Isar**: NoSQL database dengan performa tinggi untuk mobile
/// - **Hive**: Lightweight key-value database dengan support complex objects
///
/// Indikasi perlu migrasi:
/// - Waktu save > 100ms untuk dataset saat ini
/// - Memory usage meningkat signifikan
/// - Perlu query/filter yang kompleks
/// - Butuh sync dengan backend/cloud
class TransactionRepository {
  static const String _storageKey = 'financial_records_key_v1';

  /// Penanda "user sudah pernah punya data".
  ///
  /// Tanpa penanda ini, daftar kosong (`[]`) tidak bisa dibedakan dari
  /// "belum pernah dibuka", sehingga data contoh akan muncul kembali setiap
  /// kali user menghapus semua transaksinya lalu membuka ulang aplikasi.
  static const String _initializedKey = 'financial_records_initialized_v1';

  /// Muat transaksi dengan resolusi kategori custom.
  ///
  /// Kategori custom tidak tersimpan di dalam file transaksi (hanya
  /// `categoryId`), jadi tanpa [customCategories] transaksi yang memakai
  /// kategori custom akan jatuh ke "Lainnya" setiap aplikasi dibuka ulang.
  Future<List<Transaction>> loadTransactions({
    List<TransactionCategory> customCategories = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    final wasInitialized = prefs.getBool(_initializedKey) ?? false;

    if (jsonString == null || jsonString.isEmpty) {
      // First-run: beri data contoh sekali saja. Setelah penanda ada,
      // daftar yang kosong diperlakukan sebagai "user memang punya nol
      // transaksi", bukan alasan untuk menanam data contoh lagi.
      if (wasInitialized) {
        return [];
      }
      final initialData = _getInitialSampleData();
      await saveTransactions(initialData);
      return initialData;
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      
      // Parse per record - simpan yang valid, lewati yang rusak
      final validTransactions = <Transaction>[];
      final errors = <String>[];
      
      for (int i = 0; i < decodedList.length; i++) {
        try {
          final item = decodedList[i] as Map<String, dynamic>;
          final tx = Transaction.fromJson(
            item,
            customCategories: customCategories,
          );
          validTransactions.add(tx);
        } catch (e) {
          // Catat record yang rusak tapi jangan gagalkan seluruh load
          errors.add('Record $i: $e');
        }
      }
      
      // Jika ada record rusak, buat cadangan data asli sebelum menimpa
      if (errors.isNotEmpty) {
        final backupKey = '${_storageKey}_backup_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(backupKey, jsonString);
        debugPrint('Warning: ${errors.length} record gagal di-parse. Backup disimpan di: $backupKey');
        for (final err in errors) {
          debugPrint('  - $err');
        }
      }
      
      // Jika semua record rusak, JANGAN langsung ganti dengan sample data
      // Biarkan user tahu ada masalah
      if (validTransactions.isEmpty && decodedList.isNotEmpty) {
        debugPrint('Error: Semua record gagal di-parse. Data asli sudah di-backup.');
        return []; // Return empty, not sample data
      }
      
      return validTransactions;
    } catch (e) {
      // JSON completely corrupt (bukan per-record), backup dulu
      final backupKey = '${_storageKey}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(backupKey, jsonString);
      debugPrint('Error: JSON corrupt total. Backup disimpan di: $backupKey');
      debugPrint('Error detail: $e');

      // Samakan dengan jalur first-run: tandai agar pemulihan data contoh
      // berikutnya tidak dianggap sebagai first-run berulang.
      await prefs.setBool(_initializedKey, true);

      // Return sample data sebagai fallback terakhir, tapi user harusnya tahu
      return _getInitialSampleData();
    }
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
    // Simpan penanda agar data contoh tidak muncul kembali di lain waktu.
    await prefs.setBool(_initializedKey, true);
  }

  List<Transaction> _getInitialSampleData() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 'sample_1',
        title: 'Gaji Bulanan',
        amount: 8500000,
        type: TransactionType.income,
        category: TransactionCategory.getById('inc_salary'),
        date: DateTime(now.year, now.month, now.day - 3, 9, 0),
        note: 'Transfer gaji kantor',
      ),
      Transaction(
        id: 'sample_2',
        title: 'Belanja Mingguan',
        amount: 350000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_shopping'),
        date: DateTime(now.year, now.month, now.day - 2, 14, 30),
        note: 'Supermarket',
      ),
      Transaction(
        id: 'sample_3',
        title: 'Bensin & Tol',
        amount: 150000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_transport'),
        date: DateTime(now.year, now.month, now.day - 1, 8, 15),
        note: 'Isi Pertamax',
      ),
      Transaction(
        id: 'sample_4',
        title: 'Makan Siang & Kopi',
        amount: 55000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_food'),
        date: DateTime(now.year, now.month, now.day, 12, 45),
        note: 'Kafe dekat kantor',
      ),
      Transaction(
        id: 'sample_5',
        title: 'Project Sampingan',
        amount: 1200000,
        type: TransactionType.income,
        category: TransactionCategory.getById('inc_business'),
        date: DateTime(now.year, now.month, now.day, 15, 0),
        note: 'Desain UI freelance',
      ),
    ];
  }
}
