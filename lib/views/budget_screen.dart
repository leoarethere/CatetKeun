import 'package:flutter/material.dart';
import '../l10n/category_l10n.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_helper.dart';
import '../utils/thousands_input_formatter.dart';

/// Screen untuk mengelola anggaran (budget) bulanan.
class BudgetScreen extends StatefulWidget {
  final FinanceProvider provider;

  const BudgetScreen({super.key, required this.provider});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = widget.provider;

    // ListenableBuilder memastikan daftar anggaran ikut ter-refresh
    // ketika provider berubah (mis. transaksi/kategori diubah di layar lain).
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final globalProgress = provider.getGlobalBudgetProgress();
        final categoryProgress = provider.getCategoryBudgetProgress();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.manageBudgetTitle),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.budgetIntro,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ============ BUDGET GLOBAL ============
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.totalMonthlyExpense,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _BudgetCard(
                provider: provider,
                title: l10n.totalBudgetCard,
                progress: globalProgress,
                color: colorScheme.primary,
                onEdit: () => _showBudgetDialog(context, categoryId: null),
              ),
              const SizedBox(height: 24),

              // ============ BUDGET PER KATEGORI ============
              Row(
                children: [
                  Icon(Icons.category_rounded,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.perExpenseCategory,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (categoryProgress.isEmpty)
                _buildEmptyHint(l10n.noCategoryBudget)
              else
                ...categoryProgress.map((p) {
                  final cat = provider.getCategoryById(p.budget.categoryId!);
                  return _BudgetCard(
                    provider: provider,
                    title: cat.localized(context),
                    icon: cat.icon,
                    progress: p,
                    color: cat.color,
                    onEdit: () =>
                        _showBudgetDialog(context, categoryId: cat.id),
                  );
                }),

              const SizedBox(height: 24),

              // ============ TAMBAH BUDGET KATEGORI ============
              // Wajib lewat pemilih kategori dulu, karena tanpa kategori
              // dialog anggaran akan jatuh ke anggaran global.
              OutlinedButton.icon(
                onPressed: _showCategoryPicker,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addCategoryBudget),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHint(String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Buka dialog atur anggaran untuk [categoryId] (null = anggaran total).
  Future<void> _showBudgetDialog(BuildContext context,
      {String? categoryId}) {
    return showDialog<void>(
      context: context,
      builder: (_) => _BudgetDialog(
        provider: widget.provider,
        categoryId: categoryId,
      ),
    );
  }

  /// Pilih kategori pengeluaran mana yang mau diberi anggaran,
  /// baru kemudian buka dialog nominal anggarannya.
  Future<void> _showCategoryPicker() async {
    final provider = widget.provider;
    final categories = provider.getCategoriesByType(TransactionType.expense);

    final pickedCategoryId = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryBudgetPickerDialog(
        provider: provider,
        categories: categories,
      ),
    );

    if (pickedCategoryId == null || !mounted) return;
    await _showBudgetDialog(context, categoryId: pickedCategoryId);
  }
}

/// Card menampilkan progress satu budget.
class _BudgetCard extends StatelessWidget {
  final FinanceProvider provider;
  final String title;
  final IconData? icon;
  final BudgetProgress? progress;
  final Color color;
  final VoidCallback onEdit;

  const _BudgetCard({
    required this.provider,
    required this.title,
    this.icon,
    required this.progress,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final p = progress;
    final status = p?.status ?? BudgetStatus.safe;

    final statusColor = switch (status) {
      BudgetStatus.safe => Colors.green,
      BudgetStatus.warning => Colors.orange,
      BudgetStatus.over => Colors.red,
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: status == BudgetStatus.over
              ? Colors.red.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: p == null
              ? _buildUnset(l10n, theme, colorScheme)
              : _buildProgress(l10n, theme, colorScheme, p, statusColor),
        ),
      ),
    );
  }

  Widget _buildUnset(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
        ] else
          Icon(Icons.add_circle_outline_rounded,
              color: colorScheme.outline, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.notSetTapToSet,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
      ],
    );
  }

  Widget _buildProgress(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    BudgetProgress p,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${p.percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Wrap (bukan Row) supaya saat nominal panjang atau teks diperbesar,
        // baris "terpakai / dari batas" turun ke bawah dan utuh, bukan
        // terpotong di tepi kartu.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 2,
          spacing: 12,
          children: [
            Text(
              l10n.budgetSpent(CurrencyHelper.format(p.spent)),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            Text(
              l10n.ofLimit(CurrencyHelper.format(p.limit)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (p.percentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        if (p.status == BudgetStatus.over) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.overBudgetBy(CurrencyHelper.format(p.spent - p.limit)),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ] else if (p.status == BudgetStatus.warning) ...[
          const SizedBox(height: 6),
          Text(
            l10n.budgetRemaining(CurrencyHelper.format(p.remaining)),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

/// Dialog pemilih kategori pengeluaran untuk anggaran baru.
///
/// Mengembalikan ID kategori yang dipilih, atau null jika dibatalkan.
class _CategoryBudgetPickerDialog extends StatelessWidget {
  final FinanceProvider provider;
  final List<TransactionCategory> categories;

  const _CategoryBudgetPickerDialog({
    required this.provider,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(l10n.addCategoryBudget),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                l10n.perExpenseCategory,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              for (final cat in categories) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  title: Text(
                    cat.localized(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: _budgetSubtitle(l10n, theme, colorScheme, cat.id),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: colorScheme.outline),
                  onTap: () => Navigator.pop(context, cat.id),
                ),
                const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _budgetSubtitle(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    String categoryId,
  ) {
    final budget = provider.getBudgetForCategory(categoryId);
    if (budget != null) {
      return Text(
        l10n.currentBudget(CurrencyHelper.format(budget.monthlyLimit)),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
        ),
      );
    }
    return Text(
      l10n.notSetTapToSet,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.outline,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Dialog untuk set/update/hapus budget.
class _BudgetDialog extends StatefulWidget {
  final FinanceProvider provider;
  final String? categoryId;

  const _BudgetDialog({
    required this.provider,
    this.categoryId,
  });

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late TextEditingController _amountController;
  bool _isSaving = false;

  bool get isGlobal => widget.categoryId == null;

  /// Anggaran yang sedang diedit. Lookup selalu lewat provider
  /// (global via [FinanceProvider.getGlobalBudget], kategori via
  /// [FinanceProvider.getBudgetForCategory]) supaya tidak ada dua
  /// cara berbeda mendeteksi anggaran yang sama.
  Budget? get existing => isGlobal
      ? widget.provider.getGlobalBudget()
      : widget.provider.getBudgetForCategory(widget.categoryId!);

  bool get hasExisting => existing != null;

  @override
  void initState() {
    super.initState();
    final budget = existing;
    _amountController = TextEditingController(
      text: budget != null ? CurrencyHelper.formatNumber(budget.monthlyLimit) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _titleFor(AppLocalizations l10n) {
    if (isGlobal) return l10n.globalBudgetTitle;
    final cat = widget.provider.getCategoryById(widget.categoryId!);
    return l10n.categoryBudgetTitle(cat.localized(context));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final parsed = CurrencyHelper.parse(_amountController.text);

    // Tolak input kosong/bukan angka. Angka 0 hanya berarti "hapus"
    // jika memang sudah ada anggaran; kalau belum ada, 0 bukan aksi
    // yang valid dan tidak boleh ditutup seolah-olah berhasil.
    if (parsed == null || parsed < 0 || (parsed == 0 && !hasExisting)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidAmount)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.provider.setBudget(
        categoryId: widget.categoryId,
        monthlyLimit: parsed, // 0 = hapus budget
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.budgetSaveFailed('$e'))),
        );
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBudgetTitle),
        content: Text(l10n.deleteBudgetMessage(_titleFor(l10n))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.provider.deleteBudget(isGlobal ? 'global' : widget.categoryId!);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.budgetSaveFailed('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(_titleFor(l10n)),
      // `scrollable: true` membungkus judul + isi dalam scroll view sehingga
      // tetap aman di layar pendek, saat keyboard terbuka, atau ketika ukuran
      // teks diperbesar — tanpa memotong isi dialog.
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isGlobal ? l10n.globalBudgetDesc : l10n.categoryBudgetDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: const [ThousandsSeparatorInputFormatter()],
            autofocus: true,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              hintText: '0',
              helperText: hasExisting ? l10n.enterZeroToDelete : null,
              filled: true,
              fillColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (hasExisting) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: colorScheme.outline),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.currentBudget(
                      CurrencyHelper.format(existing!.monthlyLimit),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            ],
          ],
        ),
      actions: [
        if (hasExisting)
          TextButton.icon(
            onPressed: _isSaving ? null : _delete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(l10n.delete),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(hasExisting ? l10n.save : l10n.setBudget),
        ),
      ],
    );
  }
}
