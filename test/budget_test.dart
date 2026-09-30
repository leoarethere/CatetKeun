import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:catat_keuangan/l10n/generated/app_localizations.dart';
import 'package:catat_keuangan/models/budget.dart';
import 'package:catat_keuangan/models/category.dart';
import 'package:catat_keuangan/models/transaction.dart';
import 'package:catat_keuangan/providers/finance_provider.dart';
import 'package:catat_keuangan/services/budget_repository.dart';
import 'package:catat_keuangan/services/export_import_service.dart';
import 'package:catat_keuangan/utils/currency_helper.dart';
import 'package:catat_keuangan/views/budget_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CurrencyHelper.locale = 'id';
  });

  group('CurrencyHelper format angka', () {
    test('groupDigits memasang pemisah ribuan sesuai locale', () {
      expect(CurrencyHelper.groupDigits('1500000'), '1.500.000');
      expect(CurrencyHelper.groupDigits('123'), '123');
      expect(CurrencyHelper.groupDigits(''), '');
      expect(CurrencyHelper.groupDigits('0'), '0');
      expect(CurrencyHelper.groupDigits('007'), '7');
    });

    test('groupDigits memakai koma untuk locale en', () {
      CurrencyHelper.locale = 'en';
      expect(CurrencyHelper.groupDigits('1500000'), '1,500,000');
      CurrencyHelper.locale = 'id';
    });

    test('formatNumber menghasilkan angka tanpa simbol mata uang', () {
      expect(CurrencyHelper.formatNumber(1500000), '1.500.000');
      expect(CurrencyHelper.formatNumber(0), '0');
    });

    test('parse mengabaikan pemisah ribuan dan simbol', () {
      expect(CurrencyHelper.parse('Rp 1.500.000'), 1500000);
      expect(CurrencyHelper.parse('250000'), 250000);
      expect(CurrencyHelper.parse(''), isNull);
      expect(CurrencyHelper.parse('abc'), isNull);
    });
  });

  group('FinanceProvider anggaran', () {
    test('set, ubah, dan hapus anggaran global maupun kategori', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      expect(provider.getGlobalBudget(), isNull);

      await provider.setBudget(monthlyLimit: 1000000);
      expect(provider.getGlobalBudget()?.monthlyLimit, 1000000);

      // Update tidak boleh membuat duplikat
      await provider.setBudget(monthlyLimit: 500000);
      expect(provider.getGlobalBudget()?.monthlyLimit, 500000);
      expect(provider.budgets.length, 1);

      await provider.setBudget(categoryId: 'exp_food', monthlyLimit: 250000);
      expect(provider.getBudgetForCategory('exp_food')?.monthlyLimit, 250000);
      expect(provider.budgets.length, 2);

      await provider.deleteBudget('global');
      expect(provider.getGlobalBudget(), isNull);
      expect(provider.getBudgetForCategory('exp_food'), isNotNull);

      await provider.deleteBudget('exp_food');
      expect(provider.budgets, isEmpty);
    });

    test('progress anggaran memakai pengeluaran bulan berjalan', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      await provider.setBudget(monthlyLimit: 100000);
      final progress = provider.getGlobalBudgetProgress();

      expect(progress, isNotNull);
      expect(progress!.spent, provider.currentMonthExpense);
      expect(progress.limit, 100000);
    });

    test('hanya anggaran kategori pengeluaran yang ditampilkan', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      await provider.setBudget(categoryId: 'exp_food', monthlyLimit: 100000);
      await provider.setBudget(categoryId: 'inc_salary', monthlyLimit: 999);

      final progress = provider.getCategoryBudgetProgress();
      expect(progress.length, 1);
      expect(progress.first.budget.categoryId, 'exp_food');
    });

    test('anggaran kategori yatim tidak ditampilkan', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      // Simulasikan data lama: anggaran kategori yang sudah tidak ada.
      await provider.setBudget(categoryId: 'exp_hilang', monthlyLimit: 50000);

      expect(provider.hasCategory('exp_hilang'), isFalse);
      expect(provider.budgets.length, 1);
      expect(provider.getCategoryBudgetProgress(), isEmpty);
    });

    test('anggaran ikut terhapus saat kategori custom dihapus', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      final category = await provider.addCategory(
        name: 'Kopi',
        icon: Icons.savings,
        color: Colors.brown,
        type: TransactionType.expense,
      );
      await provider.setBudget(categoryId: category.id, monthlyLimit: 200000);
      expect(provider.budgets.length, 1);

      await provider.deleteCategory(category.id);

      expect(provider.budgets, isEmpty);
      expect(provider.getBudgetForCategory(category.id), isNull);
    });
  });

  group('Backup anggaran & kategori custom', () {
    test('JSON backup memuat anggaran dan kategori custom', () {
      final service = ExportImportService();
      final json = service.buildExportJson(
        const [],
        budgets: const [
          Budget(id: 'global', monthlyLimit: 1000000),
          Budget(id: 'exp_food', categoryId: 'exp_food', monthlyLimit: 200000),
        ],
        customCategories: const [
          TransactionCategory(
            id: 'exp_custom_1',
            name: 'Kopi',
            icon: Icons.savings,
            color: Colors.brown,
            type: TransactionType.expense,
            isCustom: true,
          ),
        ],
      );

      final preview = service.parseJsonBackup(json);

      expect(preview.isEmpty, isFalse);
      expect(preview.budgets.length, 2);
      expect(preview.budgets.first.monthlyLimit, 1000000);
      expect(preview.customCategories.single.name, 'Kopi');
      expect(preview.customCategories.single.isCustom, isTrue);
    });

    test('file JSON lama (tanpa anggaran) tetap bisa dibaca', () {
      final tx = Transaction(
        id: 't1',
        title: 'Belanja',
        amount: 50000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_food'),
        date: DateTime(2026, 1, 5),
      );

      final legacy = jsonEncode({
        'version': 1,
        'transactionCount': 1,
        'transactions': [tx.toJson()],
      });

      final preview = ExportImportService().parseJsonBackup(legacy);

      expect(preview.transactions.length, 1);
      expect(preview.budgets, isEmpty);
      expect(preview.customCategories, isEmpty);
      expect(preview.isEmpty, isFalse);
    });

    test('applyImport merge menulis anggaran ke storage', () async {
      final json = ExportImportService().buildExportJson(
        const [],
        budgets: const [
          Budget(id: 'global', monthlyLimit: 750000),
          Budget(id: 'exp_food', categoryId: 'exp_food', monthlyLimit: 150000),
        ],
      );

      final service = ExportImportService();
      final preview = service.parseJsonBackup(json);
      final result = await service.applyImport(
        preview: preview,
        currentTransactions: const [],
        strategy: ImportStrategy.merge,
      );

      expect(result.success, isTrue);

      final saved = await BudgetRepository().loadBudgets();
      expect(saved.length, 2);
      expect(saved.firstWhere((b) => b.id == 'global').monthlyLimit, 750000);
    });
  });

  testWidgets(
      'Tombol tambah anggaran kategori membuka pemilih kategori, bukan dialog total',
      (tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BudgetScreen(provider: provider),
      ),
    );
    await tester.pumpAndSettle();

    // Kartu anggaran total tetap membuka dialog global.
    await tester.tap(find.text('Anggaran Total'));
    await tester.pumpAndSettle();
    expect(find.text('Anggaran Total Bulanan'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah Anggaran Kategori'));
    await tester.pumpAndSettle();

    // Yang terbuka adalah pemilih kategori, bukan dialog anggaran total.
    expect(find.text('Anggaran Total Bulanan'), findsNothing);
    expect(find.byType(ListTile), findsWidgets);

    await tester.tap(find.text('Makanan & Minuman'));
    await tester.pumpAndSettle();

    // Dialog nominal untuk kategori terpilih.
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Anggaran Total Bulanan'), findsNothing);

    // Input kosong tidak dianggap berhasil (tidak menghapus/membuat apa pun).
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Nominal tidak valid'), findsOneWidget);
    expect(provider.getBudgetForCategory('exp_food'), isNull);

    // Biarkan snackbar hilang dulu agar tidak menutupi tombol simpan.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '250000');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Dialog tertutup dan anggaran kategori tersimpan.
    expect(find.byType(TextFormField), findsNothing);
    expect(provider.getBudgetForCategory('exp_food')?.monthlyLimit, 250000);
    expect(find.text('Makanan & Minuman'), findsOneWidget);
  });
}
