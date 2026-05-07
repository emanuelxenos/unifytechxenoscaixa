import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/fiscal.dart';

class FiscalRepository {
  final ApiService _api;

  FiscalRepository(this._api);

  Future<FiscalEmitirResponse> emitir(int vendaId) async {
    final response = await _api.post(
      '/api/fiscal/emitir',
      body: {'venda_id': vendaId},
    );
    
    // O backend retorna os dados diretamente ou dentro de um objeto 'data' dependendo da implementação do ApiService
    // No app-caixa, o ApiService parece retornar o response.data bruto
    return FiscalEmitirResponse.fromJson(response.data);
  }
}
