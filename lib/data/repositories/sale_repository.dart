import 'package:unifytechxenoscaixa/core/constants/api_endpoints.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/sale.dart';

class SaleRepository {
  final ApiService _api;

  SaleRepository(this._api);

  Future<SaleResponse> criarVenda(CreateSaleRequest request) async {
    final response = await _api.post(ApiEndpoints.vendas, body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return SaleResponse.fromJson(response.data);
  }

  Future<List<Sale>> listarVendasDia({String? dataInicio, String? dataFim}) async {
    final params = <String, String>{};
    if (dataInicio != null) params['data_inicio'] = dataInicio;
    if (dataFim != null) params['data_fim'] = dataFim;

    final response = await _api.get(ApiEndpoints.vendasDia, queryParams: params.isNotEmpty ? params : null);
    if (!response.isSuccess) throw Exception(response.errorMessage);

    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).map((e) => Sale.fromJson(e)).toList();
    }
    if (data is List) {
      return data.map((e) => Sale.fromJson(e)).toList();
    }
    return [];
  }

  Future<Sale> buscarPorId(int id) async {
    final response = await _api.get(ApiEndpoints.vendaPorId(id));
    if (!response.isSuccess) throw Exception(response.errorMessage);
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return Sale.fromJson(data['data']);
    }
    return Sale.fromJson(data);
  }

  Future<void> cancelarVenda(int id, CancelSaleRequest request) async {
    final response = await _api.post(ApiEndpoints.vendaCancelar(id), body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
  }
}
