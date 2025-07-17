import 'app_exception.dart';

/// Exceção específica para recursos não encontrados.
/// Estende AppException para manter a padronização de erros.
class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'resource_not_found',
          details: details,
        );
} 