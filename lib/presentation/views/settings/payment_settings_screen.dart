import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/services/payment/payment_settings.dart';
import 'package:unifytechxenoscaixa/presentation/providers/payment_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/core/services/payment/providers/mercado_pago_provider.dart';
import 'package:unifytechxenoscaixa/core/services/payment/providers/paygo_provider.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  late PaymentProviderType _selectedType;
  final Map<String, TextEditingController> _controllers = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Inicializa com o que tiver no momento
    final settings = ref.read(paymentNotifierProvider).settings;
    _selectedType = settings.type;
    _initControllers();
    
    // Escuta mudanças (caso o carregamento do banco termine depois do initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentSettings = ref.read(paymentNotifierProvider).settings;
        if (currentSettings.type != PaymentProviderType.mock && _selectedType == PaymentProviderType.mock) {
          setState(() {
            _selectedType = currentSettings.type;
            _initControllers();
          });
        }
      }
    });
  }

  void _initControllers() {
    final currentSettings = ref.read(paymentNotifierProvider).settings;
    final Map<String, String> config = (_selectedType == currentSettings.type) 
        ? currentSettings.config 
        : {};

    _controllers.clear();
    // Campos necessários por tipo
    if (_selectedType == PaymentProviderType.mercadoPago) {
      _controllers['token'] = TextEditingController(text: config['token'] ?? '');
      _controllers['deviceId'] = TextEditingController(text: config['deviceId'] ?? '');
    } else if (_selectedType == PaymentProviderType.stone) {
      _controllers['ip'] = TextEditingController(text: config['ip'] ?? 'localhost');
    } else if (_selectedType == PaymentProviderType.tef || _selectedType == PaymentProviderType.sitef || _selectedType == PaymentProviderType.payGo) {
      _controllers['host'] = TextEditingController(text: config['host'] ?? 'localhost');
      _controllers['port'] = TextEditingController(text: config['port'] ?? '8080');
      
      if (_selectedType == PaymentProviderType.sitef) {
        _controllers['empresa'] = TextEditingController(text: config['empresa'] ?? '00000000');
        _controllers['terminal'] = TextEditingController(text: config['terminal'] ?? '000001');
      }
      
      if (_selectedType == PaymentProviderType.payGo) {
        _controllers['cnpj'] = TextEditingController(text: config['cnpj'] ?? '00.000.000/0000-00');
        _controllers['pontoCaptura'] = TextEditingController(text: config['pontoCaptura'] ?? '');
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
                  onTap: () => setState(() { _selectedType = PaymentProviderType.mock; _initControllers(); }),
                ),
                _ProviderCard(
                  label: 'Mercado Pago',
                  icon: Icons.payments_rounded,
                  isSelected: _selectedType == PaymentProviderType.mercadoPago,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.mercadoPago; _initControllers(); }),
                ),
                _ProviderCard(
                  label: 'Stone',
                  icon: Icons.point_of_sale_rounded,
                  isSelected: _selectedType == PaymentProviderType.stone,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.stone; _initControllers(); }),
                ),
                _ProviderCard(
                  label: 'TEF PayGo (USB/Pinpad)',
                  icon: Icons.usb_rounded,
                  isSelected: _selectedType == PaymentProviderType.payGo,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.payGo; _initControllers(); }),
                ),
                _ProviderCard(
                  label: 'SiTef (Empresa)',
                  icon: Icons.apartment_rounded,
                  isSelected: _selectedType == PaymentProviderType.sitef,
                  onTap: () => setState(() { _selectedType = PaymentProviderType.sitef; _initControllers(); }),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildTextField('deviceId', 'ID do Dispositivo (Maquininha)')),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _searchDevices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: _isSearching 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.search_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ];
    } else if (_selectedType == PaymentProviderType.stone) {
      return [
        _buildTextField('apiKey', 'Secret Key (Stone/Pagar.me)', isPassword: true),
        const SizedBox(height: 16),
        _buildTextField('terminalId', 'Serial Number (Maquininha Ton)'),
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
    } else if (_selectedType == PaymentProviderType.payGo) {
      return [
        _buildTextField('host', 'IP do Software PayGo (Localhost)'),
        const SizedBox(height: 16),
        _buildTextField('port', 'Porta do Software (Padrão 8080)'),
        const SizedBox(height: 16),
        _buildTextField('cnpj', 'CNPJ/CPF da Instalação (Sandbox)'),
        const SizedBox(height: 16),
        _buildTextField('pontoCaptura', 'Ponto de Captura (PDC/Terminal)'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSearching ? null : _testPayGoConnection,
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Testar Conexão'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSearching ? null : _openPayGoAdmin,
                icon: const Icon(Icons.admin_panel_settings_rounded),
                label: const Text('Menu Admin'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ];
    }
    return [];
  }

  Future<void> _testPayGoConnection() async {
    final host = _controllers['host']?.text ?? 'localhost';
    final port = _controllers['port']?.text ?? '8080';
    
    setState(() => _isSearching = true);
    
    try {
      final provider = PayGoProvider(
        host: host,
        port: port,
        cnpj: '',
        pontoCaptura: '',
      );
      
      final ok = await provider.testConnection();
      
      if (!mounted) return;
      setState(() => _isSearching = false);
      
      if (ok) {
        AppSnackbar.success(context, 'Conexão com PayGo Bridge estabelecida!');
      } else {
        AppSnackbar.error(context, 'O Bridge na porta $port respondeu, mas os caminhos /venda ou /v1/venda não existem (404).');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        AppSnackbar.error(context, 'Erro de conexão: Verifique se o software PayGo está aberto na porta $port. (Erro: $e)');
      }
    }
  }

  Future<void> _openPayGoAdmin() async {
    final host = _controllers['host']?.text ?? 'localhost';
    final port = _controllers['port']?.text ?? '8080';
    final cnpj = _controllers['cnpj']?.text ?? '';
    final pdc = _controllers['pontoCaptura']?.text ?? '';
    
    if (cnpj.isEmpty || pdc.isEmpty) {
      AppSnackbar.warning(context, 'Preencha o CNPJ e o PDC para abrir o menu admin.');
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final provider = PayGoProvider(
        host: host,
        port: port,
        cnpj: cnpj,
        pontoCaptura: pdc,
      );
      
      // Mostra snackbar de aviso pois isso abre uma tela externa
      AppSnackbar.warning(context, 'Aguardando o menu administrativo no PayGo...');
      
      final result = await provider.openAdminMenu();
      
      if (!mounted) return;
      setState(() => _isSearching = false);
      
      if (result.success) {
        AppSnackbar.success(context, result.message ?? 'Operação administrativa concluída.');
      } else {
        AppSnackbar.error(context, result.message ?? 'Erro ao abrir menu admin.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        AppSnackbar.error(context, 'Erro ao abrir menu admin: $e');
      }
    }
  }

  Future<void> _searchDevices() async {
    final token = _controllers['token']?.text ?? '';
    if (token.isEmpty) {
      AppSnackbar.error(context, 'Insira o Access Token primeiro!');
      return;
    }

    setState(() => _isSearching = true);

    try {
      final provider = MercadoPagoProvider(accessToken: token, deviceId: '');
      final devices = await provider.getDevices();

      if (!mounted) return;
      setState(() => _isSearching = false);

      if (devices.isEmpty) {
        AppSnackbar.warning(context, 'Nenhum dispositivo encontrado nesta conta.');
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selecione sua Maquininha'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: devices.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final d = devices[i];
                return ListTile(
                  leading: const Icon(Icons.point_of_sale_rounded, color: AppTheme.primaryColor),
                  title: Text(d['name'] ?? 'Sem Nome'),
                  subtitle: Text('S/N: ${d['sn']}'),
                  onTap: () {
                    setState(() {
                      _controllers['deviceId']?.text = d['id']!;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        AppSnackbar.error(context, 'Erro ao buscar dispositivos: $e');
      }
    }
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
