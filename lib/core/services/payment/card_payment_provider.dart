enum PaymentStatus { idle, processing, approved, rejected, error }

enum PaymentMode { credito, debito, pix, voucher }

abstract class CardPaymentProvider {
  String get name;
  
  /// Inicia o processo de pagamento
  Future<PaymentResponse> processPayment(double amount, PaymentMode mode);
  
  /// Cancela uma transação específica
  Future<bool> cancelTransaction(String transactionId);
}

class PaymentResponse {
  final bool success;
  final String? transactionId;
  final String? message;
  final String? cardBrand;
  final String? lastDigits;

  PaymentResponse({
    required this.success,
    this.transactionId,
    this.message,
    this.cardBrand,
    this.lastDigits,
  });
}
