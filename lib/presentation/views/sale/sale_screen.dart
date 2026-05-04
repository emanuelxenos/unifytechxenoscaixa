import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/domain/models/cliente.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/cash_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/product_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/confirmation_dialog.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/product_search_dialog.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/shortcut_help_dialog.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/status_bar.dart';
import 'package:unifytechxenoscaixa/presentation/views/payment/payment_screen.dart';
import 'package:unifytechxenoscaixa/core/services/audio_service.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/customer_search_dialog.dart';
import 'package:unifytechxenoscaixa/presentation/views/sale/widgets/cart_item_row.dart';
import 'package:unifytechxenoscaixa/presentation/views/sale/widgets/customer_selection_card.dart';
import 'package:unifytechxenoscaixa/presentation/views/sale/widgets/product_display_card.dart';
import 'package:unifytechxenoscaixa/presentation/views/sale/widgets/summary_row.dart';
import 'package:unifytechxenoscaixa/presentation/views/sale/widgets/sale_menu_item.dart';

class SaleScreen extends ConsumerStatefulWidget {
  const SaleScreen({super.key});
  @override
  ConsumerState<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends ConsumerState<SaleScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();
  bool _searchFocused = false;
  bool _paymentDialogOpen = false;

  static const _headerStyle = TextStyle(
    color: AppTheme.onSurfaceVariant,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);
    Future.microtask(() {
      _searchFocus.requestFocus();
      ref.read(cashNotifierProvider.notifier).checkStatus();
    });
    _searchFocus.addListener(() {
      if (mounted && _searchFocused != _searchFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _searchFocused = _searchFocus.hasFocus);
        });
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _handleGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_paymentDialogOpen) return false;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.f1) { ShortcutHelpDialog.show(context); return true; }
    if (key == LogicalKeyboardKey.f2) { _showPayment(); return true; }
    if (key == LogicalKeyboardKey.f3) { _cancelSale(); return true; }
    if (key == LogicalKeyboardKey.f4) { _openMenu(); return true; }
    if (key == LogicalKeyboardKey.f5) { _showMovementDialog('sangria'); return true; }
    if (key == LogicalKeyboardKey.f6) { _showMovementDialog('suprimento'); return true; }
    if (key == LogicalKeyboardKey.f7) { ProductSearchDialog.show(context); return true; }
    if (key == LogicalKeyboardKey.f8) { _closeCash(); return true; }
    if (key == LogicalKeyboardKey.f9) { Navigator.of(context).pushNamed('/settings'); return true; }
    if (key == LogicalKeyboardKey.f10) { CustomerSearchDialog.show(context); return true; }
    if (key == LogicalKeyboardKey.delete) { _showRemoveItemDialog(); return true; }
    if (key == LogicalKeyboardKey.escape) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      }
      _searchFocus.requestFocus();
      return true;
    }
    return false;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _handleSearch(String value) async {
    String query = value.trim();
    if (query.isEmpty) return;

    double quantity = 1;
    if (query.contains('*')) {
      final parts = query.split('*');
      if (parts.length >= 2 && parts[0].isNotEmpty) {
        quantity = double.tryParse(parts[0].replaceAll(',', '.')) ?? 1;
        query = parts[1].trim();
        if (query.isEmpty) return;
      }
    }

    final productNotifier = ref.read(productNotifierProvider.notifier);
    final saleNotifier = ref.read(saleNotifierProvider.notifier);

    final product = await productNotifier.searchByBarcode(query);
    if (product != null) {
      saleNotifier.addProduct(product, qty: quantity);
      AudioService().playSuccess();
      _searchController.clear();
      _searchFocus.requestFocus();
      _scrollToBottom();
      if (mounted) AppSnackbar.success(context, '$quantity x ${product.nome} adicionado');
      return;
    }

    final results = await productNotifier.searchByName(query);
    if (results.isEmpty) {
      AudioService().playError();
      if (mounted) AppSnackbar.warning(context, 'Produto não encontrado');
    } else if (results.length == 1) {
      saleNotifier.addProduct(results.first, qty: quantity);
      AudioService().playSuccess();
      _searchController.clear();
      productNotifier.clearSearch();
      _scrollToBottom();
      if (mounted) AppSnackbar.success(context, '$quantity x ${results.first.nome} adicionado');
    }
    _searchFocus.requestFocus();
  }

  void _showPayment() {
    final saleState = ref.read(saleNotifierProvider);
    if (saleState.isEmpty) {
      AppSnackbar.warning(context, 'Adicione produtos ao carrinho');
      return;
    }
    
    setState(() => _paymentDialogOpen = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const PaymentScreen(),
    ).then((_) {
      if (mounted) setState(() => _paymentDialogOpen = false);
    });
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
              SaleMenuItem(icon: Icons.remove_circle_outline, label: 'Sangria', shortcut: 'F5', onTap: () { Navigator.pop(ctx); _showMovementDialog('sangria'); }),
              SaleMenuItem(icon: Icons.add_circle_outline, label: 'Suprimento', shortcut: 'F6', onTap: () { Navigator.pop(ctx); _showMovementDialog('suprimento'); }),
              const Divider(color: AppTheme.divider, height: 1),
              SaleMenuItem(icon: Icons.lock_rounded, label: 'Fechar Caixa', shortcut: 'F8', onTap: () { Navigator.pop(ctx); _closeCash(); }),
              SaleMenuItem(icon: Icons.settings_rounded, label: 'Configurações', shortcut: 'F9', onTap: () { Navigator.pop(ctx); Navigator.of(context).pushNamed('/settings'); }),
              const Divider(color: AppTheme.divider, height: 1),
              SaleMenuItem(icon: Icons.keyboard_rounded, label: 'Atalhos de Teclado', shortcut: 'F1', onTap: () { Navigator.pop(ctx); ShortcutHelpDialog.show(context); }),
              SaleMenuItem(icon: Icons.person_search_rounded, label: 'Vincular Cliente', shortcut: 'F10', onTap: () { Navigator.pop(ctx); CustomerSearchDialog.show(context); }),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveItemDialog() {
    final saleState = ref.read(saleNotifierProvider);
    if (saleState.cart.isEmpty) {
      AppSnackbar.warning(context, 'O carrinho está vazio');
      return;
    }

    final itemNumberCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300, decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_sweep_rounded, color: AppTheme.accentRed, size: 32),
              const SizedBox(height: 12),
              const Text('Remover Item', style: TextStyle(color: AppTheme.onBackground, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Digite o número do item (1 a ${saleState.cart.length})', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 20),
              GlassInput(
                controller: itemNumberCtrl, label: 'Nº do Item', hint: 'Ex: 1', 
                prefixIcon: Icons.tag, keyboardType: TextInputType.number, 
                autofocus: true,
                onSubmitted: (val) {
                  final n = int.tryParse(val) ?? 0;
                  if (n > 0 && n <= saleState.cart.length) {
                    ref.read(saleNotifierProvider.notifier).removeItem(n - 1);
                    Navigator.pop(ctx);
                    _searchFocus.requestFocus();
                    AppSnackbar.success(context, 'Item #$n removido');
                  } else {
                    AppSnackbar.error(ctx, 'Número inválido');
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: GlassButton.outline(label: 'Cancelar', onPressed: () => Navigator.pop(ctx), height: 40)),
                const SizedBox(width: 12),
                Expanded(child: GlassButton.danger(label: 'Remover', onPressed: () {
                  final n = int.tryParse(itemNumberCtrl.text) ?? 0;
                  if (n > 0 && n <= saleState.cart.length) {
                    ref.read(saleNotifierProvider.notifier).removeItem(n - 1);
                    Navigator.pop(ctx);
                    _searchFocus.requestFocus();
                  } else {
                    AppSnackbar.error(ctx, 'Número inválido');
                  }
                }, height: 40)),
              ]),
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
          width: 400, decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (tipo == 'sangria' ? AppTheme.accentRed : AppTheme.accentGreen).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(tipo == 'sangria' ? Icons.remove_circle_outline : Icons.add_circle_outline, color: tipo == 'sangria' ? AppTheme.accentRed : AppTheme.accentGreen, size: 32),
              ),
              const SizedBox(height: 14),
              Text(tipo == 'sangria' ? 'Sangria' : 'Suprimento', style: const TextStyle(color: AppTheme.onBackground, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(tipo == 'sangria' ? 'Retirada de valores do caixa' : 'Entrada de valores no caixa', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 24),
              GlassInput(controller: valorCtrl, label: 'Valor (R\$)', hint: '0,00', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, textAlign: TextAlign.right, fontSize: 20),
              const SizedBox(height: 14),
              GlassInput(controller: motivoCtrl, label: 'Motivo', hint: 'Descreva o motivo', prefixIcon: Icons.notes_rounded),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: GlassButton.outline(label: 'Cancelar', onPressed: () => Navigator.pop(ctx), height: 46)),
                  const SizedBox(width: 12),
                  Expanded(child: GlassButton.primary(label: 'Confirmar', icon: Icons.check_rounded, onPressed: () async {
                    final valor = double.tryParse(valorCtrl.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
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
                  }, height: 46)),
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

    ref.listen(saleNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        AppSnackbar.error(context, next.error!);
      }
      if (next.lastSaleResponse != null && next.lastSaleResponse != prev?.lastSaleResponse) {
        AudioService().playSuccessSale();
        _searchFocus.requestFocus();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          StatusBar(
            operadorNome: authState.user?.nome ?? '-',
            caixaNome: 'Caixa ${(cashState.sessao?.caixaFisicoId ?? 1).toString().padLeft(2, '0')}',
            sessaoCodigo: cashState.sessao?.codigoSessao,
            onMenuPressed: _openMenu,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSearchBar(productState),
                        const SizedBox(height: 12),
                        _buildCartHeader(),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 4),
                            itemCount: saleState.cart.length,
                            itemBuilder: (_, i) => CartItemRow(
                              index: i, item: saleState.cart[i], isEven: i % 2 == 0,
                              isLast: i == saleState.cart.length - 1,
                              onRemove: () => ref.read(saleNotifierProvider.notifier).removeItem(i),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.4),
                    border: const Border(left: BorderSide(color: AppTheme.divider, width: 1)),
                  ),
                  child: Column(
                    children: [
                      CustomerSelectionCard(
                        customer: saleState.selectedCustomer,
                        onTap: () => CustomerSearchDialog.show(context),
                        onRemove: () => ref.read(saleNotifierProvider.notifier).removeCustomer(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildSummaryPanel(saleState),
                              const SizedBox(height: 12),
                              if (saleState.cart.isNotEmpty) ...[
                                ProductDisplayCard(
                                  item: saleState.cart.last,
                                  totalItens: saleState.cart.length,
                                ),
                              ] else ...[
                                _buildEmptyDisplay(),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButtons(saleState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductState productState) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: AppTheme.card.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: _searchFocused ? AppTheme.primaryColor.withOpacity(0.6) : AppTheme.outline.withOpacity(0.6),
              width: _searchFocused ? 1.5 : 1,
            ),
            boxShadow: _searchFocused ? [
              BoxShadow(color: AppTheme.primaryColor.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4)),
            ] : AppTheme.glassBoxShadow,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: _searchFocused ? AppTheme.primaryColor : AppTheme.onSurfaceVariant, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController, focusNode: _searchFocus,
                  style: const TextStyle(color: AppTheme.onBackground, fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Código de barras ou nome do produto...',
                    hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.5)),
                    border: InputBorder.none, isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: _handleSearch,
                ),
              ),
              if (productState.isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text('ESC limpar', style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.3), fontSize: 11)),
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
                    _scrollToBottom();
                    AppSnackbar.success(context, '${p.nome} adicionado');
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Text('#', style: _headerStyle)),
          Expanded(flex: 5, child: Text('PRODUTO', style: _headerStyle)),
          Expanded(flex: 2, child: Text('QTD', style: _headerStyle, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('UNITÁRIO', style: _headerStyle, textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text('SUBTOTAL', style: _headerStyle, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(SaleState saleState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(children: [
        SummaryRow(label: 'Subtotal', value: Formatters.currency(saleState.subtotal)),
        if (saleState.totalDiscountAll > 0) ...[
          const SizedBox(height: 10),
          SummaryRow(label: 'Desconto', value: '- ${Formatters.currency(saleState.totalDiscountAll)}', valueColor: AppTheme.accentRed),
        ],
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: AppTheme.divider, height: 1)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('TOTAL', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
          Text(Formatters.currency(saleState.total), style: const TextStyle(color: AppTheme.accentGreen, fontSize: 32, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
        ]),
      ]),
    );
  }

  Widget _buildEmptyDisplay() {
    return Container(
      height: 180, width: double.infinity,
      decoration: AppTheme.glassCard(),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.qr_code_scanner_rounded, color: AppTheme.onSurfaceVariant.withOpacity(0.2), size: 64),
        const SizedBox(height: 16),
        Text('Aguardando leitura...', style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.4), fontSize: 14)),
      ]),
    );
  }

  Widget _buildActionButtons(SaleState saleState) {
    return Column(
      children: [
        GlassButton.success(label: 'Finalizar (F2)', icon: Icons.shopping_cart_checkout_rounded, onPressed: saleState.isEmpty ? null : _showPayment, expanded: true, height: 60),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: GlassButton.danger(label: 'Cancelar (F3)', icon: Icons.cancel_rounded, onPressed: saleState.isEmpty ? null : _cancelSale, height: 48)),
          const SizedBox(width: 10),
          Expanded(child: GlassButton.outline(label: 'Fechar (F8)', icon: Icons.lock_rounded, onPressed: saleState.isEmpty ? _closeCash : null, height: 48, color: AppTheme.accentOrange)),
        ]),
      ],
    );
  }
}
