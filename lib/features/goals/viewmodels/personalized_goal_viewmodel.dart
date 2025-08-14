import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/auth/providers/auth_providers.dart';
import 'package:ray_club_app/features/goals/models/personalized_goal.dart';
import 'package:ray_club_app/features/goals/repositories/personalized_goal_repository.dart';
import 'package:ray_club_app/services/supabase_service.dart';
import 'package:ray_club_app/core/providers/providers.dart';

/// Estado das metas personalizáveis
class PersonalizedGoalState {
  final GoalStatus? currentGoal;
  final List<GoalCheckIn> weeklyCheckIns;
  final List<GoalProgressEntry> weeklyProgressEntries;
  final bool isLoading;
  final String? errorMessage;
  final bool isCreatingGoal;
  final bool isRegistering; // Para check-ins e progresso

  const PersonalizedGoalState({
    this.currentGoal,
    this.weeklyCheckIns = const [],
    this.weeklyProgressEntries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isCreatingGoal = false,
    this.isRegistering = false,
  });

  PersonalizedGoalState copyWith({
    GoalStatus? currentGoal,
    List<GoalCheckIn>? weeklyCheckIns,
    List<GoalProgressEntry>? weeklyProgressEntries,
    bool? isLoading,
    String? errorMessage,
    bool? isCreatingGoal,
    bool? isRegistering,
    bool clearError = false,
  }) {
    return PersonalizedGoalState(
      currentGoal: currentGoal ?? this.currentGoal,
      weeklyCheckIns: weeklyCheckIns ?? this.weeklyCheckIns,
      weeklyProgressEntries: weeklyProgressEntries ?? this.weeklyProgressEntries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCreatingGoal: isCreatingGoal ?? this.isCreatingGoal,
      isRegistering: isRegistering ?? this.isRegistering,
    );
  }

  /// Verifica se tem meta ativa
  bool get hasActiveGoal => currentGoal != null;

  /// Verifica se a meta é modalidade check
  bool get isCheckMode => currentGoal?.goal.measurementType.isCheckMode ?? false;

  /// Verifica se a meta é modalidade unidade
  bool get isUnitMode => currentGoal?.goal.measurementType.isUnitMode ?? false;

  /// Verifica se pode fazer check-in hoje
  bool get canCheckInToday {
    if (!isCheckMode) return false;
    return !(currentGoal?.hasCheckedInToday ?? false);
  }

  /// Percentual de progresso atual
  double get progressPercentage => currentGoal?.goal.progressPercentage ?? 0.0;

  /// Check-ins de hoje
  List<GoalCheckIn> get todayCheckIns {
    final today = DateTime.now();
    return weeklyCheckIns.where((checkIn) {
      return checkIn.checkInDate.year == today.year &&
             checkIn.checkInDate.month == today.month &&
             checkIn.checkInDate.day == today.day;
    }).toList();
  }

  /// Progresso de hoje
  double get todayProgress {
    final today = DateTime.now();
    return weeklyProgressEntries
        .where((entry) {
          return entry.entryDate.year == today.year &&
                 entry.entryDate.month == today.month &&
                 entry.entryDate.day == today.day;
        })
        .fold(0.0, (sum, entry) => sum + entry.valueAdded);
  }
}

/// Provider do repositório
final personalizedGoalRepositoryProvider = Provider<PersonalizedGoalRepository>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return PersonalizedGoalRepository(supabaseService);
});

/// ViewModel para metas personalizáveis
class PersonalizedGoalViewModel extends StateNotifier<PersonalizedGoalState> {
  final PersonalizedGoalRepository _repository;
  final Ref _ref;

  PersonalizedGoalViewModel(this._repository, this._ref) 
    : super(const PersonalizedGoalState());

