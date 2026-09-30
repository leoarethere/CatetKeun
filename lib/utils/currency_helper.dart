import 'package:intl/intl.dart';

class CurrencyHelper {
  /// Locale aktif untuk format angka ('id' atau 'en').
  /// Diubah oleh FinanceProvider.setLocale().
  ///
  /// Catatan: simbol mata uang selalu Rp karena aplikasi ini
  /// khusus untuk pencatatan keuangan Rupiah. Locale hanya
  /// memengaruhi pemisah ribuan (id: 1.450.000 / en: 1,450,000).
  static String locale = 'id';

  /// Pemisah ribuan sesuai locale aktif ('.' untuk id, ',' untuk en).
  static String get groupSeparator => locale == 'en' ? ',' : '.';

  static NumberFormat _formatterFor(String locale) {
    final numberLocale = locale == 'en' ? 'en_US' : 'id_ID';
    return NumberFormat.currency(
      locale: numberLocale,
      symbol: 'Rp ',
      decimalDigits: 0,
    );
  }

  static String format(num amount) {
    return _formatterFor(locale).format(amount);
  }

  /// Format angka **tanpa** simbol mata uang, dengan pemisah ribuan
  /// sesuai locale aktif. Dipakai untuk nilai awal field nominal.
  static String formatNumber(int amount) {
    return groupDigits(amount.toString());
  }

  /// Kelompokkan string digit dengan pemisah ribuan sesuai locale aktif.
  ///
  /// Karakter non-digit dibuang dan nol di depan dibuang
  /// ("007" -> "7", sedangkan "0" tetap "0").
  /// String kosong tetap menghasilkan string kosong agar field
  /// nominal bisa benar-benar dikosongkan pengguna.
  static String groupDigits(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(groupSeparator);
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Ambil nilai numerik dari teks bebas ("Rp 1.500.000" -> 1500000).
  /// Return null jika teks tidak berisi angka sama sekali.
  static int? parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }
}
