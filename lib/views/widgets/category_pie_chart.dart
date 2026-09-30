import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/category_l10n.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/finance_provider.dart';
import '../../utils/currency_helper.dart';

/// Donut chart menampilkan proporsi pengeluaran/pemasukan per kategori
class CategoryPieChart extends StatefulWidget {
  final List<CategoryStat> stats;
  final bool isExpense;

  const CategoryPieChart({
    super.key,
    required this.stats,
    required this.isExpense,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? touchedIndex;

  @override
  void didUpdateWidget(covariant CategoryPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset index jika data berubah atau index sudah tidak valid
    if (touchedIndex != null &&
        (touchedIndex! < 0 ||
            touchedIndex! >= widget.stats.length ||
            widget.stats != oldWidget.stats)) {
      touchedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.stats.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = widget.stats.fold(0, (sum, s) => sum + s.totalAmount);

    final isTouchedValid = touchedIndex != null &&
        touchedIndex! >= 0 &&
        touchedIndex! < widget.stats.length;
    final activeStat = isTouchedValid ? widget.stats[touchedIndex!] : null;

    return Column(
      children: [
        // Donut Chart
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = null;
                          return;
                        }
                        final index = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                        // fl_chart mengembalikan -1 saat touch di luar sektor atau di tengah donut
                        if (index < 0 || index >= widget.stats.length) {
                          touchedIndex = null;
                        } else {
                          touchedIndex = index;
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 56,
                  sections: _buildSections(isTouchedValid),
                ),
              ),
              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeStat != null
                        ? '${activeStat.percentage.toStringAsFixed(1)}%'
                        : l10n.chartTotalLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: activeStat != null
                          ? activeStat.category.color
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (activeStat != null)
                    Text(
                      CurrencyHelper.format(activeStat.totalAmount),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Text(
                      CurrencyHelper.format(total),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            final isSelected = isTouchedValid && touchedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  touchedIndex = isSelected ? null : index;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? stat.category.color.withValues(alpha: 0.15)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: stat.category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stat.category.localized(context),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stat.percentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(bool isTouchedValid) {
    return widget.stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isTouched = isTouchedValid && index == touchedIndex;
      final radius = isTouched ? 58.0 : 48.0;

      return PieChartSectionData(
        color: stat.category.color,
        value: stat.percentage,
        title: '',
        showTitle: false,
        radius: radius,
        badgeWidget: isTouched
            ? _BadgeWidget(
                text: '${stat.percentage.toStringAsFixed(0)}%',
                color: stat.category.color,
              )
            : null,
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }
}

class _BadgeWidget extends StatelessWidget {
  final String text;
  final Color color;

  const _BadgeWidget({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
