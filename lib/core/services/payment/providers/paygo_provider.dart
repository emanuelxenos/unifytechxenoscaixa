import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

/// Provedor para integração com PayGo Web (via Client/Bridge Local)
class PayGoProvider implements CardPaymentProvider {
  final String host;
  final String port;
  final String cnpj;
  final String pontoCaptura;

  PayGoProvider({
    required this.host,
    required this.port,
    required this.cnpj,
    required this.pontoCaptura,
  });

  @override
  String get name => "PayGo Web";

  @override
  Future<PaymentResponse> processPayment(
    double amount,
    PaymentMode mode, {
    void Function(PaymentResponse)? onStatusUpdate,
  }) async {
    // No Sandbox da PayGo, valores com centavos são negados.
    // Vamos arredondar ou validar se o usuário for usar sandbox.
    final int valorCentavos = (amount * 100).round();
    
    final url = Uri.parse('http://$host:$port/venda');

    // Mapeia o modo para o padrão PayGo Web
    String meioPagamento = "CREDITO";
    if (mode == PaymentMode.debito) meioPagamento = "DEBITO";
    if (mode == PaymentMode.pix) meioPagamento = "PIX";

    final body = {
      "identificacao": {
        "pontoCaptura": pontoCaptura,
        "cnpj": cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
      },
      "venda": {
        "valorTotal": valorCentavos.toString(),
        "meioPagamento": meioPagamento,
        "tipoOperacao": "VENDA",
        "numeroControle": DateTime.now().millisecondsSinceEpoch.toString(),
      }
    };

    try {
      if (onStatusUpdate != null) {
        onStatusUpdate(PaymentResponse(success: false, message: "Aguardando interação no Pinpad..."));
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // O PayGo Web retorna sucesso se o campo 'resultado' for 0
        if (data['resultado'] == 0 || data['status'] == 'CONFIRMADA') {
          return PaymentResponse(
            success: true,
            transactionId: data['nsu'] ?? data['id_transacao'],
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
          message: "Erro na API PayGo (${response.statusCode})",
        );
      }
    } catch (e) {
      return PaymentResponse(
        success: false,
        message: "Sem conexão com o PayGo Bridge ($host:$port). Verifique se o software está aberto.",
      );
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    final url = Uri.parse('http://$host:$port/cancelamento');
    try {
      final body = {
        "identificacao": {
          "pontoCaptura": pontoCaptura,
          "cnpj": cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
        },
        "cancelamento": {
          "id_transacao": transactionId,
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
