/// Custom exception types for the King Win application.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(
      [super.message =
          'Network connectivity error. Please check your connection.']);
}

class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode]);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'Session expired. Please log in again.',
      super.statusCode = 401]);
}

class AccountBlockedException extends AppException {
  const AccountBlockedException(
      [super.message = 'ACCOUNT_BLOCKED', super.statusCode = 400]);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
