import 'dart:convert';

/// Model anggaran (budget) per bulan.
///
/// Budget bersifat recurring: user menetapkan batas sekali,
/// dan berlaku untuk setiap bulan.
class Budget {
  /// ID unik. Untuk budget global = 'global',
  /// untuk kategori = ID kategori tersebut.
  final String id;

  /// null = budget total pengeluaran bulan ini.
  /// Terisi = budget untuk kategori tertentu.
  final String? categoryId;

  /// Batas nominal per bulan (Rupiah, tanpa desimal).
  final int monthlyLimit;

  const Budget({
    required this.id,
    this.categoryId,
    required this.monthlyLimit,
  });

  bool get isGlobal => categoryId == null;

  Budget copyWith({
    String? id,
    String? categoryId,
    int? monthlyLimit,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'monthlyLimit': monthlyLimit,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    final categoryId = json['categoryId'] as String?;
    return Budget(
      id: json['id'] as String? ?? (categoryId ?? 'global'),
      categoryId: categoryId,
      monthlyLimit: (json['monthlyLimit'] as num).toInt(),
    );
  }

  /// Decode daftar budget dari string JSON.
  static List<Budget> decodeList(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) return [];
    return decoded
        .map((e) => Budget.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Encode daftar budget ke string JSON.
  static String encodeList(List<Budget> budgets) {
    return jsonEncode(budgets.map((b) => b.toJson()).toList());
  }
}

/// Status pemakaian budget terhadap realisasi.
enum BudgetStatus {
  /// Belum ada pengeluaran / di bawah 80%
  safe,

  /// 80% - 100% terpakai
  warning,

  /// Melebihi 100%
  over,
}

/// Hasil perhitungan progress sebuah budget.
class BudgetProgress {
  final Budget budget;
  final int spent;
  final int limit;

  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.limit,
  });

  /// Persentase pemakaian (bisa > 100 jika over).
  double get percentage => limit == 0 ? 0 : (spent / limit) * 100;

  int get remaining => limit - spent;

  BudgetStatus get status {
    if (percentage >= 100) return BudgetStatus.over;
    if (percentage >= 80) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }
}
