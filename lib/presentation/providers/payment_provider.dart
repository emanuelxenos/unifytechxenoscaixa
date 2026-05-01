import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/core/services/payment/card_payment_provider.dart';
import 'package:unifytechxenoscaixa/core/services/payment/providers/mock_payment_provider.dart';

part 'payment_provider.g.dart';

class PaymentState {
  final PaymentStatus status;
  final String? message;
  final PaymentResponse? lastResponse;

  PaymentState({
    this.status = PaymentStatus.idle,
    this.message,
    this.lastResponse,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? message,
    PaymentResponse? lastResponse,
    bool clearResponse = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastResponse: clearResponse ? null : (lastResponse ?? this.lastResponse),
    );
  }
}

@Riverpod(keepAlive: true)
class PaymentNotifier extends _$PaymentNotifier {
  // Por enquanto fixo no Mock, mas no futuro virá das configurações
  CardPaymentProvider _activeProvider = MockPaymentProvider();

  @override
  PaymentState build() {
    return PaymentState();
  }

  void setProvider(CardPaymentProvider provider) {
    _activeProvider = provider;
  }

  Future<PaymentResponse> pay(double amount) async {
    state = state.copyWith(status: PaymentStatus.processing, message: "Aguardando maquininha...");
    
    try {
      final response = await _activeProvider.processPayment(amount);
      
      if (response.success) {
        state = state.copyWith(
          status: PaymentStatus.approved,
          message: response.message,
          lastResponse: response,
        );
      } else {
        state = state.copyWith(
          status: PaymentStatus.rejected,
          message: response.message,
        );
      }
      return response;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        message: "Erro na comunicação com a maquininha",
      );
      return PaymentResponse(success: false, message: e.toString());
    }
  }

  void reset() {
    state = PaymentState();
  }
}
