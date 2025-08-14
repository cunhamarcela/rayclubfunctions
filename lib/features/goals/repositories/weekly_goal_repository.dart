import 'package:ray_club_app/core/errors/app_error.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository para gerenciar metas semanais
class WeeklyGoalRepository {
  final SupabaseClient _supabase;

  WeeklyGoalRepository({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  /// Obtém ou cria a meta semanal atual do usuário
  Future<WeeklyGoal> getOrCreateCurrentWeeklyGoal() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          'Usuário não autenticado',
          code: 'UNAUTHENTICATED',
        );
      }

      // ✅ USAR FUNÇÃO CRIADA: get_or_create_weekly_goal
      final response = await _supabase.rpc('get_or_create_weekly_goal', params: {
        'p_user_id': userId,
      });

      if (response == null || (response as List).isEmpty) {
        throw AppException(
          'Erro ao obter meta semanal',
          code: 'WEEKLY_GOAL_ERROR',
        );
      }

      final data = Map<String, dynamic>.from(response[0]);
      return _processWeeklyGoalData(data);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao buscar meta semanal: ${e.toString()}',
        code: 'WEEKLY_GOAL_FETCH_ERROR',
      );
    }
  }

  /// Atualiza a meta semanal do usuário
  Future<WeeklyGoal> updateWeeklyGoal(int goalMinutes) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          'Usuário não autenticado',
          code: 'UNAUTHENTICATED',
        );
      }

      // Validar entrada
      if (goalMinutes < 30 || goalMinutes > 1440) {
        throw AppException(
          'Meta deve estar entre 30 minutos e 24 horas',
          code: 'INVALID_GOAL_MINUTES',
        );
      }

      // ✅ CORREÇÃO: Usar parâmetros da função existente
      final response = await _supabase.rpc('update_weekly_goal', params: {
        'p_user_id': userId,
        'p_goal_minutes': goalMinutes,
      });

      if (response == null) {
        throw AppException(
          'Erro ao atualizar meta semanal',
          code: 'WEEKLY_GOAL_UPDATE_ERROR',
        );
      }

      // A função retorna o registro atualizado
      final data = Map<String, dynamic>.from(response);
      return _processWeeklyGoalData(data);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao atualizar meta semanal: ${e.toString()}',
        code: 'WEEKLY_GOAL_UPDATE_ERROR',
      );
    }
  }

  /// Adiciona minutos de treino à meta semanal
  Future<WeeklyGoal> addWorkoutMinutes(int minutes) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          'Usuário não autenticado',
          code: 'UNAUTHENTICATED',
        );
      }

      // ✅ CORREÇÃO: Usar parâmetros da função existente
      final response = await _supabase.rpc('add_workout_minutes_to_goal', params: {
        'p_user_id': userId,
        'p_minutes': minutes,
      });

      if (response == null) {
        throw AppException(
          'Erro ao adicionar minutos de treino',
          code: 'ADD_MINUTES_ERROR',
        );
      }

      // A função retorna o registro atualizado
      final data = Map<String, dynamic>.from(response);
      return _processWeeklyGoalData(data);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao adicionar minutos: ${e.toString()}',
        code: 'ADD_MINUTES_ERROR',
      );
    }
  }

  /// Obtém status da meta semanal (implementação direta)
  Future<WeeklyGoal> getWeeklyGoalStatus() async {
    try {
      // Usar mesma lógica do getOrCreateCurrentWeeklyGoal
      return await getOrCreateCurrentWeeklyGoal();
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao buscar status: ${e.toString()}',
        code: 'WEEKLY_GOAL_STATUS_ERROR',
      );
    }
  }

  /// Sincroniza treinos existentes da semana atual
  Future<Map<String, dynamic>> syncExistingWorkouts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          'Usuário não autenticado',
          code: 'UNAUTHENTICATED',
        );
      }

      // ✅ USAR FUNÇÃO CRIADA: sync_existing_workouts_to_weekly_goals
      final response = await _supabase.rpc('sync_existing_workouts_to_weekly_goals', params: {
        'p_user_id': userId,
      });

      if (response == null) {
        throw AppException(
          'Erro ao sincronizar treinos',
          code: 'SYNC_ERROR',
        );
      }

      final result = Map<String, dynamic>.from(response);
      debugPrint('🔄 Sincronização via RPC: ${result['message']}');
      
      return result;
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao sincronizar: ${e.toString()}',
        code: 'SYNC_ERROR',
      );
    }
  }

  /// Obtém histórico de metas semanais
  Future<List<WeeklyGoal>> getWeeklyGoalsHistory({int limit = 12}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          'Usuário não autenticado',
          code: 'UNAUTHENTICATED',
        );
      }

      // ✅ USAR FUNÇÃO EXISTENTE com parâmetros corretos
      final response = await _supabase.rpc('get_weekly_goals_history', params: {
        'p_user_id': userId,
        'p_limit': limit,
      });

      if (response == null) {
        return [];
      }

      final goals = (response as List).map((data) {
        final goalData = Map<String, dynamic>.from(data);
        goalData['user_id'] = userId; // Adicionar user_id que pode não vir da função
        return _processWeeklyGoalData(goalData);
      }).toList();

      return goals;
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao buscar histórico: ${e.toString()}',
        code: 'HISTORY_FETCH_ERROR',
      );
    }
  }

  /// Escuta mudanças em tempo real na meta semanal atual
  Stream<WeeklyGoal?> watchCurrentWeeklyGoal() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value(null);
    }

    final weekStart = _getWeekStart();
    
    return _supabase
        .from('weekly_goals')
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filtrar manualmente pelos critérios
          final filtered = data.where((item) =>
            item['user_id'] == userId &&
            item['week_start_date'] == weekStart.toIso8601String().split('T')[0]
          ).toList();
          
          if (filtered.isEmpty) return null;
          
          final goalData = Map<String, dynamic>.from(filtered.first);
          return _processWeeklyGoalData(goalData);
        });
  }

  /// Processa dados da weekly goal para formato consistente
  WeeklyGoal _processWeeklyGoalData(Map<String, dynamic> data) {
    // Converter datas se necessário
    if (data['week_start_date'] is String) {
      data['week_start_date'] = DateTime.parse(data['week_start_date']);
    }
    if (data['week_end_date'] is String) {
      data['week_end_date'] = DateTime.parse(data['week_end_date']);
    }
    
    // Calcular porcentagem
    final current = data['current_minutes'] as int? ?? 0;
    final goal = data['goal_minutes'] as int? ?? 180;
    data['percentage_completed'] = goal > 0 ? (current / goal) * 100.0 : 0.0;

    return WeeklyGoal.fromJson(data);
  }

  /// Obtém o início da semana atual (segunda-feira)
  DateTime _getWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
  }
} 