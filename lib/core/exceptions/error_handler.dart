// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'app_exception.dart';

/// Classe para padronizar o tratamento de exceções na aplicação
class AppError {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final bool isNetworkError;

  const AppError({
    required this.message,
    this.code,
    this.details,
    this.isNetworkError = false,
  });
}

/// Função para converter qualquer erro em um AppError padronizado
AppError handleError(dynamic error) {
  if (error is AppException) {
    return AppError(
      message: error.message,
      code: error.code,
      details: error.details,
    );
  }
  
  if (error is AuthException) {
    return AppError(
      message: error.message,
      code: 'auth_error',
      details: {'status': error.statusCode},
    );
  }
  
  if (error is PostgrestException) {
    return AppError(
      message: _getPostgrestErrorMessage(error),
      code: error.code,
      details: {
        'hint': error.hint,
        'status': error.code,
      },
    );
  }
  
  if (error is StorageException) {
    return AppError(
      message: 'Erro no serviço de armazenamento: ${error.message}',
      code: 'storage_error',
      details: {'status': error.statusCode},
    );
  }
  
  if (error is FormatException) {
    return AppError(
      message: 'Erro de formato: ${error.message}',
      code: 'format_error',
    );
  }
  
  // Erros genéricos
  return AppError(
    message: error?.toString() ?? 'Ocorreu um erro inesperado',
    code: 'unknown_error',
  );
}

/// Mensagens mais amigáveis para erros comuns do Postgrest
String _getPostgrestErrorMessage(PostgrestException error) {
  switch (error.code) {
    case '23505':
      return 'Este registro já existe no sistema.';
    case '23503':
      return 'Não é possível realizar esta operação pois o registro está sendo usado.';
    case '23514':
      return 'Os dados fornecidos não atendem às regras do sistema.';
    case '42703':
      return 'Coluna não encontrada na tabela.';
    case '42P01':
      return 'Tabela não encontrada no banco de dados.';
    case '22P02':
      return 'Formato de dados inválido.';
    case 'PGRST116':
      return 'Registro não encontrado.';
    default:
      if (error.message.contains('network')) {
        return 'Erro de conexão. Verifique sua internet.';
      }
      return error.message;
  }
} 