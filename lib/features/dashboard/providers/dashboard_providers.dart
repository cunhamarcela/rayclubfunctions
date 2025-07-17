// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/benefits/repositories/redeemed_benefit_repository.dart';

/// Provider para acesso direto aos dados do dashboard
final dashboardDataProvider = Provider<AsyncValue<DashboardData>>((ref) {
  return ref.watch(dashboardViewModelProvider);
});

/// Provider para acesso ao total de treinos
final totalWorkoutsProvider = Provider<AsyncValue<int>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.totalWorkouts),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso à duração total de treinos
final totalDurationProvider = Provider<AsyncValue<int>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.totalDuration),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso aos dias treinados no mês
final daysTrainedThisMonthProvider = Provider<AsyncValue<int>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.daysTrainedThisMonth),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso aos treinos por tipo
final workoutsByTypeProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.workoutsByType),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso aos treinos recentes
final recentWorkoutsProvider = Provider<AsyncValue<List<WorkoutPreview>>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.recentWorkouts),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso ao progresso dos desafios
final challengeProgressProvider = Provider<AsyncValue<ChallengeProgress>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.challengeProgress),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para a data da última atualização
final lastUpdatedProvider = Provider<AsyncValue<DateTime>>((ref) {
  final dashboardAsync = ref.watch(dashboardViewModelProvider);
  return dashboardAsync.when(
    data: (data) => AsyncValue.data(data.lastUpdated),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider para acesso aos benefícios resgatados
final redeemedBenefitsProvider = FutureProvider.autoDispose<List<RedeemedBenefit>>((ref) async {
  final repository = ref.watch(redeemedBenefitRepositoryProvider);
  return repository.getUserRedeemedBenefits();
});

 