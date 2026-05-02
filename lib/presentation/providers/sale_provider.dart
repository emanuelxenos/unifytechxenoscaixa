import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/data/repositories/sale_repository.dart';
import 'package:unifytechxenoscaixa/domain/models/cliente.dart';
import 'package:unifytechxenoscaixa/domain/models/product.dart';
import 'package:unifytechxenoscaixa/domain/models/sale.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

part 'sale_provider.g.dart';

/// Estado da venda / carrinho
class SaleState {
  final List<CartItem> cart;
  final double totalDiscount;
  final bool isLoading;
  final String? error;
  final SaleResponse? lastSaleResponse;
  final Cliente? selectedCustomer;

  const SaleState({
    this.cart = const [],
    this.totalDiscount = 0,
    this.isLoading = false,
    this.error,
    this.lastSaleResponse,
    this.selectedCustomer,
  });

  int get itemCount => cart.length;
  bool get isEmpty => cart.isEmpty;
  double get subtotal => cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalItemDiscount => cart.fold(0.0, (sum, item) => sum + item.desconto);
  double get totalDiscountAll => totalItemDiscount + totalDiscount;
  double get total => subtotal - totalDiscountAll;

  SaleState copyWith({
    List<CartItem>? cart,
    double? totalDiscount,
    bool? isLoading,
    String? error,
    SaleResponse? lastSaleResponse,
    Cliente? selectedCustomer,
    bool clearError = false,
    bool clearResponse = false,
    bool removeCustomer = false,
  }) {
    return SaleState(
      cart: cart ?? this.cart,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastSaleResponse: clearResponse ? null : (lastSaleResponse ?? this.lastSaleResponse),
      selectedCustomer: removeCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
    );
  }
}

@Riverpod(keepAlive: true)
class SaleNotifier extends _$SaleNotifier {
  SaleRepository get _saleRepo => SaleRepository(ref.read(apiServiceNotifierProvider));

  @override
  SaleState build() {
    return const SaleState();
  }

  /// Adiciona um produto ao carrinho
  void addProduct(Product product, {double qty = 1}) {
    final newCart = List<CartItem>.from(state.cart);
    final existingIndex = newCart.indexWhere((item) => item.produtoId == product.id);

    if (existingIndex >= 0) {
      newCart[existingIndex].quantidade += qty;
    } else {
      newCart.add(CartItem(
        produtoId: product.id,
        produtoNome: product.nome,
        produtoFotoUrl: product.fotoUrl,
        unidadeVenda: product.unidadeVenda,
        precoUnitario: product.precoEfetivo,
        quantidade: qty,
      ));
    }
    state = state.copyWith(cart: newCart);
  }

  /// Remove um item do carrinho
  void removeItem(int index) {
    if (index >= 0 && index < state.cart.length) {
      final newCart = List<CartItem>.from(state.cart)..removeAt(index);
      state = state.copyWith(cart: newCart);
    }
  }

  /// Atualiza quantidade de um item
  void updateQuantity(int index, double qty) {
    if (index >= 0 && index < state.cart.length && qty > 0) {
      final newCart = List<CartItem>.from(state.cart);
      newCart[index].quantidade = qty;
      state = state.copyWith(cart: newCart);
    }
  }

  /// Aplica desconto em um item
  void applyItemDiscount(int index, double discount) {
    if (index >= 0 && index < state.cart.length) {
      final newCart = List<CartItem>.from(state.cart);
      newCart[index].desconto = discount;
      state = state.copyWith(cart: newCart);
    }
  }

  /// Aplica desconto total na venda
  void applyTotalDiscount(double discount) {
    state = state.copyWith(totalDiscount: discount);
  }

  /// Seleciona um cliente para a venda
  void selectCustomer(Cliente cliente) {
    state = state.copyWith(selectedCustomer: cliente);
  }

  /// Remove o cliente da venda
  void removeCustomer() {
    state = state.copyWith(removeCustomer: true);
  }

  /// Finaliza a venda enviando ao servidor
  Future<bool> finalizeSale(List<CreatePaymentRequest> pagamentos, {int? clienteId, String? observacoes}) async {
    if (state.isEmpty) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = CreateSaleRequest(
        clienteId: clienteId,
        itens: state.cart.map((item) => CreateSaleItemRequest(
          produtoId: item.produtoId,
          quantidade: item.quantidade,
          precoUnitario: item.precoUnitario,
          valorDesconto: item.desconto,
        )).toList(),
        pagamentos: pagamentos,
        observacoes: observacoes,
      );

      final response = await _saleRepo.criarVenda(request);
      state = SaleState(lastSaleResponse: response);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Limpa o carrinho
  void clearCart() {
    state = const SaleState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
