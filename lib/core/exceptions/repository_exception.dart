/// Base exception class for repository-related errors
abstract class RepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  RepositoryException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'RepositoryException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a requested resource is not found
class ResourceNotFoundException extends RepositoryException {
  ResourceNotFoundException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when there's a validation error
class ValidationException extends RepositoryException {
  ValidationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when there's an authentication error
class AuthenticationException extends RepositoryException {
  AuthenticationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when there's a network error
class NetworkException extends RepositoryException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when there's a database error
class DatabaseException extends RepositoryException {
  DatabaseException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}
