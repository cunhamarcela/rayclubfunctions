// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../services/deep_link_service.dart';
import '../di/service_locator.dart';
import 'app_router.dart';

/// Classe responsável por gerenciar todos os deep links do aplicativo
class DeepLinkHandler {
  final ProviderRef _ref;
  StreamSubscription? _deepLinkSubscription;
  
  DeepLinkHandler(this._ref);
  
  /// Inicializa o handler e começa a ouvir por deep links
  void initialize() {
    final deepLinkService = getIt<DeepLinkService>();
    
    try {
      _deepLinkSubscription = deepLinkService.deepLinkStream.listen(_handleDeepLink);
      debugPrint('✅ DeepLinkHandler: Inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ DeepLinkHandler: Erro ao inicializar: $e');
    }
  }
  
  /// Manipula um deep link recebido
  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;
    
    debugPrint('🔗 DeepLinkHandler: Deep link recebido: $uri');
    
    final router = _ref.read(appRouterProvider);
    
    if (uri.scheme == 'rayclub') {
      _handleRayClubScheme(uri, router);
    }
  }
  
  /// Manipula deep links com o esquema rayclub://
  void _handleRayClubScheme(Uri uri, StackRouter router) {
    switch (uri.host) {
      case 'login':
      case 'login-callback':
        debugPrint('🔗 DeepLinkHandler: Redirecionando para tela de login');
        router.replaceAll([const LoginRoute()]);
        break;
        
      case 'reset-password':
        debugPrint('🔗 DeepLinkHandler: Redirecionando para tela de redefinição de senha');
        router.replaceAll([const ResetPasswordRoute()]);
        break;
        
      default:
        debugPrint('⚠️ DeepLinkHandler: Host desconhecido: ${uri.host}');
        break;
    }
  }
  
  /// Libera recursos ao descartar o handler
  void dispose() {
    _deepLinkSubscription?.cancel();
    debugPrint('🔍 DeepLinkHandler: Liberado');
  }
}

/// Provider para o handler de deep links
final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  final handler = DeepLinkHandler(ref);
  handler.initialize();
  
  ref.onDispose(() {
    handler.dispose();
  });
  
  return handler;
}); 