  /// Carregar meta ativa do usuário
  Future<void> loadActiveGoal() async {
    final authState = _ref.read(authViewModelProvider);
    final userId = authState.whenOrNull(authenticated: (user) => user.id);
    
    if (userId == null) {
      state = state.copyWith(
        errorMessage: 'Usuário não autenticado',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final goalStatus = await _repository.getUserActiveGoal(userId);
      
      if (goalStatus != null) {
        // Carregar dados adicionais
        await _loadWeeklyData(userId, goalStatus.goal.id);
      }

      state = state.copyWith(
        currentGoal: goalStatus,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Criar meta pré-estabelecida
  Future<bool> createPresetGoal(PersonalizedGoalPresetType presetType) async {
    final authState = _ref.read(authViewModelProvider);
    final userId = authState.whenOrNull(authenticated: (user) => user.id);
    
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Usuário não autenticado');
      return false;
    }

    state = state.copyWith(isCreatingGoal: true, clearError: true);

    try {
      final goal = await _repository.createPresetGoal(userId, presetType);
      
      // Recarregar meta completa
      await loadActiveGoal();
      
      state = state.copyWith(isCreatingGoal: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isCreatingGoal: false,
      );
      return false;
    }
  }

  /// Criar meta personalizada
  Future<bool> createCustomGoal(CreateGoalData goalData) async {
    final authState = _ref.read(authViewModelProvider);
    final userId = authState.whenOrNull(authenticated: (user) => user.id);
    
    if (userId == null) {
      state = state.copyWith(errorMessage: 'Usuário não autenticado');
      return false;
    }

    state = state.copyWith(isCreatingGoal: true, clearError: true);

    try {
      final goal = await _repository.createCustomGoal(userId, goalData);
      
      // Recarregar meta completa
      await loadActiveGoal();
      
      state = state.copyWith(isCreatingGoal: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isCreatingGoal: false,
      );
      return false;
    }
  }

  /// Registrar check-in
  Future<bool> registerCheckIn({String? notes}) async {
    final authState = _ref.read(authViewModelProvider);
    final userId = authState.whenOrNull(authenticated: (user) => user.id);
    final goalId = state.currentGoal?.goal.id;
    
    if (userId == null || goalId == null) {
      state = state.copyWith(errorMessage: 'Dados inválidos para check-in');
      return false;
    }

    if (!state.canCheckInToday) {
      state = state.copyWith(errorMessage: 'Check-in já registrado hoje');
      return false;
    }

    state = state.copyWith(isRegistering: true, clearError: true);

    try {
      final response = await _repository.registerCheckIn(
        userId, 
        goalId, 
        notes: notes,
      );

      if (response.success) {
        // Recarregar dados
        await loadActiveGoal();
        state = state.copyWith(isRegistering: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'Erro ao registrar check-in',
          isRegistering: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isRegistering: false,
      );
      return false;
    }
  }

  /// Adicionar progresso numérico
  Future<bool> addProgress(double value, {String? notes}) async {
    final authState = _ref.read(authViewModelProvider);
    final userId = authState.whenOrNull(authenticated: (user) => user.id);
    final goalId = state.currentGoal?.goal.id;
    
    if (userId == null || goalId == null) {
      state = state.copyWith(errorMessage: 'Dados inválidos para progresso');
      return false;
    }

    if (!state.isUnitMode) {
      state = state.copyWith(errorMessage: 'Meta não é do tipo numérico');
      return false;
    }

    if (value <= 0) {
      state = state.copyWith(errorMessage: 'Valor deve ser positivo');
      return false;
    }

    state = state.copyWith(isRegistering: true, clearError: true);

    try {
      final response = await _repository.addProgress(
        userId, 
        goalId, 
        value, 
        notes: notes,
      );

      if (response.success) {
        // Recarregar dados
        await loadActiveGoal();
        state = state.copyWith(isRegistering: false);
        return true;
      } else {
        state = state.copyWith(
          errorMessage: response.error ?? 'Erro ao adicionar progresso',
          isRegistering: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isRegistering: false,
      );
      return false;
    }
  }

  /// Adicionar progresso com incremento automático
  Future<bool> addIncrementalProgress({String? notes}) async {
    final goal = state.currentGoal?.goal;
    if (goal == null) return false;
    
    return await addProgress(goal.incrementStep, notes: notes);
  }

  /// Carregar dados semanais (check-ins e progresso)
  Future<void> _loadWeeklyData(String userId, String goalId) async {
    try {
      final checkIns = await _repository.getWeeklyCheckIns(userId, goalId);
      final progressEntries = await _repository.getWeeklyProgressEntries(userId, goalId);
      
      state = state.copyWith(
        weeklyCheckIns: checkIns,
        weeklyProgressEntries: progressEntries,
      );
    } catch (e) {
      // Não propagar erro, apenas log
      print('Erro ao carregar dados semanais: $e');
    }
  }

  /// Refresh completo
  Future<void> refresh() async {
    await loadActiveGoal();
  }

  /// Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Obter sugestões de metas
  List<CreateGoalData> getSuggestedGoals() {
    return [
      CreateGoalData.projeto7Dias(),
      CreateGoalData.cardioCheck(),
      CreateGoalData.cardioMinutes(),
      CreateGoalData.hydrationSuggestion(),
    ];
  }

  /// Verificar se pode criar nova meta (se não tem meta ativa)
  bool get canCreateNewGoal => !state.hasActiveGoal && !state.isCreatingGoal;

  /// Obter texto motivacional baseado no progresso
  String get motivationalMessage {
    return state.currentGoal?.goal.motivationalMessage ?? 
           'Vamos criar sua primeira meta? 🌟';
  }

  /// Obter incremento sugerido para a meta atual
  double get suggestedIncrement {
    return state.currentGoal?.goal.measurementType.suggestedIncrement ?? 1.0;
  }
}

/// Provider do StateNotifier
final personalizedGoalViewModelProvider = 
  StateNotifierProvider<PersonalizedGoalViewModel, PersonalizedGoalState>((ref) {
  final repository = ref.read(personalizedGoalRepositoryProvider);
  return PersonalizedGoalViewModel(repository, ref);
});

// TODO: Implementar stream providers quando necessário
// Os providers de stream foram temporariamente comentados para resolver
// problemas de compilação. Podem ser adicionados depois.

/// Provider de conveniência para verificar se tem meta ativa
final hasActiveGoalProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(personalizedGoalViewModelProvider);
  return state.hasActiveGoal;
});

/// Provider de conveniência para verificar modalidade da meta
final goalModeProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(personalizedGoalViewModelProvider);
  
  if (!state.hasActiveGoal) return null;
  return state.isCheckMode ? 'check' : 'unit';
}); 