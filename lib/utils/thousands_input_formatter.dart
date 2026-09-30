import 'package:flutter/services.dart';

import 'currency_helper.dart';

/// Input formatter untuk field nominal.
///
/// Hanya menerima digit, lalu langsung menampilkan pemisah ribuan
/// sesuai locale aktif (id: 1.500.000 / en: 1,500,000).
/// Posisi kursor dipertahankan berdasarkan jumlah digit di depannya
/// sehingga mengetik/menghapus di tengah angka tetap nyaman.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final formatted = CurrencyHelper.groupDigits(text);

    final int baseOffset = newValue.selection.isValid
        ? newValue.selection.baseOffset.clamp(0, text.length)
        : text.length;
    final digitsBeforeCursor = text
        .substring(0, baseOffset)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetForDigitCount(formatted, digitsBeforeCursor),
      ),
    );
  }

  /// Posisi kursor setelah [digitCount] digit pertama pada [formatted].
  int _offsetForDigitCount(String formatted, int digitCount) {
    if (digitCount <= 0) return 0;
    int seen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted[i])) {
        seen++;
        if (seen == digitCount) return i + 1;
      }
    }
    return formatted.length;
  }

  bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }
}
