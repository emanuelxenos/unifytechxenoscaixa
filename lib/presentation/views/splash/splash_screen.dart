import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/presentation/providers/auth_provider.dart';
import 'package:unifytechxenoscaixa/presentation/providers/service_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _statusText = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _checkSystem();
  }

  Future<void> _checkSystem() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Inicializa ApiService com config salva
    setState(() => _statusText = 'Carregando configurações...');
    await ref.read(apiServiceNotifierProvider.notifier).initFromConfig();

    if (!mounted) return;
    final auth = ref.read(authNotifierProvider.notifier);
    await auth.initialize();

    setState(() => _statusText = 'Verificando servidor...');
    final connected = await auth.checkServerConnection();

    if (!mounted) return;

    if (!connected) {
      setState(() => _statusText = 'Servidor indisponível');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() => _statusText = 'Conectado!');
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/open-cash');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0E1A), Color(0xFF141829)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                        ),
                        child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 28),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                        child: const Text('UnifyTech PDV', style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1,
                        )),
                      ),
                      const SizedBox(height: 8),
                      const Text('Sistema de Caixa', style: TextStyle(
                        color: AppTheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 2,
                      )),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 28, height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(_statusText, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
