abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Network error. Check your connection.']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({String message = 'Server error.', this.statusCode})
      : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Record not found.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication required.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error.']);
}

// Exceptions (thrown in data layer, caught and converted to Failures)
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error.']);
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Server error.', this.statusCode});
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Auth error.']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error.']);
}
