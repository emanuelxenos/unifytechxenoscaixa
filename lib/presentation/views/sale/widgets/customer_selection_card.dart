import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/utils/formatters.dart';
import 'package:unifytechxenoscaixa/domain/models/cliente.dart';

class CustomerSelectionCard extends StatelessWidget {
  final Cliente? customer;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const CustomerSelectionCard({
    super.key,
    this.customer,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasCustomer = customer != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: hasCustomer ? 12 : 10,
          ),
          decoration: AppTheme.glassCard().copyWith(
            border: Border.all(
              color: hasCustomer
                  ? AppTheme.primaryColor.withOpacity(0.4)
                  : AppTheme.outline.withOpacity(0.3),
              width: hasCustomer ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (hasCustomer ? AppTheme.primaryColor : AppTheme.onSurfaceVariant)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasCustomer ? Icons.person_rounded : Icons.person_add_rounded,
                  color: hasCustomer ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasCustomer ? customer!.nome : 'Vincular Cliente (F10)',
                      style: TextStyle(
                        color: hasCustomer ? AppTheme.onBackground : AppTheme.onSurfaceVariant,
                        fontSize: hasCustomer ? 14 : 13,
                        fontWeight: hasCustomer ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasCustomer) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            customer!.cpfCnpj ?? 'Sem documento',
                            style: const TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Crédito: ${Formatters.currency(customer!.creditoDisponivel)}',
                              style: const TextStyle(
                                color: AppTheme.accentGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (hasCustomer)
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: onRemove,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    tooltip: 'Remover cliente',
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.onSurfaceVariant,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
