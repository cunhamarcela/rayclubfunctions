// Flutter imports:
import 'dart:math';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/models/workout_stats_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';

/// Interface do repositório para estatísticas de treinos
abstract class WorkoutStatsRepository {
  /// Obtém estatísticas do usuário atual
  Future<WorkoutStats> getUserWorkoutStats();
  
  /// Atualiza as estatísticas após um novo treino
  Future<WorkoutStats> updateStatsAfterWorkout(WorkoutRecord record);
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutStatsRepository implements WorkoutStatsRepository {
  final WorkoutRecordRepository _recordRepository;
  WorkoutStats? _cachedStats;

  MockWorkoutStatsRepository(this._recordRepository);

  @override
  Future<WorkoutStats> getUserWorkoutStats() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (_cachedStats != null) {
      return _cachedStats!;
    }
    
    // Buscar registros para calcular estatísticas reais
    try {
      final records = await _recordRepository.getUserWorkoutRecords();
      final stats = _calculateStats(records);
      
      _cachedStats = stats;
      return stats;
    } catch (e) {
      // Se falhar ao buscar registros, retornar estatísticas mockadas
      return _getMockStats();
    }
  }

  @override
  Future<WorkoutStats> updateStatsAfterWorkout(WorkoutRecord record) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Em um ambiente real, recalcularíamos as estatísticas com base nos registros
    // Para o mock, vamos apenas incrementar alguns valores
    
    final currentStats = await getUserWorkoutStats();
    
    _cachedStats = currentStats.copyWith(
      totalWorkouts: currentStats.totalWorkouts + 1,
      monthWorkouts: currentStats.monthWorkouts + 1,
      weekWorkouts: currentStats.weekWorkouts + 1,
      totalMinutes: currentStats.totalMinutes + record.durationMinutes,
      lastUpdatedAt: DateTime.now(),
    );
    
