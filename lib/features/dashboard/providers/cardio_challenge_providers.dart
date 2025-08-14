// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/services/cardio_challenge_service.dart';
import 'package:ray_club_app/features/dashboard/models/cardio_challenge_progress.dart';

/// Provider para o serviço do desafio de cardio
final cardioChallengeServiceProvider = Provider<CardioChallengeService>((ref) {
  return CardioChallengeService();
});

/// Provider para o progresso do usuário no desafio de cardio
final cardioChallengeProgressProvider = FutureProvider<CardioChallengeProgress>((ref) async {
  final service = ref.watch(cardioChallengeServiceProvider);
  return service.getUserChallengeProgress();
});

/// Provider para estatísticas rápidas do desafio (para widgets menores)
final cardioChallengeQuickStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(cardioChallengeServiceProvider);
  return service.getQuickChallengeStats();
});

/// Provider para forçar refresh dos dados do desafio
final cardioChallengeRefreshProvider = StateProvider<int>((ref) => 0);

/// Provider que escuta mudanças e atualiza automaticamente
final cardioChallengeProgressWithRefreshProvider = FutureProvider<CardioChallengeProgress>((ref) async {
  // Escuta o provider de refresh para invalidar quando necessário
  ref.watch(cardioChallengeRefreshProvider);
  
  final service = ref.watch(cardioChallengeServiceProvider);
  return service.getUserChallengeProgress();
});
