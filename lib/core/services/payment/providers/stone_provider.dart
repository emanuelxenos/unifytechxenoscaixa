import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

class StoneProvider implements CardPaymentProvider {
  final String apiKey;
  final String terminalId;

  StoneProvider({required this.apiKey, required this.terminalId});

  @override
  String get name => "Stone Connect (Direto)";

  @override
  Future<PaymentResponse> processPayment(
    double amount, 
    PaymentMode mode, {
    void Function(PaymentResponse)? onStatusUpdate,
  }) async {
    const url = 'https://api.pagar.me/core/v5/orders';
    
    // Converte para centavos
    final int amountInCents = (amount * 100).toInt();
    
    // Mapeia o método de pagamento
    String method = "credit_card";
    if (mode == PaymentMode.debito) method = "debit_card";
    if (mode == PaymentMode.pix) method = "pix";

    try {
      final auth = base64Encode(utf8.encode('$apiKey:'));
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $auth',
        },
        body: jsonEncode({
          "items": [
            {
              "amount": amountInCents,
              "description": "Venda ERP UnifyTechXenos",
              "quantity": 1
            }
          ],
          "payments": [
            {
              "payment_method": method,
              "poi_payment_settings": {
                "terminal_id": terminalId
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentResponse(
          success: true,
          transactionId: data['id'],
          message: "Ordem enviada para maquininha!",
        );
      } else {
        final error = jsonDecode(response.body);
        return PaymentResponse(
          success: false, 
          message: "Erro Stone: ${error['message'] ?? 'Falha na transação'}"
        );
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro de conexão: $e");
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    return false;
  }
}
