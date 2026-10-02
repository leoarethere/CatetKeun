import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'widgets/app_logo.dart';

/// Halaman Tentang aplikasi.
///
/// Semua teks diambil dari l10n agar ikut berganti saat bahasa diubah.
/// Konstanta non-teks (versi, kontak, lisensi) dipisah ke [_AppInfo] supaya
/// nilai yang sering berubah mudah ditemukan dan tidak tersebar di widget.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        // Header mirroring HomeScreen: icon and title
        title: Row(
          children: [
            const AppLogo(size: 26),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Logo & nama aplikasi
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 88),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Deskripsi singkat
            Text(
              l10n.aboutTagline,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Versi aplikasi
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l10n.aboutVersion),
              subtitle: const Text(_AppInfo.version),
            ),
            const Divider(),
            // Pengembang / kontak
            ListTile(
              leading: const Icon(Icons.developer_mode_rounded),
              title: Text(l10n.aboutDeveloper),
              subtitle: const Text(_AppInfo.developerName),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.aboutEmail),
              subtitle: const Text(_AppInfo.email),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: Text(l10n.aboutWebsite),
              subtitle: const Text(_AppInfo.website),
            ),
            const Divider(),
            // Legal / lisensi
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.aboutLicense),
              subtitle: const Text(_AppInfo.license),
            ),
            ListTile(
              leading: const Icon(Icons.copyright_rounded),
              title: Text(l10n.aboutCopyright),
              subtitle: Text(l10n.aboutCopyrightValue),
            ),
            const Divider(),
            // Acknowledgements
            Text(
              l10n.aboutThanks,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Kebijakan privasi & syarat penggunaan.
            // Konten legal belum tersedia: buka dialog penjelasan supaya
            // tombol tidak terasa rusak (dulu onPressed kosong).
            TextButton(
              onPressed: () => _showInfoDialog(
                context,
                title: l10n.aboutPrivacy,
                message: l10n.aboutPrivacyPending,
              ),
              child: Text(l10n.aboutPrivacy),
            ),
            TextButton(
              onPressed: () => _showInfoDialog(
                context,
                title: l10n.aboutTerms,
                message: l10n.aboutTermsPending,
              ),
              child: Text(l10n.aboutTerms),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

/// Metadata aplikasi yang bukan teks terjemahan.
class _AppInfo {
  const _AppInfo._();

  static const String version = '1.0.0';
  static const String developerName = 'Leona Dev';
  static const String email = 'leona@example.com';
  static const String website = 'https://leona.dev';
  static const String license = 'MIT License';
}
