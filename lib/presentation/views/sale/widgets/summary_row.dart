import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
