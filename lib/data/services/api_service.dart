import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço HTTP centralizado para comunicação com o backend Go.
class ApiService {
  String _baseUrl;
  String? _token;
  final int _timeout;

  ApiService({
    required String host,
    required int port,
    int timeout = 30,
  })  : _baseUrl = 'http://$host:$port',
        _timeout = timeout;

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String host, int port) {
    _baseUrl = 'http://$host:$port';
  }

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// GET request
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http
          .get(uri, headers: _headers)
          .timeout(Duration(seconds: _timeout));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_parseError(e));
    }
  }

  /// POST request
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeout));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_parseError(e));
    }
  }

  /// PUT request
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeout));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(_parseError(e));
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(body, response.statusCode);
    }

    String errorMsg = 'Erro desconhecido';
    if (body is Map<String, dynamic>) {
      errorMsg = body['error'] ?? body['message'] ?? errorMsg;
    }
    return ApiResponse.error(errorMsg, response.statusCode);
  }

  String _parseError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Tempo de conexão esgotado. Verifique o servidor.';
    }
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      return 'Não foi possível conectar ao servidor.';
    }
    return 'Erro de comunicação: ${error.toString()}';
  }
}

class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse._({required this.isSuccess, this.data, this.errorMessage, this.statusCode});

  factory ApiResponse.success(dynamic data, [int? statusCode]) {
    return ApiResponse._(isSuccess: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(isSuccess: false, errorMessage: message, statusCode: statusCode);
  }
}
