import 'package:flutter/material.dart';
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

  testWidgets('About screen ikut berbahasa dan tombolnya berfungsi',
      (tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    // Buka tab Tentang.
    await tester.tap(find.text('Tentang'));
    await tester.pumpAndSettle();

    // Teks deskripsi dalam bahasa Indonesia tampil.
    expect(find.textContaining('Catetan Keuangan membantu Anda'), findsOneWidget);

    // Tombol Kebijakan Privasi tidak lagi mati: membuka dialog penjelasan.
    await tester.scrollUntilVisible(find.text('Kebijakan Privasi'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kebijakan Privasi'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kebijakan privasi sedang disiapkan'),
        findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    // Ganti ke bahasa Inggris, teks About ikut berubah.
    await provider.setLocale('en');
    await tester.pumpAndSettle();

    // Scroll kembali ke atas karena ListView membuang item di luar layar.
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(find.textContaining('helps you record, manage'), findsOneWidget);
  });
}
