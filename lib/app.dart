import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenoscaixa/core/theme/app_theme.dart';
import 'package:unifytechxenoscaixa/core/services/navigation_service.dart';
import 'package:unifytechxenoscaixa/presentation/views/splash/splash_screen.dart';
import 'package:unifytechxenoscaixa/presentation/views/login/login_screen.dart';
import 'package:unifytechxenoscaixa/presentation/views/open_cash/open_cash_screen.dart';
import 'package:unifytechxenoscaixa/presentation/views/sale/sale_screen.dart';
import 'package:unifytechxenoscaixa/presentation/views/close_cash/close_cash_screen.dart';
import 'package:unifytechxenoscaixa/presentation/views/settings/payment_settings_screen.dart';
import 'package:unifytechxenoscaixa/presentation/views/settings/settings_screen.dart';

class PDVApp extends ConsumerWidget {
  const PDVApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'UnifyTech PDV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/open-cash': (context) => const OpenCashScreen(),
        '/sale': (context) => const SaleScreen(),
        '/close-cash': (context) => const CloseCashScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/settings/payment': (context) => const PaymentSettingsScreen(),
      },
    );
  }
}
