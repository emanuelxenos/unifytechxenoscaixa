import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/cash_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_card.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';

class CloseCashScreen extends ConsumerStatefulWidget {
  const CloseCashScreen({super.key});
  @override
  ConsumerState<CloseCashScreen> createState() => _CloseCashScreenState();
}

class _CloseCashScreenState extends ConsumerState<CloseCashScreen> {
  final _saldoController = TextEditingController();
  final _senhaController = TextEditingController();
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(cashNotifierProvider.notifier).checkStatus();
  }

  double get _saldoContado => double.tryParse(_saldoController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  Future<void> _fecharCaixa() async {
    final senha = _senhaController.text.trim();
    if (senha.isEmpty) { AppSnackbar.warning(context, 'Senha do supervisor é obrigatória'); return; }

    final cashNotifier = ref.read(cashNotifierProvider.notifier);
    final ok = await cashNotifier.fecharCaixa(_saldoContado, senha, observacao: _obsController.text.trim());

    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, 'Caixa fechado com sucesso!');
      ref.read(authNotifierProvider.notifier).logout();
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      final cashState = ref.read(cashNotifierProvider);
      AppSnackbar.error(context, cashState.error ?? 'Erro ao fechar caixa');
    }
  }

  @override
  void dispose() { _saldoController.dispose(); _senhaController.dispose(); _obsController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cashState = ref.watch(cashNotifierProvider);
    final sessao = cashState.sessao;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B0E1A), Color(0xFF141829)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: GlassCard(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.lock_rounded, color: AppTheme.accentOrange, size: 36)),
                    const SizedBox(height: 16),
                    const Text('Fechamento de Caixa', style: TextStyle(color: AppTheme.onBackground, fontSize: 24, fontWeight: FontWeight.w700)),
                    if (sessao != null) ...[const SizedBox(height: 4), Text('Sessão: ${sessao.codigoSessao}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13))],
                    const SizedBox(height: 28),
                    if (sessao != null) ...[_buildSummaryGrid(sessao), const SizedBox(height: 24)],
                    GlassInput(controller: _saldoController, label: 'Saldo Contado (R\$)', hint: '0,00', prefixIcon: Icons.calculate_rounded, keyboardType: TextInputType.number, textAlign: TextAlign.right, fontSize: 20, onChanged: (_) => setState(() {})),
                    if (sessao != null && _saldoContado > 0) ...[const SizedBox(height: 12), _buildDifference(sessao)],
                    const SizedBox(height: 16),
                    GlassInput(controller: _senhaController, label: 'Senha do Supervisor', hint: 'Digite a senha', prefixIcon: Icons.admin_panel_settings_rounded, obscureText: true),
                    const SizedBox(height: 16),
                    GlassInput(controller: _obsController, label: 'Observação (opcional)', hint: 'Notas sobre o fechamento', prefixIcon: Icons.notes_rounded),
                    const SizedBox(height: 28),
                    Row(children: [
                      Expanded(child: GlassButton.outline(label: 'Voltar', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pushReplacementNamed('/sale'), height: 50)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: GlassButton(label: 'Fechar Caixa', icon: Icons.lock_rounded, gradient: AppTheme.warningGradient, onPressed: cashState.isLoading ? null : _fecharCaixa, isLoading: cashState.isLoading, height: 50, expanded: true)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(dynamic sessao) {
    return Wrap(spacing: 10, runSpacing: 10, children: [
      _SummaryTile('Saldo Inicial', Formatters.currency(sessao.saldoInicial), Icons.account_balance_wallet, AppTheme.accentBlue),
      _SummaryTile('Total Vendas', Formatters.currency(sessao.totalVendas), Icons.shopping_cart, AppTheme.accentGreen),
      _SummaryTile('Sangrias', Formatters.currency(sessao.totalSangrias), Icons.remove_circle_outline, AppTheme.accentRed),
      _SummaryTile('Suprimentos', Formatters.currency(sessao.totalSuprimentos), Icons.add_circle_outline, AppTheme.accentBlue),
      _SummaryTile('Dinheiro', Formatters.currency(sessao.totalDinheiro), Icons.payments, AppTheme.accentGreen),
      _SummaryTile('Cartões', Formatters.currency(sessao.totalCartaoDebito + sessao.totalCartaoCredito), Icons.credit_card, AppTheme.accentOrange),
      _SummaryTile('PIX', Formatters.currency(sessao.totalPix), Icons.qr_code_2, AppTheme.primaryColor),
      _SummaryTile('Descontos', Formatters.currency(sessao.totalDescontosConcedidos), Icons.discount, AppTheme.accentRed),
    ]);
  }

  Widget _buildDifference(dynamic sessao) {
    final esperado = sessao.saldoInicial + sessao.totalDinheiro - sessao.totalSangrias + sessao.totalSuprimentos;
    final diff = _saldoContado - esperado;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (diff.abs() < 0.01 ? AppTheme.accentGreen : AppTheme.accentRed).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (diff.abs() < 0.01 ? AppTheme.accentGreen : AppTheme.accentRed).withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Diferença:', style: TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(diff >= 0 ? '+${Formatters.currency(diff)}' : Formatters.currency(diff), style: TextStyle(color: diff.abs() < 0.01 ? AppTheme.accentGreen : AppTheme.accentRed, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label; final String value; final IconData icon; final Color color;
  const _SummaryTile(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 115, child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18), const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11)), const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ));
  }
}
