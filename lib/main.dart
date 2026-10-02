import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'providers/finance_provider.dart';
import 'utils/date_helper.dart';
import 'views/home_screen.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Siapkan simbol tanggal (nama bulan/hari) untuk locale id & en
  await DateHelper.ensureInitialized();

  final financeProvider = FinanceProvider();
  await financeProvider.initialize();

  runApp(CatetKeunApp(provider: financeProvider, enableSplash: true));
}

class CatetKeunApp extends StatelessWidget {
  final FinanceProvider provider;

  /// Tampilkan splash ber-animasi sebelum Home.
  ///
  /// Default `false` agar widget test bisa langsung menguji Home tanpa
  /// menunggu durasi splash. Entry point produksi ([main]) mengaktifkannya.
  final bool enableSplash;

  const CatetKeunApp({
    super.key,
    required this.provider,
    this.enableSplash = false,
  });

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
          home: AppRoot(
            provider: provider,
            enableSplash: enableSplash,
          ),
        );
      },
    );
  }
}

/// Membungkus splash → Home dengan transisi fade yang halus.
///
/// Dipisah dari [CatetKeunApp] supaya state "sedang splash" tidak membangun
/// ulang seluruh `MaterialApp` saat tema/bahasa berubah.
class AppRoot extends StatefulWidget {
  final FinanceProvider provider;
  final bool enableSplash;

  const AppRoot({
    super.key,
    required this.provider,
    this.enableSplash = false,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late bool _showSplash;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.enableSplash;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onFinished: () {
                if (mounted) setState(() => _showSplash = false);
              },
            )
          : HomeScreen(
              key: const ValueKey('home'),
              provider: widget.provider,
            ),
    );
  }
}
