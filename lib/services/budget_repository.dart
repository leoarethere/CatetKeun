import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget.dart';

/// Repository untuk persistensi data anggaran (budget).
class BudgetRepository {
  static const String _storageKey = 'budgets_v1';

  Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      return Budget.decodeList(jsonString);
    } catch (e) {
      debugPrint('Error load budgets: $e');
      return [];
    }
  }

  Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Budget.encodeList(budgets));
  }
}
