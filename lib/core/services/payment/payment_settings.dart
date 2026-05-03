enum PaymentProviderType { mock, mercadoPago, stone, pagSeguro, tef }

class PaymentSettings {
  final PaymentProviderType type;
  final Map<String, String> config; // Guarda Token, DeviceID, IP, Porta, etc.

  PaymentSettings({
    required this.type,
    this.config = const {},
  });

  // Getters facilitadores
  String get host => config['host'] ?? 'localhost';
  String get port => config['port'] ?? '8080';
  String get storeId => config['storeId'] ?? '';
  String get terminalId => config['terminalId'] ?? '';

  // Valores padrão
  factory PaymentSettings.defaultConfig() => PaymentSettings(
    type: PaymentProviderType.mock,
    config: {
      'host': 'localhost',
      'port': '8080',
    },
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
