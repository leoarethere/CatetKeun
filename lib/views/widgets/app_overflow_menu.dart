import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/finance_provider.dart';
import '../budget_screen.dart';
import '../category_management_screen.dart';
import 'app_page_route.dart';
import 'export_import_sheet.dart';

/// Menu overflow (⋮) bersama untuk Home dan Statistik.
///
/// Sebelumnya blok menu ini disalin hampir identik di dua screen; setiap
/// perubahan (mis. tambah item menu) harus diingat di dua tempat. Widget
/// ini menyatukannya, termasuk dialog pemilih bahasa di dalamnya.
class AppOverflowMenu extends StatelessWidget {
  final FinanceProvider provider;

  const AppOverflowMenu({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: l10n.moreMenu,
      onSelected: (value) => _onSelected(context, value),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'budget',
          child: _MenuRow(
            icon: Icons.savings_outlined,
            label: l10n.manageBudgetMenu,
          ),
        ),
        PopupMenuItem(
          value: 'categories',
          child: _MenuRow(
            icon: Icons.category_outlined,
            label: l10n.manageCategoryMenu,
          ),
        ),
        PopupMenuItem(
          value: 'export_import',
          child: _MenuRow(
            icon: Icons.import_export_rounded,
            label: l10n.exportImportMenu,
          ),
        ),
        PopupMenuItem(
          value: 'theme',
          child: _MenuRow(
            icon: isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            label: isDark ? l10n.lightMode : l10n.darkMode,
          ),
        ),
        PopupMenuItem(
          value: 'language',
          child: _MenuRow(
            icon: Icons.translate_outlined,
            label: l10n.languageSetting,
          ),
        ),
      ],
    );
  }

  void _onSelected(BuildContext context, String value) {
    switch (value) {
      case 'budget':
        Navigator.of(context).push(
          AppPageRoute(
            builder: (_) => BudgetScreen(provider: provider),
          ),
        );
        break;
      case 'categories':
        Navigator.of(context).push(
          AppPageRoute(
            builder: (_) => CategoryManagementScreen(provider: provider),
          ),
        );
        break;
      case 'export_import':
        ExportImportSheet.show(context, provider);
        break;
      case 'theme':
        provider.toggleTheme();
        break;
      case 'language':
        showLanguageDialog(context, provider);
        break;
    }
  }

  /// Dialog pemilih bahasa bersama (dipakai Home & Statistik).
  static Future<void> showLanguageDialog(
    BuildContext context,
    FinanceProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final current = provider.locale.languageCode;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.languageSetting),
        content: RadioGroup<String>(
          groupValue: current,
          onChanged: (v) {
            provider.setLocale(v!);
            Navigator.of(ctx).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'id',
                title: Text(l10n.languageNameId),
              ),
              RadioListTile<String>(
                value: 'en',
                title: Text(l10n.languageNameEn),
              ),
            ],
          ),
        ),
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

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
