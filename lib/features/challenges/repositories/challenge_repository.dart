// Project imports:
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../models/challenge_group.dart';
import '../models/challenge_check_in.dart';
import '../models/workout_record_with_user.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class para métodos opcionais
mixin OptionalChallengeRepositoryMethods {
  /// Obtém os convites de grupos pendentes para um usuário
  Future<List<ChallengeGroupInvite>> getPendingInvites(String userId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return [];
  }
  
  /// Obtém o número de dias consecutivos de check-in
  Future<int> getConsecutiveDaysCount(String userId, String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return 0;
  }
  
  /// Obtém a sequência atual através de função RPC
  Future<int> getCurrentStreak(String userId, String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return 0;
  }
  
  /// Registra um check-in do usuário no desafio
  Future<CheckInResult> recordChallengeCheckIn({
    required String challengeId,
    required String userId,
    String? workoutId,
    required String workoutName,
    required String workoutType,
    required DateTime date,
    required int durationMinutes,
  }) async {
    // Método opcional que pode ser implementado nas classes concretas
    return CheckInResult(
      challengeId: challengeId,
      userId: userId,
      points: 0,
      message: 'Método não implementado',
      createdAt: date,
      streak: 0,
    );
  }
  
  /// Adiciona pontos de bônus para o usuário
  Future<void> addBonusPoints(
    String userId,
    String challengeId,
    int points,
    String reason,
    String userName,
    String? userPhotoUrl,
  ) async {
    // Método opcional que pode ser implementado nas classes concretas
  }

  /// Obtém um stream de atualizações do ranking global de um desafio
  Stream<List<ChallengeProgress>> watchChallengeRanking({required String challengeId}) {
    // Método opcional que pode ser implementado nas classes concretas
    return Stream.value([]);
  }

  /// Obtém um stream de atualizações do ranking de um grupo específico
  Stream<List<ChallengeProgress>> watchGroupRanking(String groupId) {
    // Método opcional que pode ser implementado nas classes concretas
    return Stream.value([]);
  }

  /// Obtém os grupos que o usuário participa para um desafio específico
  Future<List<ChallengeGroup>> getUserGroups(String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return [];
  }

  /// Verifica se o usuário pode acessar um grupo específico
  Future<bool> canAccessGroup(String groupId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return false;
  }

  /// Exporta dados completos de um desafio para análise ou backup
  Future<Map<String, dynamic>> exportChallengeData(String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return {};
  }

  /// Habilita ou desabilita notificações para um desafio específico
  Future<bool> enableNotifications(String challengeId, bool enable) async {
    // Método opcional que pode ser implementado nas classes concretas
    return false;
  }
  
  /// Limpa o cache relacionado a um desafio específico
  Future<void> clearCache(String challengeId) async {
    // Implementação padrão vazia, a ser substituída nas classes concretas
  }

  /// Checks the cache for workout records
  Future<List<WorkoutRecordWithUser>?> _checkCacheForWorkouts(String cacheKey) async {
    // Implementação padrão vazia que pode ser sobrescrita
    return null;
  }
  
  /// Stores workout records in cache
  Future<void> _storeWorkoutsInCache(String cacheKey, List<WorkoutRecordWithUser> workouts) async {
    // Implementação padrão vazia que pode ser sobrescrita
  }
  
  /// Gets the total count of workout records for a challenge
  Future<int> getChallengeWorkoutsCount(String challengeId);
  
  /// Fetches all workout records for a specific challenge with user information
  /// Supports pagination with limit and offset parameters
  /// Uses cache to improve performance when reloading
  Future<List<WorkoutRecordWithUser>> getChallengeWorkoutRecords(
    String challengeId, {
    int limit = 20,
    int offset = 0,
    bool useCache = true,
  });
  
  /// Fetches workout records for a specific user in a specific challenge
  /// This is optimized to fetch only the workouts for a single user
  Future<List<WorkoutRecordWithUser>> getUserChallengeWorkoutRecords(
    String challengeId,
    String userId, {
    int limit = 50,
    bool useCache = false,
  });
}

/// Interface para operações de repositório de desafios
abstract class ChallengeRepository with OptionalChallengeRepositoryMethods {
  final SupabaseClient _client = Supabase.instance.client;
  
  /// Obtém todos os desafios
  Future<List<Challenge>> getChallenges();
  
  /// Obtém um desafio pelo ID
  Future<Challenge> getChallengeById(String id);
  
  /// Obtém desafios criados por um usuário específico
  Future<List<Challenge>> getUserChallenges({required String userId});
  
  /// Obtém desafios ativos (que ainda não terminaram)
  Future<List<Challenge>> getActiveChallenges();
  
  /// Obtém desafios ativos para um usuário específico
  Future<List<Challenge>> getUserActiveChallenges(String userId);
  
