import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/services/payment/payment_settings.dart';
import 'package:unifytechxenoscaixa/presentation/providers/payment_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  late PaymentProviderType _selectedType;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final settings = ref.read(paymentNotifierProvider).settings;
    _selectedType = settings.type;
    _initControllers(settings.config);
  }

  void _initControllers(Map<String, String> config) {
    _controllers.clear();
    // Campos necessários por tipo
    if (_selectedType == PaymentProviderType.mercadoPago) {
      _controllers['token'] = TextEditingController(text: config['token']);
      _controllers['deviceId'] = TextEditingController(text: config['deviceId']);
    } else if (_selectedType == PaymentProviderType.stone) {
      _controllers['ip'] = TextEditingController(text: config['ip'] ?? 'localhost');
    } else if (_selectedType == PaymentProviderType.tef || _selectedType == PaymentProviderType.sitef) {
      _controllers['host'] = TextEditingController(text: config['host'] ?? 'localhost');
      _controllers['port'] = TextEditingController(text: config['port'] ?? '8080');
      if (_selectedType == PaymentProviderType.sitef) {
        _controllers['empresa'] = TextEditingController(text: config['empresa'] ?? '00000000');
        _controllers['terminal'] = TextEditingController(text: config['terminal'] ?? '000001');
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final Map<String, String> newConfig = {};
    _controllers.forEach((key, controller) {
      newConfig[key] = controller.text;
    });

    final newSettings = PaymentSettings(
      type: _selectedType,
      config: newConfig,
    );

    ref.read(paymentNotifierProvider.notifier).updateSettings(newSettings);
    AppSnackbar.success(context, 'Configurações de pagamento salvas!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Configurar Maquininha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecione o Provedor', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            
            // Grid de opções
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _ProviderCard(
                  label: 'Simulador (Teste)',
                  icon: Icons.science_rounded,
                  isSelected: _selectedType == PaymentProviderType.mock,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.mock; _initControllers({}); }),
                ),
                _ProviderCard(
                  label: 'Mercado Pago',
                  icon: Icons.payments_rounded,
                  isSelected: _selectedType == PaymentProviderType.mercadoPago,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.mercadoPago; _initControllers({}); }),
                ),
                _ProviderCard(
                  label: 'Stone',
                  icon: Icons.point_of_sale_rounded,
                  isSelected: _selectedType == PaymentProviderType.stone,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.stone; _initControllers({}); }),
                ),
                _ProviderCard(
                  label: 'TEF (PayGo)',
                  icon: Icons.usb_rounded,
                  isSelected: _selectedType == PaymentProviderType.tef,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.tef; _initControllers({}); }),
                ),
                _ProviderCard(
                  label: 'SiTef (Empresa)',
                  icon: Icons.apartment_rounded,
                  isSelected: _selectedType == PaymentProviderType.sitef,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.sitef; _initControllers({}); }),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 24),
            
            // Formulário Dinâmico
            if (_selectedType != PaymentProviderType.mock) ...[
              const Text('Parâmetros de Conexão', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ..._buildConfigFields(),
            ] else 
              const Center(child: Text('Nenhuma configuração necessária para o simulador.', style: TextStyle(color: AppTheme.onSurfaceVariant))),

            const SizedBox(height: 48),
            GlassButton.primary(
              label: 'Salvar Configurações',
              icon: Icons.save_rounded,
              onPressed: _save,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfigFields() {
    if (_selectedType == PaymentProviderType.mercadoPago) {
      return [
        _buildTextField('token', 'Access Token do Mercado Pago', isPassword: true),
        const SizedBox(height: 16),
        _buildTextField('deviceId', 'ID do Dispositivo (Maquininha)'),
      ];
    } else if (_selectedType == PaymentProviderType.stone) {
      return [
        _buildTextField('ip', 'IP da Máquina/Bridge (ex: localhost)'),
      ];
    } else if (_selectedType == PaymentProviderType.tef) {
      return [
        _buildTextField('host', 'IP do Client TEF (ex: localhost)'),
        const SizedBox(height: 16),
        _buildTextField('port', 'Porta do Client TEF (ex: 8080)'),
      ];
    } else if (_selectedType == PaymentProviderType.sitef) {
      return [
        _buildTextField('host', 'IP do Servidor SiTef'),
        const SizedBox(height: 16),
        _buildTextField('port', 'Porta do SiTef REST'),
        const SizedBox(height: 16),
        _buildTextField('empresa', 'Código da Empresa (CNPJ)'),
        const SizedBox(height: 16),
        _buildTextField('terminal', 'ID do Terminal (ex: 000001)'),
      ];
    }
    return [];
  }

  Widget _buildTextField(String key, String label, {bool isPassword = false}) {
    return TextField(
      controller: _controllers[key],
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderCard({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.outline, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isSelected ? AppTheme.onBackground : AppTheme.onSurface, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
