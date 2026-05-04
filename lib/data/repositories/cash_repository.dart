import 'package:unifytechxenoscaixa/core/constants/api_endpoints.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/cash_session.dart';
import 'package:unifytechxenoscaixa/domain/models/payment_method.dart';

class CashRepository {
  final ApiService _api;

  CashRepository(this._api);

  Future<CashStatusResponse> status() async {
    final response = await _api.get(ApiEndpoints.caixaStatus);
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return CashStatusResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> abrir(OpenCashRequest request) async {
    final response = await _api.post(ApiEndpoints.caixaAbrir, body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> fechar(CloseCashRequest request) async {
    final response = await _api.post(ApiEndpoints.caixaFechar, body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> sangria(CashMovementRequest request) async {
    final response = await _api.post(ApiEndpoints.caixaSangria, body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
  }

  Future<void> suprimento(CashMovementRequest request) async {
    final response = await _api.post(ApiEndpoints.caixaSuprimento, body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
  }

  Future<List<PhysicalCashRegister>> listPhysicalRegisters() async {
    try {
      final response = await _api.get('${ApiEndpoints.caixaFisicos}?status=ativos');
      if (!response.isSuccess) return [];
      
      final data = response.data['data'];
      if (data is List) {
        return data.map<PhysicalCashRegister>((e) {
          return PhysicalCashRegister.fromJson(Map<String, dynamic>.from(e));
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar caixas físicos: $e');
      return [];
    }
  }

  Future<List<PaymentMethod>> listPaymentMethods() async {
    try {
      final response = await _api.get(ApiEndpoints.caixaFormasPagamento);
      if (!response.isSuccess) return [];
      
      final data = response.data['data'];
      if (data is List) {
        return data.map<PaymentMethod>((e) {
          return PaymentMethod.fromJson(Map<String, dynamic>.from(e));
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar formas de pagamento: $e');
      return [];
    }
  }
}
