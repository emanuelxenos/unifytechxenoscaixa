import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/domain/models/cliente.dart';
import 'package:unifytechxenoscaixa/domain/models/sale.dart';

part 'pending_sale_provider.g.dart';

class PendingSale {
  final String id;
  final List<CartItem> items;
  final Cliente? cliente;
  final DateTime createdAt;

  PendingSale({
    required this.id,
    required this.items,
    this.cliente,
    required this.createdAt,
  });
}

@Riverpod(keepAlive: true)
class PendingSales extends _$PendingSales {
  @override
  List<PendingSale> build() => [];

  void addSale(List<CartItem> items, Cliente? cliente) {
    if (items.isEmpty) return;
    
    final id = 'Venda #${state.length + 1} (${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')})';
    final newSale = PendingSale(
      id: id,
      items: List.from(items),
      cliente: cliente,
      createdAt: DateTime.now(),
    );
    
    state = [...state, newSale];
  }

  void removeSale(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}
