import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/finance_provider.dart';
import '../../utils/currency_helper.dart';

class BalanceCard extends StatelessWidget {
  final FinanceProvider provider;

  const BalanceCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final balance = provider.currentMonthBalance;
    final income = provider.currentMonthIncome;
    final expense = provider.currentMonthExpense;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHigh,
                  colorScheme.surfaceContainer,
                ]
              : [
                  colorScheme.primaryContainer,
                  colorScheme.surfaceContainerLowest,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.monthlyBalance,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.totalBalance(
                        CurrencyHelper.format(provider.totalBalance),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Saldo ber-animasi count-up saat berpindah bulan/data berubah.
          _AnimatedAmount(
            amount: balance,
            color: balance >= 0 ? colorScheme.onSurface : Colors.redAccent,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  label: l10n.income,
                  amount: income,
                  isIncome: true,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _buildMetricTile(
                  context: context,
                  label: l10n.expense,
                  amount: expense,
                  isIncome: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String label,
    required int amount,
    required bool isIncome,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isIncome ? Colors.teal : Colors.redAccent;
    final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyHelper.format(amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Teks nominal yang ber-animasi count-up saat nilainya berubah.
///
/// Memakai [TweenAnimationBuilder] sehingga saat [amount] berganti (misal
/// user pindah bulan), angka bergulir mulus dari nilai lama ke baru, bukan
/// langsung melompat.
class _AnimatedAmount extends StatelessWidget {
  final int amount;
  final Color color;
  final TextStyle? style;

  const _AnimatedAmount({
    required this.amount,
    required this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount.toDouble()),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          CurrencyHelper.format(value.round()),
          style: style?.copyWith(color: color),
        );
      },
    );
  }
}
