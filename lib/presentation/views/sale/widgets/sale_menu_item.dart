import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

class SaleMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? shortcut;

  const SaleMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.shortcut,
  });

  @override
  State<SaleMenuItem> createState() => _SaleMenuItemState();
}

class _SaleMenuItemState extends State<SaleMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.surfaceVariant : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppTheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.shortcut != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.outline, width: 1),
                  ),
                  child: Text(
                    widget.shortcut!,
                    style: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
