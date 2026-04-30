import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/cash_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/product_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/confirmation_dialog.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_card.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/status_bar.dart';
import 'package:unifytechxenoscaixa/presentation/views/payment/payment_screen.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});
  @override
  ConsumerState<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends ConsumerState<SaleScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    final productNotifier = ref.read(productNotifierProvider.notifier);
    final saleNotifier = ref.read(saleNotifierProvider.notifier);

    final product = await productNotifier.searchByBarcode(query);
    if (product != null) {
      saleNotifier.addProduct(product);
      _searchController.clear();
      _searchFocus.requestFocus();
      if (mounted) AppSnackbar.success(context, '${product.nome} adicionado');
      return;
    }

    final results = await productNotifier.searchByName(query);
    if (results.isEmpty) {
      if (mounted) AppSnackbar.warning(context, 'Produto não encontrado');
    } else if (results.length == 1) {
      saleNotifier.addProduct(results.first);
      _searchController.clear();
      productNotifier.clearSearch();
      if (mounted) AppSnackbar.success(context, '${results.first.nome} adicionado');
    }
    _searchFocus.requestFocus();
  }

  void _showPayment() {
    final saleState = ref.read(saleNotifierProvider);
    if (saleState.isEmpty) {
      AppSnackbar.warning(context, 'Adicione produtos ao carrinho');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const PaymentScreen(),
    );
  }

  Future<void> _cancelSale() async {
    final saleState = ref.read(saleNotifierProvider);
    if (saleState.isEmpty) return;

    final confirmed = await ConfirmationDialog.show(context,
      title: 'Cancelar Venda',
      message: 'Deseja realmente cancelar esta venda? Todos os itens serão removidos.',
      confirmLabel: 'Cancelar Venda', isDanger: true,
    );
    if (confirmed) {
      ref.read(saleNotifierProvider.notifier).clearCart();
      if (mounted) AppSnackbar.info(context, 'Venda cancelada');
      _searchFocus.requestFocus();
    }
  }

  void _closeCash() => Navigator.of(context).pushReplacementNamed('/close-cash');

  void _openMenu() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300, decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuItem(icon: Icons.remove_circle_outline, label: 'Sangria', onTap: () { Navigator.pop(ctx); _showMovementDialog('sangria'); }),
              _MenuItem(icon: Icons.add_circle_outline, label: 'Suprimento', onTap: () { Navigator.pop(ctx); _showMovementDialog('suprimento'); }),
              const Divider(color: AppTheme.divider, height: 1),
              _MenuItem(icon: Icons.lock_rounded, label: 'Fechar Caixa', onTap: () { Navigator.pop(ctx); _closeCash(); }),
              _MenuItem(icon: Icons.settings_rounded, label: 'Configurações', onTap: () { Navigator.pop(ctx); Navigator.of(context).pushNamed('/settings'); }),
            ],
          ),
        ),
      ),
    );
  }

  void _showMovementDialog(String tipo) {
    final valorCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380, decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tipo == 'sangria' ? Icons.remove_circle_outline : Icons.add_circle_outline, color: tipo == 'sangria' ? AppTheme.accentRed : AppTheme.accentGreen, size: 36),
              const SizedBox(height: 12),
              Text(tipo == 'sangria' ? 'Sangria' : 'Suprimento', style: const TextStyle(color: AppTheme.onBackground, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              TextField(controller: valorCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppTheme.onBackground, fontSize: 20), decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixIcon: Icon(Icons.attach_money))),
              const SizedBox(height: 12),
              TextField(controller: motivoCtrl, style: const TextStyle(color: AppTheme.onBackground), decoration: const InputDecoration(labelText: 'Motivo')),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: GlassButton.outline(label: 'Cancelar', onPressed: () => Navigator.pop(ctx), height: 44)),
                  const SizedBox(width: 12),
                  Expanded(child: GlassButton.primary(label: 'Confirmar', onPressed: () async {
                    final valor = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0;
                    final motivo = motivoCtrl.text.trim();
                    if (valor <= 0 || motivo.isEmpty) { AppSnackbar.warning(ctx, 'Preencha valor e motivo'); return; }
                    final cashNotifier = ref.read(cashNotifierProvider.notifier);
                    final ok = tipo == 'sangria' ? await cashNotifier.sangria(valor, motivo) : await cashNotifier.suprimento(valor, motivo);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (ok) {
                      if (mounted) AppSnackbar.success(context, '${tipo == 'sangria' ? 'Sangria' : 'Suprimento'} registrado!');
                    } else {
                      final cashState = ref.read(cashNotifierProvider);
                      if (mounted) AppSnackbar.error(context, cashState.error ?? 'Erro');
                    }
                  }, height: 44)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final cashState = ref.watch(cashNotifierProvider);
    final saleState = ref.watch(saleNotifierProvider);
    final productState = ref.watch(productNotifierProvider);

    return Scaffold(
      body: Column(
        children: [
          StatusBar(
            operadorNome: authState.user?.nome ?? '-',
            caixaNome: 'Caixa ${cashState.sessao?.caixaFisicoId ?? 1}'.padLeft(2, '0'),
            sessaoCodigo: cashState.sessao?.codigoSessao,
            onMenuPressed: _openMenu,
          ),
          Expanded(
            child: Row(
              children: [
                // LEFT PANEL (60%) — Search & Cart
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController, focusNode: _searchFocus,
                                  style: const TextStyle(color: AppTheme.onBackground, fontSize: 18, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'Código de barras ou nome do produto...',
                                    hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                    border: InputBorder.none, isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onSubmitted: _handleSearch,
                                ),
                              ),
                              if (productState.isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            ],
                          ),
                        ),
                        if (productState.searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4), constraints: const BoxConstraints(maxHeight: 200),
                            decoration: AppTheme.glassCard(),
                            child: ListView.builder(
                              shrinkWrap: true, itemCount: productState.searchResults.length,
                              itemBuilder: (_, i) {
                                final p = productState.searchResults[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryColor, size: 20),
                                  title: Text(p.nome, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14)),
                                  subtitle: Text('${Formatters.currency(p.precoVenda)} | Estoque: ${Formatters.quantity(p.estoqueAtual)}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                                  onTap: () {
                                    ref.read(saleNotifierProvider.notifier).addProduct(p);
                                    ref.read(productNotifierProvider.notifier).clearSearch();
                                    _searchController.clear();
                                    _searchFocus.requestFocus();
                                    AppSnackbar.success(context, '${p.nome} adicionado');
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            children: [
                              Expanded(flex: 1, child: Text('#', style: _headerStyle)),
                              Expanded(flex: 5, child: Text('Produto', style: _headerStyle)),
                              Expanded(flex: 2, child: Text('Qtd', style: _headerStyle, textAlign: TextAlign.center)),
                              Expanded(flex: 2, child: Text('Unitário', style: _headerStyle, textAlign: TextAlign.right)),
                              Expanded(flex: 2, child: Text('Total', style: _headerStyle, textAlign: TextAlign.right)),
                              SizedBox(width: 40),
                            ],
                          ),
                        ),
                        Expanded(
                          child: saleState.isEmpty
                              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.shopping_cart_outlined, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3), size: 64),
                                  const SizedBox(height: 12),
                                  Text('Carrinho vazio', style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Escaneie um produto para começar', style: TextStyle(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3), fontSize: 13)),
                                ]))
                              : ListView.builder(
                                  itemCount: saleState.cart.length,
                                  itemBuilder: (_, i) {
                                    final item = saleState.cart[i];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
                                      child: Row(children: [
                                        Expanded(flex: 1, child: Text('${i + 1}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13))),
                                        Expanded(flex: 5, child: Text(item.produtoNome, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500))),
                                        Expanded(flex: 2, child: Text(Formatters.quantity(item.quantidade), style: const TextStyle(color: AppTheme.onSurface, fontSize: 14), textAlign: TextAlign.center)),
                                        Expanded(flex: 2, child: Text(Formatters.currency(item.precoUnitario), style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13), textAlign: TextAlign.right)),
                                        Expanded(flex: 2, child: Text(Formatters.currency(item.total), style: const TextStyle(color: AppTheme.accentGreen, fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                                        SizedBox(width: 40, child: IconButton(icon: const Icon(Icons.close_rounded, color: AppTheme.accentRed, size: 18), onPressed: () => ref.read(saleNotifierProvider.notifier).removeItem(i), padding: EdgeInsets.zero, constraints: const BoxConstraints())),
                                      ]),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, color: AppTheme.outline.withValues(alpha: 0.5)),
                // RIGHT PANEL (40%) — Summary & Actions
                Expanded(
                  flex: 4,
                  child: Container(
                    color: AppTheme.surface.withValues(alpha: 0.5), padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        GlassCard(accentColor: AppTheme.primaryColor, isHighlighted: true, padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            _SummaryRow(label: 'Itens', value: '${saleState.itemCount}'),
                            const SizedBox(height: 10),
                            _SummaryRow(label: 'Subtotal', value: Formatters.currency(saleState.subtotal)),
                            if (saleState.totalDiscountAll > 0) ...[
                              const SizedBox(height: 10),
                              _SummaryRow(label: 'Desconto', value: '- ${Formatters.currency(saleState.totalDiscountAll)}', valueColor: AppTheme.accentRed),
                            ],
                            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: AppTheme.divider, height: 1)),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text('TOTAL', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
                              Text(Formatters.currency(saleState.total), style: const TextStyle(color: AppTheme.accentGreen, fontSize: 32, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
                            ]),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        if (saleState.cart.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.2))),
                            child: Row(children: [
                              const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20), const SizedBox(width: 10),
                              Expanded(child: Text(saleState.cart.last.produtoNome, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                              Text(Formatters.currency(saleState.cart.last.total), style: const TextStyle(color: AppTheme.accentGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        const Spacer(),
                        GlassButton.success(label: 'Finalizar Venda', icon: Icons.shopping_cart_checkout_rounded, onPressed: saleState.isEmpty ? null : _showPayment, expanded: true, height: 60),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: GlassButton.danger(label: 'Cancelar', icon: Icons.cancel_rounded, onPressed: saleState.isEmpty ? null : _cancelSale, height: 48)),
                          const SizedBox(width: 10),
                          Expanded(child: GlassButton.outline(label: 'Fechar Caixa', icon: Icons.lock_rounded, onPressed: saleState.isEmpty ? _closeCash : null, height: 48, color: AppTheme.accentOrange)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);
}

class _SummaryRow extends StatelessWidget {
  final String label; final String value; final Color? valueColor;
  const _SummaryRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
      Text(value, style: TextStyle(color: valueColor ?? AppTheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true), onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: _hovered ? AppTheme.surfaceVariant : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(widget.icon, color: AppTheme.onSurfaceVariant, size: 20), const SizedBox(width: 14),
            Text(widget.label, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14)),
          ]),
        ),
      ),
    );
  }
}
