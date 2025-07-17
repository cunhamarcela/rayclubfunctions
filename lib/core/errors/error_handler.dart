// Flutter imports:
import "package:flutter/foundation.dart";
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException, AuthException;
import 'package:gotrue/src/types/auth_exception.dart' as supabase_auth;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/providers/service_providers.dart';
import 'package:ray_club_app/core/services/logging_service.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import '../services/connectivity_service.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../router/app_router.dart';
import '../localization/app_strings.dart';
import 'error_logger.dart';

/// Utilitário para classificação de erros
class ErrorClassifier {
  /// Classifica um erro como exceção do app baseado em seu conteúdo
  static AppException classifyError(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      return error;
    }
    
    // Categorizar com base em padrões de erro comuns
    final String errorString = error.toString().toLowerCase();
    
    // Handle network errors
    if (_isNetworkError(errorString)) {
      return NetworkException(
        message: 'A conexão falhou. Verifique sua internet.',
        originalError: error,
        stackTrace: stackTrace,
        code: _extractErrorCode(errorString),
      );
    }
    
    // Handle authentication errors
    if (_isAuthError(errorString)) {
      return AppAuthException(
        message: 'Erro de autenticação. Faça login novamente.',
        originalError: error,
        stackTrace: stackTrace,
        code: _extractErrorCode(errorString),
      );
    }
    
    // Handle storage errors
    if (_isStorageError(errorString)) {
      return StorageException(
        message: 'Erro de armazenamento. Tente novamente mais tarde.',
        originalError: error,
        stackTrace: stackTrace,
        code: _extractErrorCode(errorString),
      );
    }
    
    // Handle validation errors
    if (_isValidationError(errorString)) {
      return ValidationException(
        message: 'Dados inválidos. Verifique os campos informados.',
        originalError: error,
        stackTrace: stackTrace,
        code: _extractErrorCode(errorString),
      );
    }
    
    // Default to generic AppException
    return AppException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Verifica se o erro é relacionado a rede
  static bool _isNetworkError(String errorString) {
    return errorString.contains('socketexception') ||
           errorString.contains('connection refused') ||
           errorString.contains('network') ||
           errorString.contains('timeout') ||
           errorString.contains('certificate') ||
           errorString.contains('handshake') ||
           errorString.contains('host') ||
           errorString.contains('address');
  }
  
  /// Verifica se o erro é relacionado a autenticação
  static bool _isAuthError(String errorString) {
    return errorString.contains('authentication') ||
           errorString.contains('unauthorized') ||
           errorString.contains('forbidden') ||
           errorString.contains('permission') ||
           errorString.contains('token') ||
           errorString.contains('credential') ||
           errorString.contains('login') ||
           errorString.contains('password') ||
           errorString.contains('auth');
  }
  
  /// Verifica se o erro é relacionado a armazenamento
  static bool _isStorageError(String errorString) {
    return errorString.contains('storage') ||
           errorString.contains('file') ||
           errorString.contains('bucket') ||
           errorString.contains('upload') ||
           errorString.contains('download') ||
           errorString.contains('io error');
  }
  
  /// Verifica se o erro é relacionado a validação
  static bool _isValidationError(String errorString) {
    return errorString.contains('validation') ||
           errorString.contains('invalid') ||
           errorString.contains('required') ||
           errorString.contains('format') ||
           errorString.contains('constraint') ||
           errorString.contains('not null');
  }
  
  /// Attempts to extract an error code from the error message
  static String? _extractErrorCode(String errorString) {
    // Check for common error code patterns
    final RegExp codeRegex = RegExp(r'code[\s:]+([a-zA-Z0-9_-]+)', caseSensitive: false);
    final match = codeRegex.firstMatch(errorString);
    
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }
}

/// Global error handler for Riverpod providers
class AppProviderObserver extends ProviderObserver {
  ProviderContainer? _container;

  AppProviderObserver();

  /// Define o container a ser usado pelo observer para ler providers
  void setContainer(ProviderContainer container) {
    _container = container;
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Convert to AppException if needed using unified error classifier
    final appError = ErrorClassifier.classifyError(error, stackTrace);
    
    // Log the error
    LogUtils.error(
      'Provider error: ${provider.name ?? provider.runtimeType}',
      error: appError,
      stackTrace: appError.stackTrace ?? stackTrace,
    );
    
    // Send to remote logging service if available
    if (_container != null) {
      _sendToRemoteLogging(
        'Provider error: ${provider.name ?? provider.runtimeType}',
        appError,
        appError.stackTrace ?? stackTrace,
        {'providerType': provider.runtimeType.toString()},
      );
    } else {
      LogUtils.warning(
        'Container não configurado no AppProviderObserver',
        tag: 'AppProviderObserver',
      );
    }
    
    super.providerDidFail(provider, error, stackTrace, container);
  }
  
