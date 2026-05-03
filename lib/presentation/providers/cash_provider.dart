import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/repositories/cash_repository.dart';
import 'package:unifytechxenoscaixa/domain/models/cash_session.dart';
import 'package:unifytechxenoscaixa/domain/models/payment_method.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

part 'cash_provider.g.dart';

/// Estado do caixa
class CashState {
  final CashSession? sessao;
  final List<PhysicalCashRegister> physicalRegisters;
  final List<PaymentMethod> paymentMethods;
  final bool sessaoAtiva;
  final bool isLoading;
  final String? error;

  const CashState({
    this.sessao,
    this.physicalRegisters = const [],
    this.paymentMethods = const [],
    this.sessaoAtiva = false,
    this.isLoading = false,
    this.error,
  });

  CashState copyWith({
    CashSession? sessao,
    List<PhysicalCashRegister>? physicalRegisters,
    List<PaymentMethod>? paymentMethods,
    bool? sessaoAtiva,
    bool? isLoading,
    String? error,
    bool clearSessao = false,
    bool clearError = false,
  }) {
    return CashState(
      sessao: clearSessao ? null : (sessao ?? this.sessao),
      physicalRegisters: physicalRegisters ?? this.physicalRegisters,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      sessaoAtiva: sessaoAtiva ?? this.sessaoAtiva,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@Riverpod(keepAlive: true)
class CashNotifier extends _$CashNotifier {
  CashRepository get _cashRepo => CashRepository(ref.read(apiServiceNotifierProvider));

  @override
  CashState build() {
    return const CashState();
  }

  /// Verifica status atual do caixa
  Future<void> checkStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final status = await _cashRepo.status();
      final physicals = await _cashRepo.listPhysicalRegisters();
      final methods = await _cashRepo.listPaymentMethods();
      
      state = state.copyWith(
        sessaoAtiva: status.sessaoAtiva,
        sessao: status.sessao,
        physicalRegisters: physicals.isNotEmpty ? physicals : state.physicalRegisters,
        paymentMethods: methods.isNotEmpty ? methods : state.paymentMethods,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Abre o caixa
  Future<bool> abrirCaixa(int caixaFisicoId, double saldoInicial, {String observacao = ''}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final request = OpenCashRequest(
        caixaFisicoId: caixaFisicoId,
        saldoInicial: saldoInicial,
        observacao: observacao,
      );
      await _cashRepo.abrir(request);
      
      // Sincronizar Hardware do Terminal Selecionado
      try {
        final terminal = state.physicalRegisters.firstWhere((c) => c.id == caixaFisicoId);
        final configService = ref.read(configServiceProvider);
        await configService.saveHardwareConfig(
          impressoraModelo: terminal.impressoraModelo,
          impressoraPorta: terminal.impressoraPorta,
          balancaModelo: terminal.balancaModelo,
          balancaPorta: terminal.balancaPorta,
        );
      } catch (_) {
        // Se não encontrar o terminal na lista, ignora o sync de hardware
      }

      await checkStatus();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Fecha o caixa
  Future<bool> fecharCaixa(double saldoFinal, String supervisorSenha, {String observacao = ''}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final request = CloseCashRequest(
        saldoFinal: saldoFinal,
        supervisorSenha: supervisorSenha,
        observacao: observacao,
      );
      await _cashRepo.fechar(request);
      state = state.copyWith(
        sessaoAtiva: false,
        isLoading: false,
        clearSessao: true,
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

  /// Registra sangria
  Future<bool> sangria(double valor, String motivo) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _cashRepo.sangria(CashMovementRequest(valor: valor, motivo: motivo));
      await checkStatus();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Registra suprimento
  Future<bool> suprimento(double valor, String motivo) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _cashRepo.suprimento(CashMovementRequest(valor: valor, motivo: motivo));
      await checkStatus();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const CashState();
  }
}
