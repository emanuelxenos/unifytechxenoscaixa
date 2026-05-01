import 'package:flutter/material.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';

/// Mensagens globais reutilizáveis (snackbar) para todo o sistema.
/// Tipos: success, error, warning, info
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, _SnackType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, _SnackType.error);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, _SnackType.warning);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, _SnackType.info);
  }

  static void _show(BuildContext context, String message, _SnackType type) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final config = _snackConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(config.icon, color: config.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: TextStyle(
                      color: config.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppTheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: config.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
        margin: const EdgeInsets.only(
          bottom: 24,
          left: 24,
          right: 24,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: Duration(seconds: type == _SnackType.error ? 5 : 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static _SnackConfig _snackConfig(_SnackType type) {
    switch (type) {
      case _SnackType.success:
        return _SnackConfig(
          color: AppTheme.accentGreen,
          icon: Icons.check_circle_rounded,
          title: 'Sucesso',
        );
      case _SnackType.error:
        return _SnackConfig(
          color: AppTheme.accentRed,
          icon: Icons.error_rounded,
          title: 'Erro',
        );
      case _SnackType.warning:
        return _SnackConfig(
          color: AppTheme.accentOrange,
          icon: Icons.warning_rounded,
          title: 'Atenção',
        );
      case _SnackType.info:
        return _SnackConfig(
          color: AppTheme.accentBlue,
          icon: Icons.info_rounded,
          title: 'Informação',
        );
    }
  }
}

enum _SnackType { success, error, warning, info }

class _SnackConfig {
  final Color color;
  final IconData icon;
  final String title;

  const _SnackConfig({
    required this.color,
    required this.icon,
    required this.title,
  });
}
