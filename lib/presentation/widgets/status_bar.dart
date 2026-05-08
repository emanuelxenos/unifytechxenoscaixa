import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/presentation/providers/fiscal_settings_provider.dart';

/// Status bar superior do PDV com info do operador, caixa e relógio.
class StatusBar extends ConsumerStatefulWidget {
  final String operadorNome;
  final String caixaNome;
  final String? sessaoCodigo;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const StatusBar({
    super.key,
    required this.operadorNome,
    required this.caixaNome,
    this.sessaoCodigo,
    this.onMenuPressed,
    this.actions,
  });

  @override
  ConsumerState<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends ConsumerState<StatusBar> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emitirFiscal = ref.watch(fiscalSettingsProvider);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.outline.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // Menu button
          if (widget.onMenuPressed != null)
            _StatusAction(icon: Icons.menu_rounded, onTap: widget.onMenuPressed!),
          if (widget.onMenuPressed != null) const SizedBox(width: 12),

          // App branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('PDV', style: TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5,
            )),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: AppTheme.outline),
          const SizedBox(width: 16),

          // Operador
          _StatusChip(icon: Icons.person_rounded, label: widget.operadorNome),
          const SizedBox(width: 16),

          // Caixa
          _StatusChip(icon: Icons.point_of_sale_rounded, label: widget.caixaNome),
          
          const SizedBox(width: 24),
          Container(width: 1, height: 20, color: AppTheme.outline.withOpacity(0.3)),
          const SizedBox(width: 24),

          // INDICADOR FISCAL PERSISTENTE (F3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: emitirFiscal ? AppTheme.accentGreen.withOpacity(0.12) : AppTheme.outline.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: emitirFiscal ? AppTheme.accentGreen : AppTheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.description_rounded, color: emitirFiscal ? AppTheme.accentGreen : AppTheme.onSurfaceVariant.withOpacity(0.5), size: 14),
                const SizedBox(width: 8),
                Text(
                  emitirFiscal ? 'NFC-e ATIVA' : 'NFC-e DESLIGADA',
                  style: TextStyle(
                    color: emitirFiscal ? AppTheme.accentGreen : AppTheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: emitirFiscal ? AppTheme.accentGreen.withOpacity(0.2) : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('F3', style: TextStyle(color: emitirFiscal ? AppTheme.accentGreen : AppTheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),

          // Sessão
          if (widget.sessaoCodigo != null) ...[
            const SizedBox(width: 24),
            _StatusChip(icon: Icons.receipt_long_rounded, label: widget.sessaoCodigo!),
          ],

          const Spacer(),

          // Custom actions
          if (widget.actions != null) ...widget.actions!,

          // F1 help hint
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.outline.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.outline, width: 1),
                  ),
                  child: const Text('F1', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Text('Ajuda', style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),

          // Date & Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppTheme.accentBlue, size: 14),
                const SizedBox(width: 8),
                Text(Formatters.date(_now), style: const TextStyle(
                  color: AppTheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500,
                )),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_rounded, color: AppTheme.accentGreen, size: 14),
                const SizedBox(width: 6),
                Text(Formatters.time(_now), style: const TextStyle(
                  color: AppTheme.onBackground, fontSize: 13, fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.onSurfaceVariant, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          color: AppTheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500,
        )),
      ],
    );
  }
}

class _StatusAction extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StatusAction({required this.icon, required this.onTap});

  @override
  State<_StatusAction> createState() => _StatusActionState();
}

class _StatusActionState extends State<_StatusAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.surfaceVariant : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, color: AppTheme.onSurfaceVariant, size: 20),
        ),
      ),
    );
  }
}