  /// Sends error to remote logging service
  void _sendToRemoteLogging(
    String message,
    AppException error,
    StackTrace stackTrace,
    [Map<String, dynamic>? metadata]
  ) {
    try {
      // Evitar potencial recursão ao detectar erros do próprio sistema de logging
      if (error.message.contains('remoteLoggingService') || 
          (error.originalError != null && error.originalError.toString().contains('remoteLoggingService'))) {
        LogUtils.warning(
          'Evitando recursão potencial no log remoto',
          tag: 'AppProviderObserver',
          data: {'errorType': error.runtimeType.toString()},
        );
        return;
      }
      
      final remoteLoggingService = _container?.read(remoteLoggingServiceProvider);
      remoteLoggingService?.logError(
        error,
        stackTrace,
        context: message,
      );
    } catch (e) {
      // Fallback to local logging if remote logging fails
      LogUtils.warning(
        'Falha ao enviar erro para serviço remoto',
        tag: 'AppProviderObserver',
        data: {'erro': e.toString()},
      );
    }
  }
}

/// Global error handler for the app
class ErrorHandler {
  final LoggingService? _remoteLoggingService;
  static final String _dsn = "https://864abbf5a50b211bb3f1d2d3f6710824@o4509136169533440.ingest.de.sentry.io/4509136170713168";
  
  // Instância singleton para uso estático
  static ErrorHandler? _instance;
  
  /// Construtor que injeta o serviço de logging opcional
  ErrorHandler({LoggingService? remoteLoggingService}) 
      : _remoteLoggingService = remoteLoggingService;
  
  /// Provider para o serviço de tratamento de erros
  static final provider = Provider<ErrorHandler>((ref) {
    final loggingService = ref.watch(remoteLoggingServiceProvider);
    return ErrorHandler(remoteLoggingService: loggingService);
  });
  
  /// Inicializa o Sentry com as configurações adequadas
  static Future<void> initializeSentry({
    required Future<void> Function() appRunner,
    double? tracesSampleRate,
    double? profilesSampleRate,
  }) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.tracesSampleRate = tracesSampleRate ?? 1.0;
        options.profilesSampleRate = profilesSampleRate ?? 1.0;
        options.environment = kReleaseMode ? 'production' : 'development';
        options.attachScreenshot = true;
        options.enableAutoSessionTracking = true;
        
        // Habilitar captura automática de exceções não tratadas
        options.autoAppStart = true;
        
