import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

/// Provedor para Sitef (Software Express) via Bridge REST
/// Altamente compatível com Pinpads USB de todas as marcas.
class SitefProvider implements CardPaymentProvider {
  final String host;
  final String port;
  final String empresa;
  final String terminal;

  SitefProvider({
    required this.host, 
    required this.port,
    required this.empresa,
    required this.terminal,
  });

  @override
  String get name => "SiTef (Software Express)";

  @override
  Future<PaymentResponse> processPayment(double amount, PaymentMode mode) async {
    // Porta padrão do SiTef REST costuma ser 8080 ou 8888
    final url = Uri.parse('http://$host:$port/v1/pagamento');
    
    // Mapeia a modalidade para o padrão SiTef: 1=Cartão, 2=Débito, 3=Crédito, 122=PIX
    int modalidade = 1; 
    if (mode == PaymentMode.debito) modalidade = 2;
    if (mode == PaymentMode.credito) modalidade = 3;
    if (mode == PaymentMode.pix) modalidade = 122;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'valor': (amount * 100).toInt().toString(), // SiTef costuma esperar centavos em string
          'modalidade': modalidade,
          'cnpj_empresa': empresa,
          'terminal': terminal,
          'transacao': DateTime.now().millisecondsSinceEpoch.toString().substring(5),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // O status 0 ou "APROVADO" indica sucesso no SiTef
        if (data['status'] == 0 || data['codigo_resposta'] == "00") {
          return PaymentResponse(
            success: true,
            transactionId: data['nsu_sitef'] ?? data['nsu_host'],
            cardBrand: data['bandeira'],
            message: "Aprovado via SiTef",
          );
        } else {
          return PaymentResponse(
            success: false, 
            message: data['mensagem_terminal'] ?? "Transação Recusada",
          );
        }
      } else {
        return PaymentResponse(
          success: false, 
          message: "Erro no Servidor SiTef (${response.statusCode})",
        );
      }
    } catch (e) {
      return PaymentResponse(
        success: false, 
        message: "Sem conexão com SiTef REST ($host:$port)",
      );
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    final url = Uri.parse('http://$host:$port/v1/cancelamento');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nsu_sitef': transactionId,
          'cnpj_empresa': empresa,
          'terminal': terminal,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
