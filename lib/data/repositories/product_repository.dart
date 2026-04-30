import 'package:unifytechxenoscaixa/core/constants/api_endpoints.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/product.dart';

class ProductRepository {
  final ApiService _api;

  ProductRepository(this._api);

  /// Busca produto por código de barras
  Future<Product> buscarPorCodigo(String codigo) async {
    final response = await _api.get(ApiEndpoints.produtosBusca, queryParams: {'codigo': codigo});
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return Product.fromJson(response.data);
  }

  /// Busca produtos por nome
  Future<List<Product>> buscarPorNome(String nome) async {
    final response = await _api.get(ApiEndpoints.produtosBusca, queryParams: {'nome': nome});
    if (!response.isSuccess) throw Exception(response.errorMessage);

    // API pode retornar um objeto ou uma lista
    if (response.data is List) {
      return (response.data as List).map((e) => Product.fromJson(e)).toList();
    }
    return [Product.fromJson(response.data)];
  }

  /// Lista produtos paginados
  Future<List<Product>> listar({int page = 1, int limit = 50, String? search}) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _api.get(ApiEndpoints.produtos, queryParams: params);
    if (!response.isSuccess) throw Exception(response.errorMessage);

    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).map((e) => Product.fromJson(e)).toList();
    }
    if (data is List) {
      return data.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }
}
