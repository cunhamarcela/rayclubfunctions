import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';
import '../providers/dio_provider.dart';
import '../providers/supabase_providers.dart';
import 'logging_service.dart';
import '../providers/service_providers.dart';

/// Serviço para tratamento centralizado de erros
class ErrorHandlerService {
  final LoggingService _loggingService;
  
  ErrorHandlerService(this._loggingService);
  
  /// Processa um erro e retorna uma mensagem amigável para o usuário
  Future<String> handleError(dynamic error, [StackTrace? stackTrace]) async {
    // Log do erro
    await _loggingService.logError(error, stackTrace);
    
    // Extrair a mensagem de erro apropriada para o usuário
    final message = _getUserFriendlyMessage(error);
    
    // Log para console em desenvolvimento
    if (kDebugMode) {
      debugPrint('🔴 Erro: $message');
      debugPrint('🔎 Detalhes: $error');
      if (stackTrace != null) {
        debugPrint('📊 StackTrace: $stackTrace');
      }
    }
    
    return message;
  }
  
  /// Extrai uma mensagem amigável para o usuário com base no tipo de erro
  String _getUserFriendlyMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Problema de conexão. Verifique sua internet e tente novamente.';
    }
    
    if (error is StorageException) {
      return 'Problema ao acessar dados. Tente novamente mais tarde.';
    }
    
    if (error is ValidationException) {
      return error.message;
    }
    
    if (error is NotFoundException) {
      return 'O item solicitado não foi encontrado.';
    }
    
    if (error is AppAuthException) {
      return 'Problema de autenticação. Faça login novamente.';
    }
    
    if (error is DatabaseException) {
      return 'Problema com o banco de dados. Tente novamente mais tarde.';
    }
    
    if (error is UnauthorizedException) {
      return 'Você não tem permissão para realizar esta ação.';
    }
    
    // Se não for um tipo específico, retornar uma mensagem genérica
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }
  
  /// Verifica se um erro é de autenticação
  bool isAuthError(dynamic error) {
    return error is AppAuthException || 
           error is UnauthorizedException ||
           (error is DatabaseException && error.code == 'PGRST401');
  }
}

/// Provider para o serviço de tratamento de erros
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  final remoteLoggingService = ref.watch(service_providers.remoteLoggingServiceProvider);
  return ErrorHandlerService(remoteLoggingService);
}); 