import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/repositories/fiscal_repository.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
FiscalRepository fiscalRepository(FiscalRepositoryRef ref) {
  return FiscalRepository(ref.watch(apiServiceNotifierProvider));
}

/// Provider singleton para ConfigService
@Riverpod(keepAlive: true)
ConfigService configService(ConfigServiceRef ref) {
  return ConfigService();
}

/// Provider singleton para ApiService (Notifier)
@Riverpod(keepAlive: true)
class ApiServiceNotifier extends _$ApiServiceNotifier {
  String? _currentToken;

  @override
  ApiService build() {
    final api = ApiService(host: '192.168.1.100', port: 8080);
    if (_currentToken != null) api.setToken(_currentToken);
    return api;
  }

  /// Inicializa ApiService a partir das configurações salvas
  Future<void> initFromConfig() async {
    final config = ref.read(configServiceProvider);
    final host = await config.getServerHost();
    final port = await config.getServerPort();
    final token = await config.getAuthToken();
    
    _currentToken = token;
    final api = ApiService(host: host, port: port);
    if (token != null) api.setToken(token);
    state = api;
  }

  void updateBaseUrl(String host, int port) {
    final api = ApiService(host: host, port: port);
    if (_currentToken != null) api.setToken(_currentToken);
    state = api;
  }

  void setToken(String? token) {
    _currentToken = token;
    state.setToken(token);
    // Disparamos uma atualização de estado para garantir que quem usa o provider veja a mudança
    state = state; 
  }
}
