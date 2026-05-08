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
  Future<PaymentResponse> processPayment(
    double amount, 
    PaymentMode mode, {
    void Function(PaymentResponse)? onStatusUpdate,
  }) async {
    _isCancelled = false; 

    if (deviceId == null || accessToken == null) {
      return PaymentResponse(success: false, message: "Configuração do Mercado Pago incompleta");
    }

    final int amountInCents = (amount * 100).round();
    
    // 1. Busca o pos_id e garante modo PDV
    final String originalDeviceId = deviceId.trim();
    String targetIdForConfig = originalDeviceId;
    
    try {
      final devicesUrl = Uri.parse('https://api.mercadopago.com/point/integration-api/devices');
      final response = await http.get(devicesUrl, headers: {'Authorization': 'Bearer $accessToken'});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final devices = data['devices'] as List;
        
        for (var dev in devices) {
          if (dev['id'] == originalDeviceId || dev['pos_id']?.toString() == originalDeviceId) {
            final posId = dev['pos_id']?.toString();
            if (posId != null) {
              targetIdForConfig = posId;
              print('🎯 POS_ID identificado para configuração: $targetIdForConfig');
            }
            break;
          }
        }
      }

      // Força modo PDV usando o ID de configuração
      await http.patch(
        Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$targetIdForConfig'),
        headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
        body: jsonEncode({'operating_mode': 'PDV'}),
      ).timeout(const Duration(seconds: 2));

      // Dá um tempo para a maquininha processar a mudança de modo antes de receber a venda
      await Future.delayed(const Duration(milliseconds: 800));

      // Limpeza preventiva no ID original (físico)
      await http.delete(
        Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$originalDeviceId/payment-intents'), 
        headers: {'Authorization': 'Bearer $accessToken'}
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      print('⚠️ Falha na preparação: $e');
    }

    // 2. Fluxo Especial para Pix Direto (BACEN Universal + Sem Menu)
    if (mode == PaymentMode.pix) {
      return await _processDirectPix(
        amountInCents, 
        posId: targetIdForConfig,
        onStatusUpdate: onStatusUpdate
      );
    }

    // 3. Fluxo Normal para Cartões (via Point)
    final url = Uri.parse('https://api.mercadopago.com/point/integration-api/devices/$originalDeviceId/payment-intents');
    final idempotencyKey = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> body = {
      'amount': amountInCents,
      'description': 'PDV Xenos',
      'payment_mode': 'card',
      'additional_info': {
        'external_reference': 'X$idempotencyKey',
      }
    };

    // Estrutura para pular o menu (apenas para cartões)
    String type = 'credit_card';
    if (mode == PaymentMode.debito) type = 'debit_card';
    if (mode == PaymentMode.voucher) type = 'voucher_card';

    body['payment'] = {
      'type': type,
      'installments': 1,
      'installments_cost': 'seller',
    };

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
        return await _pollPaymentStatus(data['id'], mode: mode);
      } else {
        print('❌ Erro na API do Mercado Pago (Point): ${response.statusCode} - ${response.body}');
        final errorBody = jsonDecode(response.body);
        return PaymentResponse(success: false, message: "Erro MP: ${errorBody['message'] ?? 'Falha na criação'}");
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro de conexão: $e");
    }
  }

  Future<PaymentResponse> _processDirectPix(int amountInCents, {String? posId, Function(PaymentResponse)? onStatusUpdate}) async {
    final url = Uri.parse('https://api.mercadopago.com/v1/payments');
    final idempotencyKey = 'PIX_${DateTime.now().millisecondsSinceEpoch}';

    // Tenta simplificar ao máximo para evitar erros de parâmetros
    // O erro "Collector user without key" só resolve cadastrando chave no app do MP
    final body = {
      'transaction_amount': amountInCents / 100.0,
      'description': 'PDV Xenos (Pix BACEN)',
      'payment_method_id': 'pix',
      'payer': {
        'email': 'cliente.pdv@xenos.com',
      },
    };

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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final point = data['point_of_interaction']['transaction_data'];
        
        final String qrCode = point['qr_code'];
        final String qrCodeBase64 = point['qr_code_base64'];

        if (onStatusUpdate != null) {
          onStatusUpdate(PaymentResponse(
            success: false,
            message: "QR Code PIX BACEN Gerado!",
            qrCode: qrCode,
            qrCodeBase64: qrCodeBase64,
          ));
        }

        return await _pollDirectPaymentStatus(data['id'].toString());
      } else {
        final errorBody = jsonDecode(response.body);
        return PaymentResponse(success: false, message: "Erro Pix: ${errorBody['message'] ?? 'Falha'}");
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro Conexão Pix: $e");
    }
  }

  Future<PaymentResponse> _pollDirectPaymentStatus(String paymentId) async {
    final url = Uri.parse('https://api.mercadopago.com/v1/payments/$paymentId');
    
    for (int i = 0; i < 180; i++) {
      if (_isCancelled) break;
      
      try {
        final response = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];

          if (status == 'approved') {
            return PaymentResponse(success: true, message: "Pagamento Pix aprovado!");
          } else if (status == 'rejected' || status == 'cancelled') {
            return PaymentResponse(success: false, message: "Pagamento Pix $status");
          }
        }
      } catch (_) {}
      
      await Future.delayed(const Duration(seconds: 1));
    }
    
    return PaymentResponse(success: false, message: "Tempo limite do Pix excedido");
  }

  Future<PaymentResponse> _pollPaymentStatus(String intentId, {required PaymentMode mode, String? qrCode, String? qrCodeBase64}) async {
    final url = Uri.parse('https://api.mercadopago.com/point/integration-api/payment-intents/$intentId');
    
    for (int i = 0; i < 90; i++) { // Aumentado para 90 segundos total
      if (_isCancelled) return PaymentResponse(success: false, message: "Operação cancelada pelo usuário");
      
      await Future.delayed(const Duration(seconds: 1)); // Polling a cada 1s para maior agilidade
      
      try {
        final response = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final state = data['state'];
          print('⏳ Estado da Maquininha: $state');
          
          if (state == 'OPEN' && mode == PaymentMode.pix && i == 0) {
            // Na primeira iteração, se estiver OPEN e for PIX, podemos emitir um "evento" para a UI (se suportado)
            // Mas aqui o polling é bloqueante. O ideal é o provider notificar o Notifier.
          }

          if (state == 'FINISHED') {
            final payment = data['payment'];
            return PaymentResponse(
              success: true,
              transactionId: payment != null ? payment['id'].toString() : intentId,
              cardBrand: payment != null ? payment['payment_method_id'] : null,
              message: "Pagamento Aprovado!",
              qrCode: qrCode,
              qrCodeBase64: qrCodeBase64,
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