  /// Obtém o desafio oficial atual da Ray
  Future<Challenge?> getOfficialChallenge() async {
    try {
      final now = DateTime.now().toIso8601String();
      debugPrint('🔍 SupabaseChallengeRepository - Buscando desafio oficial, data atual: $now');
      
      final response = await _client
          .from('challenges')
          .select()
          .eq('is_official', true)
          .lte('start_date', now)  // Desafio já começou (start_date <= now)
          .gte('end_date', now)    // Desafio ainda não terminou (end_date >= now)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        debugPrint('ℹ️ Nenhum desafio oficial ativo encontrado');
        
        // Listar todos os desafios oficiais para diagnóstico
        final allOfficialChallenges = await _client
            .from('challenges')
            .select('id, title, start_date, end_date')
            .eq('is_official', true)
            .order('created_at', ascending: false);
            
        debugPrint('🔍 SupabaseChallengeRepository - Encontrados ${allOfficialChallenges.length} desafios oficiais no total');
        
        for (final challenge in allOfficialChallenges) {
          debugPrint('🔍 Desafio: ${challenge['title']}, início: ${challenge['start_date']}, fim: ${challenge['end_date']}');
        }
        
        return null;
      }
      
      debugPrint('✅ SupabaseChallengeRepository - Desafio oficial ativo encontrado: ${response[0]['title']}');
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao buscar desafio oficial: $e');
      throw Exception('Erro ao buscar desafio oficial: $e');
    }
  }
  
  /// Obtém todos os desafios oficiais
  Future<List<Challenge>> getOfficialChallenges();
  
  /// Obtém o desafio principal (em destaque)
  Future<Challenge?> getMainChallenge();
  
  /// Cria um novo desafio
  Future<Challenge> createChallenge(Challenge challenge);
  
  /// Atualiza um desafio existente
  Future<void> updateChallenge(Challenge challenge);
  
  /// Exclui um desafio
  Future<void> deleteChallenge(String id);
  
  /// Participa de um desafio
  Future<void> joinChallenge({required String challengeId, required String userId});
  
  /// Sai de um desafio
  Future<void> leaveChallenge({required String challengeId, required String userId});
  
  /// Retorna o progresso do usuário em um desafio específico
  Future<ChallengeProgress?> getUserProgress({
    required String challengeId,
    required String userId,
  });
  
  /// Verifica se o usuário está participando do desafio
  Future<bool> isUserParticipatingInChallenge({
    required String challengeId,
    required String userId,
  });
  
  /// Retorna o ranking de um desafio
  Future<List<ChallengeProgress>> getChallengeProgress(String challengeId);
  
  /// Atualiza o progresso de um usuário em um desafio
  Future<void> updateUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  });
  
  /// Cria um registro de progresso para um usuário em um desafio
  Future<void> createUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  });
  
  /// Adiciona pontos ao progresso do usuário em um desafio
  Future<void> addPointsToUserProgress({
    required String challengeId,
    required String userId,
    required int pointsToAdd,
  });
  
  /// Verifica se o usuário atual é administrador
  Future<bool> isCurrentUserAdmin();
  
  /// Alterna o status de administrador do usuário atual
  Future<void> toggleAdminStatus();
  
  /// Observa as mudanças de progresso de um desafio em tempo real
  Stream<List<ChallengeProgress>> watchChallengeParticipants(
    String challengeId, {
    int limit = 50,
    int offset = 0,
  });
  
  // Métodos novos para grupos
  
  /// Cria um novo grupo para um desafio
  Future<ChallengeGroup> createGroup({
    required String challengeId,
    required String creatorId,
    required String name,
    String? description,
  });
  
  /// Obtém um grupo pelo ID
  Future<ChallengeGroup> getGroupById(String groupId);
  
  /// Obtém todos os grupos que um usuário criou
  Future<List<ChallengeGroup>> getUserCreatedGroups(String userId);
  
  /// Obtém todos os grupos dos quais um usuário é membro
  Future<List<ChallengeGroup>> getUserMemberGroups(String userId);
  
  /// Atualiza informações de um grupo
  Future<void> updateGroup(ChallengeGroup group);
  
  /// Exclui um grupo
  Future<void> deleteGroup(String groupId);
  
  /// Obtém os membros de um grupo
  Future<List<String>> getGroupMembers(String groupId);
  
  /// Convida um usuário para um grupo
  Future<void> inviteUserToGroup(String groupId, String inviterId, String inviteeId);
  
  /// Responde a um convite de grupo
  Future<void> respondToGroupInvite(String inviteId, bool accept);
  
  /// Remove um usuário de um grupo
  Future<void> removeUserFromGroup(String groupId, String userId);
  
  /// Verifica se o usuário já fez check-in em uma data específica
  Future<bool> hasCheckedInOnDate(String userId, String challengeId, DateTime date);
  
  /// Verifica se o usuário já fez check-in hoje
  Future<bool> hasCheckedInToday(String userId, String challengeId);
  
  /// Obtém o ranking de um grupo específico
  Future<List<ChallengeProgress>> getGroupRanking(String groupId);
}

// O provider challengeRepositoryProvider foi movido para lib/features/challenges/providers/challenge_providers.dart
// Remover a definição duplicada

// Importação da implementação real, remova a definição duplicada aqui
// A implementação está no arquivo supabase_challenge_repository.dart 
