// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../features/benefits/viewmodels/benefit_view_model.dart';

/// Provider para o serviço de expiração
final expirationServiceProvider = Provider<ExpirationService>((ref) {
  final service = ExpirationService(ref);
  
  // Garantir que o serviço seja descartado adequadamente
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Serviço para gerenciar verificações de expiração em toda a aplicação
class ExpirationService {
  final Ref _ref;
  Timer? _periodicCheckTimer;
  bool _initialized = false;
  
  /// Retorna se o serviço foi inicializado
  bool get isInitialized => _initialized;
  
  /// Intervalo padrão de verificação: 1 hora
  static const Duration defaultCheckInterval = Duration(hours: 1);

  ExpirationService(this._ref);
  
  /// Inicializa o serviço de expiração
  void initialize() {
    if (_initialized) return;
    
    // Inicia verificação periódica
    startPeriodicCheck();
    
    _initialized = true;
    
    if (kDebugMode) {
      print('ExpirationService inicializado');
    }
  }
  
  /// Inicia verificação periódica de itens expirados
  void startPeriodicCheck([Duration interval = defaultCheckInterval]) {
    // Cancela timer existente se houver
    _periodicCheckTimer?.cancel();
    
    // Executa verificação inicial imediatamente
    _checkAllExpirations();
    
    // Configura timer para verificações periódicas
    _periodicCheckTimer = Timer.periodic(interval, (_) {
      _checkAllExpirations();
    });
    
    if (kDebugMode) {
      print('Verificação periódica iniciada (intervalo: ${interval.inMinutes} minutos)');
    }
  }
  
  /// Para verificação periódica
  void stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
    
    if (kDebugMode) {
      print('Verificação periódica parada');
    }
  }
  
  /// Verifica expiração em todas as features
  Future<void> _checkAllExpirations() async {
    if (kDebugMode) {
      print('Executando verificação de expiração para todas as features...');
    }
    
    try {
      // Verifica expiração de benefícios/cupons
      await _checkBenefitsExpiration();
      
      // Aqui podem ser adicionadas verificações para outras features no futuro
      
      if (kDebugMode) {
        print('Verificação de expiração concluída com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro durante verificação de expiração: $e');
      }
    }
  }
  
  /// Verifica expiração de benefícios
  Future<void> _checkBenefitsExpiration() async {
    try {
      // Carrega benefícios resgatados, que internamente já verifica expiração
      await _ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar expiração de benefícios: $e');
      }
      // Não propaga a exceção para não interromper verificações de outras features
    }
  }
  
  /// Força uma verificação imediata de todas as features
  Future<void> checkExpirations() async {
    return _checkAllExpirations();
  }
  
  /// Libera recursos
  void dispose() {
    stopPeriodicCheck();
    _initialized = false;
  }
} 
