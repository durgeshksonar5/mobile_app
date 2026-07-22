import 'package:intl/intl.dart';

/// Integer-based money representation and formatting (avoiding floating point arithmetic errors).
class MoneyFormatter {
  /// Converts rupee string/num into integer minor units (paise: ₹1 = 100 paise)
  static int toPaise(dynamic amount) {
    if (amount == null) return 0;
    if (amount is int) return amount * 100;
    if (amount is double) return (amount * 100).round();
    if (amount is String) {
      final parsed = double.tryParse(amount.trim());
      if (parsed != null) return (parsed * 100).round();
    }
    return 0;
  }

  /// Formats paise integer as Rupee string e.g., 10000 -> ₹100.00
  static String formatPaiseToRupee(int paise,
      {bool includeSymbol = true, bool showDecimals = true}) {
    final double rupees = paise / 100.0;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: includeSymbol ? '₹' : '',
      decimalDigits: showDecimals ? 2 : 0,
    );
    return formatter.format(rupees).trim();
  }

  /// Direct formatting from integer rupees e.g., 100 -> ₹100
  static String formatRupees(int rupees, {bool includeSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: includeSymbol ? '₹' : '',
      decimalDigits: 0,
    );
    return formatter.format(rupees).trim();
  }
}
