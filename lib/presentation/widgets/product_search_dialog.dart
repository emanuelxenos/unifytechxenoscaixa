import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/presentation/providers/product_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';

class ProductSearchDialog extends ConsumerStatefulWidget {
  const ProductSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const ProductSearchDialog(),
    );
  }

  @override
  ConsumerState<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends ConsumerState<ProductSearchDialog> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        height: 600,
        decoration: AppTheme.glassCard(),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consultar Produto', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        Text('Pesquise por nome ou código de barras', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassInput(
                controller: _searchController,
                focusNode: _focusNode,
                hint: 'Digite para pesquisar...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => ref.read(productNotifierProvider.notifier).searchByName(val),
              ),
            ),

            // Results List
            Expanded(
              child: productState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productState.searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.onSurfaceVariant.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text('Nenhum produto encontrado', style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.5))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: productState.searchResults.length,
                          separatorBuilder: (_, __) => const Divider(color: AppTheme.divider, height: 1),
                          itemBuilder: (_, i) {
                            final p = productState.searchResults[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              leading: Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.onSurfaceVariant),
                              ),
                              title: Text(p.nome, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600)),
                              subtitle: Row(
                                children: [
                                  Text(p.codigoBarras ?? 'S/ Código', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('Estoque: ${Formatters.quantity(p.estoqueAtual)}', style: const TextStyle(color: AppTheme.accentBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(Formatters.currency(p.precoVenda), style: const TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.w700)),
                                  const Text('Preço Unitário', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10)),
                                ],
                              ),
                              onTap: () {
                                ref.read(saleNotifierProvider.notifier).addProduct(p);
                                Navigator.pop(context);
                                ref.read(productNotifierProvider.notifier).clearSearch();
                              },
                            );
                          },
                        ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.keyboard_return_rounded, size: 16, color: AppTheme.onSurfaceVariant),
                  SizedBox(width: 8),
                  Text('Pressione ENTER para selecionar', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                  Spacer(),
                  Text('ESC para sair', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
