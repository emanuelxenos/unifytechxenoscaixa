import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Modal de ajuda exibindo todos os atalhos de teclado disponíveis no PDV.
/// Acionado pela tecla F1.
class ShortcutHelpDialog extends StatelessWidget {
  const ShortcutHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => const ShortcutHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        decoration: AppTheme.glassCard(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.keyboard_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atalhos de Teclado',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Use as teclas de função para ações rápidas',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _KeyBadge('F1', small: true),
                ],
              ),
            ),

            // ─── Shortcuts Grid ─────────────────────────────
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendas
                    _SectionTitle(icon: Icons.shopping_cart_rounded, label: 'Vendas', color: AppTheme.accentGreen),
                    const SizedBox(height: 10),
                    _ShortcutRow(keyLabel: 'F2', description: 'Finalizar venda / Pagamento', color: AppTheme.accentGreen),
                    _ShortcutRow(keyLabel: 'F3', description: 'Cancelar venda atual', color: AppTheme.accentRed),
                    _ShortcutRow(keyLabel: 'ESC', description: 'Limpar busca / Fechar diálogo', color: AppTheme.onSurfaceVariant),

                    const SizedBox(height: 20),

                    // Caixa
                    _SectionTitle(icon: Icons.point_of_sale_rounded, label: 'Caixa', color: AppTheme.accentBlue),
                    const SizedBox(height: 10),
                    _ShortcutRow(keyLabel: 'F4', description: 'Menu de operações', color: AppTheme.primaryColor),
                    _ShortcutRow(keyLabel: 'F5', description: 'Sangria (retirada)', color: AppTheme.accentOrange),
                    _ShortcutRow(keyLabel: 'F6', description: 'Suprimento (entrada)', color: AppTheme.accentBlue),
                    _ShortcutRow(keyLabel: 'F8', description: 'Fechar caixa', color: AppTheme.accentOrange),

                    const SizedBox(height: 20),

                    // Sistema
                    _SectionTitle(icon: Icons.settings_rounded, label: 'Sistema', color: AppTheme.onSurfaceVariant),
                    const SizedBox(height: 10),
                    _ShortcutRow(keyLabel: 'F9', description: 'Configurações', color: AppTheme.onSurfaceVariant),
                    _ShortcutRow(keyLabel: 'F1', description: 'Exibir esta ajuda', color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),

            // ─── Footer ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _KeyBadge('ESC', small: true),
                  const SizedBox(width: 8),
                  Text(
                    'para fechar',
                    style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionTitle({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ],
    );
  }
}

// ─── Shortcut Row ─────────────────────────────────────────────

class _ShortcutRow extends StatefulWidget {
  final String keyLabel;
  final String description;
  final Color color;

  const _ShortcutRow({required this.keyLabel, required this.description, required this.color});

  @override
  State<_ShortcutRow> createState() => _ShortcutRowState();
}

class _ShortcutRowState extends State<_ShortcutRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: _hovered ? widget.color.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _KeyBadge(widget.keyLabel),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.description,
                style: TextStyle(
                  color: _hovered ? AppTheme.onBackground : AppTheme.onSurface,
                  fontSize: 14,
                  fontWeight: _hovered ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Key Badge ────────────────────────────────────────────────

class _KeyBadge extends StatelessWidget {
  final String label;
  final bool small;

  const _KeyBadge(this.label, {this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: small ? 32 : 42),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceVariant,
            AppTheme.surfaceVariant.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(small ? 6 : 8),
        border: Border.all(color: AppTheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.onBackground,
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
