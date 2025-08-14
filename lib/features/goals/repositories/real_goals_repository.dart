// Package imports:
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/real_backend_goal_models.dart';

/// **REPOSITÓRIO REAL DE METAS - RAY CLUB**
/// 
/// **Data:** 29 de Janeiro de 2025 às 18:40
/// **Objetivo:** Usar as funções SQL que JÁ EXISTEM no backend
/// **Referência:** Diagnóstico - 26 funções SQL já implementadas
/// 
/// IMPORTANTE: Este repositório chama as funções REAIS do backend

abstract class RealGoalsRepository {
  // ===== METAS POR CATEGORIA (workout_category_goals) =====
  Future<List<WorkoutCategoryGoal>> getUserCategoryGoals(String userId);
  Future<WorkoutCategoryGoal> createOrUpdateCategoryGoal(String userId, String category, int goalMinutes);
  
  // ===== METAS SEMANAIS EXPANDIDAS (weekly_goals_expanded) =====
  Future<List<WeeklyGoalExpanded>> getUserWeeklyGoals(String userId);
  Future<WeeklyGoalExpanded> createWeeklyGoal(String userId, String goalType, String measurementType, String title, double targetValue, String unitLabel);
  
  // ===== METAS PERSONALIZADAS (personalized_weekly_goals) =====
  Future<PersonalizedWeeklyGoal?> getUserActiveGoal(String userId);
  Future<PersonalizedWeeklyGoal> createPresetGoal(String userId, String presetType);
  
  // ===== CHECK-INS E PROGRESSO =====
  Future<SqlFunctionResponse> registerCheckIn(String goalId, String userId, String? notes);
  Future<SqlFunctionResponse> addGoalProgress(String goalId, String userId, double valueAdded, String? notes, String? source);
  
  // ===== INTEGRAÇÃO COM TREINOS (já funciona automaticamente) =====
  // As funções SQL já fazem isso automaticamente via triggers:
  // - update_category_goals_on_workout_trigger
  // - sync_workout_to_weekly_goals_expanded_trigger
  // - workout_completed_update_weekly_goal
}

/// **IMPLEMENTAÇÃO SUPABASE - USA FUNÇÕES SQL EXISTENTES**
class SupabaseRealGoalsRepository implements RealGoalsRepository {
  final SupabaseClient _supabaseClient;

  SupabaseRealGoalsRepository(this._supabaseClient);

