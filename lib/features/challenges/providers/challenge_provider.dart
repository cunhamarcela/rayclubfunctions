// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../models/challenge_group.dart';
import '../repositories/challenge_repository.dart';
import './challenge_providers.dart'; // Adicionando import para o provider

// O provider challengeRepositoryProvider está definido em challenge_repository.dart
// Importe de lá para uso neste arquivo

// Provider para listar todos os desafios
final challengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallenges();
});

// Provider para listar desafios oficiais
final officialChallengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getOfficialChallenges();
});

// Provider específico para o desafio oficial principal (Ray 21)
final officialChallengeProvider = FutureProvider<Challenge?>((ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getOfficialChallenge();
});

// Provider para listar desafios de um usuário
final userChallengesProvider = FutureProvider.family<List<Challenge>, String>((ref, userId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getUserChallenges(userId: userId);
});

// Provider para listar desafios ativos de um usuário
final userActiveChallengesProvider = FutureProvider.family<List<Challenge>, String>((ref, userId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getUserActiveChallenges(userId);
});

// Provider para obter um desafio pelo ID
final challengeByIdProvider = FutureProvider.family<Challenge, String>((ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeById(challengeId);
});

// Provider para obter o progresso de um desafio
final challengeProgressProvider = FutureProvider.family<List<ChallengeProgress>, String>((ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeProgress(challengeId);
});

// Provider para obter grupos criados por um usuário
final userCreatedGroupsProvider = FutureProvider.family<List<ChallengeGroup>, String>((ref, userId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getUserCreatedGroups(userId);
});

// Provider para obter grupos dos quais um usuário é membro
final userMemberGroupsProvider = FutureProvider.family<List<ChallengeGroup>, String>((ref, userId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getUserMemberGroups(userId);
});

// Provider para obter convites pendentes de grupo para um usuário
final pendingGroupInvitesProvider = FutureProvider.family<List<ChallengeGroupInvite>, String>((ref, userId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getPendingInvites(userId);
});

// Provider para obter o ranking de um grupo específico
final groupRankingProvider = FutureProvider.family<List<ChallengeProgress>, String>(
  (ref, groupId) async {
    try {
      debugPrint('🔍 Buscando ranking para grupo: $groupId');
      final repository = ref.watch(challengeRepositoryProvider);
      return await repository.getGroupRanking(groupId);
    } catch (e) {
      debugPrint('⚠️ Erro ao buscar ranking do grupo $groupId: $e');
      // Retornar lista vazia quando grupo não for encontrado
      if (e.toString().contains('Grupo não encontrado')) {
        debugPrint('ℹ️ Grupo não encontrado, retornando lista vazia');
        return [];
      }
      // Propagar outros erros
      rethrow;
    }
  },
);

// Class para parâmetros compostos para o provider de progresso do usuário
class UserChallengeProgressParams {
  final String userId;
  final String challengeId;
  
  const UserChallengeProgressParams({
    required this.userId,
    required this.challengeId,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChallengeProgressParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          challengeId == other.challengeId;

  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode;
}

// Provider para obter o progresso de um usuário em um desafio específico
final userChallengeProgressProvider = FutureProvider.family<double, UserChallengeProgressParams>((ref, params) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final challenge = await repository.getChallengeById(params.challengeId);
  final userProgress = await repository.getUserProgress(
    challengeId: params.challengeId,
    userId: params.userId,
  );
  
  if (userProgress == null || challenge.points <= 0) {
    return 0.0;
  }
  
  // Para desafios oficiais, calculamos baseado no número total de dias
  if (challenge.isOfficial) {
    final totalDays = challenge.endDate.difference(challenge.startDate).inDays + 1;
    final checkInsCount = userProgress.checkInsCount ?? 0;
    return (checkInsCount / totalDays).clamp(0.0, 1.0);
  }
  
  // Para desafios normais, usamos os pontos
  return (userProgress.points / (challenge.points * 21)).clamp(0.0, 1.0);
});

/// Parâmetros para obter progresso do usuário
class UserProgressParams {
  final String userId;
  final String challengeId;
  
  const UserProgressParams({
    required this.userId,
    required this.challengeId,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          challengeId == other.challengeId;

  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode;
}

// A FutureProvider that fetches a specific challenge
final userProgressProvider = FutureProvider.family<ChallengeProgress?, UserProgressParams>((ref, params) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final userProgress = await repository.getUserProgress(
    challengeId: params.challengeId,
    userId: params.userId,
  );
  return userProgress;
}); 