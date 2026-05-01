import '../card_payment_provider.dart';

/// Provedor de teste para desenvolvimento
class MockPaymentProvider implements CardPaymentProvider {
  @override
  String get name => "Simulador de Teste";

  @override
  Future<PaymentResponse> processPayment(double amount) async {
    // Simula o tempo de processamento da maquininha
    await Future.delayed(const Duration(seconds: 3));
    
    // Simula uma aprovação de 90% das vezes
    final isApproved = amount > 0; 

    if (isApproved) {
      return PaymentResponse(
        success: true,
        transactionId: "MOCK-${DateTime.now().millisecondsSinceEpoch}",
        message: "PAGAMENTO APROVADO",
        cardBrand: "MASTERCARD",
        lastDigits: "4455",
      );
    } else {
      return PaymentResponse(
        success: false,
        message: "CARTÃO RECUSADO",
      );
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    return true;
  }
}
