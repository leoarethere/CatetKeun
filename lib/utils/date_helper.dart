import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Helper tanggal yang sadar locale.
///
/// [locale] diubah oleh FinanceProvider.setLocale() ('id' / 'en').
/// [todayLabel] & [yesterdayLabel] diisi dari AppLocalizations
/// agar header grup transaksi ("Hari ini" / "Today") ikut berubah.
///
/// Catatan performa: pembuatan [DateFormat] itu mahal (parsing pola +
/// data ICU). Semua formatter di-cache per locale agar scroll daftar
/// transaksi tetap smooth (sebelumnya setiap tile membuat DateFormat baru).
class DateHelper {
  static String _locale = 'id';
  static String todayLabel = 'Hari ini';
  static String yesterdayLabel = 'Kemarin';

  static String get locale => _locale;

  static set locale(String value) {
    if (_locale != value) {
      _locale = value;
      _invalidateCache();
    }
  }

  static bool _dateSymbolsReady = false;

  /// Cache formatter per locale.
  static DateFormat? _fullDateFormat;
  static DateFormat? _shortDateFormat;
  static DateFormat? _monthYearFormat;
  static DateFormat? _dayNameFormat;
  static String? _formatLocale;
  static List<String>? _cachedMonthNames;
  static List<String>? _cachedShortMonthNames;
  static List<String>? _cachedDayNames;

  static void _ensureCache() {
    if (_formatLocale != _locale) {
      _invalidateCache();
      _formatLocale = _locale;
    }
    _fullDateFormat ??= DateFormat('EEEE, d MMMM y', _locale);
    _shortDateFormat ??= DateFormat('d MMM y', _locale);
    _monthYearFormat ??= DateFormat('MMMM y', _locale);
    _dayNameFormat ??= DateFormat('EEEE', _locale);
  }

  static void _invalidateCache() {
    _fullDateFormat = null;
    _shortDateFormat = null;
    _monthYearFormat = null;
    _dayNameFormat = null;
    _cachedMonthNames = null;
    _cachedShortMonthNames = null;
    _cachedDayNames = null;
  }

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
      _cachedMonthNames ??= List<String>.unmodifiable(
        DateFormat.EEEE(_locale).dateSymbols.MONTHS,
      );

  /// Nama bulan pendek per index (0 = Jan/Jan).
  static List<String> get shortMonthNames =>
      _cachedShortMonthNames ??= List<String>.unmodifiable(
        DateFormat.EEEE(_locale).dateSymbols.SHORTMONTHS,
      );

  /// Nama hari per index (0 = Senin/Monday ... 6 = Minggu/Sunday).
  /// CLDR menyimpan Sunday di index 0, jadi kita geser.
  static List<String> get dayNames {
    if (_cachedDayNames != null) return _cachedDayNames!;
    final List<String> w = DateFormat.EEEE(_locale).dateSymbols.WEEKDAYS;
    _cachedDayNames = List<String>.unmodifiable([...w.sublist(1), w[0]]);
    return _cachedDayNames!;
  }

  static String formatFullDate(DateTime date) {
    _ensureCache();
    return _fullDateFormat!.format(date);
  }

  static String formatShortDate(DateTime date) {
    _ensureCache();
    return _shortDateFormat!.format(date);
  }

  static String formatMonthYear(DateTime date) {
    _ensureCache();
    return _monthYearFormat!.format(date);
  }

  /// Format header grup untuk [date], memakai referensi [now] yang
  /// disuntikkan agar pemanggil (mis. builder list) bisa memakai satu
  /// nilai now untuk seluruh list, bukan DateTime.now() per item.
  static String formatGroupHeader(DateTime date, {DateTime? now}) {
    _ensureCache();
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return '$todayLabel - ${_shortDateFormat!.format(date)}';
    } else if (target == yesterday) {
      return '$yesterdayLabel - ${_shortDateFormat!.format(date)}';
    } else {
      final dayName = _dayNameFormat!.format(date);
      return '$dayName, ${_shortDateFormat!.format(date)}';
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
