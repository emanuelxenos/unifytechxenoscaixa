import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifytechxenoscaixa/core/constants/app_constants.dart';
import 'package:unifytechxenoscaixa/domain/models/user.dart';

/// Serviço de configuração local (SharedPreferences).
class ConfigService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Server Config ──────────────────────────────────────────
  Future<String> getServerHost() async {
    final p = await prefs;
    return p.getString(AppConstants.keyServerHost) ?? AppConstants.defaultHost;
  }

  Future<int> getServerPort() async {
    final p = await prefs;
    return p.getInt(AppConstants.keyServerPort) ?? AppConstants.defaultPort;
  }

  Future<void> saveServerConfig(String host, int port) async {
    final p = await prefs;
    await p.setString(AppConstants.keyServerHost, host);
    await p.setInt(AppConstants.keyServerPort, port);
  }

  // ─── Auth Token ─────────────────────────────────────────────
  Future<String?> getAuthToken() async {
    final p = await prefs;
    return p.getString(AppConstants.keyAuthToken);
  }

  Future<void> saveAuthToken(String token) async {
    final p = await prefs;
    await p.setString(AppConstants.keyAuthToken, token);
  }

  Future<void> clearAuthToken() async {
    final p = await prefs;
    await p.remove(AppConstants.keyAuthToken);
  }

  // ─── User Data ──────────────────────────────────────────────
  Future<User?> getSavedUser() async {
    final p = await prefs;
    final data = p.getString(AppConstants.keyUserData);
    if (data == null) return null;
    try {
      return User.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    final p = await prefs;
    await p.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    final p = await prefs;
    await p.remove(AppConstants.keyUserData);
  }

  // ─── Terminal Config ────────────────────────────────────────
  Future<String> getTerminalId() async {
    final p = await prefs;
    return p.getString(AppConstants.keyTerminalId) ?? AppConstants.defaultTerminalId;
  }

  Future<void> saveTerminalId(String terminalId) async {
    final p = await prefs;
    await p.setString(AppConstants.keyTerminalId, terminalId);
  }

  // ─── Payment Config ─────────────────────────────────────────
  Future<String?> getPaymentSettings() async {
    final p = await prefs;
    return p.getString('payment_settings');
  }

  Future<void> savePaymentSettings(String json) async {
    final p = await prefs;
    await p.setString('payment_settings', json);
  }

  // ─── Full Clear ─────────────────────────────────────────────
  Future<void> clearAll() async {
    await clearAuthToken();
    await clearUser();
  }
}
