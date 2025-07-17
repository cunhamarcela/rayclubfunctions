/// Base class para todas as exceções do aplicativo.
/// Todas as exceções específicas devem estender esta classe.
class AppException implements Exception {
  /// Mensagem de erro
  final String message;
  
  /// Erro original que causou esta exceção
  final Object? originalError;
  
  /// Stack trace do erro
  final StackTrace? stackTrace;
  
  /// Código de erro opcional para identificação
  final String? code;
  
  /// Construtor padrão
  const AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.code,
  });
  
  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Exceção para erros de rede
class NetworkException extends AppException {
  /// Código de status HTTP, se disponível
  final int? statusCode;
  
  /// Construtor padrão
  NetworkException({
    required String message,
    this.statusCode,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'NETWORK_ERROR',
        );
  
  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException [$code, status: $statusCode]: $message';
    }
    return 'NetworkException [$code]: $message';
  }
}

/// Exceção para erros de autenticação
class AuthException extends AppException {
  /// Construtor padrão
  AuthException({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'AUTH_ERROR',
        );
}

/// Exceção para erros de armazenamento
class StorageException extends AppException {
  /// Construtor padrão
  StorageException({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'STORAGE_ERROR',
        );
}

/// Alias para StorageException para evitar conflitos com outras bibliotecas
typedef AppStorageException = StorageException;

/// Exceção para erros de validação
class ValidationException extends AppException {
  /// Campo que falhou na validação
  final String? field;
  
  /// Construtor padrão
  ValidationException({
    required String message,
    this.field,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'VALIDATION_ERROR',
        );
  
  @override
  String toString() {
    if (field != null) {
      return 'ValidationException [$code, field: $field]: $message';
    }
    return 'ValidationException [$code]: $message';
  }
}

/// Exceção para erros não tratados
class UnexpectedException extends AppException {
  /// Construtor padrão
  UnexpectedException({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message ?? 'Ocorreu um erro inesperado',
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'UNEXPECTED_ERROR',
        );
}

/// Exceção para operações não suportadas
class UnsupportedException extends AppException {
  /// Construtor padrão
  UnsupportedException({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'UNSUPPORTED_OPERATION',
        );
}

/// Exceção para operações de permissão negada
class PermissionDeniedException extends AppException {
  /// Construtor padrão
  PermissionDeniedException({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: code ?? 'PERMISSION_DENIED',
        );
}

/// Authentication related exceptions
class AppAuthException extends AppException {
  const AppAuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Resource not found exceptions
class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Not found exceptions - use this when a specific resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception for features not implemented yet
class NotImplementedException extends AppException {
  const NotImplementedException({
    String message = 'This feature is not implemented yet',
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception related to file validation
class FileValidationException extends AppException {
  const FileValidationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception for authorization failures (access denied, insufficient permissions)
class AuthorizationException extends AppException {
  const AuthorizationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'AUTHORIZATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Unauthorized access exception
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'unauthorized',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Exception for timeout/operation taking too long
class TimeoutException extends AppException {
  const TimeoutException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'TIMEOUT_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
} 