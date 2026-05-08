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
    _isCancelled = false; 

    if (deviceId == null || accessToken == null) {
      return PaymentResponse(success: false, message: "Configuração do Mercado Pago incompleta");
    }

    final int amountInCents = (amount * 100).round();
    
    // 1. Preparação dinâmica do dispositivo
    try {
      final devicesUrl = Uri.parse('https://api.mercadopago.com/point/integration-api/devices');
      final response = await http.get(devicesUrl, headers: {'Authorization': 'Bearer $accessToken'});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final devices = data['devices'] as List;
        
        for (var dev in devices) {
          final devId = dev['id'];
          final posId = dev['pos_id']?.toString();
          
          // Garante modo PDV
          await http.patch(
            Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$devId'),
            headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
            body: jsonEncode({'operating_mode': 'PDV'}),
          );

          // Limpeza preventiva de fila
          await http.delete(Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$devId/payment-intents'), headers: {'Authorization': 'Bearer $accessToken'});
          if (posId != null) {
            await http.delete(Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$posId/payment-intents'), headers: {'Authorization': 'Bearer $accessToken'});
          }
        }
      }
    } catch (_) {}

    // 2. Criação da intenção mapeando o tipo de cartão
    final url = Uri.parse('https://api.mercadopago.com/point/integration-api/devices/${deviceId.trim()}/payment-intents');
    final idempotencyKey = DateTime.now().millisecondsSinceEpoch.toString();

    // Mapeamento para pular o menu da maquininha
    String mpPaymentMode = 'card';
    if (mode == PaymentMode.pix) {
      mpPaymentMode = 'qr-pix';
    }

    final Map<String, dynamic> body = {
      'amount': amountInCents,
      'description': 'Venda PDV Xenos',
      'payment_mode': mpPaymentMode,
    };

    // Estrutura correta conforme documentação oficial para pular o menu
    if (mode == PaymentMode.credito || mode == PaymentMode.debito || mode == PaymentMode.voucher) {
      String type = 'credit_card';
      if (mode == PaymentMode.debito) type = 'debit_card';
      if (mode == PaymentMode.voucher) type = 'voucher_card';

      body['payment'] = {
        'type': type,
        'installments': 1,
        'installments_cost': 'seller', // O vendedor assume o custo da parcela (padrão)
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'X-Idempotency-Key': idempotencyKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Pagamento solicitado: ${data['id']}');
        return await _pollPaymentStatus(data['id']);
      } else {
        final errorBody = jsonDecode(response.body);
        return PaymentResponse(success: false, message: "Erro MP: ${errorBody['message'] ?? 'Falha na criação'}");
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro de conexão: $e");
    }
  }

  Future<PaymentResponse> _pollPaymentStatus(String intentId) async {
    final url = Uri.parse('https://api.mercadopago.com/point/integration-api/payment-intents/$intentId');
    
    for (int i = 0; i < 60; i++) {
      if (_isCancelled) return PaymentResponse(success: false, message: "Operação cancelada pelo usuário");
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        final response = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final state = data['state'];
          print('⏳ Estado da Maquininha: $state');
          
          if (state == 'FINISHED') {
            final payment = data['payment'];
            return PaymentResponse(
              success: true,
              transactionId: payment != null ? payment['id'].toString() : intentId,
              cardBrand: payment != null ? payment['payment_method_id'] : null,
              message: "Pagamento Aprovado!",
            );
          } else if (state == 'ABANDONED' || state == 'CANCELED') {
            return PaymentResponse(success: false, message: "Pagamento cancelado na maquininha");
          }
        }
      } catch (e) {
        print('⚠️ Erro no polling: $e');
      }
    }
    
    return PaymentResponse(success: false, message: "Tempo esgotado aguardando pagamento");
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    _isCancelled = true; 
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
