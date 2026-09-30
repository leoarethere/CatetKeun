import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catat_keuangan/models/category.dart';
import 'package:catat_keuangan/models/transaction.dart';
import 'package:catat_keuangan/providers/finance_provider.dart';
import 'package:catat_keuangan/utils/currency_helper.dart';
import 'package:catat_keuangan/utils/date_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyHelper Tests', () {
    test('Format rupiah works correctly', () {
      final formatted = CurrencyHelper.format(150000);
      expect(formatted.contains('150.000'), isTrue);
      expect(formatted.contains('Rp'), isTrue);
    });

    test('Parse string to number works', () {
      expect(CurrencyHelper.parse('Rp 50.000'), 50000.0);
      expect(CurrencyHelper.parse('100000'), 100000.0);
      expect(CurrencyHelper.parse(''), isNull);
    });
  });

  group('DateHelper Tests', () {
    setUpAll(() async {
      await DateHelper.ensureInitialized();
    });

    test('Format month year returns correct month name', () async {
      final date = DateTime(2026, 9, 29);
      final result = DateHelper.formatMonthYear(date);
      expect(result, 'September 2026');
    });

    test('isSameMonth checks month and year', () {
      final a = DateTime(2026, 9, 1);
      final b = DateTime(2026, 9, 29);
      final c = DateTime(2026, 8, 29);
      expect(DateHelper.isSameMonth(a, b), isTrue);
      expect(DateHelper.isSameMonth(a, c), isFalse);
    });
  });

  group('FinanceProvider Tests', () {
    test('Add, update, and delete transactions update calculations', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      final initialCount = provider.allTransactions.length;
      final newTx = Transaction(
        id: 'test_1',
        title: 'Uji Coba Pemasukan',
        amount: 500000,
        type: TransactionType.income,
        category: TransactionCategory.getById('inc_salary'),
        date: DateTime.now(),
      );

      await provider.addTransaction(newTx);
      expect(provider.allTransactions.length, initialCount + 1);

      final updatedTx = newTx.copyWith(title: 'Uji Coba Pemasukan Diedit', amount: 600000);
      await provider.updateTransaction(updatedTx);
      expect(provider.allTransactions.first.title, 'Uji Coba Pemasukan Diedit');
      expect(provider.allTransactions.first.amount, 600000);

      await provider.deleteTransaction('test_1');
      expect(provider.allTransactions.length, initialCount);
    });
  });
}
