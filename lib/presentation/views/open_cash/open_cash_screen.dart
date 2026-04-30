import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/cash_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_card.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';

class OpenCashScreen extends ConsumerStatefulWidget {
  const OpenCashScreen({super.key});
  @override
  ConsumerState<OpenCashScreen> createState() => _OpenCashScreenState();
}

class _OpenCashScreenState extends ConsumerState<OpenCashScreen> {
  final _saldoController = TextEditingController(text: '0,00');
  final _obsController = TextEditingController();
  int _selectedCaixaId = 1;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final cashNotifier = ref.read(cashNotifierProvider.notifier);
    await cashNotifier.checkStatus();
    if (!mounted) return;
    final cashState = ref.read(cashNotifierProvider);
    if (cashState.sessaoAtiva) {
      Navigator.of(context).pushReplacementNamed('/sale');
    }
  }

  Future<void> _abrirCaixa() async {
    final saldoText = _saldoController.text.replaceAll('.', '').replaceAll(',', '.');
    final saldo = double.tryParse(saldoText) ?? 0;

    final cashNotifier = ref.read(cashNotifierProvider.notifier);
    final success = await cashNotifier.abrirCaixa(
      _selectedCaixaId, saldo, observacao: _obsController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Caixa aberto com sucesso!');
      Navigator.of(context).pushReplacementNamed('/sale');
    } else {
      final cashState = ref.read(cashNotifierProvider);
      AppSnackbar.error(context, cashState.error ?? 'Erro ao abrir caixa');
    }
  }

  void _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _saldoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final cashState = ref.watch(cashNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0E1A), Color(0xFF141829)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: GlassCard(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.point_of_sale_rounded, color: AppTheme.accentGreen, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text('Abertura de Caixa', style: TextStyle(color: AppTheme.onBackground, fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Operador: ${authState.user?.nome ?? "-"}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _CaixaOption(label: 'Caixa 01', subtitle: 'Entrada', isSelected: _selectedCaixaId == 1, onTap: () => setState(() => _selectedCaixaId = 1)),
                        const SizedBox(width: 12),
                        _CaixaOption(label: 'Caixa 02', subtitle: 'Fundo', isSelected: _selectedCaixaId == 2, onTap: () => setState(() => _selectedCaixaId = 2)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GlassInput(controller: _saldoController, label: 'Saldo Inicial (R\$)', hint: '0,00', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, textAlign: TextAlign.right, fontSize: 20),
                    const SizedBox(height: 16),
                    GlassInput(controller: _obsController, label: 'Observação (opcional)', hint: 'Notas sobre a abertura', prefixIcon: Icons.notes_rounded, maxLines: 2),
                    const SizedBox(height: 32),
                    GlassButton.success(label: 'Abrir Caixa', icon: Icons.lock_open_rounded, onPressed: cashState.isLoading ? null : _abrirCaixa, isLoading: cashState.isLoading, expanded: true, height: 56),
                    const SizedBox(height: 12),
                    GlassButton.outline(label: 'Sair', icon: Icons.logout_rounded, onPressed: _logout, expanded: true, height: 46, color: AppTheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaixaOption extends StatefulWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  const _CaixaOption({required this.label, required this.subtitle, required this.isSelected, required this.onTap});
  @override
  State<_CaixaOption> createState() => _CaixaOptionState();
}

class _CaixaOptionState extends State<_CaixaOption> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected ? AppTheme.primaryColor.withValues(alpha: 0.12) : _hovered ? AppTheme.surfaceVariant : AppTheme.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.isSelected ? AppTheme.primaryColor : AppTheme.outline, width: widget.isSelected ? 2 : 1),
            ),
            child: Column(
              children: [
                Icon(Icons.point_of_sale_rounded, color: widget.isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceVariant, size: 28),
                const SizedBox(height: 8),
                Text(widget.label, style: TextStyle(color: widget.isSelected ? AppTheme.primaryColor : AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(widget.subtitle, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
