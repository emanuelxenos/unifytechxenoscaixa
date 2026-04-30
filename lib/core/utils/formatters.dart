import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _quantityFormat = NumberFormat('#,##0.###', 'pt_BR');
  static final _percentFormat = NumberFormat('#,##0.00', 'pt_BR');

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateTimeFullFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  /// Formata valor monetário: R$ 1.234,56
  static String currency(dynamic value) {
    if (value == null) return 'R\$ 0,00';
    final doubleValue = value is int ? value.toDouble() : (value as double);
    return _currencyFormat.format(doubleValue);
  }

  /// Formata quantidade: 1.234,5
  static String quantity(dynamic value) {
    if (value == null) return '0';
    final doubleValue = value is int ? value.toDouble() : (value as double);
    return _quantityFormat.format(doubleValue);
  }

  /// Formata percentual: 12,50%
  static String percent(dynamic value) {
    if (value == null) return '0,00%';
    final doubleValue = value is int ? value.toDouble() : (value as double);
    return '${_percentFormat.format(doubleValue)}%';
  }

  /// Formata data: 30/04/2026
  static String date(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date);
  }

  /// Formata hora: 14:30:00
  static String time(DateTime? date) {
    if (date == null) return '-';
    return _timeFormat.format(date);
  }

  /// Formata data e hora: 30/04/2026 14:30
  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    return _dateTimeFormat.format(date);
  }

  /// Formata data e hora completa: 30/04/2026 14:30:00
  static String dateTimeFull(DateTime? date) {
    if (date == null) return '-';
    return _dateTimeFullFormat.format(date);
  }

  /// Formata apenas o valor numérico: 1234.56 → "1.234,56"
  static String number(dynamic value) {
    if (value == null) return '0,00';
    final doubleValue = value is int ? value.toDouble() : (value as double);
    return _percentFormat.format(doubleValue);
  }
}
