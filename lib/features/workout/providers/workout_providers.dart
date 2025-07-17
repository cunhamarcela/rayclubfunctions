// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/user_workout_repository.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/core/providers/service_providers.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';
import 'package:ray_club_app/features/challenges/providers.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/features/progress/providers/progress_providers.dart';

/// Provider para acessar o repositório de treinos.
/// A classe SupabaseWorkoutRepository está definida dentro do arquivo workout_repository.dart
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = Supabase.instance.client;
  final repository = SupabaseWorkoutRepository(client);
  
  // Log para debug
  print('🔍 WorkoutRepositoryProvider: Usando ${repository.runtimeType}');
  
  return repository;
});

/// Provider para obter o repositório de registros de treinos do usuário
final userWorkoutRepositoryProvider = Provider<UserWorkoutRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final eventBus = ref.watch(appEventBusProvider);
  final offlineHelper = ref.watch(offlineRepositoryHelperProvider);
  return UserWorkoutRepository(supabaseClient, eventBus, offlineHelper);
});

/// Provider que retorna todos os registros de treino do usuário atual
final userWorkoutsProvider = FutureProvider<List<WorkoutRecord>>((ref) async {
  final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  final user = await authRepository.getCurrentUser();
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }
  
  debugPrint('🔍 userWorkoutsProvider: Buscando treinos para usuário ${user.id}');
  final records = await workoutRecordRepository.getUserWorkoutRecords();
  debugPrint('✅ userWorkoutsProvider: Encontrados ${records.length} treinos');
  
  return records;
});

/// Provider que retorna os registros de treino para uma data específica
final userWorkoutsForDateProvider = FutureProvider.family<List<WorkoutRecord>, DateTime>((ref, date) async {
  final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  final user = await authRepository.getCurrentUser();
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }
  
  final allWorkouts = await workoutRecordRepository.getUserWorkoutRecords();
  
  // Filtra por data (comparando apenas dia, mês e ano)
  return allWorkouts.where((workout) {
    final workoutDate = workout.date;
    return workoutDate.year == date.year && 
           workoutDate.month == date.month && 
           workoutDate.day == date.day;
  }).toList();
});

/// Provider que retorna as estatísticas do usuário (dias de treino, frequência, etc)
final workoutStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  final user = await authRepository.getCurrentUser();
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }
  
  final allWorkouts = await workoutRecordRepository.getUserWorkoutRecords();
  
  // Calcular estatísticas
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final lastMonth = DateTime(now.year, now.month - 1);
  
  final workoutsThisMonth = allWorkouts.where((w) {
    final completedMonth = DateTime(w.date.year, w.date.month);
    return completedMonth.isAtSameMomentAs(currentMonth);
  }).toList();
  
  final workoutsLastMonth = allWorkouts.where((w) {
    final completedMonth = DateTime(w.date.year, w.date.month);
    return completedMonth.isAtSameMomentAs(lastMonth);
  }).toList();
  
  // Mapa de dias da semana (iniciando no domingo = 0)
  final Map<int, int> workoutsByWeekday = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  
  // Contagem de treinos por dia da semana
  for (final workout in allWorkouts) {
    final weekday = workout.date.weekday % 7; // 0-6 (Dom-Sáb)
    workoutsByWeekday[weekday] = (workoutsByWeekday[weekday] ?? 0) + 1;
  }
  
  // Calcular sequência atual
  final workoutDays = allWorkouts
      .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
      .toSet()
      .toList()
      ..sort((a, b) => b.compareTo(a)); // Ordenar descrescente
  
  int currentStreak = 0;
  if (workoutDays.isNotEmpty) {
    // Verificar se treinou hoje
    final today = DateTime(now.year, now.month, now.day);
    final hasWorkoutToday = workoutDays.contains(today);
    
    // Base da sequência
    currentStreak = hasWorkoutToday ? 1 : 0;
    
    // Check dias anteriores consecutivos
    if (workoutDays.isNotEmpty) {
      DateTime checkDate = hasWorkoutToday 
          ? today.subtract(const Duration(days: 1))
          : today;
      
      while (workoutDays.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
  }
  
  return {
    'totalWorkouts': allWorkouts.length,
    'workoutsThisMonth': workoutsThisMonth.length,
    'workoutsLastMonth': workoutsLastMonth.length,
    'currentStreak': currentStreak,
    'weekdayDistribution': workoutsByWeekday,
    'mostActiveWeekday': workoutsByWeekday.entries
        .reduce((curr, next) => curr.value > next.value ? curr : next)
        .key,
  };
});

// Provider workoutViewModelProvider foi movido para workout_view_model.dart

/// Provider para acesso ao histórico de treinos
final workoutHistoryProvider = Provider<WorkoutState>((ref) {
  return ref.watch(workoutViewModelProvider);
});

/// Provider para filtrar treinos por tipo
final workoutsByTypeProvider = Provider.family<List<WorkoutRecord>, String>((ref, type) {
  final workoutState = ref.watch(workoutViewModelProvider);
  
  return workoutState.maybeWhen(
    loaded: (workouts, filteredWorkouts, categories, filter) {
      if (type.isEmpty || type == 'Todos') {
        // Converter Workout para WorkoutRecord
        return filteredWorkouts.map((workout) => WorkoutRecord(
          id: workout.id,
          userId: '', // Será preenchido pelo repositório
          workoutId: workout.id,
          workoutName: workout.title,
          workoutType: workout.type,
          date: DateTime.now(),
          durationMinutes: workout.durationMinutes,
          notes: '',
          isCompleted: true,
          createdAt: DateTime.now(),
        )).toList();
      }
      
      final filtered = filteredWorkouts.where((workout) => 
        workout.type.toLowerCase() == type.toLowerCase()
      ).map((workout) => WorkoutRecord(
        id: workout.id,
        userId: '', // Será preenchido pelo repositório
        workoutId: workout.id,
        workoutName: workout.title,
        workoutType: workout.type,
        date: DateTime.now(),
        durationMinutes: workout.durationMinutes,
        notes: '',
        isCompleted: true,
        createdAt: DateTime.now(),
      )).toList();
      
      return filtered;
    },
    orElse: () => [],
  );
});

/// Provider para o repositório de registros de treino
final workoutRecordRepositoryProvider = Provider<WorkoutRecordRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final progressRepository = ref.watch(userProgressRepositoryProvider);
  return SupabaseWorkoutRecordRepository(supabase, progressRepository);
}); 