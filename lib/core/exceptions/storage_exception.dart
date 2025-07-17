import 'app_exception.dart';

/// Exceção específica para erros de armazenamento (storage).
/// Estende AppException para manter a padronização de erros.
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'storage_error',
          details: details,
        );
} 