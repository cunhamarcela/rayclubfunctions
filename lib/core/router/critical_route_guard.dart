// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

/// Guarda de rota para verificação rigorosa de autenticação em rotas críticas
/// como alteração de senha, informações de pagamento, etc.
class CriticalRouteGuard extends AutoRouteGuard {
  final ProviderRef _ref;

  CriticalRouteGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final targetPath = resolver.route.path;
    
    print('CriticalRouteGuard - Navegando para rota crítica: $targetPath');
    
    // Sempre forçar verificação completa com o servidor
    final authViewModel = _ref.read(authViewModelProvider.notifier);
    
    // Verificar se o token está válido (verificação com o servidor)
    print('CriticalRouteGuard - Realizando verificação rigorosa de autenticação com o servidor');
    final isSessionValid = await authViewModel.verifyAndRenewSession();
    
    if (!isSessionValid) {
      print('CriticalRouteGuard - Sessão inválida, redirecionando para login');
      // Armazenar no ViewModel a rota para redirecionamento posterior
      authViewModel.setRedirectPath(targetPath);
      router.navigateNamed(AppRoutes.login);
      resolver.next(false);
      return;
    }
    
    // Verificar se o usuário está autenticado no estado atual
    final authState = _ref.read(authViewModelProvider);
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (isAuthenticated) {
      // O usuário está autenticado e a sessão foi verificada com o servidor
      print('CriticalRouteGuard - Usuário autenticado e sessão validada, permitindo acesso');
      resolver.next(true);
    } else {
      // Armazenar no ViewModel a rota para redirecionamento posterior
      authViewModel.setRedirectPath(targetPath);
      
      print('CriticalRouteGuard - Usuário não autenticado, redirecionando para login');
      // Redirecionar para login
      router.navigateNamed(AppRoutes.login);
      resolver.next(false);
    }
  }
} 