        // Capturar spans automáticos em operações de rede e UI
        options.enableAutoPerformanceTracing = true;
      },
      appRunner: appRunner,
    );
  }
  
  /// Manipula e classifica um erro
  AppException handle(dynamic error, [StackTrace? stackTrace]) {
    // Converte o erro para AppException
    final appError = _classifyError(error, stackTrace ?? StackTrace.current);
    
    // Loga o erro no console
    _logError(appError);
    
    // Envia o erro para o serviço de logging remoto, se disponível
    _remoteLoggingService?.logError(
      appError.originalError ?? appError,
      appError.stackTrace ?? stackTrace,
      context: 'Erro tratado pelo ErrorHandler: ${appError.message}'
    );
    
    // Captura o erro também diretamente no Sentry
    _captureInSentry(appError);
    
    // Registra o erro no log de erros Markdown
    _logToMarkdown(appError);
    
    return appError;
  }
  
  /// Captura o erro diretamente no Sentry, mesmo se o RemoteLoggingService falhar
  void _captureInSentry(AppException error) {
    try {
      Sentry.captureException(
        error.originalError ?? error,
        stackTrace: error.stackTrace,
        withScope: (scope) {
          scope.setTag('error_type', error.runtimeType.toString());
          if (error.code != null) {
            scope.setTag('error_code', error.code!);
          }
        },
      );
    } catch (e) {
      // Ignore erros na captura para evitar loops
      if (kDebugMode) {
        print('Erro ao capturar exceção no Sentry: $e');
      }
    }
  }
  
  /// Registra o erro no arquivo Markdown de log
  void _logToMarkdown(AppException error) {
    try {
      // Tentar determinar a localização do erro a partir do stack trace
      String location = 'Localização desconhecida';
      if (error.stackTrace != null) {
        final stackLines = error.stackTrace.toString().split('\n');
        for (final line in stackLines) {
          if (line.contains('/lib/') && !line.contains('/flutter/') && !line.contains('/dart-sdk/')) {
            // Extrair a parte relevante da linha de stack
            final match = RegExp(r'lib\/([^\s\(\)]+)').firstMatch(line);
            if (match != null && match.groupCount >= 1) {
              location = 'lib/${match.group(1)}';
              break;
            }
          }
        }
      }
      
      // Registrar no log
      ErrorLogger.logError(
        error,
        location: location,
        stackTrace: error.stackTrace,
      );
    } catch (e) {
      // Não propagar erros do logging para evitar loops
      if (kDebugMode) {
        print('Erro ao registrar no log Markdown: $e');
      }
    }
  }
  
  /// Retorna uma mensagem amigável para o usuário com base no tipo de erro
  String getUserFriendlyMessage(AppException error) {
    if (error is NetworkException) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        return AppStrings.unauthorizedError;
      } else if (error.statusCode == 500) {
        return AppStrings.serverError;
      } else {
        return AppStrings.networkError;
      }
    } else if (error is AuthException) {
      return AppStrings.invalidCredentials;
    } else if (error is ValidationException) {
      if (error.field != null) {
        return '${error.field}: ${error.message}';
      }
      return error.message;
    } else if (error is StorageException) {
      return AppStrings.serverError;
    } else {
      return AppStrings.somethingWentWrong;
    }
  }
  
  /// Verifica se o erro é crítico e requer intervenção imediata
  static bool isCriticalError(AppException exception) {
    // Erros que impedem o funcionamento principal do app
    if (exception is DatabaseException && 
        (exception.code?.contains('connection') ?? false)) {
      return true;
    }
    
    // Erros de autenticação que afetam todo o app
    if (exception is AppAuthException &&
        (exception.code == 'session_expired' || exception.code == 'not_authenticated')) {
      return true;
    }
    
    // Erros relacionados a problemas de permissão
    if (exception.message.toLowerCase().contains('permission denied') ||
        (exception.code?.toLowerCase().contains('permission') ?? false)) {
      return true;
    }
    
    return false;
  }
  
  /// Fornece uma ação recomendada para resolver o erro
  static String? getRecommendedAction(AppException exception) {
    if (exception is NetworkException) {
      return 'Verifique sua conexão com a internet e tente novamente.';
    }
    
    if (exception is AppAuthException) {
      if (exception.code == 'session_expired') {
        return 'Sua sessão expirou. Faça login novamente.';
      }
      return 'Faça login novamente para continuar.';
    }
    
    if (exception is ValidationException) {
      return 'Verifique os dados informados e tente novamente.';
    }
    
    if (exception is DatabaseException) {
      return 'Tente novamente mais tarde. Se o problema persistir, contate o suporte.';
    }
    
    if (exception is StorageException) {
      return 'Verifique o espaço disponível no seu dispositivo.';
    }
    
    // Erro genérico
    return 'Tente novamente. Se o problema persistir, reinicie o aplicativo.';
  }
  
  /// Tenta recuperar de um erro automaticamente, se possível
  static Future<bool> attemptRecovery(AppException exception, {required ProviderContainer container}) async {
    try {
      if (exception is NetworkException) {
        // Verificar conectividade antes de tentar recuperar
        final connectivityService = container.read(connectivityServiceProvider);
        final hasConnection = await connectivityService.hasConnection();
        if (!hasConnection) {
          LogUtils.info('Sem conexão, impossível recuperar automaticamente',
            tag: 'ErrorRecovery',
          );
          return false;
        }
      }
      
      if (exception is AppAuthException && exception.code == 'session_expired') {
        // Tentar renovar a sessão
        final authRepository = container.read(authRepositoryProvider);
        try {
          await authRepository.refreshSession();
          return true;
        } catch (e) {
          LogUtils.warning('Falha ao renovar sessão', 
            tag: 'ErrorRecovery',
            data: e,
          );
          return false;
        }
      }
      
      return false;
    } catch (e) {
      LogUtils.error('Erro durante tentativa de recuperação', 
        tag: 'ErrorRecovery',
        error: e,
      );
      return false;
    }
  }
  
  /// Mapeia um status HTTP para um código e mensagem mais amigável
  static Map<String, String> mapHttpStatusToMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return {'code': 'bad_request', 'message': 'Requisição inválida.'};
      case 401:
        return {'code': 'unauthorized', 'message': 'Não autorizado. Faça login novamente.'};
      case 403:
        return {'code': 'forbidden', 'message': 'Acesso negado.'};
      case 404:
        return {'code': 'not_found', 'message': 'Recurso não encontrado.'};
      case 408:
        return {'code': 'timeout', 'message': 'Tempo de resposta excedido.'};
      case 409:
        return {'code': 'conflict', 'message': 'Conflito de dados.'};
      case 422:
        return {'code': 'validation_error', 'message': 'Dados inválidos.'};
      case 429:
        return {'code': 'too_many_requests', 'message': 'Muitas requisições. Tente mais tarde.'};
      case 500:
        return {'code': 'server_error', 'message': 'Erro no servidor.'};
      case 502:
        return {'code': 'bad_gateway', 'message': 'Serviço temporariamente indisponível.'};
      case 503:
        return {'code': 'service_unavailable', 'message': 'Serviço indisponível.'};
      case 504:
        return {'code': 'gateway_timeout', 'message': 'Tempo de resposta do servidor excedido.'};
      default:
        return {
          'code': 'http_error_$statusCode',
          'message': 'Erro de comunicação (código $statusCode).'
        };
    }
  }
  
  /// Classifica o erro original em um AppException apropriado
  AppException _classifyError(dynamic error, StackTrace stackTrace) {
    // Se já for AppException, retorna
    if (error is AppException) {
      return error;
    }
    
    // Classificar de acordo com o tipo
    if (error is DioError) {
      return _handleDioError(error, stackTrace);
    } else if (error is PostgrestException) {
      return _handleSupabaseError(error, stackTrace);
    } else if (error is supabase_auth.AuthException) {
      return AuthException(
        message: error.message,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is FormatException) {
      return ValidationException(
        message: 'Erro de formato: ${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is TypeError) {
      return ValidationException(
        message: 'Erro de tipo: ${error.toString()}',
        originalError: error,
        stackTrace: stackTrace,
      );
    } else {
      // Para erros não reconhecidos
      final errorMessage = error?.toString() ?? 'Erro desconhecido';
      return UnexpectedException(
        message: errorMessage,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Trata erros específicos do Dio
  NetworkException _handleDioError(DioError error, StackTrace stackTrace) {
    String message = 'Erro de rede';
    int? statusCode;
    
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        message = 'Tempo de conexão esgotado';
        break;
      case DioErrorType.sendTimeout:
        message = 'Tempo de envio esgotado';
        break;
      case DioErrorType.receiveTimeout:
        message = 'Tempo de recebimento esgotado';
        break;
      case DioErrorType.badResponse:
        statusCode = error.response?.statusCode;
        message = _getMessageFromStatusCode(statusCode);
        break;
      case DioErrorType.cancel:
        message = 'Requisição cancelada';
        break;
      default:
        message = 'Erro de rede: ${error.message}';
        break;
    }
    
    return NetworkException(
      message: message,
      statusCode: statusCode,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Trata erros específicos do Supabase
  AppException _handleSupabaseError(PostgrestException error, StackTrace stackTrace) {
    // Códigos de erro do PostgreSQL/Supabase
    if (error.code == 'PGRST301' || error.code == '401') {
      return AuthException(
        message: 'Não autorizado: ${error.message}',
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error.code == 'PGRST116' || error.code?.contains('42P01') == true) {
      return StorageException(
        message: 'Tabela não existe: ${error.message}',
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error.code?.startsWith('23') == true) {
      return ValidationException(
        message: 'Erro de validação: ${error.message}',
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else {
      return StorageException(
        message: 'Erro ao acessar dados: ${error.message}',
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Retorna uma mensagem com base no código de status HTTP
  String _getMessageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida';
      case 401:
        return 'Não autorizado';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 500:
      case 501:
      case 502:
      case 503:
        return 'Erro no servidor';
      default:
        return 'Erro de rede (código $statusCode)';
    }
  }
  
  /// Loga o erro no console
  void _logError(AppException error) {
    if (kDebugMode) {
      print('🔴 [ERROR] ${error.toString()}');
      if (error.originalError != null) {
        print('Original error: ${error.originalError}');
      }
      if (error.stackTrace != null) {
        print('Stack trace: ${error.stackTrace}');
      }
    }
  }

  /// Define o serviço de logging remoto a ser usado pelo handler
  static void setRemoteLoggingService(LoggingService service) {
    _instance = ErrorHandler(remoteLoggingService: service);
    LogUtils.info('Serviço de logging remoto configurado', tag: 'ErrorHandler');
  }
}

/// Observer de erros para provedores Riverpod
class ErrorObserver extends ProviderObserver {
  final ErrorHandler _errorHandler;
  
  /// Construtor
  ErrorObserver(this._errorHandler);
  
  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Trata o erro quando um provider falha
    final appError = _errorHandler.handle(error, stackTrace);
    
    // Log adicional específico para falhas em providers
    if (kDebugMode) {
      print('🔴 Provider falhou: ${provider.name ?? provider.runtimeType}');
      print('Erro tratado: ${appError.message}');
    }
  }
}

/// Provider global para o ErrorHandler
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});
