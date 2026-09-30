import 'package:flutter/widgets.dart';

import '../models/category.dart';
import 'generated/app_localizations.dart';

/// Terjemahkan pesan error operasi kategori menjadi teks sesuai bahasa.
String categoryErrorMessage(AppLocalizations l10n, Object error) {
  if (error is CategoryException) {
    switch (error.error) {
      case CategoryError.defaultCategoryCannotDelete:
        return l10n.categoryDefaultCannotDelete;
      case CategoryError.defaultCategoryCannotEdit:
        return l10n.categoryDefaultCannotEdit;
      case CategoryError.inUse:
        return l10n.categoryStillUsed(error.usageCount);
      case CategoryError.notFound:
        return l10n.categoryNotFound;
    }
  }
  return l10n.actionFailed(error.toString());
}

/// Terjemahkan error hapus kategori (termasuk pesan bebas dari provider).
String categoryDeleteErrorMessage(AppLocalizations l10n, Object error) {
  if (error is CategoryException) {
    switch (error.error) {
      case CategoryError.defaultCategoryCannotDelete:
        return l10n.categoryDefaultCannotDelete;
      case CategoryError.inUse:
        return l10n.categoryStillUsed(error.usageCount);
      case CategoryError.notFound:
        return l10n.categoryNotFound;
      case CategoryError.defaultCategoryCannotEdit:
        return l10n.categoryDefaultCannotEdit;
    }
  }
  return l10n.deleteCategoryFailed(error.toString());
}

/// Extension untuk menampilkan nama kategori sesuai bahasa aktif.
///
/// Kategori bawaan (default) diterjemahkan lewat ARB. Kategori custom
/// buatan pengguna ditampilkan apa adanya.
extension CategoryL10n on TransactionCategory {
  String localized(BuildContext context) {
    if (isCustom) return name;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return name;

    switch (id) {
      case 'exp_food':
        return l10n.catExpFood;
      case 'exp_transport':
        return l10n.catExpTransport;
      case 'exp_shopping':
        return l10n.catExpShopping;
      case 'exp_bills':
        return l10n.catExpBills;
      case 'exp_entertainment':
        return l10n.catExpEntertainment;
      case 'exp_health':
        return l10n.catExpHealth;
      case 'exp_education':
        return l10n.catExpEducation;
      case 'exp_other':
        return l10n.catExpOther;
      case 'inc_salary':
        return l10n.catIncSalary;
      case 'inc_bonus':
        return l10n.catIncBonus;
      case 'inc_investment':
        return l10n.catIncInvestment;
      case 'inc_business':
        return l10n.catIncBusiness;
      case 'inc_sale':
        return l10n.catIncSale;
      case 'inc_gift':
        return l10n.catIncGift;
      case 'inc_other':
        return l10n.catIncOther;
      default:
        return name;
    }
  }
}
