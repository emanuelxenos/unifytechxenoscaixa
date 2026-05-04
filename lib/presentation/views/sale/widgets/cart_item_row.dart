import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';

class CartItemRow extends StatelessWidget {
  final int index;
  final dynamic item;
  final bool isEven;
  final bool isLast;
  final VoidCallback onRemove;
  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  CartItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.isEven,
    required this.isLast,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _hovered,
      builder: (context, isHovered, _) {
        return MouseRegion(
          onEnter: (_) => _hovered.value = true,
          onExit: (_) => _hovered.value = false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppTheme.primaryColor.withOpacity(0.06)
                  : isEven
                      ? AppTheme.surfaceVariant.withOpacity(0.25)
                      : Colors.transparent,
              border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.4))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    item.produtoNome,
                    style: TextStyle(
                      color: isLast ? AppTheme.onBackground : AppTheme.onSurface,
                      fontSize: 14,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${item.quantidade}x',
                    style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    Formatters.currency(item.precoUnitario),
                    style: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    Formatters.currency(item.subtotal),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                
                // Botão de remover (aparece apenas no hover)
                SizedBox(
                  width: 40,
                  child: isHovered 
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.accentRed,
                          size: 20,
                        ),
                        onPressed: onRemove,
                        tooltip: 'Remover item',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
