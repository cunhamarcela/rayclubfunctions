// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../utils/log_utils.dart';
import '../errors/app_exception.dart';

/// Tipos de operações que podem ser armazenadas
enum OperationType {
  create,
  update,
  delete,
}

/// Representa uma operação que será armazenada para processamento posterior quando online
class OfflineOperation {
  /// ID único da operação
  final String id;
  
  /// Tipo de operação
  final OperationType type;
  
  /// Entidade (tabela/collection) afetada pela operação
  final String entity;
  
  /// Dados da operação em formato JSON
  final Map<String, dynamic> data;
  
  /// Timestamp de quando a operação foi criada
  final DateTime createdAt;
  
  /// Status da operação
  final bool isCompleted;
  
  /// Número de tentativas de executar a operação
  final int retryCount;
  
  /// Construtor
  OfflineOperation({
    required this.id,
    required this.type,
    required this.entity,
    required this.data,
    required this.createdAt,
    this.isCompleted = false,
    this.retryCount = 0,
  });
  
  /// Cria uma operação a partir de um mapa
  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'],
      type: OperationType.values[json['type']],
      entity: json['entity'],
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      retryCount: json['retryCount'] ?? 0,
    );
  }
  
  /// Converte a operação para um mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'entity': entity,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'retryCount': retryCount,
    };
  }
  
  /// Cria uma cópia da operação com algumas alterações
  OfflineOperation copyWith({
    String? id,
    OperationType? type,
    String? entity,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isCompleted,
    int? retryCount,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entity: entity ?? this.entity,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Gerenciador de operações offline
class OfflineOperationQueue {
  static const String _storageKey = 'offline_operations';
  final Connectivity _connectivity = Connectivity();
  SharedPreferences? _prefs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  final List<OfflineOperation> _operations = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  static final OfflineOperationQueue _instance = OfflineOperationQueue._internal();
  
  /// Factory para criar uma instância singleton
  factory OfflineOperationQueue() {
    return _instance;
  }
  
  OfflineOperationQueue._internal();
  
  /// Indica se a fila foi inicializada
  bool get isInitialized => _isInitialized;
  
  /// Obtém todas as operações pendentes
  List<OfflineOperation> get pendingOperations => _operations.where((op) => !op.isCompleted).toList();
  
  /// Inicializa a fila de operações offline
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadOperationsFromStorage();
      
      // Monitora alterações de conectividade
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          // Quando a conexão for restaurada, processa as operações pendentes
          _processQueue();
        }
      });
      
      _isInitialized = true;
      LogUtils.info('OfflineOperationQueue inicializado com sucesso', tag: 'OfflineOperationQueue');
      
      // Verifica se há conexão no momento da inicialização
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        _processQueue();
      }
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao inicializar OfflineOperationQueue',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Adiciona uma operação à fila
  Future<OfflineOperation> addOperation({
    required OperationType type,
    required String entity,
    required Map<String, dynamic> data,
  }) async {
    if (!_isInitialized) {
      throw AppException(
        message: 'OfflineOperationQueue não foi inicializado',
        code: 'queue_not_initialized',
      );
    }
    
    final operation = OfflineOperation(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_operations.length}',
      type: type,
      entity: entity,
      data: data,
      createdAt: DateTime.now(),
    );
    
    _operations.add(operation);
    await _saveOperationsToStorage();
    
    LogUtils.debug(
      'Operação adicionada à fila offline',
      tag: 'OfflineOperationQueue',
      data: {'id': operation.id, 'type': operation.type.toString(), 'entity': operation.entity},
    );
    
    // Verifica se está online para processar imediatamente
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      _processQueue();
    }
    
    return operation;
  }
  
  /// Marca uma operação como concluída
  Future<void> markOperationAsCompleted(String operationId) async {
    final index = _operations.indexWhere((op) => op.id == operationId);
    if (index >= 0) {
      _operations[index] = _operations[index].copyWith(isCompleted: true);
      await _saveOperationsToStorage();
      
      LogUtils.debug(
        'Operação marcada como concluída',
        tag: 'OfflineOperationQueue',
        data: {'id': operationId},
      );
    }
  }
  
  /// Processa todas as operações pendentes
  Future<void> _processQueue() async {
    if (_isProcessing || _operations.isEmpty) return;
    
    _isProcessing = true;
    LogUtils.info('Iniciando processamento de operações offline', tag: 'OfflineOperationQueue');
    
    try {
      final List<OfflineOperation> pendingOps = pendingOperations;
      for (final operation in pendingOps) {
        try {
          await _processOperation(operation);
          
          // Marca operação como concluída
          await markOperationAsCompleted(operation.id);
        } catch (e) {
          // Incrementa contador de tentativas
          final index = _operations.indexWhere((op) => op.id == operation.id);
          if (index >= 0) {
            _operations[index] = _operations[index].copyWith(
              retryCount: operation.retryCount + 1,
            );
            await _saveOperationsToStorage();
            
            LogUtils.warning(
              'Falha ao processar operação offline',
              tag: 'OfflineOperationQueue',
              data: {
                'id': operation.id,
                'entity': operation.entity,
                'tentativas': operation.retryCount + 1,
                'erro': e.toString(),
              },
            );
          }
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Processa uma operação específica
  Future<void> _processOperation(OfflineOperation operation) async {
    // Aqui você registraria handlers para diferentes entidades
    final handlers = <String, Future<void> Function(OfflineOperation)>{
      'workouts': _processWorkoutOperation,
      'nutrition': _processNutritionOperation,
      'benefits': _processBenefitOperation,
      'challenges': _processChallengeOperation,
      'profile': _processProfileOperation,
      // Adicione outros handlers conforme necessário
    };
    
    final handler = handlers[operation.entity];
    
    if (handler != null) {
      await handler(operation);
    } else {
      throw AppException(
        message: 'Nenhum handler encontrado para a entidade ${operation.entity}',
        code: 'handler_not_found',
      );
    }
  }
  
  // Handlers específicos para cada entidade
  Future<void> _processWorkoutOperation(OfflineOperation operation) async {
    // Aqui seria a implementação real usando o repositório
    // Por exemplo:
    try {
      final supabase = Supabase.instance.client;
      
      switch (operation.type) {
        case OperationType.create:
          await supabase.from('user_workouts').insert(operation.data);
          break;
        case OperationType.update:
          await supabase.from('user_workouts')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;
        case OperationType.delete:
          await supabase.from('user_workouts')
              .delete()
              .eq('id', operation.data['id']);
          break;
      }
      
      LogUtils.debug(
        'Processada operação offline para treinos',
        tag: 'OfflineOperationQueue',
        data: {'id': operation.id, 'type': operation.type.toString()},
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar operação offline para treinos',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  Future<void> _processNutritionOperation(OfflineOperation operation) async {
    try {
      final supabase = Supabase.instance.client;
      
      switch (operation.type) {
        case OperationType.create:
          await supabase.from('meals').insert(operation.data);
          break;
        case OperationType.update:
          await supabase.from('meals')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;
        case OperationType.delete:
          await supabase.from('meals')
              .delete()
              .eq('id', operation.data['id']);
          break;
      }
      
      LogUtils.debug(
        'Processada operação offline para nutrição',
        tag: 'OfflineOperationQueue',
        data: {'id': operation.id, 'type': operation.type.toString()},
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar operação offline para nutrição',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  Future<void> _processBenefitOperation(OfflineOperation operation) async {
    try {
      final supabase = Supabase.instance.client;
      
      switch (operation.type) {
        case OperationType.create:
          await supabase.from('redeemed_benefits').insert(operation.data);
          break;
        case OperationType.update:
          await supabase.from('redeemed_benefits')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;
        case OperationType.delete:
          // Normalmente não permitimos excluir benefícios resgatados
          throw AppException(
            message: 'Operação não suportada para benefícios',
            code: 'operation_not_supported',
          );
      }
      
      LogUtils.debug(
        'Processada operação offline para benefícios',
        tag: 'OfflineOperationQueue',
        data: {'id': operation.id, 'type': operation.type.toString()},
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar operação offline para benefícios',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  Future<void> _processChallengeOperation(OfflineOperation operation) async {
    try {
      final supabase = Supabase.instance.client;
      
      switch (operation.type) {
        case OperationType.create:
          if (operation.data['entity_type'] == 'check_in') {
            await supabase.from('challenge_check_ins').insert(operation.data);
          } else if (operation.data['entity_type'] == 'participant') {
            await supabase.from('challenge_participants').insert(operation.data);
          }
          break;
        case OperationType.update:
          if (operation.data['entity_type'] == 'progress') {
            await supabase.from('challenge_progress')
                .update(operation.data)
                .eq('id', operation.data['id']);
          }
          break;
        case OperationType.delete:
          if (operation.data['entity_type'] == 'participant') {
            await supabase.from('challenge_participants')
                .delete()
                .eq('id', operation.data['id']);
          }
          break;
      }
      
      LogUtils.debug(
        'Processada operação offline para desafios',
        tag: 'OfflineOperationQueue',
        data: {'id': operation.id, 'type': operation.type.toString()},
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar operação offline para desafios',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  Future<void> _processProfileOperation(OfflineOperation operation) async {
    try {
      final supabase = Supabase.instance.client;
      
      switch (operation.type) {
        case OperationType.update:
          await supabase.from('profiles')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;
        case OperationType.create:
        case OperationType.delete:
          throw AppException(
            message: 'Operação não suportada para perfis',
            code: 'operation_not_supported',
          );
      }
      
      LogUtils.debug(
        'Processada operação offline para perfil',
        tag: 'OfflineOperationQueue',
        data: {'id': operation.id, 'type': operation.type.toString()},
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar operação offline para perfil',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Carrega operações do armazenamento local
  Future<void> _loadOperationsFromStorage() async {
    final String? storedOps = _prefs?.getString(_storageKey);
    
    if (storedOps != null && storedOps.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(storedOps);
        _operations.clear();
        _operations.addAll(
          decoded.map((item) => OfflineOperation.fromJson(item)).toList(),
        );
        
        LogUtils.info(
          'Operações offline carregadas do armazenamento',
          tag: 'OfflineOperationQueue',
          data: {'count': _operations.length},
        );
      } catch (e, stackTrace) {
        LogUtils.error(
          'Erro ao decodificar operações offline',
          tag: 'OfflineOperationQueue',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }
  
  /// Salva operações no armazenamento local
  Future<void> _saveOperationsToStorage() async {
    try {
      final String encoded = json.encode(_operations.map((op) => op.toJson()).toList());
      await _prefs?.setString(_storageKey, encoded);
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao salvar operações offline',
        tag: 'OfflineOperationQueue',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Limpa operações concluídas com mais de X dias
  Future<void> cleanupCompletedOperations({int daysToKeep = 7}) async {
    final threshold = DateTime.now().subtract(Duration(days: daysToKeep));
    _operations.removeWhere((op) => 
      op.isCompleted && op.createdAt.isBefore(threshold)
    );
    await _saveOperationsToStorage();
    
    LogUtils.info(
      'Limpeza de operações concluídas realizada',
      tag: 'OfflineOperationQueue',
      data: {'restantes': _operations.length},
    );
  }
  
  /// Descarta todas as operações
  Future<void> clearAll() async {
    _operations.clear();
    await _saveOperationsToStorage();
    
    LogUtils.info('Todas as operações offline foram removidas', tag: 'OfflineOperationQueue');
  }
  
  /// Libera recursos quando não for mais necessário
  void dispose() {
    _connectivitySubscription?.cancel();
    _isInitialized = false;
    LogUtils.debug('OfflineOperationQueue foi descartado', tag: 'OfflineOperationQueue');
  }
}

/// Provider para acessar o OfflineOperationQueue
final offlineOperationQueueProvider = Provider<OfflineOperationQueue>((ref) {
  final queue = OfflineOperationQueue();
  ref.onDispose(() => queue.dispose());
  
  // Inicializar a fila automaticamente ao acessar o provider
  Future.microtask(() async {
    try {
      await queue.initialize();
    } catch (e) {
      LogUtils.error(
        'Erro ao inicializar OfflineOperationQueue via provider',
        tag: 'OfflineOperationQueueProvider',
        error: e,
      );
    }
  });
  
  return queue;
}); 
