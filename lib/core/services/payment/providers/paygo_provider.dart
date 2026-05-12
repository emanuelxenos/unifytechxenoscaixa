import 'dart:convert';
import 'package:http/http.dart' as http;
import '../card_payment_provider.dart';

/// Provedor para integração direta com o PayGo ControlPay (API Local)
class PayGoProvider implements CardPaymentProvider {
  final String host;
  final String port; // Padrão: 24441
  final String cnpj;
  final String pontoCaptura;

  PayGoProvider({
    required this.host,
    required this.port,
    required this.cnpj,
    required this.pontoCaptura,
  });

  @override
  String get name => "PayGo ControlPay";

  @override
  Future<PaymentResponse> processPayment(
    double amount,
    PaymentMode mode, {
    void Function(PaymentResponse)? onStatusUpdate,
  }) async {
    // Endpoint padrão do ControlPay Local para Venda
    final url = Uri.parse('http://$host:$port/api/Venda/Venda');

    // Mapeia o meio de pagamento para o que o ControlPay espera
    // 1: Crédito, 2: Débito, 3: Voucher, etc.
    int meioPagamento = 1; 
    if (mode == PaymentMode.debito) meioPagamento = 2;

    final body = {
      "PontoCaptura": pontoCaptura,
      "Cnpj": cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
      "Valor": amount, // O ControlPay costuma aceitar Double
      "MeioPagamento": meioPagamento,
      "TipoOperacao": 1, // 1: Venda
      "IdentificadorExterno": DateTime.now().millisecondsSinceEpoch.toString(),
    };

    return _sendRequest(url, body, onStatusUpdate: onStatusUpdate);
  }

  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('http://$host:$port/api/Venda/Status');
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<PaymentResponse> openAdminMenu({void Function(PaymentResponse)? onStatusUpdate}) async {
    // No ControlPay o menu administrativo costuma ser o OpCode de ADM
    final url = Uri.parse('http://$host:$port/api/Administrativo/Menu');
    final body = {
      "PontoCaptura": pontoCaptura,
      "Cnpj": cnpj.replaceAll(RegExp(r'[^0-9]'), ''),
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
        onStatusUpdate(PaymentResponse(success: false, message: "Aguardando ControlPay..."));
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // No ControlPay, sucesso costuma vir no campo 'Status' ou 'Resultado'
        bool isSuccess = data['Status'] == 1 || data['Resultado'] == 0;

        return PaymentResponse(
          success: isSuccess,
          transactionId: data['Nsu']?.toString(),
          message: data['Mensagem'] ?? (isSuccess ? "Aprovado" : "Erro no Pagamento"),
        );
      } else {
        return PaymentResponse(
          success: false, 
          message: "Erro ControlPay: ${response.statusCode}\n${response.body}"
        );
      }
    } catch (e) {
      return PaymentResponse(success: false, message: "Erro de conexão com ControlPay: $e");
    }
  }

  @override
  Future<bool> cancelTransaction(String transactionId) async {
    // Implementar cancelamento via /api/Venda/Cancelar
    return false;
  }
}
