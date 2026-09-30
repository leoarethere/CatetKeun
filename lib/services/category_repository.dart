import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

/// Repository untuk persistensi kategori custom (buatan user)
class CategoryRepository {
  static const String _storageKey = 'custom_categories_v1';

  /// Load semua kategori custom dari storage
  Future<List<TransactionCategory>> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      final categories = <TransactionCategory>[];

      for (final item in decodedList) {
        try {
          final cat = TransactionCategory.fromJson(item as Map<String, dynamic>);
          // Hanya simpan yang benar-benar custom
          if (cat.isCustom) {
            categories.add(cat);
          }
        } catch (e) {
          debugPrint('Skip kategori rusak: $e');
        }
      }

      return categories;
    } catch (e) {
      debugPrint('Error load custom categories: $e');
      return [];
    }
  }

  /// Simpan semua kategori custom ke storage
  Future<void> saveCustomCategories(List<TransactionCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    // Hanya simpan yang custom
    final customCategories = categories.where((c) => c.isCustom).toList();
    final jsonList = customCategories.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Buat ID unik untuk kategori baru
  String generateId(TransactionType type) {
    final prefix = type == TransactionType.income ? 'inc' : 'exp';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_custom_$timestamp';
  }
}
