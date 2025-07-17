// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import '../errors/app_exception.dart';
import '../providers/supabase_providers.dart';
import 'app_router.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/viewmodels/auth_view_model.dart';
import '../../utils/log_utils.dart';

/// Constante que define o intervalo mínimo entre verificações completas
/// de autenticação (em minutos)
const int AUTH_CHECK_INTERVAL_MINUTES = 15;

/// Guarda de rota em camadas para otimizar verificação de autenticação
class LayeredAuthGuard extends AutoRouteGuard {
  final ProviderRef _ref;
  
  // Armazena o timestamp da última verificação completa
  static int _lastFullAuthCheck = 0;
  
  // Token da última sessão verificada
  static String? _lastVerifiedToken;

  LayeredAuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final targetPath = resolver.route.path;
    final currentRouteName = router.currentPath;
    
    LogUtils.info('Navegando para: $targetPath (rota atual: $currentRouteName)', tag: 'LayeredAuthGuard');
    
    // Evitar loops - se já estiver na rota alvo, apenas permitir
    if (currentRouteName == targetPath) {
      LogUtils.info('Já na rota alvo, permitindo acesso', tag: 'LayeredAuthGuard');
      resolver.next(true);
      return;
    }
    
    // IMPORTANTE: Primeiro verificar se é a própria tela de intro
    // Se estiver tentando acessar diretamente a intro, sempre permitir
    if (targetPath == AppRoutes.intro) {
      LogUtils.info('Permitindo acesso direto à tela de introdução', tag: 'LayeredAuthGuard');
      resolver.next(true);
      return;
    }
    
    // Verificar se é uma rota pública que não precisa de verificação
    if (_isLoginOrPublicRoute(targetPath)) {
      LogUtils.info('Permitindo acesso à rota pública: $targetPath', tag: 'LayeredAuthGuard');
      resolver.next(true);
      return;
    }
    
    // Leitura do estado de autenticação do cache
    final authViewModel = _ref.read(authViewModelProvider.notifier);
    final authState = _ref.read(authViewModelProvider);
    
    // Verificar se o usuário está autenticado no estado atual
    final isUserAuthenticated = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    // Verificar se o usuário já viu a introdução de forma robusta
    final hasSeenIntro = await _hasSeenIntro();
    
    LogUtils.info('Status - Autenticado: $isUserAuthenticated, Viu intro: $hasSeenIntro', tag: 'LayeredAuthGuard');
    
    // PRIORIDADE 1: Se não estiver autenticado e não viu a introdução, mostrar a intro
    if (!isUserAuthenticated && !hasSeenIntro) {
      LogUtils.info('Usuário não autenticado e não viu intro, redirecionando para intro', tag: 'LayeredAuthGuard');
      router.replaceNamed(AppRoutes.intro);
      resolver.next(false);
      return;
    }
    
    // PRIORIDADE 2: Se não estiver autenticado mas já viu a intro, ir para login
    if (!isUserAuthenticated) {
      LogUtils.info('Usuário não autenticado mas já viu intro, redirecionando para login', tag: 'LayeredAuthGuard');
      authViewModel.setRedirectPath(targetPath);
      router.navigateNamed(AppRoutes.login);
      resolver.next(false);
      return;
    }
    
    // 1. Verificação rápida baseada em cache
    final isAuthenticatedInCache = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    // 2. Determinar se é necessária uma verificação completa
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final currentAuthToken = _getCurrentToken();
    final needsFullCheck = 
        !isAuthenticatedInCache || 
        _isFullCheckNeeded(currentTime) ||
        _hasTokenChanged(currentAuthToken) ||
        authState.maybeWhen(
          initial: () => true,
          loading: () => true,
          orElse: () => false,
        );
    
