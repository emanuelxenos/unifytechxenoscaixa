enum PaymentStatus { idle, processing, approved, rejected, error }

enum PaymentMode { credito, debito, pix, voucher }

abstract class CardPaymentProvider {
  String get name;
  
  /// Inicia o processo de pagamento com callback para atualizações parciais (ex: QR Code)
  Future<PaymentResponse> processPayment(
    double amount, 
    PaymentMode mode, {
    void Function(PaymentResponse)? onStatusUpdate,
  });
  
  /// Cancela uma transação específica
  Future<bool> cancelTransaction(String transactionId);
}

class PaymentResponse {
  final bool success;
  final String? transactionId;
  final String? message;
  final String? cardBrand;
  final String? lastDigits;
  final String? qrCode; // Código PIX Copia e Cola
  final String? qrCodeBase64; // Imagem do QR Code em Base64

  PaymentResponse({
    required this.success,
    this.transactionId,
    this.message,
    this.cardBrand,
    this.lastDigits,
    this.qrCode,
    this.qrCodeBase64,
  });
}
