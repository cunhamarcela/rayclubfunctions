// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import '../services/connectivity_service.dart';
import 'offline_operation_queue.dart';
import '../errors/app_exception.dart';

/// Helper para facilitar o uso da fila de operações offline em repositórios
class OfflineRepositoryHelper {
  final OfflineOperationQueue _operationQueue;
  final ConnectivityService _connectivityService;
  
  OfflineRepositoryHelper({
    required OfflineOperationQueue operationQueue,
    required ConnectivityService connectivityService,
  })  : _operationQueue = operationQueue,
        _connectivityService = connectivityService;
  
  /// Executa uma operação com suporte a modo offline
  /// 
  /// Se estiver online, executa a operação normalmente.
  /// Se estiver offline, adiciona à fila para processamento posterior.
  /// 
  /// Parâmetros:
  /// - [entity]: Nome da entidade (ex: 'workouts', 'nutrition')
  /// - [type]: Tipo de operação (create, update, delete)
  /// - [data]: Dados da operação
  /// - [onlineOperation]: Função a ser executada quando online
  Future<T> executeWithOfflineSupport<T>({
    required String entity,
    required OperationType type,
    required Map<String, dynamic> data,
    required Future<T> Function() onlineOperation,
    T Function(OfflineOperation operation)? offlineResultBuilder,
  }) async {
    // Verifica se está online
    final isOnline = await _connectivityService.hasConnection();
    
    if (isOnline) {
      try {
        // Se estiver online, executa a operação normalmente
        return await onlineOperation();
      } catch (e) {
        // Se ocorrer erro na operação online, verificamos se é um erro de conectividade
        // Se for, adicionamos à fila offline
        if (_isConnectivityError(e)) {
          // Adiciona operação à fila
          final operation = await _operationQueue.addOperation(
            type: type,
            entity: entity,
            data: data,
          );
          
          // Retorna resultado simulado se fornecido
          if (offlineResultBuilder != null) {
            return offlineResultBuilder(operation);
          }
          
          // Se não houver builder de resultado, lança exceção original
          rethrow;
        } else {
          // Se não for erro de conectividade, propaga o erro
          rethrow;
        }
      }
    } else {
      // Se estiver offline, adiciona operação à fila
      final operation = await _operationQueue.addOperation(
        type: type,
        entity: entity,
        data: data,
      );
      
      // Retorna resultado simulado se fornecido
      if (offlineResultBuilder != null) {
        return offlineResultBuilder(operation);
      }
      
      // Se não houver builder de resultado, lança exceção de offline
      throw OfflineOperationException(
        message: 'Operação adicionada à fila offline',
        operationId: operation.id,
        entity: entity,
        type: type,
      );
    }
  }
  
  /// Verifica se é um erro relacionado a conectividade
  bool _isConnectivityError(Object error) {
    // Verifica erros comuns de conectividade
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('host') ||
        errorString.contains('server') ||
        errorString.contains('connectivity');
  }
}

/// Exceção lançada quando uma operação é adicionada à fila offline
class OfflineOperationException extends AppException {
  final String operationId;
  final String entity;
  final OperationType type;
  
  OfflineOperationException({
    required String message,
    required this.operationId,
    required this.entity,
    required this.type,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: 'offline_operation',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Provider para o OfflineRepositoryHelper
final offlineRepositoryHelperProvider = Provider<OfflineRepositoryHelper>((ref) {
  final operationQueue = ref.watch(offlineOperationQueueProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return OfflineRepositoryHelper(
    operationQueue: operationQueue,
    connectivityService: connectivityService,
  );
}); 