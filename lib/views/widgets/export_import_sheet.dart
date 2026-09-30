import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/category.dart';
import '../../providers/finance_provider.dart';
import '../../services/export_import_service.dart';

/// Bottom sheet untuk Ekspor/Impor data
class ExportImportSheet extends StatefulWidget {
  final FinanceProvider provider;

  const ExportImportSheet({super.key, required this.provider});

  static Future<void> show(BuildContext context, FinanceProvider provider) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExportImportSheet(provider: provider),
    );
  }

  @override
  State<ExportImportSheet> createState() => _ExportImportSheetState();
}

class _ExportImportSheetState extends State<ExportImportSheet> {
  final ExportImportService _service = ExportImportService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Icon(
                  Icons.import_export_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.exportImportTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.exportImportSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Info jumlah transaksi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.storedTransactions(
                      widget.provider.allTransactions.length,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export Section
            Text(
              l10n.exportSection,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.code_rounded,
                    label: l10n.jsonFormat,
                    subtitle: l10n.jsonFormatDesc,
                    onTap: () => _exportData('json'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.table_chart_rounded,
                    label: l10n.csvFormat,
                    subtitle: l10n.csvFormatDesc,
                    onTap: () => _exportData('csv'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Import Section
            Text(
              l10n.importSection,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.upload_file_rounded,
              label: l10n.pickFile,
              subtitle: l10n.jsonOrCsv,
              fullWidth: true,
              onTap: _showImportFlow,
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== EXPORT ====================

  Future<void> _exportData(String format) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isProcessing = true);

    try {
      final transactions = widget.provider.allTransactions;
      final budgets = widget.provider.budgets;
      final customCategories = widget.provider.customCategories;

      // CSV hanya memuat transaksi, jadi anggaran/kategori tidak
      // bisa diwakili di format itu.
      final hasAnyData =
          transactions.isNotEmpty || budgets.isNotEmpty || customCategories.isNotEmpty;
      if (!hasAnyData || (format == 'csv' && transactions.isEmpty)) {
        _showMessage(l10n.noDataToExport);
        return;
      }

      final file = format == 'json'
          ? await _service.exportToJson(
              transactions,
              budgets: budgets,
              customCategories: customCategories,
            )
          : await _service.exportToCsv(transactions);

      // Share file
      await _service.shareFile(
        file,
        text: l10n.backupShareWithCount(
          transactions.length,
          format.toUpperCase(),
        ),
      );

      if (mounted) {
        _showMessage(l10n.exportSuccess(format.toUpperCase()));
      }
    } catch (e) {
      if (mounted) {
        _showMessage(l10n.exportFailed('$e'), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ==================== IMPORT ====================

  Future<void> _showImportFlow() async {
    final l10n = AppLocalizations.of(context)!;
    // Step 1: Pilih file dulu
    setState(() => _isProcessing = true);

    try {
      // Pick file dan parse (tanpa apply dulu)
      final pickResult = await _service.pickFileForImport();

      if (pickResult == null) {
        // User membatalkan
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      if (pickResult.isEmpty) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showMessage(l10n.noValidTransactions, isError: true);
        }
        return;
      }

      if (mounted) {
        setState(() => _isProcessing = false);

        // Step 2: Tampilkan preview dan pilih strategi
        await _showImportPreview(pickResult);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showMessage(l10n.pickFileFailed(_errorDetail(l10n, e)), isError: true);
      }
    }
  }

  Future<void> _showImportPreview(ImportPreview preview) async {
    final l10n = AppLocalizations.of(context)!;
    final strategy = await showDialog<ImportStrategy>(
      context: context,
      builder: (ctx) => _ImportPreviewDialog(preview: preview),
    );

    if (strategy == null || !mounted) return;

    // Step 3: Apply import
    setState(() => _isProcessing = true);

    try {
      final result = await _service.applyImport(
        preview: preview,
        currentTransactions: widget.provider.allTransactions,
        strategy: strategy,
      );

      if (!result.success) {
        if (mounted) {
          _showMessage(
            _errorDetail(l10n, result.errors.first),
            isError: true,
          );
        }
        return;
      }

      // Refresh provider
      await widget.provider.initialize();

      if (mounted) {
        setState(() => _isProcessing = false);
        _showImportSummary(l10n, result, strategy);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showMessage(l10n.importFailed(_errorDetail(l10n, e)), isError: true);
      }
    }
  }

  void _showImportSummary(
    AppLocalizations l10n,
    ImportResult result,
    ImportStrategy strategy,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 48,
        ),
        title: Text(l10n.importSuccessTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.importSummary(
                result.totalImported,
                result.added,
                result.updated,
                result.skipped,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _strategyDescription(l10n, strategy),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Close bottom sheet
            },
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  String _strategyDescription(AppLocalizations l10n, ImportStrategy strategy) {
    switch (strategy) {
      case ImportStrategy.replace:
        return l10n.importReplaceDesc;
      case ImportStrategy.merge:
        return l10n.importMergeDesc;
      case ImportStrategy.skipExisting:
        return l10n.importSkipDesc;
    }
  }

  /// Terjemahkan error dari service menjadi teks sesuai bahasa.
  String _errorDetail(AppLocalizations l10n, Object error) {
    if (error is ExportImportException) {
      switch (error.kind) {
        case ExportImportErrorKind.fileReadFailed:
          return l10n.errFileReadFailed;
        case ExportImportErrorKind.invalidJson:
          return l10n.errInvalidJson;
        case ExportImportErrorKind.emptyCsv:
          return l10n.errEmptyCsv;
        case ExportImportErrorKind.noValidTransactions:
          return l10n.noValidTransactions;
      }
    }
    if (error is ExportImportErrorKind) {
      switch (error) {
        case ExportImportErrorKind.fileReadFailed:
          return l10n.errFileReadFailed;
        case ExportImportErrorKind.invalidJson:
          return l10n.errInvalidJson;
        case ExportImportErrorKind.emptyCsv:
          return l10n.errEmptyCsv;
        case ExportImportErrorKind.noValidTransactions:
          return l10n.noValidTransactions;
      }
    }
    return error.toString();
  }

  void _showMessage(String message, {bool isError = false}) {    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Dialog preview import
class _ImportPreviewDialog extends StatelessWidget {
  final ImportPreview preview;

  const _ImportPreviewDialog({required this.preview});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.preview_rounded, size: 28),
          const SizedBox(width: 12),
          Text(l10n.importPreviewTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    preview.format == 'json' ? Icons.code_rounded : Icons.table_chart_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      preview.fileName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Text(
              l10n.transactionsFound(preview.transactions.length),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Breakdown
            _buildStatRow(
              context,
              l10n.income,
              preview.incomeCount,
              preview.incomeTotal,
              Colors.teal,
            ),
            _buildStatRow(
              context,
              l10n.expense,
              preview.expenseCount,
              preview.expenseTotal,
              Colors.redAccent,
            ),

            // Anggaran & kategori custom (hanya ada di backup versi 2)
            if (preview.budgets.isNotEmpty)
              _buildExtraRow(
                context,
                l10n.budgetsFound(preview.budgets.length),
                Icons.savings_rounded,
                colorScheme.primary,
              ),
            if (preview.customCategories.isNotEmpty)
              _buildExtraRow(
                context,
                l10n.customCategoriesFound(preview.customCategories.length),
                Icons.category_rounded,
                colorScheme.primary,
              ),

            const SizedBox(height: 16),

            // Sample transactions
            if (preview.transactions.isNotEmpty) ...[
              Text(
                l10n.exampleData,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...preview.transactions.take(3).map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      tx.type == TransactionType.income
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 16,
                      color: tx.type == TransactionType.income
                          ? Colors.teal
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tx.title,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rp${tx.amount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
              if (preview.transactions.length > 3)
                Text(
                  l10n.andMore(preview.transactions.length - 3),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.outline,
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () => _showStrategyPicker(context),
          icon: const Icon(Icons.upload_rounded, size: 18),
          label: Text(l10n.continueBtn),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: ', style: theme.textTheme.bodySmall),
          Text(
            l10n.categoryTransactionCount(count),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Rp$total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Baris ringkas tambahan (anggaran / kategori custom) di preview.
  Widget _buildExtraRow(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  void _showStrategyPicker(BuildContext context) {
    Navigator.pop(context); // Close preview

    showDialog(
      context: context,
      builder: (ctx) => const _ImportStrategyDialog(),
    );
  }
}

/// Dialog untuk memilih strategi import
class _ImportStrategyDialog extends StatelessWidget {
  const _ImportStrategyDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(l10n.importStrategyTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseStrategy,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _StrategyOption(
            icon: Icons.merge_rounded,
            title: l10n.mergeStrategy,
            subtitle: l10n.mergeStrategyDesc,
            recommendedLabel: l10n.recommended,
            value: ImportStrategy.merge,
            isRecommended: true,
          ),
          const SizedBox(height: 8),
          _StrategyOption(
            icon: Icons.add_circle_outline_rounded,
            title: l10n.skipStrategy,
            subtitle: l10n.skipStrategyDesc,
            recommendedLabel: l10n.recommended,
            value: ImportStrategy.skipExisting,
          ),
          const SizedBox(height: 8),
          _StrategyOption(
            icon: Icons.delete_sweep_rounded,
            title: l10n.replaceStrategy,
            subtitle: l10n.replaceStrategyDesc,
            recommendedLabel: l10n.recommended,
            value: ImportStrategy.replace,
            isDestructive: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _StrategyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String recommendedLabel;
  final ImportStrategy value;
  final bool isRecommended;
  final bool isDestructive;

  const _StrategyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.recommendedLabel,
    required this.value,
    this.isRecommended = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isDestructive
          ? colorScheme.errorContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.pop(context, value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? colorScheme.error
                    : isRecommended
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDestructive ? colorScheme.error : null,
                            ),
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              recommendedLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
