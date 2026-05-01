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
  int? _selectedCaixaId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cashNotifierProvider.notifier).checkStatus());
  }

  void _abrirCaixa() async {
    if (_selectedCaixaId == null) {
      AppSnackbar.warning(context, 'Selecione um caixa físico');
      return;
    }

    final saldoText = _saldoController.text.replaceAll('.', '').replaceAll(',', '.');
    final saldo = double.tryParse(saldoText) ?? 0;

    await ref.read(cashNotifierProvider.notifier).abrirCaixa(
      _selectedCaixaId!, saldo, observacao: _obsController.text.trim(),
    );
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
    ref.listen(cashNotifierProvider, (previous, next) {
      if (next.sessaoAtiva && !(previous?.sessaoAtiva ?? false)) {
        Navigator.of(context).pushReplacementNamed('/sale');
      }
      if (next.error != null && next.error != previous?.error) {
        AppSnackbar.error(context, next.error!);
      }
      
      // Selecionar automático se houver apenas um caixa
      if (next.physicalRegisters.length == 1 && _selectedCaixaId == null) {
        setState(() {
          _selectedCaixaId = next.physicalRegisters.first.id;
        });
      }
      
      // Fallback: Se não houver nenhum mas terminou de carregar, seleciona o ID 1 por segurança
      if (!next.isLoading && next.physicalRegisters.isEmpty && _selectedCaixaId == null) {
        setState(() {
          _selectedCaixaId = 1;
        });
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final cashState = ref.watch(cashNotifierProvider);
    final caixas = cashState.physicalRegisters;

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
                      decoration: BoxDecoration(color: AppTheme.accentGreen.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.point_of_sale_rounded, color: AppTheme.accentGreen, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text('Abertura de Caixa', style: TextStyle(color: AppTheme.onBackground, fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Operador: ${authState.user?.nome ?? "-"}', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                    const SizedBox(height: 32),
                    
                    // Seletor de Caixas (Aparece apenas se houver mais de um)
                    if (caixas.length > 1) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Selecione o Terminal:', style: TextStyle(color: AppTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedCaixaId,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1A1F30),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                            hint: const Text('Escolha um caixa', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                            items: caixas.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.nome, style: const TextStyle(color: AppTheme.onSurface)),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedCaixaId = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else if (caixas.length == 1) ...[
                       // Se houver apenas um, mostra apenas o nome como texto informativo
                       Container(
                         padding: const EdgeInsets.all(16),
                         width: double.infinity,
                         decoration: BoxDecoration(
                           color: AppTheme.primaryColor.withOpacity(0.05),
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                         ),
                         child: Row(
                           children: [
                             const Icon(Icons.computer_rounded, color: AppTheme.primaryColor, size: 20),
                             const SizedBox(width: 12),
                             Text('Terminal: ${caixas.first.nome}', style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500)),
                           ],
                         ),
                       ),
                       const SizedBox(height: 24),
                    ],

                    GlassInput(controller: _saldoController, label: 'Saldo Inicial (R\$)', hint: '0,00', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, textAlign: TextAlign.right, fontSize: 20),
                    const SizedBox(height: 16),
                    GlassInput(controller: _obsController, label: 'Observação (opcional)', hint: 'Notas sobre a abertura', prefixIcon: Icons.notes_rounded, maxLines: 2),
                    const SizedBox(height: 32),
                    GlassButton.success(label: 'Abrir Caixa', icon: Icons.lock_open_rounded, onPressed: (cashState.isLoading || _selectedCaixaId == null) ? null : _abrirCaixa, isLoading: cashState.isLoading, expanded: true, height: 56),
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

class _CaixaOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  
  _CaixaOption({required this.label, required this.subtitle, required this.isSelected, required this.onTap});

  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<bool>(
        valueListenable: _hovered,
        builder: (context, isHovered, _) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _hovered.value = true,
            onExit: (_) => _hovered.value = false,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.12) : isHovered ? AppTheme.surfaceVariant : AppTheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.outline, width: isSelected ? 2 : 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.point_of_sale_rounded, color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceVariant, size: 28),
                    const SizedBox(height: 8),
                    Text(label, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
