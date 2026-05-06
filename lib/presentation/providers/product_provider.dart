import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/repositories/product_repository.dart';
import 'package:unifytechxenoscaixa/domain/models/product.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

part 'product_provider.g.dart';

/// Estado de busca de produtos
class ProductState {
  final List<Product> searchResults;
  final Product? lastProduct;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.searchResults = const [],
    this.lastProduct,
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? searchResults,
    Product? lastProduct,
    bool? isLoading,
    String? error,
    bool clearLastProduct = false,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return ProductState(
      searchResults: clearResults ? const [] : (searchResults ?? this.searchResults),
      lastProduct: clearLastProduct ? null : (lastProduct ?? this.lastProduct),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class ProductNotifier extends _$ProductNotifier {
  ProductRepository get _productRepo => ProductRepository(ref.read(apiServiceNotifierProvider));

  @override
  ProductState build() {
    return const ProductState();
  }

  /// Busca por código de barras (retorna 1 produto)
  Future<Product?> searchByBarcode(String barcode) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final product = await _productRepo.buscarPorCodigo(barcode);
      state = state.copyWith(lastProduct: product, isLoading: false);
      return product;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        clearLastProduct: true,
      );
      return null;
    }
  }

  /// Busca por código interno (balança)
  Future<Product?> searchByInternalCode(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final product = await _productRepo.buscarPorCodigoInterno(code);
      state = state.copyWith(lastProduct: product, isLoading: false);
      return product;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        clearLastProduct: true,
      );
      return null;
    }
  }

  /// Busca por nome (retorna lista)
  Future<List<Product>> searchByName(String name) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(clearResults: true);
      return [];
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await _productRepo.buscarPorNome(name);
      state = state.copyWith(searchResults: results, isLoading: false);
      return results;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        clearResults: true,
      );
      return [];
    }
  }

  void clearSearch() {
    state = const ProductState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
