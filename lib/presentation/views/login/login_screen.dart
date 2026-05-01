import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/app_snackbar.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_button.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_card.dart';
import 'package:unifytechxenoscaixa/presentation/widgets/glass_input.dart';
import 'package:unifytechxenoscaixa/presentation/views/login/widgets/server_config_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  final _loginFocus = FocusNode();
  bool _obscureSenha = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loginFocus.requestFocus();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _senhaController.dispose();
    _loginFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final login = _loginController.text.trim();
    final senha = _senhaController.text.trim();
    if (login.isEmpty || senha.isEmpty) {
      AppSnackbar.warning(context, 'Preencha usuário e senha');
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(login, senha);

    if (!mounted) return;
    if (success) {
      final authState = ref.read(authNotifierProvider);
      AppSnackbar.success(context, 'Bem-vindo, ${authState.user?.nome ?? ""}!');
      Navigator.of(context).pushReplacementNamed('/open-cash');
    } else {
      final authState = ref.read(authNotifierProvider);
      AppSnackbar.error(context, authState.error ?? 'Falha no login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0E1A), Color(0xFF10132A), Color(0xFF141829)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -120, right: -80, child: _decorCircle(300, AppTheme.primaryColor.withOpacity(0.05))),
            Positioned(bottom: -100, left: -60, child: _decorCircle(250, AppTheme.accentGreen.withOpacity(0.04))),
            Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 420,
                    child: GlassCard(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                            ),
                            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 24),
                          const Text('UnifyTech PDV', style: TextStyle(
                            color: AppTheme.onBackground, fontSize: 24, fontWeight: FontWeight.w700,
                          )),
                          const SizedBox(height: 6),
                          const Text('Entre com suas credenciais', style: TextStyle(
                            color: AppTheme.onSurfaceVariant, fontSize: 14,
                          )),
                          const SizedBox(height: 36),
                          GlassInput(
                            controller: _loginController, label: 'Usuário', hint: 'Digite seu login',
                            prefixIcon: Icons.person_outline_rounded, focusNode: _loginFocus,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),
                          GlassInput(
                            controller: _senhaController, label: 'Senha', hint: 'Digite sua senha',
                            prefixIcon: Icons.lock_outline_rounded, obscureText: _obscureSenha,
                            suffixIcon: _obscureSenha ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            onSuffixTap: () => setState(() => _obscureSenha = !_obscureSenha),
                            textInputAction: TextInputAction.done, onSubmitted: (_) => _doLogin(),
                          ),
                          const SizedBox(height: 32),
                          GlassButton.primary(
                            label: 'Entrar', icon: Icons.login_rounded,
                            onPressed: authState.isLoading ? null : _doLogin,
                            isLoading: authState.isLoading, expanded: true, height: 54,
                          ),
                          const SizedBox(height: 16),
                          GlassButton.outline(
                            label: 'Configurar Servidor', icon: Icons.settings_ethernet_rounded,
                            onPressed: () => ServerConfigDialog.show(context),
                            expanded: true, height: 46, color: AppTheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20, right: 24,
              child: Text('v1.0.0', style: TextStyle(
                color: AppTheme.onSurfaceVariant.withOpacity(0.4), fontSize: 12,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
