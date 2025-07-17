import 'app_exception.dart';

/// Exceção específica para erros de operações de banco de dados.
/// Estende AppException para manter a padronização de erros.
class DatabaseException extends AppException {
  const DatabaseException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'database_error',
          details: details,
        );
} 