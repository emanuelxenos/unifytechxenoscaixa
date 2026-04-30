import 'package:unifytechxenoscaixa/core/constants/api_endpoints.dart';
import 'package:unifytechxenoscaixa/data/services/api_service.dart';
import 'package:unifytechxenoscaixa/domain/models/user.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _api.post(ApiEndpoints.login, body: request.toJson());
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return LoginResponse.fromJson(response.data);
  }

  Future<bool> healthCheck() async {
    final response = await _api.get(ApiEndpoints.health);
    return response.isSuccess;
  }

  Future<Map<String, String>> discover() async {
    final response = await _api.get(ApiEndpoints.discover);
    if (!response.isSuccess) throw Exception(response.errorMessage);
    return Map<String, String>.from(response.data);
  }
}