    return _cachedStats!;
  }
  
  /// Calcula estatísticas com base nos registros de treino
  WorkoutStats _calculateStats(List<WorkoutRecord> records) {
    if (records.isEmpty) {
      return WorkoutStats.empty('user123');
    }
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Filtrar registros por período
    final monthlyRecords = records.where((r) => r.date.isAfter(startOfMonth)).toList();
    final weeklyRecords = records.where((r) => r.date.isAfter(startOfWeek)).toList();
    
    // Estatísticas por dia da semana
    final weekdayStats = <String, int>{};
    final weekdayMinutes = <String, int>{};
    
    // Inicializar com zeros para todos os dias da semana
    for (var i = 1; i <= 7; i++) {
      final weekday = _getWeekdayName(i);
      weekdayStats[weekday] = 0;
      weekdayMinutes[weekday] = 0;
    }
    
    // Calcular estatísticas por dia da semana
    for (final record in records) {
      if (record.date.isAfter(now.subtract(const Duration(days: 30)))) {
        final weekday = _getWeekdayName(record.date.weekday);
        weekdayStats[weekday] = (weekdayStats[weekday] ?? 0) + 1;
        weekdayMinutes[weekday] = (weekdayMinutes[weekday] ?? 0) + record.durationMinutes;
      }
    }
    
    // Calcular streak atual (dias consecutivos com treino)
    final streakInfo = _calculateStreak(records);
    
    return WorkoutStats(
      userId: 'user123',
      totalWorkouts: records.length,
      monthWorkouts: monthlyRecords.length,
      weekWorkouts: weeklyRecords.length,
      totalMinutes: monthlyRecords.fold(0, (sum, r) => sum + r.durationMinutes),
      currentStreak: streakInfo.currentStreak,
      bestStreak: streakInfo.bestStreak,
      weekdayStats: weekdayStats,
      weekdayMinutes: weekdayMinutes,
      frequencyPercentage: _calculateFrequencyPercentage(monthlyRecords.length),
      lastUpdatedAt: DateTime.now(),
    );
  }
  
  /// Calcula a sequência atual e a melhor sequência
  ({int currentStreak, int bestStreak}) _calculateStreak(List<WorkoutRecord> records) {
    if (records.isEmpty) return (currentStreak: 0, bestStreak: 0);
    
    // Ordenar por data (mais recente primeiro)
    final sortedRecords = List<WorkoutRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // Converter para apenas datas (sem hora)
    final workoutDates = sortedRecords.map((r) => 
      DateTime(r.date.year, r.date.month, r.date.day)
    ).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (workoutDates.isEmpty) return (currentStreak: 0, bestStreak: 0);
    
    // Calcular streak atual
    int currentStreak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Verificar se treinou hoje ou ontem
    if (workoutDates.contains(today)) {
      currentStreak = 1;
      
      // Contar dias anteriores consecutivos
      var checkDate = yesterday;
      while (workoutDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else if (workoutDates.contains(yesterday)) {
      currentStreak = 1;
      
      // Contar dias anteriores consecutivos
      var checkDate = yesterday.subtract(const Duration(days: 1));
      while (workoutDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      currentStreak = 0;
    }
    
    // Calcular melhor streak histórico
    int bestStreak = currentStreak;
    int tempStreak = 0;
    
    for (int i = 0; i < workoutDates.length - 1; i++) {
      final diff = workoutDates[i].difference(workoutDates[i + 1]).inDays;
      
      if (diff == 1) {
        // Dias consecutivos
        tempStreak++;
      } else {
        // Quebra na sequência
        tempStreak = 0;
      }
      
      if (tempStreak > bestStreak) {
        bestStreak = tempStreak;
      }
    }
    
    return (currentStreak: currentStreak, bestStreak: max(bestStreak, 1));
  }
  
  /// Calcula porcentagem de frequência com base na meta (treinar 5x por semana)
  double _calculateFrequencyPercentage(int monthWorkouts) {
    // Meta: 20 treinos por mês (5 por semana)
    final target = 20;
    return ((monthWorkouts / target) * 100).clamp(0, 100);
  }
  
  /// Retorna o nome do dia da semana com base no índice (1 = segunda, 7 = domingo)
  String _getWeekdayName(int weekday) {
    const weekdays = ['', 'S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekdays[weekday];
  }
  
  /// Retorna o máximo entre dois valores
  int max(int a, int b) => a > b ? a : b;
  
  /// Retorna estatísticas mockadas para desenvolvimento
  WorkoutStats _getMockStats() {
    final weekdayStats = <String, int>{
      'S': 2,
      'M': 3,
      'T': 1,
      'W': 4,
      'T': 2,
      'F': 3,
      'S': 1,
    };
    
    final weekdayMinutes = <String, int>{
      'S': 45,
      'M': 85,
      'T': 30,
      'W': 120,
      'T': 60,
      'F': 90,
      'S': 20,
    };
    
    return WorkoutStats(
      userId: 'user123',
      totalWorkouts: 28,
      monthWorkouts: 16,
      weekWorkouts: 4,
      totalMinutes: 450,
      currentStreak: 3,
      bestStreak: 5,
      weekdayStats: weekdayStats,
      weekdayMinutes: weekdayMinutes,
      frequencyPercentage: 86.0,
      lastUpdatedAt: DateTime.now(),
    );
  }
}

/// Implementação com Supabase
class SupabaseWorkoutStatsRepository implements WorkoutStatsRepository {
  final SupabaseClient _supabaseClient;
  final WorkoutRecordRepository _recordRepository;

  SupabaseWorkoutStatsRepository(this._supabaseClient, this._recordRepository);

  @override
  Future<WorkoutStats> getUserWorkoutStats() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Tentar buscar estatísticas agregadas da visualização materializada
      final response = await _supabaseClient
          .from('workout_stats_view')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        // Temos estatísticas pré-calculadas
        return WorkoutStats.fromJson(response);
      }
      
      // Se não tiver estatísticas pré-calculadas, calcular com base nos registros
      final records = await _recordRepository.getUserWorkoutRecords();
      
      // Lógica de cálculo de estatísticas (similar ao mock)
      // Em produção, isso seria uma função complexa para calcular todas as estatísticas
      
      // Para simplificar, aqui usaremos a mesma implementação da versão mock
      final mockRepo = MockWorkoutStatsRepository(_recordRepository);
      return mockRepo._calculateStats(records);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      final mockRepo = MockWorkoutStatsRepository(_recordRepository);
      return mockRepo.getUserWorkoutStats();
    }
  }

  @override
  Future<WorkoutStats> updateStatsAfterWorkout(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Em produção, poderíamos ter um procedimento armazenado para atualizar as estatísticas
      // ou um gatilho que recalcula automaticamente quando novos registros são adicionados
      
      // Para nossa implementação, vamos recalcular todas as estatísticas
      return getUserWorkoutStats();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar estatísticas: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

/// Provider para o repositório de estatísticas de treino
final workoutStatsRepositoryProvider = Provider<WorkoutStatsRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final recordRepository = ref.watch(workoutRecordRepositoryProvider);
  return SupabaseWorkoutStatsRepository(supabaseClient, recordRepository);
}); 