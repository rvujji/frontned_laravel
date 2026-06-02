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

  Future<AuthResponse> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      '/v1/auth/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response,
      (data) => AuthResponse.fromJson(data),
    );

    await AppStorage.saveToken(apiResponse.data.token);

    return apiResponse.data;
  }

  Future<bool> emailVerificationStatus() async {
    final response = await _apiClient.get('/v1/auth/email/status');

    return response['data']?['verified'] == true;
  }

  Future<void> resendVerificationEmail() async {
    await _apiClient.post('/v1/auth/email/resend');
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post('/v1/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiClient.post(
      '/v1/auth/reset-password',
      data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<void> verifyEmail({
    required String id,
    required String hash,
    required String expires,
    required String signature,
  }) async {
    await _apiClient.get(
      '/auth/email/verify/$id/$hash',
      queryParameters: {'expires': expires, 'signature': signature},
    );
  }

  Future<void> refreshCurrentUser() async {
    await me();
  }
}
