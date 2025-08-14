// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/workout_category_goal.dart';

/// Provider para o repositório de metas por categoria
final workoutCategoryGoalsRepositoryProvider = Provider<WorkoutCategoryGoalsRepository>((ref) {
  return WorkoutCategoryGoalsRepository(Supabase.instance.client);
});

/// Interface para o repositório de metas por categoria
abstract class IWorkoutCategoryGoalsRepository {
  /// Obtém todas as metas ativas do usuário para a semana atual
  Future<List<WorkoutCategoryGoal>> getUserCategoryGoals();
  
  /// Define ou atualiza uma meta para uma categoria específica
  Future<WorkoutCategoryGoal> setCategoryGoal(String category, int goalMinutes);
  
  /// Obtém evolução semanal de uma categoria específica
  Future<List<WeeklyEvolution>> getWeeklyEvolution(String category, {int weeks = 8});
  
  /// Desativa uma meta específica
  Future<void> deactivateGoal(String goalId);
  
  /// Adiciona minutos de treino a uma categoria (chamado automaticamente via trigger)
  Future<WorkoutCategoryGoal?> addWorkoutMinutes(String category, int minutes);
}

/// Implementação do repositório usando Supabase
class WorkoutCategoryGoalsRepository implements IWorkoutCategoryGoalsRepository {
  final SupabaseClient _client;

  WorkoutCategoryGoalsRepository(this._client);

  @override
  Future<List<WorkoutCategoryGoal>> getUserCategoryGoals() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('🎯 Buscando metas por categoria para usuário: $userId');

      // Usar a função SQL para obter metas do usuário
      final response = await _client.rpc(
        'get_user_category_goals',
        params: {'p_user_id': userId},
      );

      if (response == null) {
        debugPrint('📊 Nenhuma meta encontrada para o usuário');
        return [];
      }

