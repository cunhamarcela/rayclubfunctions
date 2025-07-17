// Flutter imports:
import 'package:flutter/foundation.dart';

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import '../../utils/log_utils.dart';
import '../services/connectivity_service.dart';

part 'base_view_model.freezed.dart';

/// Estados padrão para qualquer ViewModel
@freezed
class BaseState<T> with _$BaseState<T> {
  /// Estado inicial, sem dados carregados
  const factory BaseState.initial() = BaseStateInitial<T>;
  
  /// Estado de carregamento
  const factory BaseState.loading() = BaseStateLoading<T>;
  
  /// Estado com dados carregados e disponíveis
  const factory BaseState.data({required T data}) = BaseStateData<T>;
  
  /// Estado com erro
  const factory BaseState.error({
    required String message,
    AppException? exception,
  }) = BaseStateError<T>;
  
  /// Estado offline, com dados em cache ou não
  const factory BaseState.offline({T? cachedData}) = BaseStateOffline<T>;
}

/// Base para todos os ViewModels modernos do aplicativo
/// Implementa o novo padrão de estados com Freezed
abstract class BaseViewModel<T> extends StateNotifier<BaseState<T>> {
  /// Serviço que verifica conectividade
  final ConnectivityService? _connectivityService;
  
  /// Stream subscription para mudanças de conectividade
  StreamSubscription<bool>? _connectivitySubscription;
  
  /// Construtor padrão com estado inicial
  BaseViewModel({ConnectivityService? connectivityService}) 
      : _connectivityService = connectivityService,
        super(const BaseState.initial()) {
    _initConnectivityListener();
  }
  
  /// Inicializa o listener de conectividade se estiver disponível
  void _initConnectivityListener() {
    if (_connectivityService != null) {
      _connectivitySubscription = _connectivityService!.connectionStatus.listen((hasConnection) {
        handleConnectivityChange(hasConnection);
      });
    }
  }
  
  /// Trata mudanças na conectividade
  /// Pode ser sobrescrito pelos ViewModels derivados para comportamento customizado
  @protected
  void handleConnectivityChange(bool hasConnection) {
    // Se a conexão foi restaurada e estávamos offline, tentar recarregar dados
    if (hasConnection && state is BaseStateOffline<T>) {
      // Usar dados em cache como fallback
      final cachedData = (state as BaseStateOffline<T>).cachedData;
      loadData(useCachedData: cachedData);
    }
    
    // Se perdemos conexão e não estamos em estado offline, atualizar para offline
    if (!hasConnection && !(state is BaseStateOffline<T>)) {
      // Verificar se temos dados atuais que podem ser usados como cache
      T? currentData;
      if (state is BaseStateData<T>) {
        currentData = (state as BaseStateData<T>).data;
      }
      
      state = BaseState<T>.offline(cachedData: currentData);
    }
  }
  
  /// Método que deve ser implementado pelos ViewModels para carregar dados
  @protected
  Future<void> loadData({T? useCachedData});
  
  /// Converte uma exceção para um estado de erro padronizado
  @protected
  BaseState<T> handleError(Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('Erro no ViewModel ${runtimeType.toString()}: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
    
    // Verificar se é desconexão e temos dados em cache
    if (error is NetworkException) {
      // Verificar se temos dados em cache do estado atual
      T? cachedData;
      if (state is BaseStateData<T>) {
        cachedData = (state as BaseStateData<T>).data;
      }
      
      return BaseState<T>.offline(cachedData: cachedData);
    }
    
    // Pegar mensagem personalizada se disponível
    String message = 'Ocorreu um erro ao processar sua solicitação';
    AppException? appException;
    
    if (error is AppException) {
      message = error.message;
      appException = error;
    } else if (error is Exception || error is Error) {
      message = 'Erro: ${error.toString()}';
    }
    
    return BaseState<T>.error(message: message, exception: appException);
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
  
  /// Executa uma operação assíncrona com tratamento de erros padronizado
  Future<void> execute({
    required Future<void> Function() operation,
    required void Function() onStart,
    required void Function(AppException error) onError,
    required void Function() onSuccess,
    String? errorMessage,
    String? operationName,
  }) async {
    try {
      // Marcar início da operação (geralmente mudando para estado de loading)
      onStart();
      
      // Log de operação se necessário
      if (operationName != null) {
        LogUtils.info('Iniciando operação: $operationName', tag: 'ViewModel');
      }
      
      // Executar a operação
      await operation();
      
      // Callback de sucesso
      onSuccess();
    } catch (e, stackTrace) {
      // Gerar exceção padronizada
      final appException = _handleError(
        e, 
        stackTrace, 
        errorMessage ?? 'Ocorreu um erro ao executar a operação',
      );
      
      // Log para debugging
      if (operationName != null) {
        LogUtils.error(
          'Erro em $operationName',
          error: appException,
          stackTrace: stackTrace,
          tag: 'ViewModel',
        );
      }
      
      // Callback de erro
      onError(appException);
    }
  }
  
  /// Trata erros e retorna uma exceção padronizada
  AppException _handleError(Object error, StackTrace stackTrace, String defaultMessage) {
    // Se já for uma exceção do App, apenas retorna
    if (error is AppException) {
      return error;
    }
    
    // Usar o classificador global de erros
    return ErrorClassifier.classifyError(error, stackTrace);
  }
  
  /// Método para log de debug no ViewModel
  void logDebug(String message) {
    if (kDebugMode) {
      LogUtils.debug(message, tag: runtimeType.toString());
    }
  }
  
  /// Método para log de informação no ViewModel
  void logInfo(String message) {
    LogUtils.info(message, tag: runtimeType.toString());
  }
  
  /// Método para log de erro no ViewModel
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    LogUtils.error(
      message, 
      error: error, 
      stackTrace: stackTrace,
      tag: runtimeType.toString(),
    );
  }
}

/// Interface base para estados legados
abstract class LegacyBaseState {
  /// Método para verificar se o estado representa carregamento
  bool get isLoading;
  
  /// Método para verificar se o estado representa erro
  bool get hasError;
  
  /// Método para obter a mensagem de erro, se houver
  String? get errorMessage;
}

/// Base para ViewModels legados que ainda não usam o novo padrão
abstract class LegacyBaseViewModel<T extends LegacyBaseState> extends StateNotifier<T> {
  LegacyBaseViewModel(T initialState) : super(initialState);
} 