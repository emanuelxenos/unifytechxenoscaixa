import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

class StoneProvider implements CardPaymentProvider {
  final String bridgeIp; // Geralmente localhost ou IP da rede

  StoneProvider({required this.bridgeIp});

  @override
  String get name => "Stone POS Bridge";

  @override
  Future<PaymentResponse> processPayment(double amount, PaymentMode mode) async {
    final url = Uri.parse('http://$bridgeIp:8080/transacao'); // Porta padrão do Bridge
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'valor': (amount * 100).toInt(),
          'metodo': mode.name, // 'debito', 'credito' ou 'pix'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentResponse(
          success: true,
          transactionId: data['nsu'],
          cardBrand: data['bandeira'],
          message: "Aprovado via Stone",
        );
      } else {
        return PaymentResponse(success: false, message: "Erro Stone Bridge");
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Sem comunicação com Stone Bridge");
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    return false;
  }
}
