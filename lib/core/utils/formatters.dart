import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static final _quantityFormat = NumberFormat('#,##0.###', 'pt_BR');
  static final _percentFormat = NumberFormat('#,##0.00', 'pt_BR');

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateTimeFullFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  static double _toDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Formata valor monetário: R$ 1.234,56
  static String currency(dynamic value) {
    try {
      return _currencyFormat.format(_toDouble(value));
    } catch (_) {
      return r'R$ 0,00';
    }
  }

  /// Formata quantidade: 1.234,5
  static String quantity(dynamic value) {
    try {
      return _quantityFormat.format(_toDouble(value));
    } catch (_) {
      return '0';
    }
  }

  /// Formata percentual: 12,50%
  static String percent(dynamic value) {
    try {
      return '${_percentFormat.format(_toDouble(value))}%';
    } catch (_) {
      return '0,00%';
    }
  }

  /// Formata data: 30/04/2026
  static String date(DateTime? date) {
    try {
      if (date == null) return '-';
      return _dateFormat.format(date);
    } catch (_) {
      return '-';
    }
  }

  /// Formata hora: 14:30:00
  static String time(DateTime? date) {
    try {
      if (date == null) return '-';
      return _timeFormat.format(date);
    } catch (_) {
      return '-';
    }
  }

  /// Formata data e hora: 30/04/2026 14:30
  static String dateTime(DateTime? date) {
    try {
      if (date == null) return '-';
      return _dateTimeFormat.format(date);
    } catch (_) {
      return '-';
    }
  }

  /// Formata data e hora completa: 30/04/2026 14:30:00
  static String dateTimeFull(DateTime? date) {
    try {
      if (date == null) return '-';
      return _dateTimeFullFormat.format(date);
    } catch (_) {
      return '-';
    }
  }

  /// Formata apenas o valor numérico: 1234.56 → "1.234,56"
  static String number(dynamic value) {
    try {
      return _percentFormat.format(_toDouble(value));
    } catch (_) {
      return '0,00';
    }
  }
}