  /// Helper para converter DATE do PostgreSQL para DateTime
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue is String) {
      // PostgreSQL DATE vem como "YYYY-MM-DD"
      return DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      return dateValue;
    } else {
      throw ArgumentError('Tipo de data inválido: ${dateValue.runtimeType}');
    }
  }

  @override
  Future<List<WorkoutCategoryGoal>> getUserCategoryGoals(String userId) async {
    try {
      debugPrint('🎯 [Repository] ========== INICIANDO BUSCA SQL ==========');
      debugPrint('🎯 [Repository] Buscando metas de categoria para usuário: $userId');
      debugPrint('🎯 [Repository] Timestamp: ${DateTime.now()}');
      
      // Usar função SQL existente: get_user_category_goals()
      debugPrint('🎯 [Repository] Chamando função SQL: get_user_category_goals');
      debugPrint('🎯 [Repository] Parâmetros: {p_user_id: $userId}');
      
      final response = await _supabaseClient
          .rpc('get_user_category_goals', params: {'p_user_id': userId});

      debugPrint('✅ [Repository] Resposta recebida da função SQL');
      debugPrint('✅ [Repository] Resposta: $response');
      debugPrint('✅ [Repository] Tipo da resposta: ${response.runtimeType}');
      debugPrint('✅ [Repository] É nulo? ${response == null}');
      debugPrint('✅ [Repository] É lista? ${response is List}');
      
      if (response is List) {
        debugPrint('✅ [Repository] Tamanho da lista: ${response.length}');
      }

      if (response == null) {
        debugPrint('⚠️  [Repository] Resposta é nula, retornando lista vazia');
        return [];
      }

      return (response as List)
          .map((json) {
            try {
              debugPrint('🔍 DEBUG: Processando item: $json');
              
              // Verificar tipos dos campos problemáticos
              debugPrint('🔍 week_start_date tipo: ${json['week_start_date'].runtimeType}');
              debugPrint('🔍 week_end_date tipo: ${json['week_end_date'].runtimeType}');
              debugPrint('🔍 completed tipo: ${json['completed'].runtimeType}');
              
              return WorkoutCategoryGoal.fromJson({
                'id': json['id'].toString(),
                'userId': userId,
                'category': json['category'].toString(),
                'goalMinutes': json['goal_minutes'] is int ? json['goal_minutes'] : int.parse(json['goal_minutes'].toString()),
                'currentMinutes': json['current_minutes'] is int ? json['current_minutes'] : int.parse(json['current_minutes'].toString()),
                'percentageCompleted': json['percentage_completed'] is num ? json['percentage_completed'].toDouble() : double.parse(json['percentage_completed'].toString()),
                'weekStartDate': _parseDate(json['week_start_date']),
                'weekEndDate': _parseDate(json['week_end_date']),
                'isActive': true,
                'completed': json['completed'] is bool ? json['completed'] : json['completed'].toString().toLowerCase() == 'true',
                'createdAt': DateTime.now(),
                'updatedAt': DateTime.now(),
              });
            } catch (e, stackTrace) {
              debugPrint('❌ Erro ao processar item individual: $e');
              debugPrint('❌ Item problemático: $json');
              debugPrint('❌ Stack trace: $stackTrace');
              rethrow;
            }
          })
          .toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar metas de categoria: $e');
      throw AppException(message: 'Erro ao carregar metas de categoria');
    }
  }

  @override
  Future<WorkoutCategoryGoal> createOrUpdateCategoryGoal(
      String userId, String category, int goalMinutes) async {
    try {
      debugPrint('🎯 Criando/atualizando meta: $category = ${goalMinutes}min para usuário: $userId');
      
      // Usar função SQL existente: set_category_goal()
      final response = await _supabaseClient.rpc('set_category_goal', params: {
        'p_user_id': userId,
        'p_category': category,
        'p_goal_minutes': goalMinutes,
      });

      debugPrint('✅ Meta criada/atualizada: $response');
      debugPrint('✅ Tipo da resposta: ${response.runtimeType}');

      return WorkoutCategoryGoal.fromJson({
        'id': response['id'],
        'userId': userId,
        'category': response['category'],
        'goalMinutes': response['goal_minutes'],
        'currentMinutes': response['current_minutes'],
        'weekStartDate': DateTime.parse(response['week_start_date']),
        'weekEndDate': DateTime.parse(response['week_end_date']),
        'isActive': response['is_active'],
        'completed': response['completed'],
        'createdAt': DateTime.parse(response['created_at']),
        'updatedAt': DateTime.parse(response['updated_at']),
      });
    } catch (e) {
      debugPrint('❌ Erro ao criar meta de categoria: $e');
      throw AppException(message: 'Erro ao criar meta de categoria');
    }
  }

  @override
  Future<List<WeeklyGoalExpanded>> getUserWeeklyGoals(String userId) async {
    try {
      debugPrint('🎯 Buscando metas semanais para usuário: $userId');
      
      // Usar função SQL existente: get_user_weekly_goals()
      final response = await _supabaseClient
          .rpc('get_user_weekly_goals', params: {'p_user_id': userId});

      debugPrint('📊 Resposta get_user_weekly_goals: $response');

      if (response == null) return [];

      return (response as List)
          .map((json) => WeeklyGoalExpanded.fromJson({
                'id': json['id'],
                'userId': userId,
                'goalType': json['goal_type'],
                'measurementType': json['measurement_type'],
                'goalTitle': json['goal_title'],
                'goalDescription': json['goal_description'],
                'targetValue': json['target_value']?.toDouble() ?? 0.0,
                'currentValue': json['current_value']?.toDouble() ?? 0.0,
                'unitLabel': json['unit_label'],
                'weekStartDate': DateTime.parse(json['week_start_date']),
                'weekEndDate': DateTime.parse(json['week_end_date']),
                'completed': json['completed'],
                'active': true,
                'createdAt': DateTime.now(),
                'updatedAt': DateTime.now(),
              }))
          .toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar metas semanais: $e');
      throw AppException(message: 'Erro ao carregar metas semanais');
    }
  }

  @override
  Future<WeeklyGoalExpanded> createWeeklyGoal(String userId, String goalType, 
      String measurementType, String title, double targetValue, String unitLabel) async {
    try {
      debugPrint('🎯 Criando meta semanal: $title');
      
      // Usar função SQL existente: get_or_create_weekly_goal_expanded()
      final response = await _supabaseClient.rpc('get_or_create_weekly_goal_expanded', params: {
        'p_user_id': userId,
        'p_goal_type': goalType,
        'p_measurement_type': measurementType,
        'p_goal_title': title,
        'p_target_value': targetValue,
        'p_unit_label': unitLabel,
      });

      debugPrint('✅ Meta semanal criada: $response');

      final goalData = response[0]; // Função retorna array
      return WeeklyGoalExpanded.fromJson({
        'id': goalData['id'],
        'userId': userId,
        'goalType': goalData['goal_type'],
        'measurementType': goalData['measurement_type'],
        'goalTitle': goalData['goal_title'],
        'goalDescription': goalData['goal_description'],
        'targetValue': goalData['target_value']?.toDouble() ?? 0.0,
        'currentValue': goalData['current_value']?.toDouble() ?? 0.0,
        'unitLabel': goalData['unit_label'],
        'weekStartDate': DateTime.parse(goalData['week_start_date']),
        'weekEndDate': DateTime.parse(goalData['week_end_date']),
        'completed': goalData['completed'],
        'active': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      debugPrint('❌ Erro ao criar meta semanal: $e');
      throw AppException(message: 'Erro ao criar meta semanal');
    }
  }

  @override
  Future<PersonalizedWeeklyGoal?> getUserActiveGoal(String userId) async {
    try {
      debugPrint('🎯 Buscando meta ativa para usuário: $userId');
      
      // Usar função SQL existente: get_user_active_goal()
      final response = await _supabaseClient
          .rpc('get_user_active_goal', params: {'p_user_id': userId});

      debugPrint('📊 Resposta get_user_active_goal: $response');

      if (response == null || response['success'] == false) {
        debugPrint('ℹ️ Nenhuma meta ativa encontrada');
        return null;
      }

      final goalData = response['goal'];
      return PersonalizedWeeklyGoal.fromJson({
        'id': goalData['id'],
        'userId': userId,
        'goalPresetType': 'custom',
        'goalTitle': goalData['title'],
        'goalDescription': goalData['description'],
        'measurementType': goalData['measurement_type'],
        'targetValue': goalData['target_value']?.toDouble() ?? 0.0,
        'currentProgress': goalData['current_progress']?.toDouble() ?? 0.0,
        'unitLabel': goalData['unit_label'],
        'incrementStep': goalData['increment_step']?.toDouble() ?? 1.0,
        'weekStartDate': DateTime.now(),
        'weekEndDate': DateTime.now().add(const Duration(days: 6)),
        'isActive': true,
        'isCompleted': goalData['is_completed'],
        'completedAt': null,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      debugPrint('❌ Erro ao buscar meta ativa: $e');
      return null;
    }
  }

  @override
  Future<PersonalizedWeeklyGoal> createPresetGoal(String userId, String presetType) async {
    try {
      debugPrint('🎯 Criando meta preset: $presetType');
      
      // Usar função SQL existente: create_preset_goal()
      final response = await _supabaseClient.rpc('create_preset_goal', params: {
        'p_user_id': userId,
        'p_preset_type': presetType,
      });

      debugPrint('✅ Meta preset criada: $response');

      if (response['success'] == false) {
        throw AppException(message: response['error'] ?? 'Erro ao criar meta preset');
      }

      // Buscar meta criada
      final activeGoal = await getUserActiveGoal(userId);
      if (activeGoal == null) {
        throw AppException(message: 'Meta criada mas não encontrada');
      }

      return activeGoal;
    } catch (e) {
      debugPrint('❌ Erro ao criar meta preset: $e');
      throw AppException(message: 'Erro ao criar meta preset');
    }
  }

  @override
  Future<SqlFunctionResponse> registerCheckIn(String goalId, String userId, String? notes) async {
    try {
      debugPrint('✅ Registrando check-in para meta: $goalId');
      
      // Usar função SQL existente: register_goal_checkin()
      final response = await _supabaseClient.rpc('register_goal_checkin', params: {
        'p_goal_id': goalId,
        'p_user_id': userId,
        'p_notes': notes,
      });

      debugPrint('✅ Check-in registrado: $response');
      return SqlFunctionResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao registrar check-in: $e');
      return SqlFunctionResponse(
        success: false,
        error: 'Erro ao registrar check-in: $e',
      );
    }
  }

  @override
  Future<SqlFunctionResponse> addGoalProgress(String goalId, String userId, 
      double valueAdded, String? notes, String? source) async {
    try {
      debugPrint('📈 Adicionando progresso: +$valueAdded para meta $goalId');
      
      // Usar função SQL existente: add_goal_progress()
      final response = await _supabaseClient.rpc('add_goal_progress', params: {
        'p_goal_id': goalId,
        'p_user_id': userId,
        'p_value_added': valueAdded,
        'p_notes': notes,
        'p_source': source,
      });

      debugPrint('✅ Progresso adicionado: $response');
      return SqlFunctionResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao adicionar progresso: $e');
      return SqlFunctionResponse(
        success: false,
        error: 'Erro ao adicionar progresso: $e',
      );
    }
  }
} 