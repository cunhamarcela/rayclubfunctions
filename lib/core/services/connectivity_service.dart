// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

// Project imports:
import 'package:ray_club_app/utils/log_utils.dart';

/// Serviço para monitorar e gerenciar conectividade
class ConnectivityService {
  /// Instância do Connectivity plugin
  final Connectivity _connectivity = Connectivity();
  
  /// Stream controller para emitir eventos de conectividade
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  /// Stream de status de conectividade
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  /// Última conexão conhecida
  bool _lastKnownConnection = false;
  
  /// Subscription da stream de conectividade
  StreamSubscription? _connectivitySubscription;
  
  /// Construtor
  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  /// Inicializa o status de conectividade
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Erro ao inicializar conectividade: $e');
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }
  
  /// Atualiza o status de conectividade
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Usa o primeiro resultado da lista ou none se a lista estiver vazia
    final ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    final bool hasConnection = result != ConnectivityResult.none;
    
    // Só emite evento se o status mudou
    if (hasConnection != _lastKnownConnection) {
      _lastKnownConnection = hasConnection;
      _connectionStatusController.add(hasConnection);
    }
  }
  
  /// Verifica se há conexão ativa no momento
  Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty && results.first != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      return false;
    }
  }
  
  /// Verifica a conectividade atual
  Future<List<ConnectivityResult>> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }
  
  /// Dispose do serviço
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}

/// Provider para o serviço de conectividade
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Provider para obter o status atual de conectividade
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStatus;
}); 