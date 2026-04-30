import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/repositories/auth_repository.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';
import 'package:unifytechxenoscaixa/domain/models/user.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

part 'auth_provider.g.dart';

/// Estado de autenticação
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isServerConnected;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isServerConnected = false,
  });

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isServerConnected,
    bool clearUser = false,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isServerConnected: isServerConnected ?? this.isServerConnected,
    );
  }
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  // Getters on-demand — evitam LateInitializationError
  AuthRepository get _authRepo => AuthRepository(ref.read(apiServiceNotifierProvider));
  ConfigService get _configService => ref.read(configServiceProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  /// Inicializa, tenta restaurar sessão salva
  Future<void> initialize() async {
    final token = await _configService.getAuthToken();
    final user = await _configService.getSavedUser();
    if (token != null) {
      ref.read(apiServiceNotifierProvider).setToken(token);
    }
    state = state.copyWith(user: user, token: token);
  }

  /// Testa conexão com o servidor
  Future<bool> checkServerConnection() async {
    try {
      final connected = await _authRepo.healthCheck();
      state = state.copyWith(isServerConnected: connected);
      return connected;
    } catch (_) {
      state = state.copyWith(isServerConnected: false);
      return false;
    }
  }

  /// Faz login
  Future<bool> login(String login, String senha) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final terminalId = await _configService.getTerminalId();
      final request = LoginRequest(login: login, senha: senha, terminal: terminalId);
      final response = await _authRepo.login(request);

      ref.read(apiServiceNotifierProvider).setToken(response.token);
      await _configService.saveAuthToken(response.token);
      await _configService.saveUser(response.usuario);

      state = state.copyWith(
        user: response.usuario,
        token: response.token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Faz logout
  Future<void> logout() async {
    ref.read(apiServiceNotifierProvider).setToken(null);
    await _configService.clearAll();
    state = const AuthState();
  }

  /// Atualiza config do servidor
  Future<void> updateServerConfig(String host, int port) async {
    ref.read(apiServiceNotifierProvider.notifier).updateBaseUrl(host, port);
    await _configService.saveServerConfig(host, port);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
