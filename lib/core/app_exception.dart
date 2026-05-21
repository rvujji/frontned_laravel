class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message);
}
