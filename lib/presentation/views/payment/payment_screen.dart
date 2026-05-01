import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/domain/models/payment_method.dart';
import 'package:unifytechxenoscaixa/domain/models/sale.dart';
import 'package:unifytechxenoscaixa/presentation/providers/sale_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _valorController = TextEditingController();

  final _formas = [
    PaymentMethod(id: 1, nome: 'Dinheiro', codigo: '01', tipo: 'dinheiro', requerTroco: true),
    PaymentMethod(id: 2, nome: 'Débito', codigo: '02', tipo: 'cartao_debito'),
    PaymentMethod(id: 3, nome: 'Crédito', codigo: '03', tipo: 'cartao_credito'),
    PaymentMethod(id: 4, nome: 'PIX', codigo: '04', tipo: 'pix'),
  ];

  final List<_PaymentEntry> _pagamentos = [];
  int? _selectedFormaId;
  double _valorTotal = 0;

  final _valorFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleInternalKey);
    final saleState = ref.read(saleNotifierProvider);
    _valorTotal = saleState.total;
    _selectedFormaId = 1; 
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

    if (key == LogicalKeyboardKey.digit1) { _selectForma(1); return true; }
    if (key == LogicalKeyboardKey.digit2) { _selectForma(2); return true; }
    if (key == LogicalKeyboardKey.digit3) { _selectForma(3); return true; }
    if (key == LogicalKeyboardKey.digit4) { _selectForma(4); return true; }

    return false;
  }

  double get _totalPago => _pagamentos.fold(0.0, (s, p) => s + p.valor);
  double get _restante => _valorTotal - _totalPago;
  double get _troco => _restante >= 0 ? 0 : -_restante;

  void _selectForma(int id) {
    setState(() {
      _selectedFormaId = id;
      _valorController.text = _restante > 0 ? _restante.toStringAsFixed(2).replaceAll('.', ',') : '0,00';
    });
  }

  void _addPayment() {
    if (_selectedFormaId == null) { AppSnackbar.warning(context, 'Selecione uma forma de pagamento'); return; }
    final valor = double.tryParse(_valorController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    if (valor <= 0) { AppSnackbar.warning(context, 'Informe um valor válido'); return; }
    final forma = _formas.firstWhere((f) => f.id == _selectedFormaId);
    setState(() { _pagamentos.add(_PaymentEntry(formaPagamentoId: forma.id, nome: forma.nome, valor: valor)); _selectedFormaId = null; });
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
    final pagamentos = _pagamentos.map((p) => CreatePaymentRequest(formaPagamentoId: p.formaPagamentoId, valor: p.valor)).toList();
    
    await saleNotifier.finalizeSale(pagamentos);
    // A SaleScreen detectará o sucesso e fechará este modal.
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

    // AUTODESTRUIÇÃO: Cada instância deste modal se fecha ao detectar sucesso
    ref.listen(saleNotifierProvider, (prev, next) {
      if (next.lastSaleResponse != null && prev?.lastSaleResponse == null) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Venda #${next.lastSaleResponse?.numeroVenda} finalizada!');
      }
    });

    return Dialog(
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
                Text(Formatters.currency(_valorTotal), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Forma de Pagamento', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: _formas.map((f) => _PaymentMethodChip(forma: f, isSelected: _selectedFormaId == f.id, onTap: () => _selectForma(f.id))).toList()),
                  const SizedBox(height: 20),
                  if (_selectedFormaId != null) ...[
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
  IconData get _icon { switch (widget.forma.tipo) { case 'dinheiro': return Icons.payments_rounded; case 'cartao_debito': return Icons.credit_card_rounded; case 'cartao_credito': return Icons.credit_score_rounded; case 'pix': return Icons.qr_code_2_rounded; default: return Icons.account_balance_wallet_rounded; } }
  Color get _color { switch (widget.forma.tipo) { case 'dinheiro': return AppTheme.accentGreen; case 'cartao_debito': return AppTheme.accentBlue; case 'cartao_credito': return AppTheme.accentOrange; case 'pix': return AppTheme.primaryColor; default: return AppTheme.onSurfaceVariant; } }

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

class _PaymentEntry { final int formaPagamentoId; final String nome; final double valor; _PaymentEntry({required this.formaPagamentoId, required this.nome, required this.valor}); }
