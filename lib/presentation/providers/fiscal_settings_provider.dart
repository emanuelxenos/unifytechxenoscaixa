import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'fiscal_settings_provider.g.dart';

@Riverpod(keepAlive: true)
class FiscalSettings extends _$FiscalSettings {
  static const _key = 'emitir_fiscal_automatico';

  @override
  bool build() {
    // Carrega o valor inicial de forma síncrona se possível ou inicia falso
    _loadSettings();
    return false;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = !state;
    await prefs.setBool(_key, newState);
    state = newState;
  }

  Future<void> setEmitir(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    state = value;
  }
}
