import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Dialog de confirmação reutilizável com design premium glass.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final Color? iconColor;
  final LinearGradient? confirmGradient;
  final bool isDanger;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.icon,
    this.iconColor,
    this.confirmGradient,
    this.isDanger = false,
  });

  /// Exibe o dialog e retorna true se confirmado
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    IconData? icon,
    Color? iconColor,
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        iconColor: iconColor,
        isDanger: isDanger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDanger ? AppTheme.accentRed : (iconColor ?? AppTheme.primaryColor);
    final effectiveGradient = isDanger ? AppTheme.dangerGradient : (confirmGradient ?? AppTheme.primaryGradient);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: AppTheme.glassCard(),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isDanger ? Icons.warning_rounded : Icons.help_outline_rounded),
                color: effectiveColor, size: 32,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(title, style: const TextStyle(
              color: AppTheme.onBackground, fontSize: 18, fontWeight: FontWeight.w600,
            ), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            // Message
            Text(message, style: const TextStyle(
              color: AppTheme.onSurfaceVariant, fontSize: 14, height: 1.5,
            ), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    onPressed: () => Navigator.of(context).pop(true),
                    gradient: effectiveGradient,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final LinearGradient? gradient;

  const _DialogButton({required this.label, required this.onPressed, this.isOutlined = false, this.gradient});

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          decoration: widget.isOutlined
              ? BoxDecoration(
                  color: _hovered ? AppTheme.surfaceVariant : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outline, width: 1),
                )
              : BoxDecoration(
                  gradient: widget.gradient ?? AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _hovered ? AppTheme.glowShadow(widget.gradient?.colors.first ?? AppTheme.primaryColor) : null,
                ),
          child: Center(
            child: Text(widget.label, style: TextStyle(
              color: widget.isOutlined ? AppTheme.onSurface : Colors.white,
              fontSize: 14, fontWeight: FontWeight.w600,
            )),
          ),
        ),
      ),
    );
  }
}
