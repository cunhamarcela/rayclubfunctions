import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'repositories/challenge_repository.dart';
import 'providers/challenge_providers.dart';
import 'services/realtime_service.dart';
import 'viewmodels/challenge_view_model.dart';
import 'viewmodels/challenge_ranking_view_model.dart';
import 'models/challenge_state.dart';
import 'services/challenge_realtime_service.dart';
import '../auth/repositories/auth_repository.dart';
import '../../core/providers/providers.dart';

// Serviços
final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseRealtimeService(supabase);
});

// Adicionando provider para ChallengeRealtimeService
final challengeRealtimeServiceProvider = Provider<ChallengeRealtimeService>((ref) {
  final supabase = Supabase.instance.client;
  final repository = ref.watch(challengeRepositoryProvider);
  
  return ChallengeRealtimeService(supabase, repository);
});

// ViewModels
final challengeViewModelProvider = StateNotifierProvider<ChallengeViewModel, ChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final realtimeService = ref.watch(challengeRealtimeServiceProvider);
  
  return ChallengeViewModel(
    repository: repository,
    authRepository: authRepository,
    realtimeService: realtimeService,
    ref: ref,
  );
});

final challengeRankingViewModelProvider = StateNotifierProvider<ChallengeRankingViewModel, ChallengeRankingState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final realtimeService = ref.watch(realtimeServiceProvider);
  return ChallengeRankingViewModel(repository, realtimeService);
}); 