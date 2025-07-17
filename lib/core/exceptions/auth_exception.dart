import 'app_exception.dart';

/// Exceção específica para erros de autenticação.
/// Estende AppException para manter a padronização de erros.
class AppAuthException extends AppException {
  const AppAuthException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'auth_error',
          details: details,
        );
} 