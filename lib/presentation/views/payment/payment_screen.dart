import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/domain/models/payment_method.dart';
import 'package:unifytechxenoscaixa/domain/models/sale.dart';
import 'package:unifytechxenoscaixa/presentation/providers/cash_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/providers/payment_provider.dart';
import 'package:unifytechxenoscaixa/core/services/payment/card_payment_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/customer_search_dialog.dart';
import 'package:unifytechxenoscaixa/core/services/print_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _valorController = TextEditingController();

  final List<_PaymentEntry> _pagamentos = [];
  int? _selectedFormaId;
  double _valorTotal = 0;
  bool _hasPrinted = false;

  final _valorFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleInternalKey);
    final saleState = ref.read(saleNotifierProvider);
    final cashState = ref.read(cashNotifierProvider);
    _valorTotal = saleState.total;
    
    // Seleciona a primeira forma disponível (geralmente Dinheiro)
    if (cashState.paymentMethods.isNotEmpty) {
      _selectedFormaId = cashState.paymentMethods.first.id;
    }

    _valorController.text = _valorTotal.toStringAsFixed(2).replaceAll('.', ',');
    _valorFocus.requestFocus();
  }

  bool _handleInternalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return true;
    }

    if (key == LogicalKeyboardKey.f2) {
      final isLoading = ref.read(saleNotifierProvider).isLoading;
      if (isLoading) return true;

      if (_restante <= 0.01 && _pagamentos.isNotEmpty) {
        _confirm();
      } else if (_selectedFormaId != null) {
        _addPayment();
      }
      return true;
    }

    if (key == LogicalKeyboardKey.digit1) { _selectByOrdem(1); return true; }
    if (key == LogicalKeyboardKey.digit2) { _selectByOrdem(2); return true; }
    if (key == LogicalKeyboardKey.digit3) { _selectByOrdem(3); return true; }
    if (key == LogicalKeyboardKey.digit4) { _selectByOrdem(4); return true; }
    if (key == LogicalKeyboardKey.digit5) { _selectByOrdem(5); return true; }
    if (key == LogicalKeyboardKey.f10) { _showCustomerSearch(); return true; }

    return false;
  }

  void _showCustomerSearch() {
    CustomerSearchDialog.show(context);
  }

  double get _totalPago => _pagamentos.fold(0.0, (s, p) => s + p.valor);
  double get _restante => _valorTotal - _totalPago;
  double get _troco => _restante >= 0 ? 0 : -_restante;

  void _selectByOrdem(int ordem) {
    final formas = ref.read(cashNotifierProvider).paymentMethods;
    if (ordem <= formas.length) {
      _selectForma(formas[ordem - 1].id);
    }
  }

  void _selectForma(int id) {
    final formas = ref.read(cashNotifierProvider).paymentMethods;
    final forma = formas.firstWhere((f) => f.id == id);
    final valorRestante = _restante;

    // Melhora UX: Se for Crediário, PIX ou Cartão, adiciona DIRETO e limpa a seleção anterior
    final tipo = forma.tipo.toLowerCase();
    if (tipo == 'crediario' || tipo == 'pix' || tipo == 'cartao_debito' || tipo == 'cartao_credito') {
      if (valorRestante > 0) {
        setState(() => _selectedFormaId = null); // Limpa para o campo sumir na hora
        _addPayment(id: id, forcedValor: valorRestante);
        return; 
      }
    }

    setState(() {
      _selectedFormaId = id;
      _valorController.text = valorRestante > 0 ? valorRestante.toStringAsFixed(2).replaceAll('.', ',') : '0,00';
    });
  }

  void _addPayment({int? id, double? forcedValor}) {
    final targetId = id ?? _selectedFormaId;
    if (targetId == null) { AppSnackbar.warning(context, 'Selecione uma forma de pagamento'); return; }
    
    final valor = forcedValor ?? (double.tryParse(_valorController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0);
    if (valor <= 0) { AppSnackbar.warning(context, 'Informe um valor válido'); return; }
    
    final formas = ref.read(cashNotifierProvider).paymentMethods;
    final forma = formas.firstWhere((f) => f.id == targetId);
    
    // Validação de Crediário
    if (forma.tipo == 'crediario') {
      final saleState = ref.read(saleNotifierProvider);
      if (saleState.selectedCustomer == null) {
        AppSnackbar.error(context, 'Vincule um cliente (F10) para usar o Crediário');
        return;
      }

      final disponivel = saleState.selectedCustomer!.creditoDisponivel;
      if (valor > disponivel + 0.01) {
        // FECHA O MODAL PARA VER O ERRO NA TELA PRINCIPAL
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        AppSnackbar.error(context, 'Limite do crediário atingido (Disp: ${Formatters.currency(disponivel)}). Falar com o gerente para liberar mais crédito');
        return;
      }
    }

    // Se for cartão, tentamos o fluxo integrado
    if (forma.tipo == 'cartao_debito' || forma.tipo == 'cartao_credito') {
      _processCardPayment(forma, valor);
    } else {
      setState(() { 
        _pagamentos.add(_PaymentEntry(formaPagamentoId: forma.id, nome: forma.nome, valor: valor, tipo: forma.tipo)); 
        _selectedFormaId = null; 
      });
    }
  }

  Future<void> _processCardPayment(PaymentMethod forma, double valor) async {
    final paymentNotifier = ref.read(paymentNotifierProvider.notifier);
    
    // Inicia o pagamento na maquininha (Mock por enquanto)
    final response = await paymentNotifier.pay(valor);

    if (response.success) {
      setState(() {
        _pagamentos.add(_PaymentEntry(
          formaPagamentoId: forma.id, 
          nome: '${forma.nome} (${response.cardBrand})', 
          valor: valor,
          tipo: forma.tipo,
          transactionId: response.transactionId,
        ));
        _selectedFormaId = null;
      });
      if (mounted) AppSnackbar.success(context, 'Cartão aprovado!');
    } else {
      if (mounted) AppSnackbar.error(context, response.message ?? 'Falha no cartão');
    }
    
    paymentNotifier.reset();
  }

  void _removePayment(int index) => setState(() => _pagamentos.removeAt(index));

  Future<void> _confirm() async {
    final saleState = ref.read(saleNotifierProvider);
    if (saleState.isLoading) return;

    if (_restante > 0.01) { 
      AppSnackbar.warning(context, 'Valor insuficiente. Faltam ${Formatters.currency(_restante)}'); 
      return; 
    }
    
    final saleNotifier = ref.read(saleNotifierProvider.notifier);
    final pagamentos = _pagamentos.map((p) => CreatePaymentRequest(
      formaPagamentoId: p.formaPagamentoId, 
      valor: p.valor,
      autorizacao: p.transactionId, // Envia o ID da maquininha para o banco
    )).toList();
    
    await saleNotifier.finalizeSale(pagamentos, clienteId: saleState.selectedCustomer?.id);
  }

  bool _shouldShowValueField(List<PaymentMethod> formas) {
    if (_selectedFormaId == null) return false;
    try {
      final forma = formas.firstWhere((f) => f.id == _selectedFormaId);
      final tipo = forma.tipo.toLowerCase();
      // SÓ MOSTRA O CAMPO SE FOR DINHEIRO OU OUTROS
      return tipo == 'dinheiro' || tipo == 'outros';
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() { 
    HardwareKeyboard.instance.removeHandler(_handleInternalKey);
    _valorController.dispose(); 
    _valorFocus.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleNotifierProvider);
    final cashState = ref.watch(cashNotifierProvider);
    final paymentState = ref.watch(paymentNotifierProvider);

    // Se as formas de pagamento carregarem depois do initState, seleciona a primeira (APENAS UMA VEZ)
    if (_selectedFormaId == null && cashState.paymentMethods.isNotEmpty && _pagamentos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedFormaId == null && _pagamentos.isEmpty) {
          _selectForma(cashState.paymentMethods.first.id);
        }
      });
    }

    // Escuta sucesso
    ref.listen(saleNotifierProvider, (prev, next) {
      if (next.lastSaleResponse != null && next.lastSaleResponse != prev?.lastSaleResponse) {
        // Dispara impressão automática (apenas uma vez)
        if (!_hasPrinted) {
          _hasPrinted = true;
          final comprovante = next.lastSaleResponse?.comprovante;
          if (comprovante != null) {
            ref.read(printServiceProvider).printReceipt(comprovante);
          }
          // Limpa o carrinho e a resposta IMEDIATAMENTE para evitar re-trigger
          Future.microtask(() => ref.read(saleNotifierProvider.notifier).clearCart());
        }

        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Venda #${next.lastSaleResponse?.numeroVenda} finalizada!');
      }
    });

    // Escuta erro (Ex: Limite excedido no backend)
    ref.listen(saleNotifierProvider, (prev, next) {
      if (next.error != null) {
        // FECHA O MODAL NA MARRETA
        Navigator.of(context).pop();
        // Mostra o erro na tela principal
        AppSnackbar.error(context, next.error!);
        // Limpa o erro para não disparar de novo
        Future.microtask(() => ref.read(saleNotifierProvider.notifier).clearError());
      }
    });

    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.all(40),
          child: Container(
            width: 560, constraints: const BoxConstraints(maxHeight: 640), decoration: AppTheme.glassCard(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  child: Row(children: [
                    const Icon(Icons.payment_rounded, color: Colors.white, size: 28), const SizedBox(width: 14),
                    const Expanded(child: Text('Pagamento', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Formatters.currency(_valorTotal), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
                        if (saleState.selectedCustomer != null)
                          Text(
                            'Cliente: ${saleState.selectedCustomer!.nome}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Forma de Pagamento', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 10, runSpacing: 10, children: cashState.paymentMethods.map((f) => _PaymentMethodChip(forma: f, isSelected: _selectedFormaId == f.id, onTap: () => _selectForma(f.id))).toList()),
                      const SizedBox(height: 20),
                      
                      // LÓGICA DE EXIBIÇÃO DO CAMPO DE VALOR: SÓ APARECE PARA DINHEIRO
                      if (_selectedFormaId != null && _shouldShowValueField(cashState.paymentMethods)) ...[
                        Row(children: [
                          Expanded(child: TextField(
                            controller: _valorController, 
                            focusNode: _valorFocus,
                            autofocus: true,
                            keyboardType: TextInputType.number, 
                            textAlign: TextAlign.right, 
                            style: const TextStyle(color: AppTheme.onBackground, fontSize: 24, fontWeight: FontWeight.w700), 
                            decoration: InputDecoration(
                              labelText: 'Valor (R\$)', 
                              prefixIcon: const Icon(Icons.attach_money), 
                              suffixIcon: IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.accentGreen), onPressed: _addPayment)
                            ), 
                            onSubmitted: (_) => _addPayment()
                          )),
                        ]),
                        const SizedBox(height: 16),
                      ],
                      if (_pagamentos.isNotEmpty) ...[
                        const Text('Pagamentos Adicionados', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...List.generate(_pagamentos.length, (i) {
                          final p = _pagamentos[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                            child: Row(children: [
                              const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 18), const SizedBox(width: 10),
                              Expanded(child: Text(p.nome, style: const TextStyle(color: AppTheme.onSurface, fontSize: 14))),
                              Text(Formatters.currency(p.valor), style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              GestureDetector(onTap: () => _removePayment(i), child: const Icon(Icons.close, color: AppTheme.accentRed, size: 18)),
                            ]),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          _PayRow('Total da Venda', Formatters.currency(_valorTotal)),
                          const SizedBox(height: 6),
                          _PayRow('Total Pago', Formatters.currency(_totalPago), color: AppTheme.accentGreen),
                          if (_restante > 0.01) ...[const SizedBox(height: 6), _PayRow('Restante', Formatters.currency(_restante), color: AppTheme.accentOrange)],
                          if (_troco > 0) ...[const SizedBox(height: 6), _PayRow('Troco', Formatters.currency(_troco), color: AppTheme.accentBlue, bold: true)],
                        ]),
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Expanded(child: GlassButton.outline(label: 'Voltar (ESC)', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pop(), height: 50)),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: GlassButton.success(label: 'Confirmar (F2)', icon: Icons.check_rounded, onPressed: (_pagamentos.isEmpty || saleState.isLoading) ? null : _confirm, isLoading: saleState.isLoading, height: 50)),
                  ]),
                ),
              ],
            ),
          ),
        ),
        
        // Camada de processamento do cartão
        if (paymentState.status == PaymentStatus.processing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    Text(paymentState.message ?? 'Aguardando maquininha...', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Siga as instruções na máquina', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PayRow extends StatelessWidget {
  final String label; final String value; final Color? color; final bool bold;
  const _PayRow(this.label, this.value, {this.color, this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
      Text(value, style: TextStyle(color: color ?? AppTheme.onSurface, fontSize: 15, fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
    ]);
  }
}

class _PaymentMethodChip extends StatefulWidget {
  final PaymentMethod forma; final bool isSelected; final VoidCallback onTap;
  const _PaymentMethodChip({required this.forma, required this.isSelected, required this.onTap});
  @override
  State<_PaymentMethodChip> createState() => _PaymentMethodChipState();
}

class _PaymentMethodChipState extends State<_PaymentMethodChip> {
  bool _hovered = false;
  IconData get _icon { switch (widget.forma.tipo) { case 'dinheiro': return Icons.payments_rounded; case 'cartao_debito': return Icons.credit_card_rounded; case 'cartao_credito': return Icons.credit_score_rounded; case 'pix': return Icons.qr_code_2_rounded; case 'crediario': return Icons.person_pin_rounded; default: return Icons.account_balance_wallet_rounded; } }
  Color get _color { switch (widget.forma.tipo) { case 'dinheiro': return AppTheme.accentGreen; case 'cartao_debito': return AppTheme.accentBlue; case 'cartao_credito': return AppTheme.accentOrange; case 'pix': return AppTheme.primaryColor; case 'crediario': return AppTheme.accentPurple; default: return AppTheme.onSurfaceVariant; } }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _hovered = true), onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onTap,
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 120, height: 80,
          decoration: BoxDecoration(
            color: widget.isSelected ? _color.withOpacity(0.15) : _hovered ? AppTheme.surfaceVariant : AppTheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.isSelected ? _color : AppTheme.outline, width: widget.isSelected ? 2 : 1),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_icon, color: widget.isSelected ? _color : AppTheme.onSurfaceVariant, size: 26),
            const SizedBox(height: 6),
            Text(widget.forma.nome, style: TextStyle(color: widget.isSelected ? _color : AppTheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _PaymentEntry { 
  final int formaPagamentoId; 
  final String nome; 
  final double valor; 
  final String tipo;
  final String? transactionId;
  _PaymentEntry({required this.formaPagamentoId, required this.nome, required this.valor, required this.tipo, this.transactionId}); 
}
