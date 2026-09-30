import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Helper tanggal yang sadar locale.
///
/// [locale] diubah oleh FinanceProvider.setLocale() ('id' / 'en').
/// [todayLabel] & [yesterdayLabel] diisi dari AppLocalizations
/// agar header grup transaksi ("Hari ini" / "Today") ikut berubah.
class DateHelper {
  static String locale = 'id';
  static String todayLabel = 'Hari ini';
  static String yesterdayLabel = 'Kemarin';

  static bool _dateSymbolsReady = false;

  /// Pastikan simbol tanggal (nama bulan/hari) sudah dimuat untuk
  /// semua locale yang didukung. Panggil sekali saat app start.
  static Future<void> ensureInitialized() async {
    if (_dateSymbolsReady) return;
    await initializeDateFormatting('id');
    await initializeDateFormatting('en');
    _dateSymbolsReady = true;
  }

  /// Nama bulan panjang per index (0 = Januari/January).
  static List<String> get monthNames =>
      List<String>.of(DateFormat.EEEE(locale).dateSymbols.MONTHS);

  /// Nama bulan pendek per index (0 = Jan/Jan).
  static List<String> get shortMonthNames =>
      List<String>.of(DateFormat.EEEE(locale).dateSymbols.SHORTMONTHS);

  /// Nama hari per index (0 = Senin/Monday ... 6 = Minggu/Sunday).
  /// CLDR menyimpan Sunday di index 0, jadi kita geser.
  static List<String> get dayNames {
    final List<String> w = DateFormat.EEEE(locale).dateSymbols.WEEKDAYS;
    return <String>[...w.sublist(1), w[0]];
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM y', locale).format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM y', locale).format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM y', locale).format(date);
  }

  static String formatGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return '$todayLabel - ${formatShortDate(date)}';
    } else if (target == yesterday) {
      return '$yesterdayLabel - ${formatShortDate(date)}';
    } else {
      final dayName = DateFormat('EEEE', locale).format(date);
      return '$dayName, ${formatShortDate(date)}';
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
