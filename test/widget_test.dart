import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:catat_keuangan/l10n/generated/app_localizations.dart';
import 'package:catat_keuangan/main.dart';
import 'package:catat_keuangan/models/category.dart';
import 'package:catat_keuangan/providers/finance_provider.dart';
import 'package:catat_keuangan/views/widgets/category_pie_chart.dart';
import 'package:catat_keuangan/views/splash_screen.dart';
import 'package:catat_keuangan/views/home_screen.dart';
import 'package:catat_keuangan/views/widgets/app_logo.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash tampil saat enableSplash lalu berlanjut ke Home',
      (WidgetTester tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(
      CatetKeunApp(provider: provider, enableSplash: true),
    );
    // Frame pertama: splash terlihat, Home belum.
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    // Latar splash memakai warna brand.
    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(SplashScreen),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.backgroundColor, AppLogo.brandColor);

    // Setelah durasi splash + transisi, Home tampil.
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('Tanpa enableSplash, langsung tampil Home (tanpa splash)',
      (WidgetTester tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('App renders correctly and displays title and balance', (WidgetTester tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    // Pastikan judul aplikasi dan elemen utama tampil
    expect(find.text('CatetKeun'), findsOneWidget);
    expect(find.text('Saldo Bulan Ini'), findsOneWidget);
    expect(find.text('Catat Transaksi'), findsOneWidget);
  });

  testWidgets('Statistics pie chart view renders without RangeError', (WidgetTester tester) async {
    final provider = FinanceProvider();
    await provider.initialize();

    await tester.pumpWidget(CatetKeunApp(provider: provider));
    await tester.pumpAndSettle();

    // Pindah ke tab Statistik
    final statsTab = find.byIcon(Icons.pie_chart_outline_rounded);
    expect(statsTab, findsOneWidget);
    await tester.tap(statsTab);
    await tester.pumpAndSettle();

    // Ubah tampilan dari List ke Chart (Donut/Pie) menggunakan tooltip
    final chartToggle = find.byTooltip('Tampilan Grafik');
    expect(chartToggle, findsOneWidget);
    await tester.tap(chartToggle);
    await tester.pumpAndSettle();

    // Pastikan PieChart berhasil dirender tanpa RangeError
    expect(find.byType(PieChart), findsOneWidget);

    // Lakukan tap pada PieChart untuk memastikan touch callback tidak crash
    await tester.tap(find.byType(PieChart), warnIfMissed: false);
    await tester.pumpAndSettle();
  });

  testWidgets('CategoryPieChart handles negative touchedSectionIndex safely', (WidgetTester tester) async {
    final sampleStats = [
      const CategoryStat(
        category: TransactionCategory(
          id: 'exp_food',
          name: 'Makanan & Minuman',
          icon: Icons.fastfood,
          color: Colors.orange,
          type: TransactionType.expense,
        ),
        totalAmount: 100000,
        count: 2,
        percentage: 100.0,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: CategoryPieChart(
            stats: sampleStats,
            isExpense: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pastikan chart tampil
    expect(find.byType(PieChart), findsOneWidget);

    // Tap pada legend item (menggunakan localized name)
    final legendItem = find.text('Makanan & Minuman');
    expect(legendItem, findsOneWidget);
    await tester.tap(legendItem);
    await tester.pumpAndSettle();
    expect(find.text('100.0%'), findsOneWidget);

    // Tap legend item lagi untuk deselect
    await tester.tap(legendItem);
    await tester.pumpAndSettle();
  });
}
