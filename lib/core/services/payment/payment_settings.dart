enum PaymentProviderType { mock, mercadoPago, stone, pagSeguro }

class PaymentSettings {
  final PaymentProviderType type;
  final Map<String, String> config; // Guarda Token, DeviceID, IP, etc.

  PaymentSettings({
    required this.type,
    this.config = const {},
  });

  // Valores padrão
  factory PaymentSettings.defaultConfig() => PaymentSettings(
    type: PaymentProviderType.mock,
    config: {},
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'config': config,
  };

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      type: PaymentProviderType.values.firstWhere((e) => e.name == json['type'], orElse: () => PaymentProviderType.mock),
      config: Map<String, String>.from(json['config'] ?? {}),
    );
  }
}
