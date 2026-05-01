import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';

class ServerConfigDialog extends ConsumerStatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  ConsumerState<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends ConsumerState<ServerConfigDialog> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  bool _testing = false;
  bool? _testResult;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = ConfigService();
    final host = await config.getServerHost();
    final port = await config.getServerPort();
    _hostController.text = host;
    _portController.text = port.toString();
  }

  Future<void> _testConnection() async {
    setState(() { _testing = true; _testResult = null; });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8080;
    await authNotifier.updateServerConfig(host, port);
    final ok = await authNotifier.checkServerConnection();

    if (!mounted) return;
    setState(() { _testing = false; _testResult = ok; });

    if (ok) {
      AppSnackbar.success(context, 'Conexão estabelecida!');
    } else {
      AppSnackbar.error(context, 'Não foi possível conectar ao servidor');
    }
  }

  Future<void> _save() async {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8080;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.updateServerConfig(host, port);

    if (!mounted) return;
    AppSnackbar.success(context, 'Configuração salva!');
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: AppTheme.glassCard(),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dns_rounded, color: AppTheme.accentBlue, size: 22),
                ),
                const SizedBox(width: 14),
                const Text('Configurar Servidor', style: TextStyle(
                  color: AppTheme.onBackground, fontSize: 18, fontWeight: FontWeight.w600,
                )),
              ],
            ),
            const SizedBox(height: 24),
            GlassInput(controller: _hostController, label: 'Host / IP', hint: '192.168.1.100', prefixIcon: Icons.computer_rounded),
            const SizedBox(height: 16),
            GlassInput(controller: _portController, label: 'Porta', hint: '8080', prefixIcon: Icons.tag_rounded, keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            if (_testResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      _testResult! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: _testResult! ? AppTheme.accentGreen : AppTheme.accentRed, size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _testResult! ? 'Servidor conectado' : 'Falha na conexão',
                      style: TextStyle(color: _testResult! ? AppTheme.accentGreen : AppTheme.accentRed, fontSize: 13),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: GlassButton.outline(label: 'Testar', icon: Icons.wifi_find_rounded, onPressed: _testing ? null : _testConnection, height: 46, color: AppTheme.accentBlue)),
                const SizedBox(width: 12),
                Expanded(child: GlassButton.primary(label: 'Salvar', icon: Icons.save_rounded, onPressed: _save, height: 46)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
