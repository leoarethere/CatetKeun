import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catat_keuangan/main.dart';
import 'package:catat_keuangan/providers/finance_provider.dart';
import 'package:catat_keuangan/utils/currency_helper.dart';
import 'package:catat_keuangan/utils/date_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Reset helper ke default Indonesia
    CurrencyHelper.locale = 'id';
    DateHelper.locale = 'id';
    DateHelper.todayLabel = 'Hari ini';
    DateHelper.yesterdayLabel = 'Kemarin';
  });

  testWidgets('Default locale menampilkan bahasa Indonesia', (tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    expect(find.text('CatetKeun'), findsWidgets);
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Saldo Bulan Ini'), findsOneWidget);
  });

  testWidgets('Ganti ke bahasa Inggris mengubah seluruh UI', (tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Transaksi'), findsOneWidget);

    await provider.setLocale('en');
    await tester.pumpAndSettle();

    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.text('Balance This Month'), findsOneWidget);
    expect(find.text('Riwayat Transaksi'), findsNothing);

    // Helper format ikut berubah
    expect(CurrencyHelper.locale, 'en');
    expect(DateHelper.locale, 'en');
    expect(DateHelper.todayLabel, 'Today');

    // Locale juga dipersist ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'en');
  });

  testWidgets('Locale tersimpan dipulihkan saat app dibuka', (tester) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});

    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    expect(find.text('Transaction History'), findsOneWidget);
    expect(provider.locale.languageCode, 'en');
  });
}
