import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

class MercadoPagoProvider implements CardPaymentProvider {
  final String accessToken;
  final String deviceId;

  MercadoPagoProvider({required this.accessToken, required this.deviceId});

  @override
  String get name => "Mercado Pago Point";

  @override
  Future<PaymentResponse> processPayment(double amount, PaymentMode mode) async {
    final url = Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$deviceId/payment-intents');
    
    // Mapeia o modo para o que o Mercado Pago espera
    String mpMode = 'credit_card';
    if (mode == PaymentMode.debito) mpMode = 'debit_card';
    if (mode == PaymentMode.pix) mpMode = 'pix';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': (amount * 100).toInt(),
          'description': 'Venda UnifyTech Xenos',
          'payment_mode': 'local_res',
          'payment_method_id': mpMode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentResponse(
          success: true,
          transactionId: data['id'],
          message: "Aguardando cartão na maquininha...",
        );
      } else {
        return PaymentResponse(success: false, message: "Erro MP: ${response.statusCode}");
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro de conexão: $e");
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    // Lógica de cancelamento via API do MP
    return false;
  }
}
