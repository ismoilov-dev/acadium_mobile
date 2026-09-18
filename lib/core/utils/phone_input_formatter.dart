import 'package:flutter/services.dart';

/// Telefon raqamni "90 123 45 67" ko'rinishida formatlaydi.
/// "+998" prefiksi maydonning `prefixText` qismida ko'rsatiladi.
class PhoneInputFormatter extends TextInputFormatter {
  static const int maxDigits = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits =
        newValue.text.replaceAll(RegExp(r'\D'), '').limitedToMaxDigits;

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

extension on String {
  /// Faqat birinchi 9 ta raqamni qoldiradi.
  String get limitedToMaxDigits => length <= PhoneInputFormatter.maxDigits
      ? this
      : substring(0, PhoneInputFormatter.maxDigits);
}
