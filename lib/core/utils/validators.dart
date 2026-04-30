class Validators {
  Validators._();

  /// Valida se um campo obrigatório não está vazio
  static String? required(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  /// Valida PIN de 4 dígitos
  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN é obrigatório';
    }
    if (value.length != 4 || int.tryParse(value) == null) {
      return 'PIN deve ter 4 dígitos';
    }
    return null;
  }

  /// Valida valor monetário (> 0)
  static String? money(String? value, [String fieldName = 'Valor']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    return null;
  }

  /// Valida quantidade (> 0)
  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantidade é obrigatória';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Quantidade deve ser maior que zero';
    }
    return null;
  }

  /// Valida host (IP ou hostname)
  static String? host(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host é obrigatório';
    }
    return null;
  }

  /// Valida porta
  static String? port(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Porta é obrigatória';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1 || parsed > 65535) {
      return 'Porta deve ser entre 1 e 65535';
    }
    return null;
  }
}
