// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/core/services/logging_service.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Classe para monitorar o desempenho de operações críticas
class PerformanceMonitor {
  static final Map<String, _Operation> _activeOperations = {};
  static final Map<String, List<int>> _operationHistory = {};
  static LoggingService? _remoteLoggingService;
  
  /// Define o serviço de log remoto
  static void setRemoteLoggingService(LoggingService service) {
    _remoteLoggingService = service;
  }
  
  /// Inicia o monitoramento de uma operação
  static String startOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final uniqueId = '${operationName}_${DateTime.now().millisecondsSinceEpoch}_${_activeOperations.length}';
    final operation = _Operation(
      name: operationName,
      startTime: DateTime.now(),
      metadata: metadata,
    );
    
    _activeOperations[uniqueId] = operation;
    
    LogUtils.debug(
      'Iniciada operação: $operationName',
      tag: 'PerformanceMonitor',
      data: {'id': uniqueId, ...?metadata},
    );
    
    return uniqueId;
  }
  
  /// Finaliza o monitoramento de uma operação
  static void endOperation(String operationId, {bool success = true, String? error}) {
    final operation = _activeOperations[operationId];
    if (operation == null) {
      LogUtils.warning(
        'Tentativa de finalizar operação desconhecida',
        tag: 'PerformanceMonitor',
        data: {'id': operationId},
      );
      return;
    }
    
    final endTime = DateTime.now();
    final duration = endTime.difference(operation.startTime).inMilliseconds;
    
    // Registrar histórico para análise de tendências
    if (!_operationHistory.containsKey(operation.name)) {
      _operationHistory[operation.name] = [];
    }
    _operationHistory[operation.name]!.add(duration);
    
    // Manter apenas as últimas 100 operações para evitar crescimento infinito
    if (_operationHistory[operation.name]!.length > 100) {
      _operationHistory[operation.name]!.removeAt(0);
    }
    
    final averageDuration = _calculateAverage(_operationHistory[operation.name]!);
    
    final data = {
      'duration': duration,
      'average': averageDuration,
      'success': success,
      ...?operation.metadata,
    };
    
    if (error != null) {
      data['error'] = error;
    }
    
    LogUtils.info(
      'Finalizada operação: ${operation.name} (${duration}ms)',
      tag: 'PerformanceMonitor',
      data: data,
    );
    
    // Enviar dados para o serviço de log remoto para análise
    _remoteLoggingService?.logMetric(
      metricName: 'operation_duration',
      value: duration.toDouble(),
      unit: 'ms',
      dimensions: {
        'operation': operation.name,
        'success': success.toString(),
        ...?operation.metadata,
      },
    );
    
    _activeOperations.remove(operationId);
  }
  
  /// Executa uma função com monitoramento de desempenho
  static Future<T> trackAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final operationId = startOperation(operationName, metadata: metadata);
    try {
      final result = await operation();
      endOperation(operationId, success: true);
      return result;
    } catch (e) {
      endOperation(operationId, success: false, error: e.toString());
      rethrow;
    }
  }
  
  /// Executa uma função sincronizada com monitoramento de desempenho
  static T track<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final operationId = startOperation(operationName, metadata: metadata);
    try {
      final result = operation();
      endOperation(operationId, success: true);
      return result;
    } catch (e) {
      endOperation(operationId, success: false, error: e.toString());
      rethrow;
    }
  }
  
  /// Obtém estatísticas de todas as operações monitoradas
  static Map<String, Map<String, dynamic>> getStatistics() {
    final stats = <String, Map<String, dynamic>>{};
    
    _operationHistory.forEach((operationName, durations) {
      stats[operationName] = {
        'count': durations.length,
        'average': _calculateAverage(durations),
        'min': durations.isEmpty ? 0 : durations.reduce((a, b) => a < b ? a : b),
        'max': durations.isEmpty ? 0 : durations.reduce((a, b) => a > b ? a : b),
      };
    });
    
    return stats;
  }
  
  /// Calcula a média de uma lista de durações
  static int _calculateAverage(List<int> durations) {
    if (durations.isEmpty) return 0;
    final sum = durations.fold<int>(0, (a, b) => a + b);
    return (sum / durations.length).round();
  }
}

/// Classe interna para representar uma operação em andamento
class _Operation {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic>? metadata;
  
  _Operation({
    required this.name,
    required this.startTime,
    this.metadata,
  });
} 
