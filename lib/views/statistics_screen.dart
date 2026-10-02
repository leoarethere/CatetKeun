import 'package:flutter/material.dart';
import '../l10n/category_l10n.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_helper.dart';
import '../utils/date_helper.dart';
import 'budget_screen.dart';
import 'widgets/app_logo.dart';
import 'widgets/app_overflow_menu.dart';
import 'widgets/app_page_route.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/empty_state.dart';
import 'widgets/monthly_trend_chart.dart';

/// Tampilan statistik: list atau chart
enum StatsView { list, chart }

class StatisticsScreen extends StatefulWidget {
  final FinanceProvider provider;

  const StatisticsScreen({super.key, required this.provider});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TransactionType _selectedType = TransactionType.expense;
  StatsView _statsView = StatsView.list;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = widget.provider;

    final stats = _selectedType == TransactionType.expense
        ? provider.getExpenseCategoryStats()
        : provider.getIncomeCategoryStats();

    final totalAmount = _selectedType == TransactionType.expense
        ? provider.currentMonthExpense
        : provider.currentMonthIncome;

    final isExpense = _selectedType == TransactionType.expense;
    final activeColor = isExpense ? Colors.redAccent : Colors.teal;

    return Scaffold(
      appBar: AppBar(
        // Replicate header from HomeScreen: icon, app name, and overflow menu
        title: Row(
          children: [
            const AppLogo(size: 26),
            const SizedBox(width: 10),
            Text(l10n.appTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.2)),
          ],
        ),
        centerTitle: false,
      actions: [
          // Menu overflow bersama (sama seperti HomeScreen)
          AppOverflowMenu(provider: provider),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Period Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: provider.previousMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: l10n.previousMonth,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  DateHelper.formatMonthYear(provider.selectedMonth),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: provider.nextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: l10n.nextMonth,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Toggle: List / Chart + Segmented Pengeluaran/Pemasukan
            Row(
              children: [
                // View toggle (List vs Chart)
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildViewToggle(
                        icon: Icons.list_rounded,
                        view: StatsView.list,
                        tooltip: l10n.listViewTooltip,
                      ),
                      _buildViewToggle(
                        icon: Icons.pie_chart_rounded,
                        view: StatsView.chart,
                        tooltip: l10n.chartViewTooltip,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Type toggle
                Expanded(
                  child: SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment<TransactionType>(
                        value: TransactionType.income,
                        label: Text(l10n.incomeShort),
                        icon: const Icon(Icons.arrow_downward_rounded),
                      ),
                      ButtonSegment<TransactionType>(
                        value: TransactionType.expense,
                        label: Text(l10n.expenseShort),
                        icon: const Icon(Icons.arrow_upward_rounded),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (set) {
                      setState(() => _selectedType = set.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor:
                          activeColor.withValues(alpha: 0.15),
                      selectedForegroundColor: activeColor,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Total Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surfaceContainerLowest,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.totalThisMonth(
                      isExpense ? l10n.expense : l10n.income,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyHelper.format(totalAmount),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.categoriesRecorded(stats.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ============ ANGGARAN (jika ada) ============
            ..._buildBudgetSection(context),

            // ============ KONTEN: LIST atau CHART ============
            if (_statsView == StatsView.list) ...[
              Text(
                l10n.categoryBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (stats.isEmpty)
                EmptyState(
                  title: l10n.emptyDataTitle,
                  message: l10n.emptyStatsMessage(
                    isExpense ? l10n.expense : l10n.income,
                    DateHelper.formatMonthYear(provider.selectedMonth),
                  ),
                )
              else
                ...stats.map((stat) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    color: colorScheme.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: stat.category.color
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  stat.category.icon,
                                  color: stat.category.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stat.category.localized(context),
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      l10n.categoryTransactionCount(stat.count),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyHelper.format(stat.totalAmount),
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${stat.percentage.toStringAsFixed(1)}%',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: stat.percentage / 100.0,
                              ),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) =>
                                  LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  stat.category.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ] else ...[
              // ===== CHART VIEW =====
              if (stats.isEmpty)
                EmptyState(
                  title: l10n.emptyDataTitle,
                  message: l10n.emptyStatsMessage(
                    isExpense ? l10n.expense : l10n.income,
                    DateHelper.formatMonthYear(provider.selectedMonth),
                  ),
                )
              else ...[
                Text(
                  l10n.proportionPerCategory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CategoryPieChart(
                  stats: stats,
                  isExpense: isExpense,
                ),
                const SizedBox(height: 28),
              ],

              // Tren 6 bulan
              Builder(builder: (context) {
                final trend = provider.getMonthlyTrend(months: 6);
                final hasData = trend.any((t) => t.income > 0 || t.expense > 0);
                if (!hasData) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trendTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.trendSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MonthlyTrendChart(trendData: trend),
                  ],
                );
              }),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required StatsView view,
    required String tooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _statsView == view;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _statsView = view),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? colorScheme.onPrimary : colorScheme.outline,
          ),
        ),
      ),
    );
  }

  /// Bagian anggaran di StatisticsScreen (muncul hanya jika ada budget).
  List<Widget> _buildBudgetSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = widget.provider;

    // Hanya tampilkan jika type = expense (anggaran hanya untuk pengeluaran)
    if (_selectedType != TransactionType.expense) return [];

    // Anggaran selalu dihitung untuk bulan berjalan. Sembunyikan blok ini
    // saat pengguna membuka bulan lain supaya angkanya tidak dianggap
    // anggaran dari bulan yang sedang dilihat.
    final now = DateTime.now();
    final isCurrentMonth =
        provider.selectedMonth.year == now.year &&
        provider.selectedMonth.month == now.month;
    if (!isCurrentMonth) return [];

    final global = provider.getGlobalBudgetProgress();
    final categories = provider
        .getCategoryBudgetProgress()
        .where((p) => p.budget.categoryId != null)
        .toList();

    if (global == null && categories.isEmpty) return [];

    return [
      Row(
        children: [
          Icon(Icons.savings_rounded, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.budgetThisMonth,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                AppPageRoute(
                  builder: (_) => BudgetScreen(provider: provider),
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                l10n.setBudget,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),

      // Budget global
      if (global != null)
        _BudgetMiniCard(progress: global, label: l10n.totalExpenseLabel),

      // Budget per kategori (maks 4 tampil, sisanya di screen kelola)
      ...categories.take(4).map((p) {
        final cat = provider.getCategoryById(p.budget.categoryId!);
        return _BudgetMiniCard(
          progress: p,
          label: cat.localized(context),
          icon: cat.icon,
          color: cat.color,
        );
      }),

      if (categories.length > 4)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l10n.moreBudgets(categories.length - 4),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      const SizedBox(height: 16),
    ];
  }
}

/// Kartu mini progress budget untuk StatisticsScreen.
class _BudgetMiniCard extends StatelessWidget {
  final BudgetProgress progress;
  final String label;
  final IconData? icon;
  final Color? color;

  const _BudgetMiniCard({
    required this.progress,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = switch (progress.status) {
      BudgetStatus.safe => Colors.green,
      BudgetStatus.warning => Colors.orange,
      BudgetStatus.over => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progress.status == BudgetStatus.over
              ? Colors.red.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color ?? colorScheme.primary),
                const SizedBox(width: 8),
              ] else
                Icon(Icons.account_balance_wallet_rounded,
                    size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${progress.percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: (progress.percentage / 100).clamp(0.0, 1.0),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Wrap (bukan Row) supaya nominal panjang tetap utuh: baris turun
          // ke bawah alih-alih terpotong di tepi kartu.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 2,
            spacing: 12,
            children: [
              Text(
                CurrencyHelper.format(progress.spent),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.ofLimit(CurrencyHelper.format(progress.limit)),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
