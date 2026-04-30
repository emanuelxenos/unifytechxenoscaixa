import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Card glass reutilizável com efeito de vidro premium.
/// Usado em todo o sistema para agrupar conteúdo.
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const GlassCard({
    super.key,
    required this.child,
    this.borderColor,
    this.accentColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = AppTheme.radiusLg,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = isHighlighted && accentColor != null
        ? AppTheme.glassCardHighlight(accentColor: accentColor!)
        : AppTheme.glassCard(borderColor: borderColor);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      margin: margin,
      decoration: decoration.copyWith(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        child: child,
      ),
    );

    if (onTap != null) {
      return _TappableGlassCard(onTap: onTap!, child: card);
    }

    return card;
  }
}

class _TappableGlassCard extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _TappableGlassCard({required this.onTap, required this.child});

  @override
  State<_TappableGlassCard> createState() => _TappableGlassCardState();
}

class _TappableGlassCardState extends State<_TappableGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isHovered ? 0.9 : 1.0,
          child: AnimatedScale(
            scale: _isHovered ? 0.995 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
