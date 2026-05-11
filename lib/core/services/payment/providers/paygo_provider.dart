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
    final int valorCentavos = (amount * 100).round();
    
    // Tentando o padrão /v1/venda
    final url = Uri.parse('http://$host:$port/v1/venda');

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

    return _sendRequest(url, body, onStatusUpdate: onStatusUpdate);
  }

  /// Tenta uma conexão básica com o Bridge
  Future<bool> testConnection() async {
    // Testamos os dois caminhos mais comuns
    final paths = ['/v1/venda', '/venda'];
    
    for (var path in paths) {
      try {
        final url = Uri.parse('http://$host:$port$path');
        final response = await http.get(url).timeout(const Duration(seconds: 2));
        // Se retornar 200, 401 ou 405, o caminho existe. Se for 404, não existe.
        if (response.statusCode != 404 && response.statusCode != 0) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  /// Abre o menu administrativo do PayGo
  Future<PaymentResponse> openAdminMenu({void Function(PaymentResponse)? onStatusUpdate}) async {
    final url = Uri.parse('http://$host:$port/v1/venda');
    final body = {
      "identificacao": {
        "pontoCaptura": pontoCaptura,
        "cnpj": cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
      },
      "venda": {
        "tipoOperacao": "ADMINISTRATIVO",
        "valorTotal": "0",
        "numeroControle": DateTime.now().millisecondsSinceEpoch.toString(),
      }
    };

    return _sendRequest(url, body, onStatusUpdate: onStatusUpdate);
  }

  Future<PaymentResponse> _sendRequest(
    Uri url, 
    Map<String, dynamic> body, {
    void Function(PaymentResponse)? onStatusUpdate,
  }) async {
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
        print('DEBUG PayGo Response: $data');
        
        if (data['resultado'] == 0 || data['status'] == 'CONFIRMADA') {
          return PaymentResponse(
            success: true,
            transactionId: data['nsu'] ?? data['id_transacao'],
            cardBrand: data['bandeira'],
            message: data['mensagem'] ?? "Operação realizada com sucesso",
          );
        } else {
          return PaymentResponse(
            success: false,
            message: data['mensagem'] ?? "Operação negada ou cancelada",
          );
        }
      } else {
        return PaymentResponse(
          success: false,
          message: "Erro na API PayGo (${response.statusCode}) em ${url.path}",
        );
      }
    } catch (e) {
      return PaymentResponse(
        success: false,
        message: "Sem conexão com o PayGo Bridge em $url. Verifique se o software está aberto.",
      );
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    final url = Uri.parse('http://$host:$port/v1/cancelamento');
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
