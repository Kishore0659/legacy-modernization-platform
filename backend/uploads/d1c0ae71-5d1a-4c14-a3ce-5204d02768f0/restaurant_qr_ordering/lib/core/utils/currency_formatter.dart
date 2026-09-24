import 'package:intl/intl.dart';

/// Central currency formatting (adjust locale/symbol as needed).
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _fmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  static String format(double amount) => _fmt.format(amount);
}
