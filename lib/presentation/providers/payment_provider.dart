import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/core/services/payment/card_payment_provider.dart';
import 'package:unifytechxenoscaixa/core/services/payment/providers/mock_payment_provider.dart';
import 'package:unifytechxenoscaixa/core/services/payment/payment_settings.dart';
import 'package:unifytechxenoscaixa/core/services/payment/providers/mercado_pago_provider.dart';
import 'package:unifytechxenoscaixa/core/services/payment/providers/stone_provider.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';

part 'payment_provider.g.dart';

class PaymentState {
  final PaymentStatus status;
  final String? message;
  final PaymentResponse? lastResponse;
  final PaymentSettings settings;

  PaymentState({
    this.status = PaymentStatus.idle,
    this.message,
    this.lastResponse,
    required this.settings,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? message,
    PaymentResponse? lastResponse,
    PaymentSettings? settings,
    bool clearResponse = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastResponse: clearResponse ? null : (lastResponse ?? this.lastResponse),
      settings: settings ?? this.settings,
    );
  }
}

@Riverpod(keepAlive: true)
class PaymentNotifier extends _$PaymentNotifier {
  final _configService = ConfigService();

  @override
  PaymentState build() {
    _loadSettings(); 
    return PaymentState(settings: PaymentSettings.defaultConfig());
  }

  Future<void> _loadSettings() async {
    final saved = await _configService.getPaymentSettings();
    if (saved != null) {
      try {
        final settings = PaymentSettings.fromJson(jsonDecode(saved));
        state = state.copyWith(settings: settings);
      } catch (_) {}
    }
  }

  CardPaymentProvider get _activeProvider {
    final s = state.settings;
    switch (s.type) {
      case PaymentProviderType.mercadoPago:
        return MercadoPagoProvider(
          accessToken: s.config['token'] ?? '',
          deviceId: s.config['deviceId'] ?? '',
        );
      case PaymentProviderType.stone:
        return StoneProvider(
          bridgeIp: s.config['ip'] ?? 'localhost',
        );
      default:
        return MockPaymentProvider();
    }
  }

  Future<void> updateSettings(PaymentSettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _configService.savePaymentSettings(jsonEncode(newSettings.toJson()));
  }

  Future<PaymentResponse> pay(double amount) async {
    state = state.copyWith(status: PaymentStatus.processing, message: 'Aguardando maquininha...');
    
    try {
      final response = await _activeProvider.processPayment(amount);
      
      if (response.success) {
        state = state.copyWith(
          status: PaymentStatus.approved,
          lastResponse: response,
          message: 'Pagamento Aprovado!',
        );
      } else {
        state = state.copyWith(
          status: PaymentStatus.rejected,
          message: response.message ?? 'Pagamento Recusado',
        );
      }
      return response;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        message: 'Erro na comunicação com a maquininha',
      );
      return PaymentResponse(success: false, message: e.toString());
    }
  }

  void reset() {
    state = state.copyWith(status: PaymentStatus.idle, clearResponse: true, message: null);
  }
}
