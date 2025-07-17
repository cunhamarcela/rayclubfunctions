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

      final response = await _supabase
          .rpc('get_or_create_weekly_goal', params: {'p_user_id': userId});

      if (response == null || (response as List).isEmpty) {
        throw AppException(
          'Erro ao obter meta semanal',
          code: 'WEEKLY_GOAL_ERROR',
        );
      }

      final data = response[0] as Map<String, dynamic>;
      
      // Converter datas de string para DateTime
      data['week_start_date'] = DateTime.parse(data['week_start_date']);
      data['week_end_date'] = DateTime.parse(data['week_end_date']);
      data['percentage_completed'] = double.tryParse(data['percentage_completed'].toString()) ?? 0.0;

      return WeeklyGoal.fromJson(data);
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

      final data = response as Map<String, dynamic>;
      
      // Converter datas
      data['week_start_date'] = DateTime.parse(data['week_start_date']);
      data['week_end_date'] = DateTime.parse(data['week_end_date']);
      
      // Calcular porcentagem
      final current = data['current_minutes'] as int;
      final goal = data['goal_minutes'] as int;
      data['percentage_completed'] = goal > 0 ? (current / goal) * 100 : 0.0;

      return WeeklyGoal.fromJson(data);
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

      final data = response as Map<String, dynamic>;
      
      // Converter datas
      data['week_start_date'] = DateTime.parse(data['week_start_date']);
      data['week_end_date'] = DateTime.parse(data['week_end_date']);
      
      // Calcular porcentagem
      final current = data['current_minutes'] as int;
      final goal = data['goal_minutes'] as int;
      data['percentage_completed'] = goal > 0 ? (current / goal) * 100 : 0.0;

      return WeeklyGoal.fromJson(data);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppException(
        'Erro ao adicionar minutos: ${e.toString()}',
        code: 'ADD_MINUTES_ERROR',
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

      final response = await _supabase.rpc('get_weekly_goals_history', params: {
        'p_user_id': userId,
        'p_limit': limit,
      });

      if (response == null) {
        return [];
      }

      final goals = (response as List).map((data) {
        final goalData = data as Map<String, dynamic>;
        
        // Converter datas
        goalData['week_start_date'] = DateTime.parse(goalData['week_start_date']);
        goalData['week_end_date'] = DateTime.parse(goalData['week_end_date']);
        goalData['percentage_completed'] = double.tryParse(goalData['percentage_completed'].toString()) ?? 0.0;
        
        // Adicionar user_id que não vem da função
        goalData['user_id'] = userId;

        return WeeklyGoal.fromJson(goalData);
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
          
          // Converter datas
          goalData['week_start_date'] = DateTime.parse(goalData['week_start_date']);
          goalData['week_end_date'] = DateTime.parse(goalData['week_end_date']);
          
          // Calcular porcentagem
          final current = goalData['current_minutes'] as int;
          final goal = goalData['goal_minutes'] as int;
          goalData['percentage_completed'] = goal > 0 ? (current / goal) * 100 : 0.0;
          
          return WeeklyGoal.fromJson(goalData);
        });
  }

  /// Obtém o início da semana atual (segunda-feira)
  DateTime _getWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
  }
} 