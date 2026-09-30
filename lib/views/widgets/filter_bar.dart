import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/category.dart';
import '../../providers/finance_provider.dart';
import '../../utils/date_helper.dart';

class FilterBar extends StatelessWidget {
  final FinanceProvider provider;

  const FilterBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Bulan & Navigasi Periode
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
            InkWell(
              onTap: () => _showMonthPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      DateHelper.formatMonthYear(provider.selectedMonth),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
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
        const SizedBox(height: 12),
        // Filter Type (Semua / Pemasukan / Pengeluaran)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                selected: provider.selectedTypeFilter == null,
                label: Text(l10n.allFilter),
                avatar: const Icon(Icons.all_inclusive_rounded, size: 16),
                onSelected: (_) => provider.setTypeFilter(null),
                showCheckmark: false,
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: provider.selectedTypeFilter == TransactionType.income,
                label: Text(l10n.income),
                avatar: const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.teal),
                onSelected: (_) {
                  provider.setTypeFilter(
                    provider.selectedTypeFilter == TransactionType.income
                        ? null
                        : TransactionType.income,
                  );
                },
                showCheckmark: false,
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: provider.selectedTypeFilter == TransactionType.expense,
                label: Text(l10n.expense),
                avatar: const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.redAccent),
                onSelected: (_) {
                  provider.setTypeFilter(
                    provider.selectedTypeFilter == TransactionType.expense
                        ? null
                        : TransactionType.expense,
                  );
                },
                showCheckmark: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();
    final currentSelected = provider.selectedMonth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        int selectedYear = currentSelected.year;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setModalState(() => selectedYear--),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          '$selectedYear',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setModalState(() => selectedYear++),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: 12,
                      itemBuilder: (ctx, index) {
                        final monthNum = index + 1;
                        final isSelected =
                            selectedYear == currentSelected.year && monthNum == currentSelected.month;
                        final isCurrentMonth =
                            selectedYear == now.year && monthNum == now.month;

                        return ChoiceChip(
                          label: Text(
                            DateHelper.monthNames[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            provider.setSelectedMonth(DateTime(selectedYear, monthNum));
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isCurrentMonth && !isSelected
                                ? BorderSide(color: Theme.of(context).colorScheme.primary)
                                : BorderSide.none,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
