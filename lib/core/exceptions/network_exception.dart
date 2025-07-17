import 'app_exception.dart';

/// Exceção específica para erros de rede e comunicação.
/// Estende AppException para manter a padronização de erros.
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'network_error',
          details: details,
        );
} 