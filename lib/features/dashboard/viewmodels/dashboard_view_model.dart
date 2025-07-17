// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Provider para o DashboardViewModel
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardData>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Verifica se tem usuário autenticado
  final userId = authState.maybeWhen(
    authenticated: (user) => user.id,
    orElse: () => null,
  );
  
  return DashboardViewModel(repository, userId);
});

/// ViewModel para os dados do dashboard
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardData>> {
  /// Repositório para acesso aos dados
  final DashboardRepository _repository;
  
  /// ID do usuário atual
  final String? _userId;
  
  /// Construtor que inicializa o estado como loading e carrega os dados
  DashboardViewModel(this._repository, this._userId) 
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      debugPrint('📊 Dashboard inicializado para usuário: $_userId');
      loadDashboardData();
    } else {
      debugPrint('❌ Dashboard inicializado sem usuário autenticado');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
    }
  }
  
  /// Carrega os dados do dashboard
  Future<void> loadDashboardData() async {
    if (_userId == null) {
      debugPrint('❌ Tentativa de carregar dashboard sem usuário');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
      return;
    }
    
    // Marca como carregando
    state = const AsyncValue.loading();
    
    try {
      debugPrint('🔄 Carregando dados do dashboard para usuário: $_userId');
      // Carrega os dados do dashboard usando o novo formato
      final dashboardData = await _repository.getDashboardData(_userId!);
      
      // Atualiza o estado com os novos dados
      state = AsyncValue.data(dashboardData);
      
      debugPrint('✅ Dados do dashboard carregados com sucesso:');
      debugPrint('✅ - Total de treinos: ${dashboardData.totalWorkouts}');
      debugPrint('✅ - Duração total: ${dashboardData.totalDuration} minutos');
      debugPrint('✅ - Dias treinados no mês: ${dashboardData.daysTrainedThisMonth}');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar dados do dashboard: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Força uma atualização dos dados do dashboard
  Future<void> refreshData() async {
    try {
      await loadDashboardData();
      debugPrint('✅ Dados do dashboard atualizados com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar dados do dashboard: $e');
    }
  }
} 