import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';

/// Status bar superior do PDV com info do operador, caixa e relógio.
class StatusBar extends StatefulWidget {
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
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.outline.withValues(alpha: 0.5))),
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

          // Sessão
          if (widget.sessaoCodigo != null) ...[
            const SizedBox(width: 16),
            _StatusChip(icon: Icons.receipt_long_rounded, label: widget.sessaoCodigo!),
          ],

          const Spacer(),

          // Custom actions
          if (widget.actions != null) ...widget.actions!,

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
