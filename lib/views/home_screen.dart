import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/date_helper.dart';
import 'add_edit_transaction_screen.dart';
import 'widgets/app_logo.dart';
import 'widgets/app_overflow_menu.dart';
import 'widgets/app_page_route.dart';
import 'statistics_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/filter_bar.dart';
import 'widgets/transaction_item_tile.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  final FinanceProvider provider;

  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTransaction(BuildContext context, [Transaction? tx]) {
    Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => AddEditTransactionScreen(
          provider: widget.provider,
          initialTransaction: tx,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_currentNavIndex),
          child: _currentNavIndex == 0
              ? _buildTransactionsTab(context, l10n)
              : _currentNavIndex == 1
                  ? StatisticsScreen(provider: widget.provider)
                  : const AboutScreen(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        currentIndex: _currentNavIndex,
        onTap: (idx) => setState(() => _currentNavIndex = idx),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.navTransactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            activeIcon: const Icon(Icons.pie_chart_rounded),
            label: l10n.navStatistics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info_outline_rounded),
            activeIcon: const Icon(Icons.info_rounded),
            label: l10n.navAbout,
          ),
        ],
      ),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddTransaction(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addTransaction),
              elevation: 3,
            )
          : null,
    );
  }

  Widget _buildTransactionsTab(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = widget.provider;

    return CustomScrollView(
      slivers: [
        // App Bar Material 3
        SliverAppBar(
          floating: true,
          pinned: true,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    border: InputBorder.none,
                  ),
                  onChanged: provider.setSearchQuery,
                )
              : Row(
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
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
              tooltip: _isSearching ? l10n.closeSearchTitle : l10n.searchTitle,
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    provider.setSearchQuery('');
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
            AppOverflowMenu(provider: provider),
            const SizedBox(width: 8),
          ],
        ),

        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                BalanceCard(provider: provider),
                const SizedBox(height: 16),

                // Filter Bar
                FilterBar(provider: provider),
                const SizedBox(height: 12),

                // Subheader
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.transactionHistory,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.transactionCount(provider.filteredTransactions.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Transactions List or Empty State
        if (provider.isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (provider.filteredTransactions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: l10n.emptyTransactionsTitle,
              message: provider.searchQuery.isNotEmpty
                  ? l10n.emptySearchMessage(provider.searchQuery)
                  : l10n.emptyPeriodMessage(
                      DateHelper.formatMonthYear(provider.selectedMonth),
                    ),
              actionLabel: l10n.addNewRecord,
              onAction: () => _openAddTransaction(context),
            ),
          )
        else
          _buildGroupedTransactionsSliver(context, provider, l10n),

        // Bottom space so FAB doesn't obscure the last item
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildGroupedTransactionsSliver(
    BuildContext context,
    FinanceProvider provider,
    AppLocalizations l10n,
  ) {
    final transactions = provider.filteredTransactions;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Grouping by Date
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in transactions) {
      final headerKey = DateHelper.formatGroupHeader(tx.date);
      grouped.putIfAbsent(headerKey, () => []).add(tx);
    }

    final groupKeys = grouped.keys.toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, groupIndex) {
            final groupTitle = groupKeys[groupIndex];
            final items = grouped[groupTitle]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      groupTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Items in this group
                  ...items.map((tx) {
                    return TransactionItemTile(
                      transaction: tx,
                      onTap: () => _openAddTransaction(context, tx),
                      onDelete: () {
                        final deletedTx = tx;
                        provider.deleteTransaction(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.transactionDeleted(deletedTx.title),
                            ),
                            action: SnackBarAction(
                              label: l10n.undo,
                              onPressed: () {
                                provider.addTransaction(deletedTx);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          },
          childCount: groupKeys.length,
        ),
      ),
    );
  }
}
