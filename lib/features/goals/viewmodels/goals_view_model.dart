// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';
import 'package:ray_club_app/features/goals/models/user_goal_mapper.dart';

/// Provider para o ViewModel de metas (usando GoalData para dashboard)
final goalsViewModelProvider = 
    StateNotifierProvider<GoalsViewModel, AsyncValue<List<GoalData>>>((ref) {
  return GoalsViewModel();
});

/// ViewModel para gerenciar metas do usuário (versão dashboard)
class GoalsViewModel extends StateNotifier<AsyncValue<List<GoalData>>> {
  final _supabase = Supabase.instance.client;
  
  GoalsViewModel() : super(const AsyncValue.loading()) {
    loadGoals();
  }
  
  /// Carrega todas as metas do usuário
  Future<void> loadGoals() async {
    try {
      debugPrint('🔄 Iniciando carregamento de metas...');
      state = const AsyncValue.loading();
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      debugPrint('📋 Usuário autenticado: $userId');
      
      final response = await _supabase
          .from('user_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      debugPrint('📊 Dados brutos do Supabase: $response');
      debugPrint('📊 Tipo do response: ${response.runtimeType}');
      debugPrint('📊 Total de metas encontradas: ${(response as List).length}');
      
      // Converter para GoalData usando a estrutura do dashboard
      final goals = <GoalData>[];
      
      for (int i = 0; i < (response as List).length; i++) {
        final json = response[i] as Map<String, dynamic>;
        debugPrint('🔍 Processando meta $i: ${json.keys.join(", ")}');
        
        try {
          // Verificar cada campo individualmente
          final id = json['id'];
          final title = json['title'];
          final currentValue = json['current_value'];
          final targetValue = json['target_value'];
          final unit = json['unit'];
          final isCompleted = json['is_completed'];
          final createdAt = json['created_at'];
          final updatedAt = json['updated_at'];
          
          debugPrint('  🔍 id: $id (${id.runtimeType})');
          debugPrint('  🔍 title: $title (${title.runtimeType})');
          debugPrint('  🔍 current_value: $currentValue (${currentValue.runtimeType})');
          debugPrint('  🔍 target_value: $targetValue (${targetValue.runtimeType})');
          debugPrint('  🔍 unit: $unit (${unit.runtimeType})');
          debugPrint('  🔍 is_completed: $isCompleted (${isCompleted.runtimeType})');
          debugPrint('  🔍 created_at: $createdAt (${createdAt.runtimeType})');
          debugPrint('  🔍 updated_at: $updatedAt (${updatedAt.runtimeType})');
          
          final goal = GoalData(
            id: id?.toString() ?? '',
            title: title?.toString() ?? '',
            currentValue: double.tryParse(currentValue?.toString() ?? '0') ?? 0.0,
            targetValue: double.tryParse(targetValue?.toString() ?? '1') ?? 1.0,
            unit: unit?.toString() ?? '',
            isCompleted: isCompleted == true,
            createdAt: DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(updatedAt?.toString() ?? '') ?? DateTime.now(),
          );
          
          goals.add(goal);
          debugPrint('  ✅ Meta $i processada com sucesso');
          
        } catch (e) {
          debugPrint('  ❌ Erro ao processar meta $i: $e');
          debugPrint('  📊 JSON da meta com erro: $json');
          rethrow;
        }
      }
      
      debugPrint('✅ Todas as metas processadas com sucesso: ${goals.length}');
      state = AsyncValue.data(goals);
      
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Postgres: $e');
      state = AsyncValue.error(
        AppException(
          message: 'Erro ao carregar metas',
          code: e.code ?? 'DATABASE_ERROR',
          originalError: e,
        ),
        StackTrace.current,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao carregar metas: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      state = AsyncValue.error(
        AppException(
          message: 'Erro inesperado ao carregar metas',
          code: 'UNKNOWN_ERROR',
          originalError: e,
        ),
        stackTrace,
      );
    }
  }
  
  /// Cria uma nova meta
  Future<void> createGoal({
    required String title,
    required String category,
    required double targetValue,
    required String unit,
    String? description,
    DateTime? deadline,
  }) async {
    try {
      debugPrint('🎯 Definindo meta: $targetValue $unit para categoria "$category"');
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      // CORREÇÃO: Usar a estrutura EXATA da tabela user_goals
      final newGoal = <String, dynamic>{
        'user_id': userId,
        'title': title,
        'target_value': targetValue,
        'current_value': 0.0,
        'unit': unit ?? '', // Garantir que não seja null
        'goal_type': category ?? 'custom', // Garantir que não seja null
        'start_date': DateTime.now().toIso8601String(),
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'progress_percentage': 0.0,
      };
      
      // Adicionar campos opcionais apenas se não forem null
      if (deadline != null) {
        newGoal['target_date'] = deadline.toIso8601String();
      }
      
      debugPrint('📤 Enviando dados para Supabase: ${newGoal.keys.join(", ")}');
      
      await _supabase.from('user_goals').insert(newGoal);
      
      debugPrint('✅ Meta criada com sucesso!');
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      debugPrint('❌ Erro inesperado ao definir meta: $e');
      throw AppException(
        message: 'Erro inesperado ao definir meta',
        code: 'CREATE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Atualiza uma meta existente
  Future<void> updateGoal({
    required String goalId,
    required String title,
    required String category,
    required double targetValue,
    required String unit,
    String? description,
    DateTime? deadline,
  }) async {
    try {
      final updates = {
        'title': title,
        'goal_type': category,
        'target_value': targetValue,
        'unit': unit,
        'target_date': deadline?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'progress_percentage': 0.0, // Será recalculado
      };
      
      await _supabase
          .from('user_goals')
          .update(updates)
          .eq('id', goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar meta',
        code: 'UPDATE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Atualiza o progresso de uma meta
  Future<void> updateGoalProgress(String goalId, double currentValue) async {
    try {
      // Buscar meta atual para calcular progresso
      final response = await _supabase
          .from('user_goals')
          .select('target_value')
          .eq('id', goalId)
          .single();
      
      final targetValue = double.tryParse(response['target_value']?.toString() ?? '1') ?? 1.0;
      final progressPercentage = targetValue > 0 ? (currentValue / targetValue * 100) : 0.0;
      final isCompleted = currentValue >= targetValue;
      
      await _supabase
          .from('user_goals')
          .update({
            'current_value': currentValue,
            'progress_percentage': progressPercentage,
            'is_completed': isCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      // Se falhar, recarrega
      await loadGoals();
      throw AppException(
        message: 'Erro ao atualizar progresso',
        code: 'UPDATE_PROGRESS_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Marca uma meta como concluída
  Future<void> completeGoal(String goalId) async {
    try {
      await _supabase
          .from('user_goals')
          .update({
            'is_completed': true,
            'progress_percentage': 100.0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao completar meta',
        code: 'COMPLETE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Exclui uma meta
  Future<void> deleteGoal(String goalId) async {
    try {
      await _supabase
          .from('user_goals')
          .delete()
          .eq('id', goalId);
      
      // Recarrega as metas
      await loadGoals();
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao excluir meta',
        code: 'DELETE_ERROR',
        originalError: e,
      );
    }
  }
  
  /// Busca uma meta específica pelo ID
  Future<GoalData?> getGoalById(String goalId) async {
    try {
      final response = await _supabase
          .from('user_goals')
          .select()
          .eq('id', goalId)
          .maybeSingle();
      
      if (response != null) {
        return GoalData(
          id: response['id']?.toString() ?? '',
          title: response['title']?.toString() ?? '',
          currentValue: double.tryParse(response['current_value']?.toString() ?? '0') ?? 0.0,
          targetValue: double.tryParse(response['target_value']?.toString() ?? '1') ?? 1.0,
          unit: response['unit']?.toString() ?? '',
          isCompleted: response['is_completed'] == true,
          createdAt: DateTime.tryParse(response['created_at']?.toString() ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(response['updated_at']?.toString() ?? '') ?? DateTime.now(),
        );
      }
      
      return null;
      
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar meta',
        code: 'GET_GOAL_ERROR',
        originalError: e,
      );
    }
  }
} 