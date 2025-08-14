import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal_expanded.dart';
import 'package:ray_club_app/features/goals/models/goal_period_filter.dart';
import 'package:ray_club_app/features/goals/repositories/weekly_goal_expanded_repository.dart';
import 'package:ray_club_app/features/auth/providers/auth_providers.dart';

/// Estado das metas semanais expandidas
class WeeklyGoalExpandedState {
  final WeeklyGoalExpanded? currentGoal; // Primeira meta (compatibilidade)
  final List<WeeklyGoalExpanded> currentWeekGoals; // ✅ TODAS as metas da semana atual
  final List<WeeklyGoalExpanded> allGoals;
  final List<WeeklyGoalExpanded> filteredGoals; // 🗓️ Metas filtradas por período
  final GoalPeriodFilter currentFilter; // 🗓️ Filtro atual
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final bool isUpdating;
  final String? error;

  const WeeklyGoalExpandedState({
    this.currentGoal,
    this.currentWeekGoals = const [],
    this.allGoals = const [],
    this.filteredGoals = const [],
    this.currentFilter = GoalPeriodFilter.currentWeek,
    this.stats,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
  });

  WeeklyGoalExpandedState copyWith({
    WeeklyGoalExpanded? currentGoal,
    List<WeeklyGoalExpanded>? currentWeekGoals,
    List<WeeklyGoalExpanded>? allGoals,
    List<WeeklyGoalExpanded>? filteredGoals,
    GoalPeriodFilter? currentFilter,
    Map<String, dynamic>? stats,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    bool clearError = false,
  }) {
    return WeeklyGoalExpandedState(
      currentGoal: currentGoal ?? this.currentGoal,
      currentWeekGoals: currentWeekGoals ?? this.currentWeekGoals,
      allGoals: allGoals ?? this.allGoals,
      filteredGoals: filteredGoals ?? this.filteredGoals,
      currentFilter: currentFilter ?? this.currentFilter,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel para metas semanais expandidas
class WeeklyGoalExpandedViewModel extends StateNotifier<WeeklyGoalExpandedState> {
  final WeeklyGoalExpandedRepository _repository;
  final String? _userId;

  WeeklyGoalExpandedViewModel(this._repository, this._userId) 
      : super(const WeeklyGoalExpandedState()) {
    if (_userId != null) {
      loadCurrentGoal();
    }
  }

  /// Carrega meta da semana atual
  Future<void> loadCurrentGoal() async {
    if (_userId == null) {
      print('🔍 DEBUG: UserId é null, não carregando metas');
      return;
    }
    
    print('🔍 DEBUG: Iniciando carregamento de metas para userId: $_userId');
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      print('🔍 DEBUG: Chamando getAllCurrentWeekGoals...');
      // ✅ MÚLTIPLAS METAS: Carregar todas as metas da semana atual
      final currentWeekGoals = await _repository.getAllCurrentWeekGoals(_userId!);
      print('🔍 DEBUG: currentWeekGoals carregadas: ${currentWeekGoals.length} itens');
      
      final currentGoal = currentWeekGoals.isNotEmpty ? currentWeekGoals.first : null;
      print('🔍 DEBUG: currentGoal: ${currentGoal?.goalTitle ?? "nenhuma"}');
      
      print('🔍 DEBUG: Chamando getUserWeeklyGoals...');
      final allGoals = await _repository.getUserWeeklyGoals(_userId!);
      print('🔍 DEBUG: allGoals carregadas: ${allGoals.length} itens');
      
      print('🔍 DEBUG: Chamando getUserGoalStats...');
      final stats = await _repository.getUserGoalStats(_userId!);
      print('🔍 DEBUG: stats carregadas: $stats');
      
      state = state.copyWith(
        currentGoal: currentGoal,
        currentWeekGoals: currentWeekGoals,
        allGoals: allGoals,
        stats: stats,
        isLoading: false,
      );
      
      print('🔍 DEBUG: Estado atualizado com sucesso');
    } catch (e, stackTrace) {
      print('🚨 ERRO DEBUG: Falha ao carregar metas: $e');
      print('🚨 ERRO DEBUG: Stack trace: $stackTrace');
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cria meta a partir de preset
  Future<WeeklyGoalExpanded?> createPresetGoal(GoalPresetType presetType) async {
    if (_userId == null) return null;
    
    state = state.copyWith(isUpdating: true, clearError: true);
    
    try {
      final newGoal = await _repository.createPresetGoal(
        userId: _userId!,
        presetType: presetType,
      );
      
      // Recarregar dados após um pequeno delay para garantir que o banco processou
      await Future.delayed(const Duration(milliseconds: 500));
      await loadCurrentGoal();
      
      state = state.copyWith(isUpdating: false);
      return newGoal;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Cria meta personalizada
  Future<WeeklyGoalExpanded?> createCustomGoal({
    required String goalTitle,
    String? goalDescription,
    required GoalMeasurementType measurementType,
    required double targetValue,
    required String unitLabel,
  }) async {
    if (_userId == null) return null;
    
    state = state.copyWith(isUpdating: true, clearError: true);
    
    try {
      final newGoal = await _repository.createCustomGoal(
        userId: _userId!,
        goalTitle: goalTitle,
        goalDescription: goalDescription,
        measurementType: measurementType,
        targetValue: targetValue,
        unitLabel: unitLabel,
      );
      
      // Recarregar dados após um pequeno delay para garantir que o banco processou
      await Future.delayed(const Duration(milliseconds: 500));
      await loadCurrentGoal();
      
      state = state.copyWith(isUpdating: false);
      return newGoal;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Atualiza meta existente
  Future<bool> updateGoal({
    required String goalId,
    String? goalTitle,
    String? goalDescription,
    double? targetValue,
    String? unitLabel,
    GoalMeasurementType? measurementType,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    
    try {
      await _repository.updateGoal(
        goalId: goalId,
        goalTitle: goalTitle,
        goalDescription: goalDescription,
        targetValue: targetValue,
        unitLabel: unitLabel,
        measurementType: measurementType,
      );
      
      // Recarregar dados
      await loadCurrentGoal();
      
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Adiciona progresso à meta
  Future<bool> addProgress({
    required double value,
    GoalMeasurementType measurementType = GoalMeasurementType.minutes,
  }) async {
    if (_userId == null) return false;
    
    try {
      final success = await _repository.updateGoalProgress(
        userId: _userId!,
        addedValue: value,
        measurementType: measurementType,
      );
      
      if (success) {
        // Recarregar apenas a meta atual para refletir mudanças
        final updatedGoal = await _repository.getCurrentWeekGoal(_userId!);
        state = state.copyWith(currentGoal: updatedGoal);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 🔴 NOVO: Define progresso absoluto para check-ins (não soma, define)
  Future<bool> setCheckInProgress({
    required double absoluteValue,
    GoalMeasurementType measurementType = GoalMeasurementType.days,
  }) async {
    if (_userId == null) return false;
    
    print('🔍 DEBUG: setCheckInProgress - valor absoluto: $absoluteValue');
    
    try {
      final success = await _repository.setGoalProgressAbsolute(
        userId: _userId!,
        absoluteValue: absoluteValue,
        measurementType: measurementType,
      );
      
      if (success) {
        print('🔍 DEBUG: ✅ Progresso absoluto definido com sucesso!');
        // Recarregar dados após mudança
        await loadCurrentGoal();
      }
      
      return success;
    } catch (e) {
      print('🚨 DEBUG: ERRO ao definir progresso absoluto: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Marca meta como concluída
  Future<bool> completeGoal(String goalId) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    
    try {
      await _repository.completeGoal(goalId);
      await loadCurrentGoal();
      
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Desativa meta
  Future<bool> deactivateGoal(String goalId) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    
    try {
      await _repository.deactivateGoal(goalId);
      await loadCurrentGoal();
      
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Obtém ou cria meta padrão
  Future<WeeklyGoalExpanded?> getOrCreateDefaultGoal() async {
    if (_userId == null) return null;
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final goal = await _repository.getOrCreateWeeklyGoal(userId: _userId!);
      
      // Recarregar dados
      await loadCurrentGoal();
      
      state = state.copyWith(isLoading: false);
      return goal;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Força refresh dos dados
  Future<void> refresh() async {
    await loadCurrentGoal();
  }

  /// 🗓️ Filtrar metas por período
  Future<void> filterGoalsByPeriod(GoalPeriodFilter filter) async {
    if (_userId == null) return;
    
    try {
      print('🔍 DEBUG: Filtrando metas por período: ${filter.displayName}');
      
      state = state.copyWith(isLoading: true, clearError: true);
      
      final filteredGoals = await _repository.getGoalsByPeriod(_userId!, filter);
      
      state = state.copyWith(
        filteredGoals: filteredGoals,
        currentFilter: filter,
        isLoading: false,
      );
      
      print('🔍 DEBUG: ✅ Filtro aplicado: ${filteredGoals.length} metas encontradas');
    } catch (e) {
      print('🚨 DEBUG: Erro ao filtrar metas: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// 🗓️ Obter metas para exibição (baseado no filtro atual)
  List<WeeklyGoalExpanded> get displayGoals {
    return state.currentFilter == GoalPeriodFilter.currentWeek 
        ? state.currentWeekGoals 
        : state.filteredGoals;
  }
}

/// Provider do repositório
final weeklyGoalExpandedRepositoryProvider = Provider<WeeklyGoalExpandedRepository>((ref) {
  return WeeklyGoalExpandedRepository();
});

/// Provider do ViewModel
final weeklyGoalExpandedViewModelProvider = 
    StateNotifierProvider<WeeklyGoalExpandedViewModel, WeeklyGoalExpandedState>((ref) {
  final repository = ref.watch(weeklyGoalExpandedRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Extrair userId de forma segura do AuthState
  final userId = authState.whenOrNull(
    authenticated: (user) => user.id,
  );
  
  return WeeklyGoalExpandedViewModel(repository, userId);
});

/// Provider para meta atual (conveniência)
final currentWeeklyGoalProvider = Provider<WeeklyGoalExpanded?>((ref) {
  final state = ref.watch(weeklyGoalExpandedViewModelProvider);
  return state.currentGoal;
});

/// Provider para estatísticas (conveniência)
final weeklyGoalStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  final state = ref.watch(weeklyGoalExpandedViewModelProvider);
  return state.stats;
});

/// Provider para check se há meta ativa
final hasActiveWeeklyGoalProvider = Provider<bool>((ref) {
  final currentGoal = ref.watch(currentWeeklyGoalProvider);
  return currentGoal != null;
});

/// Provider para progresso da meta atual
final currentGoalProgressProvider = Provider<double>((ref) {
  final currentGoal = ref.watch(currentWeeklyGoalProvider);
  return currentGoal?.percentageCompleted ?? 0.0;
});

/// Provider para verificar se meta foi atingida
final isCurrentGoalAchievedProvider = Provider<bool>((ref) {
  final currentGoal = ref.watch(currentWeeklyGoalProvider);
  return currentGoal?.isAchieved ?? false;
}); 