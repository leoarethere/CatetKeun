// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CatetKeun';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get continueBtn => 'Continue';

  @override
  String get close => 'Close';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get incomeShort => 'In';

  @override
  String get expenseShort => 'Out';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get searchTitle => 'Search Transactions';

  @override
  String get closeSearchTitle => 'Close Search';

  @override
  String get searchHint => 'Search transactions...';

  @override
  String get moreMenu => 'More options';

  @override
  String get manageBudgetMenu => 'Manage Budget';

  @override
  String get manageCategoryMenu => 'Manage Categories';

  @override
  String get exportImportMenu => 'Export/Import Data';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navAbout => 'About';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String transactionCount(int count) {
    return '$count transactions';
  }

  @override
  String get emptyTransactionsTitle => 'No Transactions Yet';

  @override
  String emptySearchMessage(String query) {
    return 'No transactions found matching the keyword \"$query\".';
  }

  @override
  String emptyPeriodMessage(String period) {
    return 'No financial records for $period.';
  }

  @override
  String get addNewRecord => 'Add New Record';

  @override
  String transactionDeleted(String title) {
    return 'Record \"$title\" deleted';
  }

  @override
  String get undo => 'Undo';

  @override
  String get monthlyBalance => 'Balance This Month';

  @override
  String totalBalance(String amount) {
    return 'Total: $amount';
  }

  @override
  String get allFilter => 'All';

  @override
  String get statisticsTitle => 'Reports & Statistics';

  @override
  String get listViewTooltip => 'List View';

  @override
  String get chartViewTooltip => 'Chart View';

  @override
  String totalThisMonth(String type) {
    return 'Total $type This Month';
  }

  @override
  String categoriesRecorded(int count) {
    return '$count categories recorded';
  }

  @override
  String get budgetThisMonth => 'Budget This Month';

  @override
  String get setBudget => 'Set';

  @override
  String get categoryBreakdown => 'Breakdown by Category';

  @override
  String get emptyDataTitle => 'No Data Yet';

  @override
  String emptyStatsMessage(String type, String period) {
    return 'No $type records for $period.';
  }

  @override
  String get proportionPerCategory => 'Proportion by Category';

  @override
  String get trendTitle => 'Last 6 Months Trend';

  @override
  String get trendSubtitle => 'Income vs expense comparison';

  @override
  String categoryTransactionCount(int count) {
    return '$count transactions';
  }

  @override
  String get chartTotalLabel => 'Total';

  @override
  String get compactBillion => 'B';

  @override
  String get compactMillion => 'M';

  @override
  String get compactThousand => 'K';

  @override
  String get addRecordTitle => 'Add New Record';

  @override
  String get editRecordTitle => 'Edit Record';

  @override
  String get updateRecord => 'Update Record';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Enter the transaction amount';

  @override
  String get amountMustBePositive => 'Amount must be greater than 0';

  @override
  String get transactionTitleLabel => 'Transaction Title';

  @override
  String get transactionTitleRequired => 'Transaction title is required';

  @override
  String get transactionTitleHint => 'e.g. Lunch, Office Salary, etc.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get dateLabel => 'Date';

  @override
  String get noteOptionalLabel => 'Additional Note (Optional)';

  @override
  String get noteHint => 'Details or extra information...';

  @override
  String get deleteRecordAction => 'Delete Record';

  @override
  String get deleteRecordTitle => 'Delete Record?';

  @override
  String get deleteRecordMessage => 'This record will be deleted permanently.';

  @override
  String deleteTransactionConfirm(String title) {
    return 'Are you sure you want to delete the record \"$title\"?';
  }

  @override
  String get manageCategoryTitle => 'Manage Categories';

  @override
  String yourCategories(int count) {
    return 'Your Categories ($count)';
  }

  @override
  String defaultCategories(int count) {
    return 'Default Categories ($count)';
  }

  @override
  String get addCategory => 'Add Category';

  @override
  String categoryAdded(String name) {
    return 'Category \"$name\" added';
  }

  @override
  String categoryUpdated(String name) {
    return 'Category \"$name\" updated';
  }

  @override
  String categoryDeleted(String name) {
    return 'Category \"$name\" deleted';
  }

  @override
  String get deleteCategoryTitle => 'Delete Category?';

  @override
  String deleteCategoryMessage(String name) {
    return 'Category \"$name\" will be deleted permanently.';
  }

  @override
  String get deleteCategoryUnusedInfo =>
      'This category is not used by any transaction.';

  @override
  String deleteCategoryFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get categoryInUseTooltip => 'In use';

  @override
  String get notUsed => 'Not used';

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get categoryNameRequired => 'Name is required';

  @override
  String get categoryNameMax30 => 'Maximum 30 characters';

  @override
  String get categoryNameHint => 'e.g. Coffee, Pets, etc.';

  @override
  String get pickIcon => 'Pick Icon';

  @override
  String get pickColor => 'Pick Color';

  @override
  String get customBadge => 'Custom';

  @override
  String get categoryEditInfo =>
      'Changes will apply to all transactions using this category.';

  @override
  String actionFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get categoryDefaultCannotDelete =>
      'Default categories cannot be deleted';

  @override
  String get categoryDefaultCannotEdit => 'Default categories cannot be edited';

  @override
  String categoryStillUsed(int count) {
    return 'Category is still used by $count transactions';
  }

  @override
  String get categoryNotFound => 'Category not found';

  @override
  String get manageBudgetTitle => 'Manage Budget';

  @override
  String get budgetIntro =>
      'Set monthly spending limits for total or per category.';

  @override
  String get totalMonthlyExpense => 'Total Monthly Expense';

  @override
  String get totalExpenseLabel => 'Total Expense';

  @override
  String get totalBudgetCard => 'Total Budget';

  @override
  String get perExpenseCategory => 'By Expense Category';

  @override
  String get noCategoryBudget => 'No category budget yet. Tap + to add one.';

  @override
  String get notSetTapToSet => 'Not set - tap to set a budget';

  @override
  String get addCategoryBudget => 'Add Category Budget';

  @override
  String get globalBudgetTitle => 'Total Monthly Budget';

  @override
  String categoryBudgetTitle(String name) {
    return '$name Budget';
  }

  @override
  String get globalBudgetDesc =>
      'Monthly spending limit across all categories.';

  @override
  String get categoryBudgetDesc => 'Monthly spending limit for this category.';

  @override
  String get enterZeroToDelete => 'Enter 0 to delete the budget';

  @override
  String currentBudget(String amount) {
    return 'Current: $amount/month';
  }

  @override
  String get deleteBudgetTitle => 'Delete Budget?';

  @override
  String deleteBudgetMessage(String title) {
    return 'Budget \"$title\" will be deleted.';
  }

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String budgetSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String budgetSpent(String amount) {
    return 'Spent $amount';
  }

  @override
  String ofLimit(String amount) {
    return 'of $amount';
  }

  @override
  String overBudgetBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount left';
  }

  @override
  String moreBudgets(int count) {
    return '+$count more budgets';
  }

  @override
  String get exportImportTitle => 'Export & Import Data';

  @override
  String get exportImportSubtitle =>
      'Back up your data or move it to another device';

  @override
  String storedTransactions(int count) {
    return '$count transactions stored';
  }

  @override
  String get exportSection => 'EXPORT';

  @override
  String get jsonFormat => 'JSON';

  @override
  String get jsonFormatDesc => 'Full format';

  @override
  String get csvFormat => 'CSV';

  @override
  String get csvFormatDesc => 'For Excel';

  @override
  String get importSection => 'IMPORT';

  @override
  String get pickFile => 'Choose File';

  @override
  String get jsonOrCsv => 'JSON or CSV';

  @override
  String exportSuccess(String format) {
    return '$format file created successfully';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String pickFileFailed(String error) {
    return 'Failed to pick file: $error';
  }

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get noValidTransactions => 'No valid transactions in the file';

  @override
  String get errFileReadFailed => 'Failed to read the file';

  @override
  String get errInvalidJson => 'Invalid JSON format';

  @override
  String get errEmptyCsv => 'CSV is empty or contains no data';

  @override
  String get importSuccessTitle => 'Import Successful';

  @override
  String get importPreviewTitle => 'Import Preview';

  @override
  String get importStrategyTitle => 'Import Strategy';

  @override
  String get chooseStrategy => 'Choose how data from the file is imported:';

  @override
  String get mergeStrategy => 'Merge';

  @override
  String get mergeStrategyDesc => 'Keep existing data, update matching entries';

  @override
  String get skipStrategy => 'Add New Only';

  @override
  String get skipStrategyDesc => 'Skip transactions whose ID already exists';

  @override
  String get replaceStrategy => 'Replace All';

  @override
  String get replaceStrategyDesc => 'Remove existing data, replace with file';

  @override
  String get recommended => 'Recommended';

  @override
  String transactionsFound(int count) {
    return '$count transactions found';
  }

  @override
  String budgetsFound(int count) {
    return '$count budgets found';
  }

  @override
  String customCategoriesFound(int count) {
    return '$count custom categories found';
  }

  @override
  String get exampleData => 'Sample data:';

  @override
  String andMore(int count) {
    return '... and $count more';
  }

  @override
  String get backupShareText => 'CatetKeun backup';

  @override
  String backupShareWithCount(int count, String format) {
    return 'CatetKeun backup - $count transactions ($format)';
  }

  @override
  String importSummary(int total, int added, int updated, int skipped) {
    return '$total transactions imported ($added new, $updated updated, $skipped skipped)';
  }

  @override
  String get importReplaceDesc =>
      'All existing data is replaced with data from the file';

  @override
  String get importMergeDesc => 'Data is merged - existing updated, new added';

  @override
  String get importSkipDesc => 'Only new transactions are added';

  @override
  String get catExpFood => 'Food & Drinks';

  @override
  String get catExpTransport => 'Transportation';

  @override
  String get catExpShopping => 'Shopping';

  @override
  String get catExpBills => 'Bills & Utilities';

  @override
  String get catExpEntertainment => 'Entertainment';

  @override
  String get catExpHealth => 'Health';

  @override
  String get catExpEducation => 'Education';

  @override
  String get catExpOther => 'Others';

  @override
  String get catIncSalary => 'Base Salary';

  @override
  String get catIncBonus => 'Bonus & THR';

  @override
  String get catIncInvestment => 'Investment';

  @override
  String get catIncBusiness => 'Business';

  @override
  String get catIncSale => 'Item Sale';

  @override
  String get catIncGift => 'Gifts';

  @override
  String get catIncOther => 'Others';

  @override
  String get languageSetting => 'Language';

  @override
  String get languageNameId => 'Indonesia';

  @override
  String get languageNameEn => 'English';

  @override
  String get sampleSalaryTitle => 'Monthly Salary';

  @override
  String get sampleSalaryNote => 'Office salary transfer';

  @override
  String get sampleShoppingTitle => 'Weekly Groceries';

  @override
  String get sampleShoppingNote => 'Supermarket';

  @override
  String get sampleFuelTitle => 'Fuel & Toll';

  @override
  String get sampleFuelNote => 'Fill up Pertamax';

  @override
  String get sampleLunchTitle => 'Lunch & Coffee';

  @override
  String get sampleLunchNote => 'Cafe near the office';

  @override
  String get sampleSideJobTitle => 'Side Project';

  @override
  String get sampleSideJobNote => 'Freelance UI design';
}
