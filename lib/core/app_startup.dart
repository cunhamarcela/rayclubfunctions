// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/core/services/app_tracking_service.dart';

/// Inicializa listeners e componentes que dependem de autenticação
Future<void> initializeAppListeners(WidgetRef ref) async {
  debugPrint('🔄 Inicializando listeners do aplicativo');
  
  // Solicitar permissão de tracking após o app estar inicializado
  // Isso é feito aqui para garantir que o app esteja totalmente carregado
  await AppTrackingService.requestTrackingPermissionIfNeeded();
  
  // Verificar se o usuário está autenticado
  final authState = ref.read(authViewModelProvider);
  
  authState.whenOrNull(
    authenticated: (user) {
      debugPrint('👤 Usuário autenticado: ${user.id}');
      
      // Carregar dados do dashboard
      final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
      dashboardViewModel.loadDashboardData();
      debugPrint('📊 Carregamento inicial do dashboard iniciado');
      
      // Aqui podem ser adicionados outros listeners que dependem de autenticação
    },
  );
}

/// Inicializa components após mudança no estado de autenticação
void setupAuthStateChangeListener(WidgetRef ref) {
  ref.listen(authViewModelProvider, (previous, current) {
    current.whenOrNull(
      authenticated: (user) {
        debugPrint('👤 Autenticação detectada: ${user.id}');
        
        // Carregar dados do dashboard sempre que o usuário logar
        final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
        dashboardViewModel.loadDashboardData();
        debugPrint('📊 Carregamento do dashboard iniciado após login');
      },
    );
  });
} 