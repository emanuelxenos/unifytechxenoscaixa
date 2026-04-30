import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';

part 'service_providers.g.dart';

/// Provider singleton para ConfigService
@Riverpod(keepAlive: true)
ConfigService configService(ConfigServiceRef ref) {
  return ConfigService();
}

/// Provider singleton para ApiService (Notifier)
@Riverpod(keepAlive: true)
class ApiServiceNotifier extends _$ApiServiceNotifier {
  @override
  ApiService build() {
    return ApiService(host: '192.168.1.100', port: 8080);
  }

  /// Inicializa ApiService a partir das configurações salvas
  Future<void> initFromConfig() async {
    final config = ref.read(configServiceProvider);
    final host = await config.getServerHost();
    final port = await config.getServerPort();
    state = ApiService(host: host, port: port);
  }

  void updateBaseUrl(String host, int port) {
    state = ApiService(host: host, port: port);
  }
}
