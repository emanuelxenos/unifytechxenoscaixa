import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/cliente.dart';

class CustomerRepository {
  final ApiService _apiService;

  CustomerRepository(this._apiService);

  Future<List<Cliente>> searchCustomers(String query) async {
    try {
      final response = await _apiService.get('/api/clientes/busca', queryParams: {'q': query});
      if (response.isSuccess && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => Cliente.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Cliente>> listCustomers() async {
    try {
      final response = await _apiService.get('/api/clientes');
      if (response.isSuccess && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => Cliente.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
