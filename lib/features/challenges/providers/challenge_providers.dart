// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/repositories/supabase_challenge_repository.dart';

/// Provider para o repositório de desafios
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabaseChallengeRepository(client, ref);
});

/// Provider para obter todos os desafios ativos
final activeChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getActiveChallenges();
});

/// Provider para obter desafios do usuário atual
final userChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Extrair o usuário usando o padrão when/maybeWhen
  final AppUser? currentUser = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (currentUser == null) {
    throw const AppException(
      code: 'auth-required',
      message: 'Você precisa estar autenticado para acessar seus desafios',
    );
  }
  
  return repository.getUserChallenges(userId: currentUser.id);
});

/// Provider para obter o progresso ativo dos desafios do usuário
final userActiveChallengesProvider = FutureProvider<List<ChallengeProgress>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Extrair o usuário usando o padrão when/maybeWhen
  final AppUser? currentUser = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (currentUser == null) {
    return [];
  }
  
  try {
    // Alterado para usar getUserActiveChallenges e então buscar o progresso de cada desafio individualmente
    final userChallenges = await repository.getUserActiveChallenges(currentUser.id);
    List<ChallengeProgress> allProgresses = [];
    
    // Para cada desafio, obter o progresso do usuário
    for (final challenge in userChallenges) {
      final progress = await repository.getUserProgress(
        challengeId: challenge.id,
        userId: currentUser.id,
      );
      if (progress != null) {
        allProgresses.add(progress);
      }
    }
    
    // Filtra apenas desafios em andamento (não completados)
    return allProgresses.where((progress) => !progress.completed).toList();
  } catch (e) {
    // Log do erro e retorna lista vazia para não quebrar a UI
    debugPrint('Erro ao carregar desafios ativos: $e');
    return [];
  }
});

/// Provider para obter progresso de desafios para uma data específica
/// Retorna uma lista de progressos de desafios onde o último check-in foi na data especificada
final challengeProgressForDateProvider = FutureProvider.family<List<ChallengeProgress>, DateTime>((ref, date) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Extrair o usuário usando o padrão when/maybeWhen
  final AppUser? currentUser = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (currentUser == null) {
    throw const AppException(
      code: 'auth-required',
      message: 'Você precisa estar autenticado para acessar seu progresso',
    );
  }
  
  final userId = currentUser.id;
  
  // Alterado para obter desafios do usuário e então buscar o progresso de cada um
  final userChallenges = await repository.getUserChallenges(userId: userId);
  List<ChallengeProgress> allProgress = [];
  
  // Para cada desafio, buscar o progresso
  for (final challenge in userChallenges) {
    final progress = await repository.getUserProgress(
      challengeId: challenge.id,
      userId: userId,
    );
    if (progress != null) {
      allProgress.add(progress);
    }
  }
  
  // Filtra os progressos que foram atualizados na data especificada
  return allProgress.where((progress) {
    if (progress.lastCheckIn == null) return false;
    final checkInDate = progress.lastCheckIn!;
    return checkInDate.year == date.year && 
           checkInDate.month == date.month && 
           checkInDate.day == date.day;
  }).toList();
});

/// Provider para monitorar o ranking global de um desafio
final challengeRankingProvider = StreamProvider.family<List<ChallengeProgress>, String>((ref, challengeId) {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.watchChallengeRanking(challengeId: challengeId);
});

/// Provider para obter o top 3 do ranking de um desafio (para o dashboard)
final challengeTopRankingProvider = FutureProvider.family<List<ChallengeProgress>, String>((ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  try {
    // Buscar o ranking completo do desafio
    final fullRanking = await repository.getChallengeProgress(challengeId);
    
    // ✅ USAR DADOS DIRETO DO BANCO (já vem ordenado por position):
    // Retornar os 3 primeiros ou menos, se a lista tiver menos de 3 elementos
    return fullRanking.take(3).toList();
  } catch (e) {
    debugPrint('Erro ao carregar top ranking do desafio: $e');
    return [];
  }
});

/// Provider para obter o progresso do usuário em um desafio específico
final userChallengeProgressProvider = FutureProvider.family<ChallengeProgress?, String>((ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Extrair o usuário usando o padrão when/maybeWhen
  final AppUser? currentUser = authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  if (currentUser == null) {
    throw const AppException(
      code: 'auth-required',
      message: 'Você precisa estar autenticado para acessar seu progresso',
    );
  }
  
  return repository.getUserProgress(
    userId: currentUser.id, 
    challengeId: challengeId,
  );
});

/// Provider para obter um desafio específico por ID
final challengeByIdProvider = FutureProvider.family<Challenge, String>((ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeById(challengeId);
}); 