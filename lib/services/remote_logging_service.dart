// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/di/base_service.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/core/services/logging_service.dart';
import 'package:ray_club_app/utils/uuid_extensions.dart';

/// Serviço responsável por enviar logs para um serviço remoto
class RemoteLoggingService implements BaseService, LoggingService {
  static const String _logTag = 'RemoteLoggingService';
  
  final Dio _dio;
  final String _apiKey;
  final String _endpoint;
  final bool _enabled;
  bool _initialized = false;
  
  /// Cria uma instância do serviço de log remoto
  /// 
  /// Validação das variáveis de ambiente é feita durante a inicialização,
  /// não no construtor, para permitir a injeção de dependência em testes.
  RemoteLoggingService({Dio? dio})
      : _dio = dio ?? Dio(),
        _apiKey = dotenv.env['REMOTE_LOGGING_API_KEY'] ?? '',
        _endpoint = dotenv.env['REMOTE_LOGGING_ENDPOINT'] ?? '',
        _enabled = dotenv.env['ENABLE_REMOTE_LOGGING'] == 'true';
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  Future<void> initialize() async {
    // Validar se o logging remoto está habilitado
    if (!_enabled) {
      LogUtils.info(
        'Serviço de log remoto desabilitado por configuração',
        tag: _logTag,
      );
      return;
    }
    
    // Validar API key
    if (_apiKey.isEmpty) {
      LogUtils.warning(
        'API key para logging remoto não configurada. Verifique a variável REMOTE_LOGGING_API_KEY',
        tag: _logTag,
      );
      return;
    }
    
    // Validar endpoint
    if (_endpoint.isEmpty) {
      LogUtils.warning(
        'Endpoint para logging remoto não configurado. Verifique a variável REMOTE_LOGGING_ENDPOINT',
        tag: _logTag,
      );
      return;
    }
    
    try {
      // Configurar interceptors do Dio
      _dio.interceptors.add(InterceptorsWrapper(
        onError: (error, handler) {
          LogUtils.error(
            'Erro ao enviar log remoto',
            tag: _logTag,
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ));
      
      // Configurar timeouts mais adequados
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status >= 200 && status < 400;
        },
      );
      
      // Validar conexão com endpoint (opcional)
      try {
        final response = await _dio.get(_endpoint, 
          queryParameters: {'test': 'connection'},
          options: Options(
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );
        
        if (response.statusCode == 200) {
          LogUtils.info('Conexão com serviço de log remoto validada', tag: _logTag);
        }
      } catch (e) {
        // Apenas log de aviso, não impede a inicialização
        LogUtils.warning(
          'Não foi possível validar conexão com serviço de log remoto',
          tag: _logTag,
          data: {'erro': e.toString()},
        );
      }
      
      _initialized = true;
      LogUtils.info('Serviço de log remoto inicializado', tag: _logTag);
    } catch (e) {
      LogUtils.error(
        'Erro ao inicializar serviço de log remoto',
        tag: _logTag,
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }
  
  /// Envia um log de erro para o serviço remoto
  Future<void> logErrorInternal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_enabled || !_initialized || _apiKey.isEmpty || _endpoint.isEmpty) {
      return;
    }
    
    try {
      // Enviar para o Sentry, se estiver disponível
      await _sendToSentry(message, error, stackTrace, metadata);
      
      // Determinar o nível de severidade com base no tipo de erro
      final String severity = _getSeverityFromError(error);
      
      // Sanitizar dados de logs para reduzir exposição de informações sensíveis
      final Map<String, dynamic> logPayload = {
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'tag': tag ?? _logTag,
        'severity': severity,
        // Limitamos as informações do erro e stack trace para reduzir exposição
        'errorType': error != null ? error.runtimeType.toString() : null,
        'errorSummary': error?.toString()?.substring(0, 
          error.toString().length > 200 ? 200 : error.toString().length),
        // Enviamos somente parte do stack trace com informações pertinentes
        'stackTracePreview': _sanitizeStackTrace(stackTrace),
        'metadata': _sanitizeMetadata(metadata ?? {}),
        'appInfo': await _getAppInfo(),
      };
      
      // Enviar para o serviço remoto de forma assíncrona
      // Não aguardamos a resposta para não bloquear a UI
      _dio.post(
        _endpoint,
        data: jsonEncode(logPayload),
      ).then((_) {
        LogUtils.debug('Log enviado com sucesso', tag: _logTag);
      }).catchError((e) {
        LogUtils.warning(
          'Falha ao enviar log remoto',
          tag: _logTag,
          data: {'erro': e.toString()},
        );
      });
    } catch (e) {
      // Apenas registra localmente falhas no envio de logs
      LogUtils.warning(
        'Erro ao preparar log remoto',
        tag: _logTag,
        data: {'erro': e.toString()},
      );
    }
  }
  
  /// Envia um erro para o Sentry
  Future<void> _sendToSentry(
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      if (error == null) {
        // Se não houver erro específico, capturar apenas a mensagem
        await Sentry.captureMessage(
          message,
          level: _getSentryLevel(error),
        );
        return;
      }
      
      // Capturar a exceção com contexto
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          // Adicionar tags e metadados ao escopo
          scope.setTag('source', _logTag);
          scope.setTag('message', message);
          
          // Adicionar metadados extras
          if (metadata != null) {
            // Sanitizar metadados para remover dados sensíveis
            final sanitizedMetadata = _sanitizeMetadata(metadata);
            sanitizedMetadata.forEach((key, value) {
              scope.setExtra(key, value);
            });
          }
          
          // Adicionar informações do app
          _getAppInfo().then((appInfo) {
            appInfo.forEach((key, value) {
              scope.setExtra(key, value);
            });
          });
        },
      );
    } catch (e) {
      // Falhar silenciosamente para não interromper o fluxo principal
      LogUtils.warning(
        'Falha ao enviar erro para o Sentry',
        tag: _logTag,
        data: {'erro': e.toString()},
      );
    }
  }
  
  /// Converte a severidade interna para os níveis do Sentry
  SentryLevel _getSentryLevel(Object? error) {
    if (error is AppException) {
      if (error is ValidationException) return SentryLevel.warning;
      if (error is NetworkException) return SentryLevel.warning;
      if (error is AppAuthException) return SentryLevel.warning;
      if (error is StorageException) return SentryLevel.warning;
      return SentryLevel.error;
    }
    
    return SentryLevel.error;
  }
  
  /// Sanitiza o stack trace para remover informações sensíveis
  String? _sanitizeStackTrace(StackTrace? stackTrace) {
    if (stackTrace == null) return null;
    
    final String strTrace = stackTrace.toString();
    final List<String> lines = strTrace.split('\n');
    
    // Limite a 10 linhas para reduzir tamanho e exposição
    final shortTrace = lines.take(10).join('\n');
    
    return shortTrace;
  }
  
  /// Sanitiza metadata para remover dados sensíveis
  Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic> metadata) {
    final sanitized = <String, dynamic>{};
    
    metadata.forEach((key, value) {
      // Evitar envio de dados sensíveis como tokens, senhas, etc.
      if (key.toLowerCase().contains('token') || 
          key.toLowerCase().contains('password') ||
          key.toLowerCase().contains('secret') ||
          key.toLowerCase().contains('key')) {
        sanitized[key] = '[REDACTED]';
      } else if (value is String && value.length > 500) {
        // Limitar tamanho de valores string
        sanitized[key] = '${value.substring(0, 500)}...';
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }
  
  /// Determina a severidade com base no tipo de erro
  String _getSeverityFromError(Object? error) {
    if (error is AppException) {
      if (error is NetworkException) return 'warning';
      if (error is AppAuthException) return 'warning';
      if (error is StorageException) return 'warning';
      if (error is ValidationException) return 'info';
      return 'error';
    }
    
    return 'error';
  }
  
  /// Obtém informações adicionais sobre o ambiente da aplicação
  Future<Map<String, dynamic>> _getAppInfo() async {
    // Em uma implementação real, você pode adicionar mais informações
    // como versão do app, dispositivo, sistema operacional, etc.
    return {
      'appVersion': dotenv.env['APP_VERSION'] ?? 'unknown',
      'environment': dotenv.env['ENVIRONMENT'] ?? 'development',
    };
  }
  
  /// Loga uma métrica de desempenho no serviço remoto
  @override
  Future<void> logMetric({
    required String metricName,
    required double value,
    String? unit,
    Map<String, String>? dimensions,
  }) async {
    if (!_initialized) {
      return;
    }
    
    try {
      // Preparar dados da métrica
      final metric = {
        'name': metricName,
        'value': value,
        'unit': unit ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'environment': dotenv.env['ENVIRONMENT'] ?? 'development',
        'app_version': dotenv.env['APP_VERSION'] ?? 'unknown',
        'platform': defaultTargetPlatform.toString(),
      };
      
      if (dimensions != null) {
        metric['dimensions'] = dimensions;
      }
      
      // Em ambiente de desenvolvimento, apenas logar localmente
      if (kDebugMode) {
        LogUtils.debug(
          'Métrica: $metricName = $value $unit',
          tag: _logTag,
          data: metric,
        );
        return;
      }
      
      // Enviar para o endpoint de métricas
      await _dio.post(
        _endpoint,
        data: jsonEncode(metric),
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Falhar silenciosamente em erro de telemetria para não interromper o aplicativo
      LogUtils.warning(
        'Falha ao enviar métrica para o serviço remoto',
        tag: _logTag,
        data: {'metric': metricName, 'error': e.toString()},
      );
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
    _dio.close();
  }

  /// Implementação da interface LoggingService.logError
  @override
  Future<void> logError(dynamic error, StackTrace? stackTrace, {String? context}) async {
    // Adaptação para chamar a implementação interna com a assinatura correta
    await logErrorInternal(
      context ?? 'Erro não categorizado',
      error: error,
      stackTrace: stackTrace, 
      tag: 'LoggingService',
    );
  }

  @override
  Future<void> logEvent(String event, {Map<String, dynamic>? parameters}) async {
    if (!_enabled || !_initialized || _apiKey.isEmpty || _endpoint.isEmpty) {
      if (!kReleaseMode) {
        debugPrint('EVENT: $event ${parameters ?? ''}');
      }
      return;
    }

    try {
      // Validar UUIDs em parâmetros conhecidos
      final Map<String, dynamic> validatedParams = {};
      
      // Copiar parâmetros originais
      if (parameters != null) {
        validatedParams.addAll(parameters);
        
        // Validar campos conhecidos que são UUIDs
        final uuidFields = [
          'userId', 'user_id',
          'challengeId', 'challenge_id',
          'workoutId', 'workout_id',
          'groupId', 'group_id',
          'id', 'benefitId', 'eventId'
        ];
        
        for (final field in uuidFields) {
          if (validatedParams.containsKey(field) && validatedParams[field] is String) {
            validatedParams[field] = (validatedParams[field] as String).toValidUuid();
          }
        }
      }
      
      final Map<String, dynamic> logPayload = {
        'message': event,
        'timestamp': DateTime.now().toIso8601String(),
        'tag': 'Event',
        'severity': 'info',
        'metadata': _sanitizeMetadata(validatedParams),
        'appInfo': await _getAppInfo(),
      };
      
      // Enviar para o serviço remoto de forma assíncrona
      _dio.post(
        _endpoint,
        data: jsonEncode(logPayload),
      ).then((_) {
        LogUtils.debug('Evento enviado com sucesso', tag: _logTag);
      }).catchError((e) {
        LogUtils.warning(
          'Falha ao enviar evento',
          tag: _logTag,
          data: {'erro': e.toString()},
        );
      });
    } catch (e) {
      LogUtils.warning(
        'Erro ao preparar evento para log remoto',
        tag: _logTag,
        data: {'erro': e.toString()},
      );
    }
  }
} 
