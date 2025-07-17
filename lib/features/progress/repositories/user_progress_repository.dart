// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Provider para o repositório de progresso do usuário
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return UserProgressRepository(supabaseClient);
});

/// Classe responsável por gerenciar dados de progresso do usuário
class UserProgressRepository {
  /// Cliente Supabase para comunicação com o backend
  final SupabaseClient _client;
  
  /// Nome da tabela no Supabase
  static const String _tableName = 'user_progress';
  
  /// Construtor da classe
  UserProgressRepository(this._client);
  
  /// Obtém o progresso do usuário a partir do Supabase
  /// [userId] - ID do usuário para buscar o progresso
  Future<UserProgress> getProgressForUser(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .single();
          
      return UserProgress.fromJson(response);
    } catch (e, stackTrace) {
      // Se o registro não existe, tenta criar um novo
      if (e is PostgrestException && e.code == 'PGRST116') {
        // Erro de nenhum resultado encontrado
        // Criar um novo registro de progresso para este usuário
        return await _createInitialProgressForUser(userId);
      }
      
      // Outros erros
      throw AppException(
        message: 'Erro ao buscar progresso do usuário: ${e.toString()}',
      );
    }
  }
  
  /// Cria um registro inicial de progresso para um novo usuário
  Future<UserProgress> _createInitialProgressForUser(String userId) async {
    try {
      // Valores iniciais para um novo usuário
      final initialData = {
        'user_id': userId,
        'workouts': 0,
        'points': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'workouts_by_type': {},
        'total_duration': 0,
        'completed_challenges': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      // Insere o registro no Supabase
      final response = await _client
          .from(_tableName)
          .insert(initialData)
          .select()
          .single();
          
      return UserProgress.fromJson(response);
    } catch (e, stackTrace) {
      throw AppException(
        message: 'Erro ao criar registro de progresso: ${e.toString()}',
      );
    }
  }
  
  /// Atualiza o progresso após um novo treino
  Future<void> updateProgressAfterWorkout(String userId, WorkoutRecord workout) async {
    try {
      // Tenta usar a nova função RPC implementada no Supabase
      try {
        await _client.rpc(
          'update_progress_after_workout',
          params: {
            '_user_id': userId,
            '_workout_id': workout.id,
            '_duration_minutes': workout.durationMinutes,
            '_workout_type': workout.workoutType
          },
        );
        return; // Se a RPC funcionar, retorna com sucesso
      } catch (rpcError) {
        // Se falhar, cai no método alternativo (fallback)
        debugPrint('⚠️ Função RPC update_progress_after_workout falhou, usando método alternativo: $rpcError');
      }

      // Busca o progresso atual
      final currentProgress = await getProgressForUser(userId);
      
      // Obter o tipo de treino
      final workoutType = workout.workoutType ?? 'outros';
      
      // Atualizar o mapa de treinos por tipo
      final updatedWorkoutsByType = Map<String, int>.from(currentProgress.workoutsByType);
      updatedWorkoutsByType[workoutType] = (updatedWorkoutsByType[workoutType] ?? 0) + 1;
      
      // Preparar os dados para atualização
      final updatedData = {
        'workouts': currentProgress.totalWorkouts + 1,
        'points': currentProgress.totalPoints + _calculatePointsForWorkout(workout),
        'total_duration': currentProgress.totalDuration + (workout.durationMinutes ?? 0),
        'last_workout': workout.date.toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'workouts_by_type': updatedWorkoutsByType,
      };
      
      // Atualizar o registro no Supabase
      await _client
          .from(_tableName)
          .update(updatedData)
          .eq('user_id', userId);
    } catch (e) {
      // Registra o erro, mas não lança exceção para não interromper o fluxo principal
      debugPrint('⚠️ Erro ao atualizar progresso, mas continuando: ${e.toString()}');
    }
  }
  
  /// Calcula os pontos ganhos por um treino com base na duração e intensidade
  int _calculatePointsForWorkout(WorkoutRecord workout) {
    final duration = workout.durationMinutes ?? 0;
    // Utilizamos um valor padrão para intensidade já que o modelo não tem mais essa propriedade
    const intensity = 1.0;
    
    // Cálculo básico: duração × intensidade
    return (duration * intensity).round();
  }
  
  /// Sincroniza o progresso a partir de todos os registros de treino
  /// Útil para recalcular estatísticas ou corrigir dados inconsistentes
  Future<void> syncProgressFromWorkoutRecords(String userId) async {
    try {
      // Buscar todos os treinos do usuário
      final workouts = await _client
          .from('workout_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
          
      final workoutRecords = workouts
          .map((record) => WorkoutRecord.fromJson(record))
          .toList();
          
      // Calcular estatísticas
      int totalWorkouts = workoutRecords.length;
      int totalPoints = 0;
      int totalDuration = 0;
      DateTime? lastWorkout;
      final Map<String, int> workoutsByType = {};
      final Map<String, int> monthlyWorkouts = {};
      final Map<String, int> weeklyWorkouts = {};
      
      // Processar cada treino
      for (final workout in workoutRecords) {
        // Pontos totais
        totalPoints += _calculatePointsForWorkout(workout);
        
        // Duração total
        totalDuration += workout.durationMinutes ?? 0;
        
        // Último treino (já está ordenado por data, então o primeiro é o mais recente)
        if (lastWorkout == null || (workout.date.isAfter(lastWorkout))) {
          lastWorkout = workout.date;
        }
        
        // Contagem por tipo
        final type = workout.workoutType ?? 'outros';
        workoutsByType[type] = (workoutsByType[type] ?? 0) + 1;
        
        // Contagem por mês (formato "YYYY-MM")
        final monthKey = '${workout.date.year}-${workout.date.month.toString().padLeft(2, '0')}';
        monthlyWorkouts[monthKey] = (monthlyWorkouts[monthKey] ?? 0) + 1;
        
        // Contagem por semana (formato "YYYY-WW")
        // Número da semana no ano (1-53)
        final weekNumber = (workout.date.difference(DateTime(workout.date.year, 1, 1)).inDays / 7).floor() + 1;
        final weekKey = '${workout.date.year}-${weekNumber.toString().padLeft(2, '0')}';
        weeklyWorkouts[weekKey] = (weeklyWorkouts[weekKey] ?? 0) + 1;
      }
      
      // Calcular streak (dias consecutivos de treino)
      final currentStreak = _calculateCurrentStreak(workoutRecords);
      final longestStreak = _calculateLongestStreak(workoutRecords);
      
      // Preparar dados para atualização
      final updatedData = {
        'workouts': totalWorkouts,
        'points': totalPoints,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'workouts_by_type': workoutsByType,
        'total_duration': totalDuration,
        'last_workout': lastWorkout?.toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'monthly_workouts': monthlyWorkouts,
        'weekly_workouts': weeklyWorkouts,
        'days_trained_this_month': _calculateDaysTrainedThisMonth(workoutRecords),
      };
      
      // Atualizar ou criar registro
      await _client
          .from(_tableName)
          .upsert({
            'user_id': userId,
            ...updatedData
          })
          .select();
    } catch (e, stackTrace) {
      throw AppException(
        message: 'Erro ao sincronizar progresso: ${e.toString()}',
      );
    }
  }
  
  /// Calcula a sequência atual de dias consecutivos com treino
  int _calculateCurrentStreak(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Mapeia as datas de treino (apenas ano-mês-dia)
    final workoutDays = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Ordena decrescente (mais recente primeiro)
    
    // Pega a data mais recente
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Verifica se treinou hoje ou ontem para começar a streak
    int streakCount = 0;
    DateTime? lastDate;
    
    // Se treinou hoje, começa com 1
    if (workoutDays.isNotEmpty && workoutDays.first.isAtSameMomentAs(today)) {
      streakCount = 1;
      lastDate = today;
    } 
    // Se treinou ontem mas não hoje, ainda conta como streak (com 1 dia)
    else if (workoutDays.isNotEmpty && workoutDays.first.isAtSameMomentAs(yesterday)) {
      streakCount = 1;
      lastDate = yesterday;
    }
    // Se não treinou nem hoje nem ontem, já perdeu a streak
    else {
      return 0;
    }
    
    // Continua a verificar dias anteriores
    for (int i = 1; i < 1000; i++) { // Limite de 1000 dias para evitar loop infinito
      final checkDate = (lastDate ?? today).subtract(Duration(days: i));
      
      if (workoutDays.any((date) => date.isAtSameMomentAs(checkDate))) {
        streakCount++;
        lastDate = checkDate;
      } else {
        break; // Streak quebrada
      }
    }
    
    return streakCount;
  }
  
  /// Calcula a maior sequência histórica de treinos
  int _calculateLongestStreak(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Mapeia as datas de treino (apenas ano-mês-dia)
    final workoutDays = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Ordena crescente
    
    int currentStreak = 1;
    int longestStreak = 1;
    
    for (int i = 1; i < workoutDays.length; i++) {
      final prevDay = workoutDays[i - 1];
      final currentDay = workoutDays[i];
      
      // Verifica se os dias são consecutivos
      if (currentDay.difference(prevDay).inDays == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } 
      // Se o mesmo dia, ignora (não quebra a streak)
      else if (currentDay.difference(prevDay).inDays == 0) {
        continue;
      }
      // Se dias não consecutivos, reinicia a contagem
      else {
        currentStreak = 1;
      }
    }
    
    return longestStreak;
  }
  
  /// Calcula o número de dias com treino no mês atual
  int _calculateDaysTrainedThisMonth(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) return 0;
    
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    // Filtra treinos do mês atual e conta dias únicos
    final daysWithWorkouts = workouts
        .where((w) {
          final workoutMonth = DateTime(w.date.year, w.date.month);
          return workoutMonth.isAtSameMomentAs(currentMonth);
        })
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
        
    return daysWithWorkouts.length;
  }
} 