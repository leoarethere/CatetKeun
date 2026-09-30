import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/finance_provider.dart';
import '../../utils/currency_helper.dart';
import '../../utils/date_helper.dart';

/// Bar chart tren pemasukan/pengeluaran N bulan terakhir
class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTrendData> trendData;

  const MonthlyTrendChart({super.key, required this.trendData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Hitung max value untuk skala Y
    int maxVal = 0;
    for (final d in trendData) {
      if (d.income > maxVal) maxVal = d.income;
      if (d.expense > maxVal) maxVal = d.expense;
    }
    if (maxVal == 0) maxVal = 100000; // default agar chart tidak error

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendDot(Colors.teal, l10n.income),
            const SizedBox(width: 20),
            _buildLegendDot(Colors.redAccent, l10n.expense),
          ],
        ),
        const SizedBox(height: 16),

        // Bar Chart
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.15,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < 0 || groupIndex >= trendData.length) {
                      return null;
                    }
                    final data = trendData[groupIndex];
                    final value = rodIndex == 0 ? data.income : data.expense;
                    final label =
                        rodIndex == 0 ? l10n.incomeShort : l10n.expenseShort;
                    return BarTooltipItem(
                      '$label\n${CurrencyHelper.format(value)}',
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        backgroundColor:
                            rodIndex == 0 ? Colors.teal : Colors.redAccent,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= trendData.length) {
                        return const SizedBox.shrink();
                      }
                      final month = trendData[index].month;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateHelper.shortMonthNames[month.month - 1],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) {
                      // Format dalam ribu (K) atau juta (Jt/M)
                      return Text(
                        _formatCompact(value.toInt(), l10n),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxVal / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: trendData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final isCurrentMonth =
                    index == trendData.length - 1;

                return BarChartGroupData(
                  x: index,
                  barsSpace: 3,
                  barRods: [
                    BarChartRodData(
                      toY: data.income.toDouble(),
                      color: Colors.teal,
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: data.expense.toDouble(),
                      color: Colors.redAccent,
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                  showingTooltipIndicators: isCurrentMonth ? [0, 1] : [],
                );
              }).toList(),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _formatCompact(int value, AppLocalizations l10n) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}${l10n.compactBillion}';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}${l10n.compactMillion}';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}${l10n.compactThousand}';
    }
    return value.toString();
  }
}
