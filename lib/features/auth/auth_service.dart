import '../../core/api_client.dart';
import '../../core/api_response.dart';
import '../../core/storage.dart';
import 'auth_models.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/v1/auth/login',

      data: {'email': email, 'password': password},
    );

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => AuthResponse.fromJson(data),
    );

    await AppStorage.saveToken(apiResponse.data.token);

    return apiResponse.data;
  }

  Future<User> me() async {
    final response = await _apiClient.get('/v1/auth/me');

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => User.fromJson(data),
    );

    return apiResponse.data;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/v1/auth/logout');
    } catch (_) {}

    await AppStorage.clearToken();
  }
}