    if (needsFullCheck) {
      LogUtils.info('Realizando verificação completa de autenticação', tag: 'LayeredAuthGuard');
      
      try {
        // Verificar conectividade antes de fazer verificação
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          // Se não houver conexão, usar o estado de auth em cache
          LogUtils.warning('Sem conexão, usando estado em cache', tag: 'LayeredAuthGuard');
          
          // Se não estiver autenticado em cache e offline, redirecionar para login
          if (!isAuthenticatedInCache) {
            LogUtils.info('Não autenticado e offline, redirecionando para login', tag: 'LayeredAuthGuard');
            authViewModel.setRedirectPath(targetPath);
            router.navigateNamed(AppRoutes.login);
            resolver.next(false);
            return;
          }
        } else {
          // Com conexão, realiza verificação completa
          await authViewModel.checkAuthStatus();
          _lastFullAuthCheck = currentTime;
          _lastVerifiedToken = currentAuthToken;
        }
      } catch (e, stackTrace) {
        // Tratamento de erro na verificação
        LogUtils.error(
          'Erro ao verificar autenticação',
          error: e,
          stackTrace: stackTrace,
          tag: 'LayeredAuthGuard'
        );
        
        // Em caso de erro e não autenticado, redirecionar para login
        if (!isAuthenticatedInCache) {
          authViewModel.setRedirectPath(targetPath);
          router.navigateNamed(AppRoutes.login);
          resolver.next(false);
          return;
        }
        
        // Se estiver autenticado em cache, continuar usando cache
        LogUtils.warning(
          'Erro na verificação, mas autenticado em cache. Permitindo navegação.',
          tag: 'LayeredAuthGuard'
        );
      }
    } else {
      LogUtils.info(
        'Usando estado em cache (última verificação há ${_getMinutesSinceLastCheck(currentTime)} minutos)',
        tag: 'LayeredAuthGuard'
      );
    }
    
    // Ler o estado atualizado após verificação (se ocorreu)
    final updatedAuthState = _ref.read(authViewModelProvider);
    
    // Verificar se o usuário está autenticado no estado atual
    final isAuthenticatedAfterCheck = updatedAuthState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (isAuthenticatedAfterCheck) {
      // O usuário está autenticado, permitir navegação
      LogUtils.info('Usuário autenticado, permitindo acesso', tag: 'LayeredAuthGuard');
      resolver.next(true);
    } else {
      // Evitar loops de redirecionamento - apenas redirecionar se não estiver indo para login
      if (targetPath != AppRoutes.login) {
        // Armazenar no ViewModel a rota para redirecionamento posterior
        authViewModel.setRedirectPath(targetPath);
        
        LogUtils.info('Usuário não autenticado, redirecionando para login', tag: 'LayeredAuthGuard');
        // Redirecionar para login
        router.navigateNamed(AppRoutes.login);
        resolver.next(false);
      } else {
        // Se já estiver indo para login, apenas permitir
        resolver.next(true);
      }
    }
  }
  
  /// Verifica se é uma rota pública que não requer autenticação
  bool _isPublicRoute(String? path) {
    final publicRoutes = AppRoutes.publicRoutes;
    return path != null && publicRoutes.contains(path);
  }
  
  /// Verifica se é uma rota de login ou outra rota pública
  bool _isLoginOrPublicRoute(String? path) {
    // Login tem tratamento especial
    if (path == AppRoutes.login) return true;
    
    // Verificar outras rotas públicas
    return _isPublicRoute(path);
  }
  
  /// Verifica se é necessário realizar uma verificação completa baseado no tempo
  bool _isFullCheckNeeded(int currentTime) {
    // Converter intervalo de minutos para milissegundos
    final intervalMs = AUTH_CHECK_INTERVAL_MINUTES * 60 * 1000;
    return (currentTime - _lastFullAuthCheck) > intervalMs;
  }
  
  /// Retorna quantos minutos se passaram desde a última verificação completa
  int _getMinutesSinceLastCheck(int currentTime) {
    return (currentTime - _lastFullAuthCheck) ~/ (60 * 1000);
  }
  
  /// Obtém o token atual da sessão
  String? _getCurrentToken() {
    try {
      return _ref.read(supabaseClientProvider).auth.currentSession?.accessToken;
    } catch (e) {
      return null;
    }
  }
  
  /// Verifica se o token mudou desde a última verificação
  bool _hasTokenChanged(String? currentToken) {
    return currentToken != _lastVerifiedToken;
  }
  
  /// Verifica se o usuário já viu a introdução de forma robusta
  Future<bool> _hasSeenIntro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Método 1: Verificar boolean direto
      final boolValue = prefs.getBool('has_seen_intro');
      if (boolValue == true) {
        LogUtils.info('Flag has_seen_intro encontrada como boolean: true', tag: 'LayeredAuthGuard');
        return true;
      }
      
      // Método 2: Verificar valor como string
      final stringValue = prefs.getString('has_seen_intro_str');
      if (stringValue == 'true') {
        LogUtils.info('Flag has_seen_intro_str encontrada como string: true', tag: 'LayeredAuthGuard');
        // Atualizar o valor boolean para consistência
        await prefs.setBool('has_seen_intro', true);
        return true;
      }
      
      // Método 3: Verificar backup
      final backupValue = prefs.getString('intro_seen_backup');
      if (backupValue != null) {
        LogUtils.info('Flag intro_seen_backup encontrada: $backupValue', tag: 'LayeredAuthGuard');
        // Atualizar o valor boolean para consistência
        await prefs.setBool('has_seen_intro', true);
        return true;
      }
      
      // Nenhum método encontrou a flag
      LogUtils.info('Nenhuma flag de intro_seen encontrada', tag: 'LayeredAuthGuard');
      return false;
    } catch (e) {
      LogUtils.error('Erro ao verificar has_seen_intro', error: e, tag: 'LayeredAuthGuard');
      return false;
    }
  }
} 