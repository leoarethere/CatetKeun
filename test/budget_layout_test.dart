import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:catat_keuangan/l10n/generated/app_localizations.dart';
import 'package:catat_keuangan/providers/finance_provider.dart';
import 'package:catat_keuangan/utils/currency_helper.dart';
import 'package:catat_keuangan/views/budget_screen.dart';

/// Regression test: layar Kelola Anggaran tidak boleh menghasilkan
/// RenderFlex overflow pada berbagai ukuran layar dan skala teks.
///
/// Flutter menandai overflow saat test框架 memproses frame, jadi test ini
/// otomatis gagal (tanpa perlu assert manual) bila ada Row/Column yang
/// melebihi ruangnya — termasuk striped yellow-and-black yang dulu muncul
/// sebagai "BOTTOM OVERFLOWED" pada dialog nominal.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CurrencyHelper.locale = 'id';
  });

  Widget wrap(Widget child, double scale) {
    return MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: scale,
        child: child!,
      ),
      home: child,
    );
  }

  /// Anggaran sengaja dibuat sangat besar supaya nominalnya panjang
  /// ("Rp 1.500.000.000") dan status "over" aktif.
  Future<FinanceProvider> bigBudgetProvider() async {
    final provider = FinanceProvider();
    await provider.initialize();
    await provider.setBudget(monthlyLimit: 1500000000);
    await provider.setBudget(categoryId: 'exp_food', monthlyLimit: 500000);
    await provider.setBudget(categoryId: 'exp_transport', monthlyLimit: 100);
    return provider;
  }

  // 320 = ponsel kecil, 360x480 = layar pendek (mirip kondisi keyboard
  // terbuka), 411 = ponsel normal.
  const sizes = [Size(320, 568), Size(360, 480), Size(411, 914)];
  const scales = [1.0, 1.5, 2.0];

  for (final size in sizes) {
    for (final scale in scales) {
      final tag = '${size.width.toInt()}x${size.height.toInt()} scale $scale';

      testWidgets('Halaman anggaran tidak overflow - $tag', (tester) async {
        final provider = await bigBudgetProvider();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          wrap(BudgetScreen(provider: provider), scale),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('Dialog nominal tidak overflow - $tag', (tester) async {
        final provider = await bigBudgetProvider();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          wrap(BudgetScreen(provider: provider), scale),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Anggaran Total'));
        await tester.pumpAndSettle();
      });

      testWidgets('Pemilih kategori tidak overflow - $tag', (tester) async {
        final provider = await bigBudgetProvider();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          wrap(BudgetScreen(provider: provider), scale),
        );
        await tester.pumpAndSettle();
        // Tombol berada di bawah lipatan pada layar pendek, scroll dulu.
        await tester.drag(find.byType(ListView).first, const Offset(0, -600));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tambah Anggaran Kategori'));
        await tester.pumpAndSettle();
      });
    }
  }
}
