// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../benefits/viewmodels/benefit_view_model.dart';

/// Provider para o AppViewModel
final appViewModelProvider = Provider<AppViewModel>((ref) {
  return AppViewModel(ref);
});

/// ViewModel global para gerenciar estado e operações da aplicação
class AppViewModel {
  final Ref _ref;
  Timer? _expirationCheckTimer;

  AppViewModel(this._ref) {
    // Inicia verificação automática de benefícios expirados
    _startExpirationCheck();
  }

  /// Inicia a verificação periódica de benefícios expirados
  /// A verificação ocorre imediatamente e depois a cada 1 hora
  void _startExpirationCheck() {
    // Verifica imediatamente ao iniciar o app
    _checkExpiredBenefits();
    
    // Configura verificação periódica a cada 1 hora
    _expirationCheckTimer = Timer.periodic(
      const Duration(hours: 1), 
      (_) => _checkExpiredBenefits()
    );
  }

  /// Para a verificação periódica de benefícios expirados
  void stopExpirationCheck() {
    _expirationCheckTimer?.cancel();
    _expirationCheckTimer = null;
  }

  /// Executa a verificação de benefícios expirados
  Future<void> _checkExpiredBenefits() async {
    try {
      // Carrega benefícios resgatados, que já incluem a verificação de expiração
      await _ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits();
      
      if (kDebugMode) {
        print('Verificação de benefícios expirados concluída');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar benefícios expirados: $e');
      }
    }
  }
  
  /// Força verificação manual de benefícios expirados
  Future<void> checkExpiredBenefits() async {
    return _checkExpiredBenefits();
  }
  
  /// Método para limpar recursos ao desmontar o provider
  void dispose() {
    stopExpirationCheck();
  }
} 
