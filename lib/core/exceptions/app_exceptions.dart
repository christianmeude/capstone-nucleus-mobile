/// Base exception class for the app
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException(this.message, {this.code, this.originalException});

  @override
  String toString() => message;
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalException});
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
      : super('Invalid email or password', code: 'INVALID_CREDENTIALS');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException()
      : super('User not found', code: 'USER_NOT_FOUND');
}

class UserAlreadyExistsException extends AuthException {
  UserAlreadyExistsException()
      : super('User already exists', code: 'USER_EXISTS');
}

class SessionExpiredException extends AuthException {
  SessionExpiredException()
      : super('Session expired. Please login again.', code: 'SESSION_EXPIRED');
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalException});
}

class NoInternetException extends NetworkException {
  NoInternetException()
      : super('No internet connection', code: 'NO_INTERNET');
}

class ServerException extends NetworkException {
  ServerException([String? message])
      : super(message ?? 'Server error occurred', code: 'SERVER_ERROR');
}

/// Data related exceptions
class DataException extends AppException {
  DataException(super.message, {super.code, super.originalException});
}

class NotFoundException extends DataException {
  NotFoundException([String? message])
      : super(message ?? 'Resource not found', code: 'NOT_FOUND');
}

class ValidationException extends DataException {
  ValidationException(super.message) : super(code: 'VALIDATION_ERROR');
}

/// File related exceptions
class FileException extends AppException {
  FileException(super.message, {super.code, super.originalException});
}

class FileTooLargeException extends FileException {
  FileTooLargeException([int? maxSizeMB])
      : super('File size exceeds ${maxSizeMB ?? 10}MB limit', code: 'FILE_TOO_LARGE');
}

class InvalidFileTypeException extends FileException {
  InvalidFileTypeException([List<String>? allowed])
      : super('Invalid file type. Allowed: ${allowed?.join(", ") ?? "PDF"}',
            code: 'INVALID_FILE_TYPE');
}
