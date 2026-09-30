import 'package:flutter/material.dart';
import '../../l10n/category_l10n.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/category.dart';
import '../../providers/finance_provider.dart';

/// Screen untuk mengelola kategori (CRUD)
class CategoryManagementScreen extends StatefulWidget {
  final FinanceProvider provider;

  const CategoryManagementScreen({super.key, required this.provider});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageCategoryTitle),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.arrow_downward_rounded),
              text: l10n.income,
            ),
            Tab(
              icon: const Icon(Icons.arrow_upward_rounded),
              text: l10n.expense,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(
            provider: widget.provider,
            type: TransactionType.income,
          ),
          _CategoryList(
            provider: widget.provider,
            type: TransactionType.expense,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(
          context,
          _tabController.index == 0
              ? TransactionType.income
              : TransactionType.expense,
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addCategory),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(
      BuildContext context, TransactionType type) async {
    final result = await showDialog<TransactionCategory>(
      context: context,
      builder: (_) => _CategoryFormDialog(
        provider: widget.provider,
        type: type,
      ),
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.categoryAdded(result.name),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// List kategori berdasarkan tipe
class _CategoryList extends StatelessWidget {
  final FinanceProvider provider;
  final TransactionType type;

  const _CategoryList({
    required this.provider,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final defaultCategories = type == TransactionType.income
        ? TransactionCategory.defaultIncomeCategories
        : TransactionCategory.defaultExpenseCategories;

    final customCategories =
        provider.customCategories.where((c) => c.type == type).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // ==================== KATEGORI CUSTOM ====================
        if (customCategories.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.yourCategories(customCategories.length),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...customCategories.map((cat) => _CategoryTile(
                provider: provider,
                category: cat,
                onEdit: () => _showEditDialog(context, cat),
                onDelete: () => _confirmDelete(context, cat),
              )),
          const SizedBox(height: 20),
        ],

        // ==================== KATEGORI DEFAULT ====================
        Row(
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 16, color: colorScheme.outline),
            const SizedBox(width: 8),
            Text(
              l10n.defaultCategories(defaultCategories.length),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...defaultCategories.map((cat) => _CategoryTile(
              provider: provider,
              category: cat,
              isDefault: true,
            )),

        const SizedBox(height: 80), // Space untuk FAB
      ],
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, TransactionCategory category) async {
    final result = await showDialog<TransactionCategory>(
      context: context,
      builder: (_) => _CategoryFormDialog(
        provider: provider,
        type: category.type,
        initialCategory: category,
      ),
    );

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.categoryUpdated(result.name),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, TransactionCategory category) async {
    final l10n = AppLocalizations.of(context)!;

    // Cek apakah bisa dihapus
    final check = provider.canDeleteCategory(category);
    if (!check.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            categoryErrorMessage(
              l10n,
              CategoryException(check.error!, usageCount: check.usageCount),
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: Text(l10n.deleteCategoryTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.deleteCategoryMessage(category.name),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.deleteCategoryUnusedInfo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final navContext = context;
      try {
        await provider.deleteCategory(category.id);
        if (navContext.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(navContext)!.categoryDeleted(category.name),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (navContext.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                categoryDeleteErrorMessage(
                  AppLocalizations.of(navContext)!,
                  e,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

/// Tile untuk menampilkan kategori
class _CategoryTile extends StatelessWidget {
  final FinanceProvider provider;
  final TransactionCategory category;
  final bool isDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.provider,
    required this.category,
    this.isDefault = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final usageCount = provider.getCategoryUsageCount(category.id);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          category.localized(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (category.isCustom) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.customBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    usageCount > 0
                        ? l10n.categoryTransactionCount(usageCount)
                        : l10n.notUsed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            if (!isDefault) ...[
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                onPressed: onEdit,
                tooltip: l10n.edit,
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: usageCount > 0
                      ? colorScheme.outline
                      : colorScheme.error,
                ),
                onPressed: onDelete,
                tooltip: usageCount > 0 ? l10n.categoryInUseTooltip : l10n.delete,
              ),
            ] else
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog form untuk tambah/ubah kategori
class _CategoryFormDialog extends StatefulWidget {
  final FinanceProvider provider;
  final TransactionType type;
  final TransactionCategory? initialCategory;

  const _CategoryFormDialog({
    required this.provider,
    required this.type,
    this.initialCategory,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;

  bool get isEditing => widget.initialCategory != null;

  // Preset icons untuk dipilih
  static const List<IconData> _availableIcons = [
    Icons.shopping_cart_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.health_and_safety_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.flight_rounded,
    Icons.coffee_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.fitness_center_rounded,
    Icons.checkroom_rounded,
    Icons.phone_iphone_rounded,
    Icons.laptop_mac_rounded,
    Icons.card_giftcard_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
    Icons.savings_rounded,
    Icons.trending_up_rounded,
    Icons.business_center_rounded,
    Icons.payments_rounded,
    Icons.account_balance_rounded,
    Icons.card_membership_rounded,
  ];

  // Preset colors
  static const List<Color> _availableColors = [
    Color(0xFFE53935), // Red
    Color(0xFFEF6C00), // Orange
    Color(0xFFFDD835), // Yellow
    Color(0xFF43A047), // Green
    Color(0xFF00897B), // Teal
    Color(0xFF1E88E5), // Blue
    Color(0xFF3949AB), // Indigo
    Color(0xFF8E24AA), // Purple
    Color(0xFFD81B60), // Pink
    Color(0xFF6D4C41), // Brown
    Color(0xFF546E7A), // Blue Grey
    Color(0xFF757575), // Grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialCategory?.name ?? '',
    );
    _selectedIcon = widget.initialCategory?.icon ?? Icons.category_rounded;
    _selectedColor = widget.initialCategory?.color ?? _availableColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEditing) {
        // Update
        final updated = widget.initialCategory!.copyWith(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
        );
        await widget.provider.updateCategory(updated);
        if (mounted) Navigator.pop(context, updated);
      } else {
        // Create
        final created = await widget.provider.addCategory(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          type: widget.type,
        );
        if (mounted) Navigator.pop(context, created);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryErrorMessage(AppLocalizations.of(context)!, e),
            ),
            backgroundColor: Colors.red,
          ),
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
      title: Text(isEditing ? l10n.editCategoryTitle : l10n.addCategory),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _selectedIcon,
                    color: _selectedColor,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nama
              Text(
                l10n.categoryNameLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.categoryNameHint,
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.categoryNameRequired;
                  }
                  if (val.trim().length > 30) {
                    return l10n.categoryNameMax30;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Icon picker
              Text(
                l10n.pickIcon,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _availableIcons.length,
                  itemBuilder: (ctx, index) {
                    final icon = _availableIcons[index];
                    final isSelected = icon == _selectedIcon;

                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? _selectedColor
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Color picker
              Text(
                l10n.pickColor,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = color == _selectedColor;

                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              if (isEditing) ...[
                const SizedBox(height: 16),
                // Info untuk edit
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.categoryEditInfo,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
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
        FilledButton.icon(
          onPressed: _save,
          icon: Icon(isEditing ? Icons.check_rounded : Icons.add_rounded),
          label: Text(isEditing ? l10n.save : l10n.add),
        ),
      ],
    );
  }
}
