// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

/// Flag para desabilitar verificação de autenticação (APENAS PARA DESENVOLVIMENTO)
const bool DISABLE_AUTH_CHECK = false; // Verificação de autenticação ativada

/// Guarda de rotas para verificar autenticação
/// Redireciona para login se o usuário não estiver autenticado
class AuthGuard extends AutoRouteGuard {
  final ProviderRef _ref;

  AuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final targetPath = resolver.route.path;
    
    print('AuthGuard - Navegando para: $targetPath');
    
    // MODO DE DESENVOLVIMENTO: Ignorar verificação de autenticação
    if (DISABLE_AUTH_CHECK) {
      print('AuthGuard - MODO DE DESENVOLVIMENTO: Ignorando verificação de autenticação');
      resolver.next(true);
      return;
    }
    
    final authViewModel = _ref.read(authViewModelProvider.notifier);
    
    // Rotas que não precisam de autenticação
    final nonAuthRoutes = [
      AppRoutes.intro,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
    ];
    
    // Se for uma rota que não precisa de autenticação, permitir acesso
    if (nonAuthRoutes.contains(targetPath)) {
      print('AuthGuard - Permitindo acesso à rota pública: $targetPath');
      resolver.next(true);
      return;
    }
    
    // Verificar se o usuário já viu a tela de introdução
    final hasSeenIntro = GetIt.instance<SharedPreferences>().getBool('has_seen_intro') ?? false;
    print('🔍 AuthGuard - Verificando se já viu intro: $hasSeenIntro (rota alvo: $targetPath)');
    if (!hasSeenIntro && targetPath != AppRoutes.intro) {
      // Se ainda não viu a introdução e está tentando ir para qualquer rota,
      // redirecionar para introdução
      print('AuthGuard - Usuário ainda não viu intro, redirecionando para tela de introdução');
      router.replaceNamed(AppRoutes.intro);
      resolver.next(false);
      return;
    }
    
    // Verificar o estado atual de autenticação
    // Se estiver no estado inicial ou carregando, forçar uma verificação
    final authState = _ref.read(authViewModelProvider);
    final needsCheck = authState.maybeWhen(
      initial: () => true,
      loading: () => true,
      orElse: () => false,
    );
    
    if (needsCheck) {
      print('AuthGuard - Estado de autenticação não concluído, verificando status atual');
      await authViewModel.checkAuthStatus();
    }
    
    // Ler o estado novamente após a verificação
    final updatedAuthState = _ref.read(authViewModelProvider);
    
    // Verificar se o usuário está autenticado
    final isAuthenticated = updatedAuthState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (isAuthenticated) {
      // O usuário está autenticado, permitir navegação
      print('AuthGuard - Usuário autenticado, permitindo acesso');
      print('AuthGuard - Rota alvo: $targetPath');
      resolver.next(true);
    } else {
      // Para todas as rotas protegidas, redirecionar para login
      if (!nonAuthRoutes.contains(targetPath)) {
        // Armazenar no ViewModel a rota para redirecionamento posterior
        authViewModel.setRedirectPath(targetPath);
        
        print('AuthGuard - Usuário não autenticado, redirecionando para login');
        print('AuthGuard - Tentou acessar rota protegida: $targetPath');
        // Redirecionar para login
        router.navigateNamed(AppRoutes.login);
        resolver.next(false);
      } else {
        // Permitir acesso a rotas de autenticação
        print('AuthGuard - Permitindo acesso a rotas de autenticação');
        resolver.next(true);
      }
    }
  }
} 