      // Converter resposta para lista de metas
      final goals = (response as List).map((data) {
        // 🔧 CORREÇÃO: Tratar valores null e usar campos corretos
        debugPrint('🔍 Processando dados da meta: $data');
        
        return WorkoutCategoryGoal.fromJson({
          'id': data['id']?.toString() ?? '',
          'userId': userId, // ✅ Corrigido: usar 'userId' não 'user_id'
          'category': data['category']?.toString() ?? '',
          'goalMinutes': data['goal_minutes']?.toInt() ?? 0,
          'currentMinutes': data['current_minutes']?.toInt() ?? 0,
          'weekStartDate': data['week_start_date']?.toString() ?? DateTime.now().toIso8601String(),
          'weekEndDate': data['week_end_date']?.toString() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'isActive': true,
          'completed': data['completed'] ?? false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }).toList();

      debugPrint('✅ ${goals.length} metas carregadas com sucesso');
      return goals;

    } on PostgrestException catch (e) {
      debugPrint('❌ Erro PostgreSQL ao carregar metas: ${e.message}');
      throw AppException(
        message: 'Erro ao carregar metas por categoria',
        code: e.code ?? 'DATABASE_ERROR',
        originalError: e,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao carregar metas: $e');
      throw AppException(
        message: 'Erro inesperado ao carregar metas',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutCategoryGoal> setCategoryGoal(String category, int goalMinutes) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      // Validar entrada
      if (category.trim().isEmpty) {
        throw AppException(
          message: 'Categoria não pode ser vazia',
          code: 'VALIDATION_ERROR',
        );
      }

      if (goalMinutes < 15 || goalMinutes > 1440) {
        throw AppException(
          message: 'Meta deve estar entre 15 e 1440 minutos (24 horas)',
          code: 'VALIDATION_ERROR',
        );
      }

      debugPrint('🎯 Definindo meta: $goalMinutes minutos para categoria "$category"');

      // Primeiro, verificar se a função SQL existe
      final functionExists = await _checkIfFunctionExists('set_category_goal');
      if (!functionExists) {
        throw AppException(
          message: 'Sistema de metas não foi configurado. Por favor, contate o administrador.',
          code: 'FUNCTION_NOT_FOUND',
        );
      }

      // Usar a função SQL para definir a meta
      final response = await _client.rpc(
        'set_category_goal',
        params: {
          'p_user_id': userId,
          'p_category': category.toLowerCase().trim(),
          'p_goal_minutes': goalMinutes,
        },
      );

      if (response == null) {
        throw AppException(
          message: 'Erro ao criar meta - resposta vazia do servidor',
          code: 'EMPTY_RESPONSE',
        );
      }

      // Verificar se a resposta tem os campos obrigatórios
      final responseMap = response as Map<String, dynamic>;
      if (responseMap['id'] == null) {
        throw AppException(
          message: 'Erro ao criar meta - ID não retornado',
          code: 'INVALID_RESPONSE',
        );
      }

      // Converter resposta para modelo com tratamento de nulls
      final goal = WorkoutCategoryGoal.fromJson({
        'id': responseMap['id']?.toString() ?? '',
        'userId': responseMap['user_id']?.toString() ?? userId, // ✅ Corrigido: userId
        'category': responseMap['category']?.toString() ?? category.toLowerCase().trim(),
        'goalMinutes': responseMap['goal_minutes'] ?? goalMinutes, // ✅ Corrigido: goalMinutes
        'currentMinutes': responseMap['current_minutes'] ?? 0, // ✅ Corrigido: currentMinutes
        'weekStartDate': responseMap['week_start_date']?.toString() ?? DateTime.now().toIso8601String(), // ✅ Corrigido
        'weekEndDate': responseMap['week_end_date']?.toString() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(), // ✅ Corrigido
        'isActive': responseMap['is_active'] ?? true, // ✅ Corrigido: isActive
        'completed': responseMap['completed'] ?? false,
        'createdAt': responseMap['created_at']?.toString() ?? DateTime.now().toIso8601String(), // ✅ Corrigido: createdAt
        'updatedAt': responseMap['updated_at']?.toString() ?? DateTime.now().toIso8601String(), // ✅ Corrigido: updatedAt
      });

      debugPrint('✅ Meta definida com sucesso: ${goal.categoryDisplayName} - ${goal.goalMinutesDisplay}');
      return goal;

    } on PostgrestException catch (e) {
      debugPrint('❌ Erro PostgreSQL ao definir meta: ${e.message}');
      throw AppException(
        message: 'Erro no banco de dados: ${e.message}',
        code: e.code ?? 'DATABASE_ERROR',
        originalError: e,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao definir meta: $e');
      if (e is AppException) rethrow;
      
      throw AppException(
        message: 'Erro inesperado ao definir meta: $e',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WeeklyEvolution>> getWeeklyEvolution(String category, {int weeks = 8}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('📈 Buscando evolução semanal para categoria "$category" (${weeks} semanas)');

      // Usar a função SQL para obter evolução semanal
      final response = await _client.rpc(
        'get_weekly_evolution_by_category',
        params: {
          'p_user_id': userId,
          'p_category': category.toLowerCase().trim(),
          'p_weeks': weeks,
        },
      );

      if (response == null) {
        debugPrint('📊 Nenhum dado de evolução encontrado');
        return [];
      }

      // Converter resposta para lista de evolução
      final evolution = (response as List).map((data) {
        return WeeklyEvolution.fromJson({
          'week_start_date': data['week_start_date'],
          'goal_minutes': data['goal_minutes'],
          'current_minutes': data['current_minutes'],
          'percentage_completed': (data['percentage_completed'] as num).toDouble(),
          'completed': data['completed'],
        });
      }).toList();

      debugPrint('✅ ${evolution.length} semanas de evolução carregadas');
      return evolution;

    } on PostgrestException catch (e) {
      debugPrint('❌ Erro PostgreSQL ao carregar evolução: ${e.message}');
      throw AppException(
        message: 'Erro ao carregar evolução semanal',
        code: e.code ?? 'DATABASE_ERROR',
        originalError: e,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao carregar evolução: $e');
      throw AppException(
        message: 'Erro inesperado ao carregar evolução',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deactivateGoal(String goalId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('🗑️ Desativando meta: $goalId');

      await _client
          .from('workout_category_goals')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId)
          .eq('user_id', userId);

      debugPrint('✅ Meta desativada com sucesso');

    } on PostgrestException catch (e) {
      debugPrint('❌ Erro PostgreSQL ao desativar meta: ${e.message}');
      throw AppException(
        message: 'Erro ao desativar meta',
        code: e.code ?? 'DATABASE_ERROR',
        originalError: e,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao desativar meta: $e');
      throw AppException(
        message: 'Erro inesperado ao desativar meta',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutCategoryGoal?> addWorkoutMinutes(String category, int minutes) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('➕ Adicionando $minutes minutos à categoria "$category"');

      // Usar a função SQL para adicionar minutos
      final response = await _client.rpc(
        'add_workout_minutes_to_category',
        params: {
          'p_user_id': userId,
          'p_category': category.toLowerCase().trim(),
          'p_minutes': minutes,
        },
      );

      if (response == null) {
        debugPrint('⚠️ Nenhuma meta encontrada para a categoria "$category"');
        return null;
      }

      // Converter resposta para modelo
      final goal = WorkoutCategoryGoal.fromJson({
        'id': response['id'],
        'user_id': response['user_id'],
        'category': response['category'],
        'goal_minutes': response['goal_minutes'],
        'current_minutes': response['current_minutes'],
        'week_start_date': response['week_start_date'],
        'week_end_date': response['week_end_date'],
        'is_active': response['is_active'],
        'completed': response['completed'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });

      debugPrint('✅ Meta atualizada: ${goal.currentMinutesDisplay}/${goal.goalMinutesDisplay}');
      return goal;

    } on PostgrestException catch (e) {
      debugPrint('❌ Erro PostgreSQL ao adicionar minutos: ${e.message}');
      // Não propagamos erro aqui pois é chamado automaticamente
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao adicionar minutos: $e');
      // Não propagamos erro aqui pois é chamado automaticamente
      return null;
    }
  }

  /// Obtém as categorias mais usadas pelo usuário
  Future<List<String>> getPopularCategories() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('workout_records')
          .select('workout_type')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      if (response == null || response.isEmpty) {
        return ['corrida', 'funcional', 'yoga']; // Categorias padrão
      }

      // Contar ocorrências e retornar as mais populares
      final Map<String, int> categoryCount = {};
      for (final record in response) {
        final category = (record['workout_type'] as String?)?.toLowerCase().trim();
        if (category != null && category.isNotEmpty) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }

      // Ordenar por popularidade e retornar top 10
      final sortedCategories = categoryCount.entries
          .where((entry) => entry.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final result = sortedCategories
          .take(10)
          .map((entry) => entry.key)
          .toList();

      return result.isNotEmpty ? result : ['corrida', 'funcional', 'yoga'];

    } catch (e) {
      debugPrint('⚠️ Erro ao buscar categorias populares: $e');
      return ['corrida', 'funcional', 'yoga']; // Fallback
    }
  }

  /// Verifica se uma função SQL existe no banco de dados
  Future<bool> _checkIfFunctionExists(String functionName) async {
    try {
      final result = await _client.rpc(
        'function_exists',
        params: {'function_name_param': functionName},
      );
      return result == true;
    } catch (e) {
      // Se a própria função de verificação não existir, assumir que a migração não foi aplicada
      debugPrint('⚠️ Função de verificação não encontrada, migração não foi aplicada');
      return false;
    }
  }
} 