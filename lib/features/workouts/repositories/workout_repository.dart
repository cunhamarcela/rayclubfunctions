// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';

/// Repositório de treinos para manipular dados no Supabase
class WorkoutRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'workouts';
  final String _userWorkoutsTable = 'user_workouts';
  
  /// Busca todos os treinos disponíveis
  Future<List<Workout>> getAllWorkouts() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Busca treinos por tipo/categoria
  Future<List<Workout>> getWorkoutsByType(String type) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('type', type)
          .order('created_at', ascending: false);
      
      return response.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos por tipo',
        details: {'error': e.toString(), 'type': type},
      );
    }
  }
  
  /// Busca treinos populares para exibir na home
  Future<List<Workout>> getPopularWorkouts() async {
    final cacheService = CacheService();
    final cacheKey = 'popular_workouts';
    
    try {
      // Tenta pegar do cache primeiro
      final cachedData = cacheService.get(cacheKey);
      if (cachedData != null) {
        final List<dynamic> workoutList = cachedData;
        return workoutList.map((json) => Workout.fromJson(json)).toList();
      }
      
      // Se não estiver em cache, busca do Supabase
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_popular', true)
          .order('created_at', ascending: false);
      
      final workouts = response.map((json) => Workout.fromJson(json)).toList();
      
      // Salva no cache para futuras requisições
      cacheService.set(cacheKey, response, duration: const Duration(hours: 2));
      
      return workouts;
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos populares',
        details: {'error': e.toString()},
      );
    } catch (e) {
      throw AppException(
        message: 'Erro inesperado ao buscar treinos populares',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Busca treinos de um usuário específico
  Future<List<Workout>> getUserWorkouts(String userId) async {
    try {
      final response = await _client
          .from(_userWorkoutsTable)
          .select('*, workout:workout_id(*)')
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      
      return response.map((json) {
        final workoutData = json['workout'];
        // Adiciona data de conclusão do treino do usuário
        workoutData['completed_at'] = json['completed_at'];
        return Workout.fromJson(workoutData);
      }).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos do usuário',
        details: {'error': e.toString(), 'userId': userId},
      );
    }
  }
  
  /// Busca treinos de um usuário em uma data específica
  Future<List<Workout>> getUserWorkoutsForDate(String userId, DateTime date) async {
    try {
      // Calcular o início e fim do dia
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final response = await _client
          .from(_userWorkoutsTable)
          .select('*, workout:workout_id(*)')
          .eq('user_id', userId)
          .gte('completed_at', startOfDay.toIso8601String())
          .lte('completed_at', endOfDay.toIso8601String())
          .order('completed_at', ascending: false);
      
      return response.map((json) {
        final workoutData = json['workout'];
        // Adiciona data de conclusão do treino do usuário
        workoutData['completed_at'] = json['completed_at'];
        return Workout.fromJson(workoutData);
      }).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos do usuário para a data',
        details: {'error': e.toString(), 'userId': userId, 'date': date.toString()},
      );
    }
  }
  
  /// Busca um treino específico por ID
  Future<Workout?> getWorkoutById(String workoutId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', workoutId)
          .single();
      
      return Workout.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Registro não encontrado
        return null;
      }
      throw AppException(
        message: 'Erro ao buscar treino por ID',
        details: {'error': e.toString(), 'workoutId': workoutId},
      );
    } catch (e) {
      throw AppException(
        message: 'Erro inesperado ao buscar treino',
        details: {'error': e.toString(), 'workoutId': workoutId},
      );
    }
  }
  
  /// Conta o número de treinos de um usuário entre duas datas
  Future<int> countUserWorkouts({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .from(_userWorkoutsTable)
          .select('id')
          .eq('user_id', userId)
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String());
      
      return response.length;
    } catch (e) {
      throw AppException(
        message: 'Erro ao contar treinos do usuário',
        details: {
          'error': e.toString(),
          'userId': userId,
          'startDate': startDate.toString(),
          'endDate': endDate.toString()
        },
      );
    }
  }
  
  /// Calcula a sequência atual de dias com treinos do usuário
  Future<int> getUserWorkoutStreak(String userId) async {
    try {
      final today = DateTime.now();
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      
      // Busca treinos dos últimos 30 dias para cálculo da sequência
      final response = await _client
          .from(_userWorkoutsTable)
          .select('completed_at')
          .eq('user_id', userId)
          .gte('completed_at', thirtyDaysAgo.toIso8601String())
          .lte('completed_at', today.toIso8601String())
          .order('completed_at', ascending: false);
      
      if (response.isEmpty) {
        return 0;
      }
      
      // Converte as datas e agrupa por dia
      final Set<String> workoutDays = {};
      for (final workout in response) {
        final date = DateTime.parse(workout['completed_at']);
        workoutDays.add('${date.year}-${date.month}-${date.day}');
      }
      
      // Ordena em ordem decrescente
      final sortedDays = workoutDays.toList()
        ..sort((a, b) => b.compareTo(a));
      
      // Calcula a sequência atual
      int streak = 1;
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final yesterdayKey = '${today.subtract(const Duration(days: 1)).year}-'
          '${today.subtract(const Duration(days: 1)).month}-'
          '${today.subtract(const Duration(days: 1)).day}';
      
      // Se não treinou hoje nem ontem, começa do último dia que treinou
      if (!workoutDays.contains(todayKey) && !workoutDays.contains(yesterdayKey)) {
        return 0;
      }
      
      // Se treinou hoje, começa de hoje; se não, começa de ontem
      int currentDay = workoutDays.contains(todayKey) ? 0 : 1;
      
      // Verifica dias consecutivos
      while (currentDay < 30) {
        final checkDate = today.subtract(Duration(days: currentDay));
        final nextDate = today.subtract(Duration(days: currentDay + 1));
        
        final checkKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
        final nextKey = '${nextDate.year}-${nextDate.month}-${nextDate.day}';
        
        // Se o dia atual está presente e o próximo também, aumenta a sequência
        if (workoutDays.contains(checkKey) && workoutDays.contains(nextKey)) {
          streak++;
          currentDay++;
        } 
        // Se o dia atual está presente mas o próximo não, encerra a sequência
        else if (workoutDays.contains(checkKey) && !workoutDays.contains(nextKey)) {
          break;
        } 
        // Se o dia atual não está presente, encerra a sequência
        else {
          break;
        }
      }
      
      return streak;
    } catch (e) {
      throw AppException(
        message: 'Erro ao calcular sequência de treinos',
        details: {'error': e.toString(), 'userId': userId},
      );
    }
  }
  
  /// Registra um novo treino para o usuário
  Future<void> recordUserWorkout({
    required String userId,
    required String workoutId,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'workout_id': workoutId,
        'completed_at': completedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        ...?additionalData,
      };
      
      await _client.from(_userWorkoutsTable).insert(data);
    } catch (e) {
      throw AppException(
        message: 'Erro ao registrar treino do usuário',
        details: {'error': e.toString(), 'userId': userId, 'workoutId': workoutId},
      );
    }
  }
} 