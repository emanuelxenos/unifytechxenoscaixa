import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/repositories/customer_repository.dart';
import 'package:unifytechxenoscaixa/domain/models/cliente.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

part 'customer_provider.g.dart';

class CustomerState {
  final List<Cliente> searchResults;
  final bool isLoading;
  final String? error;

  const CustomerState({
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerState copyWith({
    List<Cliente>? searchResults,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CustomerState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class CustomerNotifier extends _$CustomerNotifier {
  CustomerRepository get _repository => CustomerRepository(ref.read(apiServiceNotifierProvider));
  Timer? _debounce;

  @override
  CustomerState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const CustomerState();
  }

  Future<void> search(String query) async {
    _debounce?.cancel();
    
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], clearError: true);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = state.copyWith(isLoading: true, clearError: true);
      try {
        final results = await _repository.searchCustomers(query);
        state = state.copyWith(searchResults: results, isLoading: false);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(searchResults: [], clearError: true);
  }
}
