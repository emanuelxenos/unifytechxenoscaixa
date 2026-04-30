import 'package:unifytechxenoscaixa/core/constants/api_endpoints.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/cash_session.dart';

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
}
