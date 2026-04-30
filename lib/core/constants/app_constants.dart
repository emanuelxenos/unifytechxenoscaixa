class AppConstants {
  AppConstants._();

  static const String appName = 'UnifyTech PDV';
  static const String appVersion = '1.0.0';
  static const String appTitle = 'Caixa';

  // Default server config
  static const String defaultHost = '192.168.1.100';
  static const int defaultPort = 8080;
  static const int requestTimeout = 30; // seconds

  // SharedPreferences keys
  static const String keyServerHost = 'server_host';
  static const String keyServerPort = 'server_port';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyTerminalId = 'terminal_id';
  static const String keyTerminalName = 'terminal_name';

  // Terminal defaults
  static const String defaultTerminalId = 'CAIXA-01';
  static const String defaultTerminalName = 'Caixa Principal';
}
