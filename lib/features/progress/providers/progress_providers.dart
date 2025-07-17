// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/progress/repositories/user_progress_repository.dart';

// Provider para o gerenciamento de progresso
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserProgressRepository(supabase);
});

// Provider para obter workouts para uma data específica
final userWorkoutsForDateProvider = FutureProvider.family<List<dynamic>, DateTime>((ref, date) async {
  // Retornar lista vazia para evitar erros
  return [];
});

// Provider para o streak do usuário
final userWorkoutStreakProvider = FutureProvider<int>((ref) async {
  // Retornar valor default para evitar erro
  return 0;
});

// Provider para contagem de treinos
final userWorkoutCountProvider = FutureProvider.family<int, int>((ref, days) async {
  // Retornar valor default para evitar erro
  return 0;
}); 