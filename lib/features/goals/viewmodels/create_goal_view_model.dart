// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../models/unified_goal_model.dart';
import '../repositories/unified_goal_repository.dart';

part 'create_goal_view_model.freezed.dart';

/// **ESTADO DO VIEWMODEL DE CRIAÇÃO DE METAS**
@freezed
class CreateGoalState with _$CreateGoalState {
  const factory CreateGoalState({
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    String? errorMessage,
  }) = _CreateGoalState;
}

/// **PROVIDER DO VIEWMODEL**
final createGoalViewModelProvider = StateNotifierProvider<CreateGoalViewModel, CreateGoalState>((ref) {
  final repository = ref.watch(unifiedGoalRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  return CreateGoalViewModel(
    repository: repository,
    authRepository: authRepository,
  );
});

/// **VIEWMODEL PARA CRIAÇÃO DE METAS - RAY CLUB**
/// 
/// **Data:** 30 de Janeiro de 2025 às 16:15
/// **Objetivo:** Gerenciar criação de metas personalizadas e pré-definidas
/// **Funcionalidades:**
/// 1. Criar meta personalizada (título livre)
/// 2. Criar meta pré-definida (categoria de exercício)
/// 3. Suporte a medição em minutos ou dias
/// 4. Integração automática com sistema de treinos
class CreateGoalViewModel extends StateNotifier<CreateGoalState> {
  final UnifiedGoalRepository _repository;
  final dynamic _authRepository; // IAuthRepository

  CreateGoalViewModel({
    required UnifiedGoalRepository repository,
    required dynamic authRepository,
  }) : 
    _repository = repository,
    _authRepository = authRepository,
    super(const CreateGoalState());

  /// **CRIAR NOVA META**
  /// Cria uma meta seguindo exatamente a especificação:
  /// - Meta personalizada: título livre + tipo de medição
  /// - Meta pré-definida: categoria + tipo de medição + integração automática
  Future<bool> createGoal({
    required String title,
    String? category, // null = meta personalizada
    required String measurementType, // 'minutes' ou 'days'
    required double targetValue,
    required bool isCustom,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // 1. Obter usuário atual
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw const AppException(
          message: 'Usuário não autenticado',
          code: 'auth_required',
        );
      }

      // 2. Determinar tipo de meta
      final goalType = _determineGoalType(isCustom, category, measurementType);
      
      // 3. Determinar unidade
      final unit = _determineUnit(measurementType, category);
      
      // 4. Criar objeto UnifiedGoal
      final goal = UnifiedGoal(
        id: const Uuid().v4(),
        userId: user.id,
        title: title,
        description: _generateDescription(title, category, measurementType, targetValue),
        type: goalType,
        category: category != null ? GoalCategory.fromString(category) : null,
        targetValue: targetValue,
        currentValue: 0.0,
        unit: unit,
        measurementType: measurementType,
        startDate: DateTime.now(),
        endDate: _calculateEndDate(),
        isCompleted: false,
        autoIncrement: !isCustom && category != null, // Auto-incremento apenas para metas pré-definidas
        createdAt: DateTime.now(),
      );

      // 5. Salvar no repositório
      await _repository.createGoal(goal);
      
      debugPrint('✅ Meta criada com sucesso: $title (${isCustom ? "personalizada" : category})');
      
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
      
    } catch (e) {
      final errorMessage = e is AppException 
          ? e.message 
          : 'Erro ao criar meta: ${e.toString()}';
          
      debugPrint('❌ Erro ao criar meta: $errorMessage');
      
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  /// **LIMPAR ESTADO**
  void clearState() {
    state = const CreateGoalState();
  }

  /// Determina o tipo de meta baseado nos parâmetros
  UnifiedGoalType _determineGoalType(bool isCustom, String? category, String measurementType) {
    if (isCustom) {
      return measurementType == 'days' 
          ? UnifiedGoalType.dailyHabit 
          : UnifiedGoalType.custom;
    } else {
      return measurementType == 'minutes' 
          ? UnifiedGoalType.weeklyMinutes 
          : UnifiedGoalType.workoutCategory;
    }
  }

  /// Determina a unidade baseada no tipo de medição
  GoalUnit _determineUnit(String measurementType, String? category) {
    switch (measurementType) {
      case 'minutes':
        return GoalUnit.minutos;
      case 'days':
        return GoalUnit.dias;
      default:
        return GoalUnit.unidade;
    }
  }

  /// Gera descrição automática para a meta
  String _generateDescription(String title, String? category, String measurementType, double targetValue) {
    if (category != null) {
      // Meta pré-definida
      final unit = measurementType == 'minutes' ? 'minutos' : 'dias';
      return 'Meta semanal de $category: ${targetValue.toInt()} $unit. '
             'Progresso atualizado automaticamente quando você registra treinos de $category.';
    } else {
      // Meta personalizada
      final unit = measurementType == 'minutes' ? 'minutos' : 'dias';
      return 'Meta personalizada: ${targetValue.toInt()} $unit por semana.';
    }
  }

  /// Calcula data de fim (1 semana a partir de hoje)
  DateTime _calculateEndDate() {
    return DateTime.now().add(const Duration(days: 7));
  }
}

/// **PROVIDER DO REPOSITÓRIO**
final unifiedGoalRepositoryProvider = Provider<UnifiedGoalRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseUnifiedGoalRepository(supabase);
});

