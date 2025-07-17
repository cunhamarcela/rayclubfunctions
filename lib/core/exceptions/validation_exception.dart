import 'app_exception.dart';

/// Exceção específica para erros de validação de dados.
/// Estende AppException para manter a padronização de erros.
class ValidationException extends AppException {
  const ValidationException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'validation_error',
          details: details,
        );
} 