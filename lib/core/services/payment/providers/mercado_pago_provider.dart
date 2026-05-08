import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

class MercadoPagoProvider implements CardPaymentProvider {
  final String accessToken;
  final String deviceId;
  bool _isCancelled = false;

  MercadoPagoProvider({required this.accessToken, required this.deviceId});

  @override
  String get name => "Mercado Pago Point";

  @override
  Future<PaymentResponse> processPayment(double amount, PaymentMode mode) async {
    _isCancelled = false; // Reseta flag ao iniciar novo pagamento
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
        final String intentId = data['id'];
        
        // Inicia Polling para verificar se o pagamento foi concluído
        return await _pollPaymentStatus(intentId);
      } else {
        return PaymentResponse(success: false, message: "Erro MP: ${response.statusCode}");
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro de conexão: $e");
    }
  }

  Future<PaymentResponse> _pollPaymentStatus(String intentId) async {
    final statusUrl = Uri.parse('https://api.mercadopago.com/point/integration-api/payment-intents/$intentId');
    
    // Tenta por até 90 segundos
    for (int i = 0; i < 45; i++) {
      if (_isCancelled) return PaymentResponse(success: false, message: "Operação cancelada pelo usuário");
      
      try {
        await Future.delayed(const Duration(seconds: 2));
        
        final response = await http.get(
          statusUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];
          
          if (status == 'FINISHED') {
            final payment = data['payment'];
            return PaymentResponse(
              success: true,
              transactionId: payment != null ? payment['id'].toString() : intentId,
              cardBrand: payment != null ? payment['payment_method_id'] : null,
              message: "Pagamento Aprovado!",
            );
          } else if (status == 'ABANDONED' || status == 'CANCELED') {
            return PaymentResponse(success: false, message: "Pagamento cancelado na maquininha");
          }
          // Se for 'OPEN' ou 'ON_TERMINAL', continua aguardando
        }
      } catch (e) {
        // Se der erro de rede no meio, ignora e tenta a próxima
      }
    }
    
    return PaymentResponse(success: false, message: "Tempo esgotado: O pagamento não foi concluído");
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    _isCancelled = true; // Interrompe o polling local
    // Para cancelar um payment intent aberto no MP
    final url = Uri.parse('https://api.mercadopago.com/point/integration-api/payment-intents/$transactionId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
