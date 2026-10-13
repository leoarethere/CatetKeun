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

    test('Separates Cash and Digital while correctly calculating grand totals', () async {
      final provider = FinanceProvider();
      await provider.initialize();

      // Clear existing transactions to test pristine math
      for (final tx in List.of(provider.allTransactions)) {
        await provider.deleteTransaction(tx.id);
      }

      final now = DateTime.now();

      // Cash transactions: Masuk 200.000, Keluar 50.000 -> Saldo Cash 150.000
      await provider.addTransaction(Transaction(
        id: 'tx_cash_in',
        title: 'Cash Masuk',
        amount: 200000,
        type: TransactionType.income,
        category: TransactionCategory.getById('inc_salary'),
        date: now,
        paymentMethod: PaymentMethod.cash,
      ));

      await provider.addTransaction(Transaction(
        id: 'tx_cash_out',
        title: 'Cash Keluar',
        amount: 50000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_food'),
        date: now,
        paymentMethod: PaymentMethod.cash,
      ));

      // Digital transactions: Masuk 500.000, Keluar 100.000 -> Saldo Digital 400.000
      await provider.addTransaction(Transaction(
        id: 'tx_digital_in',
        title: 'Digital Masuk',
        amount: 500000,
        type: TransactionType.income,
        category: TransactionCategory.getById('inc_salary'),
        date: now,
        paymentMethod: PaymentMethod.digital,
      ));

      await provider.addTransaction(Transaction(
        id: 'tx_digital_out',
        title: 'Digital Keluar',
        amount: 100000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_shopping'),
        date: now,
        paymentMethod: PaymentMethod.digital,
      ));

      // Check Cash metrics
      expect(provider.currentMonthCashIncome, 200000);
      expect(provider.currentMonthCashExpense, 50000);
      expect(provider.currentMonthCashBalance, 150000);
      expect(provider.totalCashBalance, 150000);

      // Check Digital metrics
      expect(provider.currentMonthDigitalIncome, 500000);
      expect(provider.currentMonthDigitalExpense, 100000);
      expect(provider.currentMonthDigitalBalance, 400000);
      expect(provider.totalDigitalBalance, 400000);

      // Check Grand Totals (Cash + Digital tetap ditotal semuanya)
      expect(provider.currentMonthIncome, 700000);
      expect(provider.currentMonthExpense, 150000);
      expect(provider.currentMonthBalance, 550000);
      expect(provider.totalBalance, 550000);

      // Check Filtering by PaymentMethod
      expect(provider.filteredTransactions.length, 4);

      provider.setPaymentMethodFilter(PaymentMethod.cash);
      expect(provider.filteredTransactions.length, 2);
      expect(provider.filteredTransactions.every((t) => t.paymentMethod == PaymentMethod.cash), isTrue);

      provider.setPaymentMethodFilter(PaymentMethod.digital);
      expect(provider.filteredTransactions.length, 2);
      expect(provider.filteredTransactions.every((t) => t.paymentMethod == PaymentMethod.digital), isTrue);

      provider.setPaymentMethodFilter(null);
      expect(provider.filteredTransactions.length, 4);
    });

    test('Transaction serialization handles PaymentMethod with backward compatibility', () {
      final txCash = Transaction(
        id: '1',
        title: 'Tunai',
        amount: 10000,
        type: TransactionType.expense,
        category: TransactionCategory.getById('exp_food'),
        date: DateTime.now(),
        paymentMethod: PaymentMethod.cash,
      );
      final jsonCash = txCash.toJson();
      expect(jsonCash['paymentMethod'], 'cash');
      expect(Transaction.fromJson(jsonCash).paymentMethod, PaymentMethod.cash);

      final txDigital = txCash.copyWith(paymentMethod: PaymentMethod.digital);
      final jsonDigital = txDigital.toJson();
      expect(jsonDigital['paymentMethod'], 'digital');
      expect(Transaction.fromJson(jsonDigital).paymentMethod, PaymentMethod.digital);

      // Legacy JSON without paymentMethod defaults to cash
      final legacyJson = {
        'id': 'legacy_1',
        'title': 'Legacy Tx',
        'amount': 25000,
        'type': 'expense',
        'categoryId': 'exp_food',
        'date': DateTime.now().toIso8601String(),
      };
      final parsedLegacy = Transaction.fromJson(legacyJson);
      expect(parsedLegacy.paymentMethod, PaymentMethod.cash);
    });
  });
}
