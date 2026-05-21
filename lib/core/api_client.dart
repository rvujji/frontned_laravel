import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'constants.dart';
import 'storage.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),

        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppStorage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('REQUEST => ${options.method} ${options.path}');
          print('DATA => ${options.data}');

          handler.next(options);
        },

        onResponse: (response, handler) {
          print('RESPONSE => ${response.statusCode}');
          print('BODY => ${response.data}');

          handler.next(response);
        },

        onError: (DioException error, handler) {
          print('ERROR => ${error.response?.statusCode}');
          print('MESSAGE => ${error.message}');

          handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 401:
        return UnauthorizedException('Unauthorized');

      case 422:
        return ValidationException('Validation failed');

      case 500:
        return ServerException('Server error');

      default:
        return NetworkException(error.message ?? 'Something went wrong');
    }
  }
}
