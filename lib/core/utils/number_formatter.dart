import 'package:intl/intl.dart';

class NumberFormatter {
  static final _currencyFormatter = NumberFormat('#,##0.00', 'en_US');
  static final _percentFormatter = NumberFormat('+#,##0.00;-#,##0.00', 'en_US');
  static final _compactFormatter = NumberFormat('#,##0', 'en_US');

  static String currency(double value) => _currencyFormatter.format(value);
  static String percent(double value) => '${_percentFormatter.format(value)}%';
  static String compact(double value) => _compactFormatter.format(value);
}
