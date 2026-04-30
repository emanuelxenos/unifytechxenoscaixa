import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Teclado numérico glass reutilizável para PDV.
class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;
  final VoidCallback? onEnter;
  final bool showDecimal;
  final bool showEnter;
  final double buttonSize;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    this.onBackspace,
    this.onClear,
    this.onEnter,
    this.showDecimal = true,
    this.showEnter = true,
    this.buttonSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((key) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _KeyButton(
            label: key,
            size: buttonSize,
            onTap: () => onKeyPressed(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decimal or Clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: showDecimal
              ? _KeyButton(label: ',', size: buttonSize, onTap: () => onKeyPressed(','))
              : _KeyButton(
                  icon: Icons.clear_rounded,
                  size: buttonSize,
                  color: AppTheme.accentOrange,
                  onTap: onClear ?? () {},
                ),
        ),
        // Zero
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _KeyButton(label: '0', size: buttonSize, onTap: () => onKeyPressed('0')),
        ),
        // Backspace or Enter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: showEnter
              ? _KeyButton(
                  icon: Icons.keyboard_return_rounded,
                  size: buttonSize,
                  gradient: AppTheme.successGradient,
                  textColor: Colors.white,
                  onTap: onEnter ?? () {},
                )
              : _KeyButton(
                  icon: Icons.backspace_rounded,
                  size: buttonSize,
                  color: AppTheme.accentRed,
                  onTap: onBackspace ?? () {},
                ),
        ),
      ],
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final double size;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final LinearGradient? gradient;

  const _KeyButton({
    this.label,
    this.icon,
    required this.size,
    required this.onTap,
    this.color,
    this.textColor,
    this.gradient,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null
                ? (_pressed
                    ? (widget.color ?? AppTheme.primaryColor).withValues(alpha: 0.3)
                    : _hovered
                        ? AppTheme.surfaceVariant.withValues(alpha: 0.9)
                        : AppTheme.surfaceVariant)
                : null,
            borderRadius: BorderRadius.circular(14),
            border: widget.gradient == null
                ? Border.all(
                    color: _hovered ? AppTheme.primaryColor.withValues(alpha: 0.5) : AppTheme.outline,
                    width: 1,
                  )
                : null,
            boxShadow: _pressed
                ? null
                : _hovered && widget.gradient != null
                    ? AppTheme.glowShadow(widget.gradient!.colors.first)
                    : null,
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(widget.icon, color: widget.textColor ?? widget.color ?? AppTheme.onSurface, size: 22)
                : Text(
                    widget.label!,
                    style: TextStyle(
                      color: widget.textColor ?? widget.color ?? AppTheme.onBackground,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
