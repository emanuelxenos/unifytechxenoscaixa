import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Botão glass reutilizável com gradientes, hover e animações.
/// Usado em todo o sistema para ações primárias e secundárias.
class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final bool expanded;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.gradient,
    this.color,
    this.textColor,
    this.width,
    this.height = 52,
    this.fontSize = 15,
    this.iconSize = 20,
    this.borderRadius = 12,
    this.isLoading = false,
    this.isOutlined = false,
    this.expanded = false,
  });

  /// Botão primário (gradiente roxo→azul)
  factory GlassButton.primary({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 52,
    bool isLoading = false,
    bool expanded = false,
  }) {
    return GlassButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      gradient: AppTheme.primaryGradient,
      height: height,
      isLoading: isLoading,
      expanded: expanded,
    );
  }

  /// Botão de sucesso (gradiente verde)
  factory GlassButton.success({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 52,
    bool isLoading = false,
    bool expanded = false,
  }) {
    return GlassButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      gradient: AppTheme.successGradient,
      height: height,
      isLoading: isLoading,
      expanded: expanded,
    );
  }

  /// Botão de perigo (gradiente vermelho)
  factory GlassButton.danger({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    double height = 52,
    bool isLoading = false,
    bool expanded = false,
  }) {
    return GlassButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      gradient: AppTheme.dangerGradient,
      height: height,
      isLoading: isLoading,
      expanded: expanded,
    );
  }

  /// Botão outline (borda, sem fundo)
  factory GlassButton.outline({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    Color? color,
    double height = 52,
    bool expanded = false,
  }) {
    return GlassButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      color: color ?? AppTheme.primaryColor,
      isOutlined: true,
      height: height,
      expanded: expanded,
    );
  }

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final effectiveColor = widget.color ?? AppTheme.primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => _controller.forward(),
        onTapUp: isDisabled
            ? null
            : (_) {
                _controller.reverse();
                widget.onPressed?.call();
              },
        onTapCancel: isDisabled ? null : () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.expanded ? double.infinity : widget.width,
            height: widget.height,
            decoration: widget.isOutlined
                ? BoxDecoration(
                    color: _isHovered
                        ? effectiveColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: isDisabled
                          ? effectiveColor.withOpacity(0.3)
                          : effectiveColor,
                      width: 1.5,
                    ),
                  )
                : BoxDecoration(
                    gradient: isDisabled
                        ? null
                        : widget.gradient ??
                            LinearGradient(colors: [
                              effectiveColor,
                              effectiveColor,
                            ]),
                    color: isDisabled
                        ? AppTheme.surfaceVariant
                        : null,
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius),
                    boxShadow: isDisabled || !_isHovered
                        ? null
                        : AppTheme.glowShadow(
                            widget.gradient?.colors.first ??
                                effectiveColor),
                  ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.isOutlined
                              ? effectiveColor
                              : Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: widget.iconSize,
                              color: isDisabled
                                  ? AppTheme.onSurfaceVariant
                                  : widget.isOutlined
                                      ? effectiveColor
                                      : widget.textColor ?? Colors.white,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.w600,
                                color: isDisabled
                                    ? AppTheme.onSurfaceVariant
                                    : widget.isOutlined
                                        ? effectiveColor
                                        : widget.textColor ?? Colors.white,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
