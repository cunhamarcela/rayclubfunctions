// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:logger/logger.dart';

// Project imports:
import 'package:ray_club_app/utils/debug_utils.dart';

/// Utilitário para logging de eventos e erros no aplicativo
class LogUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, 
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.verbose : Level.warning,
  );
  
  /// Registra uma mensagem informativa
  static void info(String message, {String? tag, Object? data}) {
    _logger.i({'tag': tag, 'message': message, 'data': data});
  }
  
  /// Registra uma mensagem de debug (apenas em modo debug)
  static void debug(String message, {String? tag, Object? data}) {
    _logger.d({'tag': tag, 'message': message, 'data': data});
  }
  
  /// Registra uma mensagem de warning
  static void warning(String message, {String? tag, Object? data}) {
    _logger.w({'tag': tag, 'message': message, 'data': data});
  }
  
  /// Registra um erro
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.e(
      {'tag': tag, 'message': message, 'error': error},
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Registra um erro crítico
  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.f(
      {'tag': tag, 'message': message, 'error': error},
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Função especializada para diagnóstico de erros relacionados a campos nulos
  /// sendo tratados como String
  static void diagnoseNullStringError(Object error, {
    required String context,
    required Map<String, dynamic> data,
    List<String>? fieldsToCheck,
  }) {
    if (error.toString().contains("type 'Null' is not a subtype of type 'String'")) {
      LogUtils.error('Detectado erro de NULL em campo String no contexto: $context', tag: 'DiagnoseError');
      
      try {
        // Análise avançada de estrutura JSON
        
        // Se houver campos específicos para verificar, focar neles
        if (fieldsToCheck != null && fieldsToCheck.isNotEmpty) {
          LogUtils.info('Verificando campos específicos em $context:', tag: 'DiagnoseError');
          
          // Verificar cada campo solicitado
          for (final field in fieldsToCheck) {
            final value = data[field];
            final runtimeType = value?.runtimeType.toString() ?? 'null';
            
            if (value == null) {
              LogUtils.error('⚠️ Campo "$field" é NULL - possível origem do erro', tag: 'DiagnoseError');
            } else {
              LogUtils.info('✅ Campo "$field": $value ($runtimeType)', tag: 'DiagnoseError');
            }
          }
        }
        
        // Sugerir correções
        LogUtils.info('🔧 Sugestões para correção:', tag: 'DiagnoseError');
        LogUtils.info('1. Use JsonUtils.getStringValue() em vez de "as String"', tag: 'DiagnoseError');
        LogUtils.info('2. Declare campos como String? em vez de String quando podem ser nulos', tag: 'DiagnoseError');
        LogUtils.info('3. Use operador de coalescência nula (??) para fornecer valores padrão', tag: 'DiagnoseError');
      } catch (diagnoseError) {
        LogUtils.error('Erro ao diagnosticar problema: $diagnoseError', tag: 'DiagnoseError');
      }
    }
  }
  
  /// Função especializada para diagnóstico de erros relacionados a tipos incompatíveis
  /// como DateTime sendo tratado como String ou vice-versa
  static void diagnoseTypeError(Object error, {
    String? context,
    Map<String, dynamic>? data,
    List<String>? fieldsToCheck,
  }) {
    final tag = 'TypeDiagnoseError';
    
    // Erros específicos de tipo DateTime vs String
    if (error.toString().contains("'DateTime' is not a subtype of type 'String'") || 
        error.toString().contains("type 'DateTime' is not a subtype of type 'String'")) {
      LogUtils.error('Detectado erro de tipo: valor DateTime usado onde String é esperada', tag: tag);
      
      try {
        if (data != null) {
          // Se houver campos específicos para verificar, focar neles
          final fields = fieldsToCheck ?? data.keys.toList();
          LogUtils.info('Verificando campos em ${context ?? "desconhecido"}:', tag: tag);
          
          for (final field in fields) {
            final value = data[field];
            final runtimeType = value?.runtimeType.toString() ?? 'null';
            
            if (value == null) {
              LogUtils.info('Campo "$field" é NULL', tag: tag);
            } else if (value is DateTime) {
              LogUtils.error('⚠️ Campo "$field" é DateTime ($value) - possível origem do erro', tag: tag);
              // Tentar corrigir os dados diretamente para evitar erros futuros
              data[field] = value.toIso8601String();
              LogUtils.info('🔧 Campo "$field" convertido para String: ${data[field]}', tag: tag);
            } else {
              LogUtils.info('Campo "$field": $value ($runtimeType)', tag: tag);
            }
          }
          
          // Sugerir correções
          LogUtils.info('🔧 Sugestões para correção:', tag: tag);
          LogUtils.info('1. Use JsonUtils.safeDateTime() para converter valores de data', tag: tag);
          LogUtils.info('2. Garanta que campos de data estejam sendo convertidos para String antes de serem usados como tal', tag: tag);
          LogUtils.info('3. Use sanitizadores de dados para garantir compatibilidade de tipos', tag: tag);
        }
      } catch (diagnoseError) {
        LogUtils.error('Erro ao diagnosticar problema: $diagnoseError', tag: tag);
      }
    }
  }
} 
