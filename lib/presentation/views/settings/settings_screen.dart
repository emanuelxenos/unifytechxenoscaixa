import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/constants/app_constants.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/data/services/config_service.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_card.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _terminalController = TextEditingController();
  bool _testing = false;
  bool? _testResult;

  @override
  void initState() { super.initState(); _loadConfig(); }

  Future<void> _loadConfig() async {
    final config = ConfigService();
    _hostController.text = await config.getServerHost();
    _portController.text = (await config.getServerPort()).toString();
    _terminalController.text = await config.getTerminalId();
    setState(() {});
  }

  Future<void> _testConnection() async {
    setState(() { _testing = true; _testResult = null; });
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.updateServerConfig(_hostController.text.trim(), int.tryParse(_portController.text.trim()) ?? 8080);
    final ok = await authNotifier.checkServerConnection();
    if (!mounted) return;
    setState(() { _testing = false; _testResult = ok; });
    if (ok) { AppSnackbar.success(context, 'Servidor conectado!'); } else { AppSnackbar.error(context, 'Falha na conexão'); }
  }

  Future<void> _save() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.updateServerConfig(_hostController.text.trim(), int.tryParse(_portController.text.trim()) ?? 8080);
    final config = ConfigService();
    await config.saveTerminalId(_terminalController.text.trim());
    if (!mounted) return;
    AppSnackbar.success(context, 'Configurações salvas!');
  }

  @override
  void dispose() { _hostController.dispose(); _portController.dispose(); _terminalController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B0E1A), Color(0xFF141829)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Center(
          child: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(children: [
                Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.onSurfaceVariant), onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 8),
                  const Text('Configurações', style: TextStyle(color: AppTheme.onBackground, fontSize: 22, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 24),
                GlassCard(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.dns_rounded, color: AppTheme.accentBlue, size: 20), const SizedBox(width: 10), const Text('Servidor', style: TextStyle(color: AppTheme.onBackground, fontSize: 16, fontWeight: FontWeight.w600))]),
                  const SizedBox(height: 18),
                  GlassInput(controller: _hostController, label: 'Host / IP', hint: '192.168.1.100', prefixIcon: Icons.computer_rounded),
                  const SizedBox(height: 12),
                  GlassInput(controller: _portController, label: 'Porta', hint: '8080', prefixIcon: Icons.tag_rounded, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  if (_testResult != null)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: (_testResult! ? AppTheme.accentGreen : AppTheme.accentRed).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [Icon(_testResult! ? Icons.check_circle : Icons.error, color: _testResult! ? AppTheme.accentGreen : AppTheme.accentRed, size: 18), const SizedBox(width: 8), Text(_testResult! ? 'Conectado' : 'Falha', style: TextStyle(color: _testResult! ? AppTheme.accentGreen : AppTheme.accentRed, fontSize: 13))])),
                  const SizedBox(height: 12),
                  GlassButton.outline(label: _testing ? 'Testando...' : 'Testar Conexão', icon: Icons.wifi_find_rounded, onPressed: _testing ? null : _testConnection, expanded: true, height: 44, color: AppTheme.accentBlue),
                ])),
                const SizedBox(height: 16),
                GlassCard(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.point_of_sale_rounded, color: AppTheme.accentGreen, size: 20), const SizedBox(width: 10), const Text('Terminal', style: TextStyle(color: AppTheme.onBackground, fontSize: 16, fontWeight: FontWeight.w600))]),
                  const SizedBox(height: 18),
                  GlassInput(controller: _terminalController, label: 'ID do Terminal', hint: 'CAIXA-01', prefixIcon: Icons.badge_rounded),
                ])),
                const SizedBox(height: 16),
                // --- NOVA SEÇÃO DE PAGAMENTO ---
                GlassCard(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.credit_card_rounded, color: AppTheme.accentOrange, size: 20), const SizedBox(width: 10), const Text('Pagamentos', style: TextStyle(color: AppTheme.onBackground, fontSize: 16, fontWeight: FontWeight.w600))]),
                  const SizedBox(height: 18),
                  const Text('Configure a integração com sua maquininha de cartão.', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 16),
                  GlassButton.outline(
                    label: 'Configurar Maquininha', 
                    icon: Icons.settings_remote_rounded, 
                    onPressed: () => Navigator.of(context).pushNamed('/settings/payment'), 
                    expanded: true, 
                    height: 44,
                    color: AppTheme.accentOrange
                  ),
                ])),
                const SizedBox(height: 16),
                GlassCard(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.info_rounded, color: AppTheme.primaryColor, size: 20), const SizedBox(width: 10), const Text('Sobre', style: TextStyle(color: AppTheme.onBackground, fontSize: 16, fontWeight: FontWeight.w600))]),
                  const SizedBox(height: 14),
                  const _InfoRow('Aplicação', AppConstants.appName),
                  const _InfoRow('Versão', AppConstants.appVersion),
                  const _InfoRow('Plataforma', 'Windows Desktop'),
                ])),
                const SizedBox(height: 24),
                GlassButton.primary(label: 'Salvar Configurações', icon: Icons.save_rounded, onPressed: _save, expanded: true, height: 52),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label; final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
      Text(value, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
    ]));
  }
}
