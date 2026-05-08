import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

/// Provedor genérico para TEF via API Local (REST)
/// Compatível com PayGo, Cappta e outros que usem Bridge REST
class TefProvider implements CardPaymentProvider {
  final String host;
  final String port;

  TefProvider({required this.host, required this.port});

  @override
  String get name => "TEF Multiadquirente";

  @override
  Future<PaymentResponse> processPayment(
    double amount, 
    PaymentMode mode, {
    void Function(PaymentResponse)? onStatusUpdate,
  }) async {
    // Endpoint padrão do PayGo Web
    final url = Uri.parse('http://$host:$port/v1/venda');
    
    // Mapeia o modo para o padrão PayGo: 1=Crédito, 2=Débito, 10=PIX
    String pgMode = '1'; 
    if (mode == PaymentMode.debito) pgMode = '2';
    if (mode == PaymentMode.pix) pgMode = '10';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'valor': amount.toStringAsFixed(2), // PayGo Web espera "10.00"
          'vendedor': '1',
          'numeroControle': DateTime.now().millisecondsSinceEpoch.toString(),
          'formaPagamento': pgMode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // O PayGo Web retorna o status no campo 'resultado' (0 = Sucesso)
        if (data['resultado'] == 0 || data['status'] == 'CONFIRMADA') {
          return PaymentResponse(
            success: true,
            transactionId: data['nsu'] ?? data['id'],
            cardBrand: data['bandeira'],
            message: "Aprovado via PayGo",
          );
        } else {
          return PaymentResponse(
            success: false, 
            message: data['mensagem'] ?? "Transação negada pela PayGo",
          );
        }
      } else {
        return PaymentResponse(
          success: false, 
          message: "Erro no PayGo Web (${response.statusCode})",
        );
      }
    } catch (e) {
      return PaymentResponse(
        success: false, 
        message: "Sem conexão com o Client TEF ($host:$port)",
      );
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    final url = Uri.parse('http://$host:$port/tef/v1/cancelamento');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_transacao': transactionId}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
