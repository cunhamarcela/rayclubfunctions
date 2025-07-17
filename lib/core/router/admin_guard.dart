// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

/// Guarda de rotas para verificar permissões de administrador
/// Redireciona para home se o usuário não for administrador
class AdminGuard extends AutoRouteGuard {
  final ProviderRef _ref;

  AdminGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authState = _ref.read(authViewModelProvider);
    
    // Verificar se o usuário está autenticado e é administrador
    final isAdmin = authState.maybeWhen(
      authenticated: (user) => user.isAdmin ?? false,
      orElse: () => false,
    );
    
    if (isAdmin) {
      // Usuário é administrador, permitir navegação
      resolver.next(true);
    } else {
      // Usuário não é administrador, redirecionar para home
      router.navigateNamed(AppRoutes.home);
      resolver.next(false);
    }
  }
} 
