import 'package:flutter/material.dart';

const List<IconData> _availableIcons = [
  Icons.restaurant,
  Icons.directions_car,
  Icons.shopping_bag,
  Icons.receipt_long,
  Icons.sports_esports,
  Icons.medical_services,
  Icons.school,
  Icons.more_horiz,
  Icons.account_balance_wallet,
  Icons.card_giftcard,
  Icons.trending_up,
  Icons.storefront,
  Icons.sell,
  Icons.redeem,
  Icons.savings,
];

IconData iconFromCodePoint(int cp) => _availableIcons.firstWhere(
      (i) => i.codePoint == cp,
      orElse: () => Icons.category_rounded);

enum TransactionType {
  income,
  expense;
}

/// Jenis error operasi kategori.
/// Dipakai agar pesan error bisa diterjemahkan oleh UI (l10n),
/// bukan di-hardcode dalam bahasa tertentu di lapisan provider.
enum CategoryError {
  /// Kategori bawaan tidak bisa dihapus.
  defaultCategoryCannotDelete,

  /// Kategori bawaan tidak bisa diubah.
  defaultCategoryCannotEdit,

  /// Masih dipakai oleh transaksi (lihat [CategoryException.usageCount]).
  inUse,

  /// Kategori tidak ditemukan.
  notFound,
}

/// Exception ber-tipe untuk operasi kategori.
class CategoryException implements Exception {
  final CategoryError error;
  final int usageCount;

  const CategoryException(this.error, {this.usageCount = 0});

  @override
  String toString() => 'CategoryException(${error.name}, usage: $usageCount)';
}

/// Hasil pengecekan apakah sebuah kategori boleh dihapus.
class CategoryDeleteCheck {
  /// `null` berarti boleh dihapus.
  final CategoryError? error;
  final int usageCount;

  const CategoryDeleteCheck({this.error, this.usageCount = 0});

  bool get canDelete => error == null;
}

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;
  final bool isCustom;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isCustom = false,
  });

  TransactionCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    TransactionType? type,
    bool? isCustom,
  }) {
    return TransactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'colorValue': color.toARGB32(),
      'isCustom': isCustom,
    };
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    final iconCodePoint = json['iconCodePoint'] as int;

    final colorValue = json['colorValue'] as int;

// Resolve icon using constant list lookup for tree shaking
final icon = iconFromCodePoint(iconCodePoint);
    final color = Color(colorValue);

    return TransactionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: icon,
      color: color,
      type: TransactionType.values.byName(json['type'] as String),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  // ==================== KATEGORI DEFAULT ====================

  // Kategori default pengeluaran
  static const List<TransactionCategory> defaultExpenseCategories = [
    TransactionCategory(
      id: 'exp_food',
      name: 'Makanan & Minuman',
      icon: Icons.restaurant,
      color: Color(0xFFEF6C00),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_transport',
      name: 'Transportasi',
      icon: Icons.directions_car,
      color: Color(0xFF1976D2),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_shopping',
      name: 'Belanja',
      icon: Icons.shopping_bag,
      color: Color(0xFF8E24AA),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_bills',
      name: 'Tagihan & Utilitas',
      icon: Icons.receipt_long,
      color: Color(0xFFE53935),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_entertainment',
      name: 'Hiburan',
      icon: Icons.sports_esports,
      color: Color(0xFF00897B),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_health',
      name: 'Kesehatan',
      icon: Icons.medical_services,
      color: Color(0xFFD81B60),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_education',
      name: 'Pendidikan',
      icon: Icons.school,
      color: Color(0xFF3949AB),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'exp_other',
      name: 'Lainnya',
      icon: Icons.more_horiz,
      color: Color(0xFF757575),
      type: TransactionType.expense,
    ),
  ];

  // Kategori default pemasukan
  static const List<TransactionCategory> defaultIncomeCategories = [
    TransactionCategory(
      id: 'inc_salary',
      name: 'Gaji Pokok',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF2E7D32),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'inc_bonus',
      name: 'Bonus & THR',
      icon: Icons.card_giftcard,
      color: Color(0xFF43A047),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'inc_investment',
      name: 'Investasi',
      icon: Icons.trending_up,
      color: Color(0xFF00ACC1),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'inc_business',
      name: 'Usaha / Bisnis',
      icon: Icons.storefront,
      color: Color(0xFFF4511E),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'inc_sale',
      name: 'Penjualan Barang',
      icon: Icons.sell,
      color: Color(0xFF546E7A),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'inc_gift',
      name: 'Hadiah & Hibah',
      icon: Icons.redeem,
      color: Color(0xFFC2185B),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'inc_other',
      name: 'Lainnya',
      icon: Icons.savings,
      color: Color(0xFF00897B),
      type: TransactionType.income,
    ),
  ];

  static List<TransactionCategory> get allDefaultCategories => [
        ...defaultExpenseCategories,
        ...defaultIncomeCategories,
      ];

  /// Ambil kategori by ID dari daftar yang diberikan
  /// (fallback ke default jika tidak ditemukan)
  static TransactionCategory getById(String id,
      {List<TransactionCategory>? customCategories}) {
    // Cek custom categories dulu
    if (customCategories != null) {
      for (final c in customCategories) {
        if (c.id == id) return c;
      }
    }

    // Cek default
    for (final c in allDefaultCategories) {
      if (c.id == id) return c;
    }

    // Fallback ke "Lainnya"
    return defaultExpenseCategories.last;
  }

  /// Validasi ID: hanya kategori default atau custom yang valid
  static bool isValidId(String id, {List<TransactionCategory>? customCategories}) {
    if (customCategories != null) {
      for (final c in customCategories) {
        if (c.id == id) return true;
      }
    }
    for (final c in allDefaultCategories) {
      if (c.id == id) return true;
    }
    return false;
  }
}
