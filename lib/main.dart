import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'providers/finance_provider.dart';
import 'utils/date_helper.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Siapkan simbol tanggal (nama bulan/hari) untuk locale id & en
  await DateHelper.ensureInitialized();

  final financeProvider = FinanceProvider();
  await financeProvider.initialize();

  runApp(CatetKeunApp(provider: financeProvider));
}

class CatetKeunApp extends StatelessWidget {
  final FinanceProvider provider;

  const CatetKeunApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Warna dasar Material 3 bernuansa financial green / teal yang seimbang dan tenang
    const primarySeedColor = Color(0xFF00796B);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'CatetKeun',
          debugShowCheckedModeBanner: false,
          locale: provider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: provider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primarySeedColor,
              brightness: Brightness.light,
            ),
            cardTheme: const CardThemeData(
              elevation: 0,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 2,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primarySeedColor,
              brightness: Brightness.dark,
            ),
            cardTheme: const CardThemeData(
              elevation: 0,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 2,
            ),
          ),
          home: HomeScreen(provider: provider),
        );
      },
    );
  }
}
