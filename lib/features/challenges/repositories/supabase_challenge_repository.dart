// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/core/extensions/supabase_extensions.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/models/challenge_check_in.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/mappers/challenge_mapper.dart';
import 'package:ray_club_app/features/challenges/constants/challenge_rpc_params.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/core/extensions/date_extensions.dart';
import 'package:ray_club_app/features/challenges/models/workout_record_with_user.dart';

/// Exceção específica para erros de validação de dados.
class ValidationException extends AppException {
  const ValidationException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'validation_error',
          details: details,
        );
}

/// Exceção específica para erros de armazenamento (storage).
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'storage_error',
          details: details,
        );
}

// O provider challengeRepositoryProvider está definido em challenge_repository.dart
// Não duplique a definição aqui

/// Implementação do repositório de desafios usando Supabase
class SupabaseChallengeRepository implements ChallengeRepository {
  final SupabaseClient _client;
  final Ref? _ref;
  
  // Constantes para nomes de tabelas
  static const String _challengesTable = 'challenges';
  static const String _challengeProgressTable = 'challenge_progress';
  static const String _challengeParticipantsTable = 'challenge_participants';
  static const String _challengeGroupsTable = 'challenge_groups';
  static const String _challengeGroupMembersTable = 'challenge_group_members';
  static const String _challengeGroupInvitesTable = 'challenge_group_invites';
  static const String _challengeCheckInsTable = 'challenge_check_ins';
  static const String _challengeBonusesTable = 'challenge_bonuses';
  
  // Constante para bucket de imagens
  static const String _challengeImagesBucket = 'challenge_images';
  
  SupabaseChallengeRepository(this._client, [this._ref]);
  
  @override
  Future<List<Challenge>> getChallenges() async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios');
    }
  }
  
  @override
  Future<Challenge> getChallengeById(String id) async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('id', id)
          .single();
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response)) {
        return ChallengeMapper.fromSupabase(response);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar detalhes do desafio');
    }
  }
  
  @override
  Future<List<Challenge>> getUserChallenges({required String userId}) async {
    try {
      // Buscar IDs de desafios que o usuário participa
      final participantResponse = await _client
          .from(_challengeParticipantsTable)
          .select('challenge_id')
          .eq('user_id', userId);
      
      final challengeIds = participantResponse
          .map<String>((item) => item['challenge_id'] as String)
          .toList();
      
      if (challengeIds.isEmpty) {
        return [];
      }
      
      // Buscar detalhes dos desafios
      final challengesResponse = await _client
          .from(_challengesTable)
          .select()
          .filter('id', 'in', challengeIds)
          .order('created_at', ascending: false);
      
      return challengesResponse
          .map<Challenge>((json) => _mapSupabaseToChallenge(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios do usuário');
    }
  }
  
  @override
  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_challengesTable)
          .select()
          .lt('start_date', now)
          .gt('end_date', now)
          .order('created_at', ascending: false);
      
      return response
          .map<Challenge>((json) => _mapSupabaseToChallenge(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios ativos');
    }
  }
  
  @override
  Future<List<Challenge>> getUserActiveChallenges(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Buscar IDs de desafios ativos que o usuário participa
      final participantResponse = await _client
          .from(_challengeParticipantsTable)
          .select('challenge_id')
          .eq('user_id', userId);
      
      final challengeIds = participantResponse
          .map<String>((item) => item['challenge_id'] as String)
          .toList();
      
      if (challengeIds.isEmpty) {
        return [];
      }
      
      // Buscar detalhes dos desafios ativos
      final challengesResponse = await _client
          .from(_challengesTable)
          .select()
          .filter('id', 'in', challengeIds)
          .lt('start_date', now)
          .gt('end_date', now)
          .order('created_at', ascending: false);
      
      return challengesResponse
          .map<Challenge>((json) => _mapSupabaseToChallenge(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios ativos do usuário');
    }
  }
  
  @override
  Future<Challenge?> getOfficialChallenge() async {
    try {
      final now = DateTime.now().toIso8601String();
      debugPrint('🔍 SupabaseChallengeRepository - Buscando desafio oficial, data atual: $now');
      
      // Primeiro buscar sem restrições de data para fins de diagnóstico
      final oficialChallenges = await _client
          .from(_challengesTable)
          .select()
          .eq('is_official', true)
          .order('created_at', ascending: false);
      
      debugPrint('🔍 SupabaseChallengeRepository - Encontrados ${oficialChallenges.length} desafios oficiais no total');
      if (oficialChallenges.isNotEmpty) {
        for (final challenge in oficialChallenges) {
          debugPrint('🔍 Desafio: ${challenge['title']}, início: ${challenge['start_date']}, fim: ${challenge['end_date']}');
        }
      }
      
      // Buscar desafios oficiais ativos
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('is_official', true)
          .lte('start_date', now) // Começou antes ou exatamente agora
          .gte('end_date', now)   // Termina depois ou exatamente agora
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        debugPrint('⚠️ SupabaseChallengeRepository - Nenhum desafio oficial ativo encontrado');
        
        // Se não encontrar um desafio ativo, retornar o mais recente para fins de teste
        if (oficialChallenges.isNotEmpty) {
          debugPrint('ℹ️ SupabaseChallengeRepository - Retornando o último desafio oficial para testes');
          return Challenge.fromJson(oficialChallenges[0]);
        }
        
        return null;
      }
      
      debugPrint('✅ SupabaseChallengeRepository - Desafio oficial ativo encontrado: ${response[0]['title']}');
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response[0])) {
        return ChallengeMapper.fromSupabase(response[0]);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      debugPrint('❌ SupabaseChallengeRepository - Erro ao buscar desafio oficial: $e');
      throw _handleError(e, stackTrace, 'Erro ao buscar desafio oficial');
    }
  }
  
  /// Método auxiliar para mapear dados do Supabase para o modelo Challenge com segurança
  Challenge _mapSupabaseToChallenge(Map<String, dynamic> json) {
    // Usar o ChallengeMapper em vez da implementação manual
    return ChallengeMapper.fromSupabase(json);
  }
  
  @override
  Future<List<Challenge>> getOfficialChallenges() async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('is_official', true)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios oficiais');
    }
  }
  
  @override
  Future<Challenge?> getMainChallenge() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('is_featured', true)
          .lt('start_date', now)
          .gt('end_date', now)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        return null;
      }
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response[0])) {
        return ChallengeMapper.fromSupabase(response[0]);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafio em destaque');
    }
  }
  
  @override
  Future<Challenge> createChallenge(Challenge challenge) async {
    try {
      // Se houver uma imagem para o desafio, fazer o upload
      String? imageUrl = challenge.imageUrl;
      if (challenge.localImagePath != null) {
        imageUrl = await _uploadChallengeImage(
          File(challenge.localImagePath!),
          challenge.id,
        );
      }
      
      // Preparar dados para inserção
      final challengeData = challenge.toJson();
      challengeData['image_url'] = imageUrl;
      challengeData['created_at'] = DateTime.now().toIso8601String();
      challengeData['updated_at'] = DateTime.now().toIso8601String();
      
      // Remover campos que não são colunas na tabela
      challengeData.remove('local_image_path');
      
      final response = await _client
          .from(_challengesTable)
          .insert(challengeData)
          .select();
      
      if (response.isEmpty) {
        throw AppException(
          message: 'Erro ao criar desafio: nenhum dado retornado',
          code: 'insert_error',
        );
      }
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response[0])) {
        return ChallengeMapper.fromSupabase(response[0]);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao criar desafio');
    }
  }
  
  @override
  Future<void> updateChallenge(Challenge challenge) async {
    try {
      // Se houver uma nova imagem para o desafio, fazer o upload
      String? imageUrl = challenge.imageUrl;
      if (challenge.localImagePath != null) {
        imageUrl = await _uploadChallengeImage(
          File(challenge.localImagePath!),
          challenge.id,
        );
      }
      
      // Preparar dados para atualização
      final challengeData = challenge.toJson();
      if (imageUrl != null) {
        challengeData['image_url'] = imageUrl;
      }
      challengeData['updated_at'] = DateTime.now().toIso8601String();
      
      // Remover campos que não são colunas na tabela
      challengeData.remove('local_image_path');
      
      await _client
          .from(_challengesTable)
          .update(challengeData)
          .eq('id', challenge.id)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar desafio');
    }
  }
  
  @override
  Future<void> deleteChallenge(String id) async {
    try {
      // Primeiro deletar dados relacionados
      await _client
          .from(_challengeParticipantsTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      await _client
          .from(_challengeProgressTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      await _client
          .from(_challengeCheckInsTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      await _client
          .from(_challengeBonusesTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      // Por fim, deletar o desafio
      await _client
          .from(_challengesTable)
          .delete()
          .eq('id', id)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao deletar desafio');
    }
  }
  
  @override
  Future<void> joinChallenge({required String challengeId, required String userId}) async {
    try {
      // PATCH: Corrigir bug 6 - Garantir que o usuário apareça no desafio 
      debugPrint('🔄 Verificando participação no desafio $challengeId para usuário $userId');
      
      // Verificar se o desafio existe
      final challengeResponse = await _client
          .from(_challengesTable)
          .select()
          .eq('id', challengeId)
          .maybeSingle();
      
      if (challengeResponse == null) {
        throw ValidationException(message: 'Desafio não encontrado');
      }
      
      debugPrint('✅ Desafio encontrado: ${challengeResponse['title']}');
      
      // Verificar se o usuário já participa
      final checkResponse = await _client
          .from(_challengeParticipantsTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
      
      if (checkResponse.isNotEmpty) {
        // Usuário já participa, verificar se tem progresso
        debugPrint('ℹ️ Usuário já participa do desafio, verificando progresso');
        
        final checkProgress = await _client
            .from(_challengeProgressTable)
            .select()
            .eq('challenge_id', challengeId)
            .eq('user_id', userId)
            .maybeSingle();
            
        if (checkProgress == null) {
          debugPrint('⚠️ Progresso não encontrado, criando progresso inicial');
          
          // Buscar informações do usuário
          final userResponse = await _client
              .from('profiles')
              .select('name, photo_url')
              .eq('id', userId)
              .maybeSingle();
          
          String? userName = userResponse != null ? userResponse['name'] as String? : null;
          String? userPhotoUrl = userResponse != null ? userResponse['photo_url'] as String? : null;
          
          if (userName == null || userName.isEmpty) {
            userName = 'Usuário';
          }
          
          debugPrint('🔍 Dados do usuário: nome=$userName, foto=$userPhotoUrl');
          
          // Criar registro de progresso inicial
          await _client
              .from(_challengeProgressTable)
              .insert({
                'challenge_id': challengeId,
                'user_id': userId,
                'user_name': userName,
                'user_photo_url': userPhotoUrl,
                'points': 0,
                'completion_percentage': 0.0,
                'position': 0,
                'check_ins_count': 0,
                'consecutive_days': 0,
                'total_check_ins': 0,
                'completed': false,
                'last_check_in': null,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
              
          debugPrint('✅ Progresso inicial criado para o usuário no desafio');
        } else {
          debugPrint('✅ Usuário já tem progresso registrado no desafio: id=${checkProgress['id']}');
        }
        
        return;
      }
      
      debugPrint('ℹ️ Usuário não participa do desafio, adicionando...');
      
      // Buscar informações do usuário
      final userResponse = await _client
          .from('profiles')
          .select('name, photo_url')
          .eq('id', userId)
          .maybeSingle();
      
      String? userName = userResponse != null ? userResponse['name'] as String? : null;
      String? userPhotoUrl = userResponse != null ? userResponse['photo_url'] as String? : null;
      
      if (userName == null || userName.isEmpty) {
        userName = 'Usuário';
      }
      
      debugPrint('🔍 Dados do usuário: nome=$userName, foto=$userPhotoUrl');
      
      // Adicionar participante
      final participantResult = await _client
          .from(_challengeParticipantsTable)
          .insert({
            'challenge_id': challengeId,
            'user_id': userId,
            'joined_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      debugPrint('✅ Participante adicionado: id=${participantResult['id']}');
          
      // Criar registro de progresso inicial
      final progressResult = await _client
          .from(_challengeProgressTable)
          .insert({
            'challenge_id': challengeId,
            'user_id': userId,
            'user_name': userName,
            'user_photo_url': userPhotoUrl,
            'points': 0,
            'completion_percentage': 0.0,
            'position': 0,
            'check_ins_count': 0,
            'consecutive_days': 0,
            'total_check_ins': 0,
            'completed': false,
            'last_check_in': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
          
      debugPrint('✅ Progresso inicial criado: id=${progressResult['id']}');
      debugPrint('✅ Usuário adicionado ao desafio com sucesso e progresso inicial criado');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao participar do desafio: $e');
      throw _handleError(e, stackTrace, 'Erro ao participar do desafio');
    }
  }
  
  @override
  Future<void> leaveChallenge({required String challengeId, required String userId}) async {
    try {
      // PATCH: Corrigir bug 6 - Remover participação e progresso quando sair do desafio
      debugPrint('🔄 Removendo participação do usuário $userId no desafio $challengeId');
      
      // Remover participante
      await _client
          .from(_challengeParticipantsTable)
          .delete()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId);
          
      // Remover progresso para manter consistência
      await _client
          .from(_challengeProgressTable)
          .delete()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId);
          
      debugPrint('✅ Usuário removido do desafio com sucesso');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao sair do desafio: $e');
      throw _handleError(e, stackTrace, 'Erro ao sair do desafio');
    }
  }
  
  @override
  Future<void> updateUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  }) async {
    try {
      // Verificar se já existe um registro de progresso
      final checkResponse = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
      
      if (checkResponse.isEmpty) {
        // Se não existe, criar um novo
        await createUserProgress(
          challengeId: challengeId,
          userId: userId,
          userName: userName,
          userPhotoUrl: userPhotoUrl,
          points: points,
          completionPercentage: completionPercentage,
        );
        return;
      }
      
      // Atualizar progresso existente
      await _client
          .from(_challengeProgressTable)
          .update({
            'user_name': userName,
            'user_photo_url': userPhotoUrl,
            'points': points,
            'completion_percentage': completionPercentage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar progresso do usuário');
    }
  }
  
  @override
  Future<void> createUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  }) async {
    try {
      // Primeiro verificar se já existe um progresso para evitar conflitos
      final existingProgress = await getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (existingProgress != null) {
        debugPrint('⚠️ Progresso já existe, atualizando em vez de criar');
        // Se já existe, atualizar em vez de criar
        await _client
            .from(_challengeProgressTable)
            .update({
              'user_name': userName,
              'user_photo_url': userPhotoUrl,
              'points': points,
              'completion_percentage': completionPercentage,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('challenge_id', challengeId)
            .eq('user_id', userId);
        return;
      }
      
      // Se não existe, criar novo
      await _client
          .from(_challengeProgressTable)
          .insert({
            'challenge_id': challengeId,
            'user_id': userId,
            'user_name': userName,
            'user_photo_url': userPhotoUrl,
            'points': points,
            'completion_percentage': completionPercentage,
            'position': 0,
            'check_ins_count': 0,
            'consecutive_days': 0,
            'total_check_ins': 0,
            'completed': false,
            'last_check_in': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          
      debugPrint('✅ Progresso criado com sucesso para usuário $userId no desafio $challengeId');
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
        debugPrint('⚠️ Conflito ao criar progresso: $e');
        // Progresso já existe, ignorar erro de chave duplicada
        return;
      }
      LogUtils.error('Erro ao criar progresso do usuário: $e', error: e);
      throw _handleError(e, StackTrace.current, 'Erro ao criar progresso do usuário');
    }
  }
  
  @override
  Future<ChallengeProgress?> getUserProgress({
    required String challengeId,
    required String userId,
  }) async {
    try {
      // Forçar limpeza de cache com uma consulta preliminar
      debugPrint('🔄 Limpando cache antes de buscar progresso do usuário: $userId no desafio: $challengeId');
      await _client.from(_challengeProgressTable).select('id').limit(1);
      
      // Aguardar um momento para garantir consistência
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Buscar dados atualizados
      debugPrint('🔄 Buscando progresso atualizado');
      final response = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('⚠️ Progresso não encontrado para o usuário');
        return null;
      }
      
      debugPrint('✅ Progresso do usuário recebido: ${response['points']} pontos');
      return ChallengeProgress.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao buscar progresso do usuário: $e');
      return null;
    }
  }
  
  @override
  Future<bool> isUserParticipatingInChallenge({
    required String challengeId,
    required String userId,
  }) async {
    try {
      debugPrint('🔍 Verificando se o usuário $userId está participando do desafio $challengeId');
      
      final response = await _client
          .from(_challengeParticipantsTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .maybeSingle();
      
      final isParticipating = response != null;
      debugPrint('🔍 Usuário ${isParticipating ? 'ESTÁ' : 'NÃO ESTÁ'} participando do desafio');
      
      return isParticipating;
    } catch (e) {
      debugPrint('❌ Erro ao verificar participação do usuário: $e');
      return false;
    }
  }
  
  @override
  Future<List<ChallengeProgress>> getChallengeProgress(String challengeId) async {
    try {
      // Forçar limpeza de cache com uma consulta preliminar
      debugPrint('🔄 Limpando cache antes de buscar ranking do desafio: $challengeId');
      await _client.from(_challengeProgressTable).select('id').limit(1);
      
      // Aguardar um momento para garantir consistência
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Buscar dados atualizados
      debugPrint('🔄 Buscando ranking atualizado do desafio: $challengeId');
      final response = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          .order('position', ascending: true)  // ✅ Usar posição calculada pelo banco
          ;
      
      debugPrint('✅ Ranking atualizado recebido com ${response.length} participantes');
      return response
          .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar ranking do desafio');
    }
  }
  
  @override
  Stream<List<ChallengeProgress>> watchChallengeParticipants(
    String challengeId, {
    int limit = 50,
    int offset = 0,
  }) {
    try {
      return _client
          .from(_challengeProgressTable)
          .stream(primaryKey: ['challenge_id', 'user_id'])
          .eq('challenge_id', challengeId)
          .order('position', ascending: true)  // ✅ Usar posição calculada pelo banco
          .limit(limit)
          .map((data) {
            return data
                .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
                .toList();
          });
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao observar participantes do desafio');
    }
  }
  
  @override
  Future<List<ChallengeGroupInvite>> getPendingInvites(String userId) async {
    try {
      final response = await _client
          .from(_challengeGroupInvitesTable)
          .select('*, challenge_groups!inner(name)')
          .eq('invitee_id', userId)
          .eq('status', 0) // 0 = pendente, 1 = aceito, 2 = recusado
          ;
      
      return (response as List).map<ChallengeGroupInvite>((item) {
        // Criar um mapa combinado com as informações necessárias
        final combinedData = <String, dynamic>{
          ...item as Map<String, dynamic>,
          'groupName': item['challenge_groups']['name'],
        };
        return ChallengeGroupInvite.fromJson(combinedData);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar convites pendentes');
    }
  }
  
  @override
  Future<bool> isCurrentUserAdmin() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }
      
      final response = await _client
          .rpc('is_admin', params: {'user_id': userId})
          ;
      
      return response ?? false;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao verificar status de admin');
    }
  }
  
  @override
  Future<void> toggleAdminStatus() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      await _client
          .rpc('toggle_admin_status', params: {'user_id': userId})
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao alterar status de admin');
    }
  }
  
  @override
  Future<ChallengeGroup> createGroup({
    required String challengeId,
    required String creatorId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _client
          .from(_challengeGroupsTable)
          .insert({
            'challenge_id': challengeId,
            'creator_id': creatorId,
            'name': name,
            'description': description,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          ;
      
      if (response.isEmpty) {
        throw AppException(
          message: response.error!.message,
          code: response.error!.code,
        );
      }
      
      final groupId = response[0]['id'];
      
      // Adicionar o criador como membro do grupo
      await _client
          .from(_challengeGroupMembersTable)
          .insert({
            'group_id': groupId,
            'user_id': creatorId,
            'joined_at': DateTime.now().toIso8601String(),
          })
          ;
      
      return ChallengeGroup.fromJson(response[0]);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao criar grupo');
    }
  }
  
  @override
  Future<ChallengeGroup> getGroupById(String groupId) async {
    try {
      final response = await _client
          .from(_challengeGroupsTable)
          .select()
          .eq('id', groupId)
          .single()
          ;
      
      return ChallengeGroup.fromJson(response);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupo');
    }
  }
  
  @override
  Future<List<ChallengeGroup>> getUserCreatedGroups(String userId) async {
    try {
      final response = await _client
          .from(_challengeGroupsTable)
          .select()
          .eq('creator_id', userId)
          .order('created_at', ascending: false)
          ;
      
      return response
          .map<ChallengeGroup>((json) => ChallengeGroup.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupos criados pelo usuário');
    }
  }
  
  @override
  Future<List<ChallengeGroup>> getUserMemberGroups(String userId) async {
    try {
      final response = await _client
          .from(_challengeGroupMembersTable)
          .select('group_id')
          .eq('user_id', userId)
          ;
      
      if (response.isEmpty) {
        return [];
      }
      
      final groupIds = response
          .map<String>((json) => json['group_id'] as String)
          .toList();
      
      final groupsResponse = await _client
          .from(_challengeGroupsTable)
          .select()
          .filter('id', 'in', groupIds)
          ;
      
      return groupsResponse
          .map<ChallengeGroup>((json) => ChallengeGroup.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupos dos quais o usuário é membro');
    }
  }
  
  @override
  Future<void> updateGroup(ChallengeGroup group) async {
    try {
      await _client
          .from(_challengeGroupsTable)
          .update({
            'name': group.name,
            'description': group.description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', group.id)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar grupo');
    }
  }
  
  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      // Primeiro remover registros associados
      await _client
          .from(_challengeGroupMembersTable)
          .delete()
          .eq('group_id', groupId)
          ;
      
      await _client
          .from(_challengeGroupInvitesTable)
          .delete()
          .eq('group_id', groupId)
          ;
      
      // Depois remover o grupo
      await _client
          .from(_challengeGroupsTable)
          .delete()
          .eq('id', groupId)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao excluir grupo');
    }
  }
  
  @override
  Future<List<String>> getGroupMembers(String groupId) async {
    try {
      final response = await _client
          .from(_challengeGroupMembersTable)
          .select('user_id')
          .eq('group_id', groupId)
          ;
      
      return response
          .map<String>((json) => json['user_id'] as String)
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar membros do grupo');
    }
  }
  
  @override
  Future<void> inviteUserToGroup(String groupId, String inviterId, String inviteeId) async {
    try {
      // Verificar se o usuário já é membro do grupo
      final checkMemberResponse = await _client
          .from(_challengeGroupMembersTable)
          .select()
          .eq('group_id', groupId)
          .eq('user_id', inviteeId)
          ;
      
      if (checkMemberResponse.isNotEmpty) {
        throw StorageException(
          message: 'O usuário já é membro deste grupo',
          code: 'user_already_member',
        );
      }
      
      // Verificar se já existe um convite pendente
      final checkInviteResponse = await _client
          .from(_challengeGroupInvitesTable)
          .select()
          .eq('group_id', groupId)
          .eq('invitee_id', inviteeId)
          .eq('status', 0) // 0 = pendente
          ;
      
      if (checkInviteResponse.isNotEmpty) {
        throw StorageException(
          message: 'Já existe um convite pendente para este usuário',
          code: 'invite_already_exists',
        );
      }
      
      // Criar o convite
      await _client
          .from(_challengeGroupInvitesTable)
          .insert({
            'group_id': groupId,
            'inviter_id': inviterId,
            'invitee_id': inviteeId,
            'status': 0, // 0 = pendente
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao convidar usuário para o grupo');
    }
  }
  
  @override
  Future<void> respondToGroupInvite(String inviteId, bool accept) async {
    try {
      final inviteResponse = await _client
          .from(_challengeGroupInvitesTable)
          .select()
          .eq('id', inviteId)
          .single()
          ;
      
      final invite = inviteResponse;
      final groupId = invite['group_id'];
      final inviteeId = invite['invitee_id'];
      
      // Atualizar o status do convite
      // O status é armazenado como inteiro no banco: 0=pendente, 1=aceito, 2=recusado
      final newStatus = accept ? 1 : 2; // 1 = aceito, 2 = recusado
      
      await _client
          .from(_challengeGroupInvitesTable)
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', inviteId)
          ;
      
      // Se aceito, adicionar usuário ao grupo
      if (accept) {
        await _client
            .from(_challengeGroupMembersTable)
            .insert({
              'group_id': groupId,
              'user_id': inviteeId,
              'joined_at': DateTime.now().toIso8601String(),
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            ;
      }
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao responder convite de grupo');
    }
  }
  
  @override
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      await _client
          .from(_challengeGroupMembersTable)
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao remover usuário do grupo');
    }
  }
  
  @override
  Future<List<ChallengeProgress>> getGroupRanking(String groupId) async {
    try {
      final response = await _client
          .rpc('get_group_ranking', params: {'group_id_param': groupId})
          ;
      
      return response
          .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar ranking do grupo');
    }
  }
  
  @override
  Future<bool> hasCheckedInOnDate(String userId, String challengeId, DateTime date) async {
    try {
      // Usar a extensão para garantir o timezone correto
      final dateWithTimezone = date.toSupabaseString();
      debugPrint('🔍 Verificando check-in para data com timezone: $dateWithTimezone');
      
      // Criar intervalo de datas para verificação mais precisa
      final startOfDay = date.toStartOfDayWithTimezone();
      final endOfDay = date.toEndOfDayWithTimezone();
      
      debugPrint('🔍 Intervalo para verificação: ${startOfDay.toIso8601String()} até ${endOfDay.toIso8601String()}');
      
      final data = await _client
          .from(_challengeCheckInsTable)
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .gte('check_in_date', startOfDay.toIso8601String())
          .lte('check_in_date', endOfDay.toIso8601String());
      
      debugPrint('✅ VERIFICAÇÃO DIRETA - Check-ins encontrados: ${data.length}');
      for (var i = 0; i < data.length; i++) {
        final checkIn = data[i];
        final checkInId = checkIn['id'];
        final checkInName = checkIn['workout_name'] ?? 'Sem nome';
        final checkInDuration = checkIn['duration_minutes'];
        debugPrint('  → ID: $checkInId, Nome: $checkInName, Duração: ${checkInDuration}min');
      }

      // Se encontrou registros, retorna true (já tem check-in)
      return data.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ VERIFICAÇÃO DIRETA - Erro ao verificar check-ins: $e');
      LogUtils.error('hasCheckedInOnDate', error: e, stackTrace: stackTrace);
      // Em caso de erro, retornar false para permitir a tentativa de check-in
      return false;
    }
  }
  
  @override
  Future<bool> hasCheckedInToday(String userId, String challengeId) async {
    try {
      // Usar a data atual com timezone de Brasília
      final today = DateTime.now();
      return hasCheckedInOnDate(userId, challengeId, today);
    } catch (e) {
      debugPrint('Erro ao verificar check-in do dia: $e');
      return false;
    }
  }
  
  @override
  Future<int> getConsecutiveDaysCount(String userId, String challengeId) async {
    try {
      final response = await _client
        .rpc('get_current_streak', params: {
          'user_id_param': userId,
          'challenge_id_param': challengeId
        });
      
      if (response == null) {
        return 0;
      }
      
      // O valor retornado será um inteiro diretamente
      return response as int? ?? 0;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao buscar dias consecutivos: $e', error: e, stackTrace: stackTrace);
      return 0; // Em caso de erro, retorna 0 para não quebrar o app
    }
  }
  
  @override
  Future<int> getCurrentStreak(String userId, String challengeId) async {
    try {
      final response = await _client
        .rpc('get_current_streak', params: {
          'user_id_param': userId,
          'challenge_id_param': challengeId
        });
      
      if (response == null) {
        return 0;
      }
      
      return response as int? ?? 0;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao buscar streak atual: $e', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  @override
  Future<void> addPointsToUserProgress({
    required String challengeId,
    required String userId,
    required int pointsToAdd,
  }) async {
    try {
      // Buscar progresso atual do usuário
      final userProgress = await getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (userProgress == null) {
        throw AppException(
          message: 'Usuário não possui progresso registrado neste desafio',
        );
      }
      
      // Calcular novos pontos
      final newPoints = userProgress.points + pointsToAdd;
      
      // Atualizar pontos no banco de dados
      await _client
          .from(_challengeProgressTable)
          .update({'points': newPoints, 'updated_at': DateTime.now().toIso8601String()})
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
          
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar pontos ao progresso do usuário');
    }
  }
  
  // Método auxiliar para upload de imagens
  Future<String?> _uploadChallengeImage(File file, String challengeId) async {
    try {
      // Nome do arquivo: challenge_id_timestamp.extensão
      final extension = file.path.split('.').last;
      final fileName = '${challengeId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _client.storage
          .from(_challengeImagesBucket)
          .upload(fileName, file);
      
      // Obter URL pública
      final String publicUrl = _client.storage
          .from(_challengeImagesBucket)
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao fazer upload de imagem para desafio',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
  
  @override
  Stream<List<ChallengeProgress>> watchChallengeRanking({
    required String challengeId,
  }) {
    try {
      return _client
          .from(_challengeProgressTable)
          .stream(primaryKey: ['id'])
          .eq('challenge_id', challengeId)
          .order('position', ascending: true)  // ✅ Usar posição calculada pelo banco
          .map((data) => data
              .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
              .toList());
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao observar ranking: $e', error: e, stackTrace: stackTrace);
      // Em caso de erro, retorna um stream vazio
      return Stream.value([]);
    }
  }

  @override
  Stream<List<ChallengeProgress>> watchGroupRanking(String groupId) {
    try {
      // Usar RPC para obter ranking do grupo específico
      return _client
          .rpc('get_group_ranking', params: {'group_id_param': groupId})
          .asStream()
          .map((response) => (response as List)
              .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
              .toList());
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao observar ranking do grupo: $e', error: e, stackTrace: stackTrace);
      return Stream.value([]);
    }
  }

  @override
  Future<bool> canAccessGroup(String groupId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }
      
      final response = await _client.rpcWithValidUuids(
        'can_access_group', 
        params: {
          'user_id_param': userId,
          'group_id_param': groupId,
        }
      );
          
      return response as bool? ?? false;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao verificar acesso ao grupo: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  @override
  Future<List<ChallengeGroup>> getUserGroups(String challengeId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      // Buscar grupos em que o usuário é membro
      final memberResponse = await _client
          .from(_challengeGroupMembersTable)
          .select('group_id')
          .eq('user_id', userId)
          ;
      
      final groupIds = memberResponse
          .map<String>((item) => item['group_id'] as String)
          .toList();
      
      if (groupIds.isEmpty) {
        return [];
      }
      
      // Buscar grupos para o desafio específico
      final groupsResponse = await _client
          .from(_challengeGroupsTable)
          .select()
          .filter('id', 'in', groupIds)
          .eq('challenge_id', challengeId)
          ;
      
      return groupsResponse
          .map<ChallengeGroup>((json) => ChallengeGroup.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupos do usuário');
    }
  }
  
  @override
  Future<CheckInResult> recordChallengeCheckIn({
    required String challengeId,
    required String userId,
    String? workoutId,
    required String workoutName,
    required String workoutType,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      // Log detalhado para debug
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Usar a extensão para garantir o formato correto com timezone de Brasília
      final formattedDate = date.toSupabaseString();
      
      debugPrint('🎯 Registrando check-in no desafio: $challengeId');
      debugPrint('🔄 [DIAGNÓSTICO] Iniciando registro de check-in no desafio: $challengeId');
      debugPrint('🎯 Dados: userId=$userId, workoutId=$workoutId, workoutName=$workoutName, tipo=$workoutType, duração=$durationMinutes min');
      debugPrint('🎯 Data fornecida: ${date.toIso8601String()}, data normalizada com timezone: $formattedDate');
      
      // Garantir que workoutId não seja null
      final safeWorkoutId = workoutId ?? const Uuid().v4();
      
      // Limpar cache antes de chamar a função
      await _client.from('challenge_check_ins').select('id').limit(1);
      await _client.from(_challengeProgressTable).select('id').limit(1);
      debugPrint('🔄 [DIAGNÓSTICO] Cache limpo antes de chamar RPC');
      
      // Tentar usar a RPC
      try {
        debugPrint('=> [DIAGNOSTICO] Chamando RPC record_challenge_check_in_v2 com params: challenge=$challengeId, user=$userId');
        final result = await _client.rpcWithValidUuids(
          ChallengeRpcParams.recordChallengeCheckInFunction,
          params: {
            ChallengeRpcParams.challengeIdParam: challengeId,
            ChallengeRpcParams.userIdParam: userId,
            ChallengeRpcParams.workoutIdParam: safeWorkoutId,
            ChallengeRpcParams.workoutNameParam: workoutName,
            ChallengeRpcParams.workoutTypeParam: workoutType,
            ChallengeRpcParams.dateParam: formattedDate,
            ChallengeRpcParams.durationMinutesParam: durationMinutes
          }
        );
        
        debugPrint('✅ [DIAGNÓSTICO] Tipo de resposta RPC: ${result.runtimeType}');
        debugPrint('✅ Resposta da RPC record_challenge_check_in_v2: $result');
        
        // Usar o parser centralizado para interpretar o resultado
        return parseRpcResponse(
          result,
          challengeId: challengeId,
          userId: userId,
          workoutId: safeWorkoutId,
          checkInDate: normalizedDate,
        );
      } catch (rpcError) {
        debugPrint('⚠️ Erro na RPC record_challenge_check_in_v2: $rpcError');
        debugPrint('⚠️ [DIAGNÓSTICO] Falha ao chamar RPC: $rpcError');
        // Continue para o método alternativo abaixo
      }
      
      // Método alternativo (fallback) - Implementação antiga caso a RPC falhe
      debugPrint('⚠️ Usando método alternativo para registrar check-in');
      debugPrint('⚠️ [DIAGNÓSTICO] Iniciando método alternativo (fallback) para check-in');
      
      // Primeiro verificar se já existe check-in para este usuário e desafio na data específica
      debugPrint('🔄 [DIAGNÓSTICO] Verificando check-ins existentes para userId=$userId, desafio=$challengeId, data=$formattedDate');
      final existingCheckIn = await _client
          .from(_challengeCheckInsTable)
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .eq('check_in_date', formattedDate)
          .maybeSingle();
          
      final isAlreadyCheckedIn = existingCheckIn != null;
      if (isAlreadyCheckedIn) {
        debugPrint('⚠️ Usuário já fez check-in nesta data');
        debugPrint('⚠️ [DIAGNÓSTICO] Check-in existente encontrado para a data');
        
        // Recuperar informações do desafio para mensagem personalizada
        final challenge = await getChallengeById(challengeId);
        
        return CheckInResult(
          challengeId: challengeId,
          userId: userId,
          points: 0,
          message: 'Você já fez check-in para o desafio "${challenge.title}" hoje.',
          createdAt: DateTime.now(),
          streak: await getConsecutiveDaysCount(userId, challengeId),
        );
      }
      
      // Registrar o check-in com UUIDs válidos e timezone correto
      final checkInData = {
        'id': const Uuid().v4(),
        'challenge_id': challengeId,
        'user_id': userId,
        'workout_id': safeWorkoutId,
        'workout_name': workoutName,
        'workout_type': workoutType,
        'check_in_date': formattedDate,
        'duration_minutes': durationMinutes,
        'created_at': DateTime.now().toSupabaseString(),
      };
      
      debugPrint('🔄 [DIAGNÓSTICO] Inserindo novo check-in via método alternativo');
      final response = await _client
          .from(_challengeCheckInsTable)
          .insert(checkInData)
          .select()
          .single();
          
      final checkInId = response['id'] as String;
      debugPrint('✅ [DIAGNÓSTICO] Check-in inserido com ID: $checkInId');
      
      // Calcular pontos e atualizar progresso
      final pointsForCheckIn = _calculatePointsForWorkout(durationMinutes);
      debugPrint('🔄 [DIAGNÓSTICO] Calculados $pointsForCheckIn pontos para este check-in');
      
      debugPrint('🔄 [DIAGNÓSTICO] Chamando RPC add_points_to_progress para atualizar pontos');
      await _client.rpcWithValidUuids(
        'add_points_to_progress', 
        params: {
          'challenge_id_param': challengeId,
          'user_id_param': userId,
          'points_to_add': pointsForCheckIn,
        }
      );
      
      // Forçar recálculo do streak
      debugPrint('🔄 [DIAGNÓSTICO] Calculando sequência de dias consecutivos');
      final streak = await getConsecutiveDaysCount(userId, challengeId);
      
      debugPrint('✅ Check-in registrado: $checkInId | $pointsForCheckIn pontos');
      
      // Forçar atualização do progresso para refletir as mudanças
      debugPrint('🔄 [DIAGNÓSTICO] Forçando atualização do progresso para refletir mudanças');
      await _forceUpdateProgress(userId, challengeId);
      
      return CheckInResult(
        challengeId: challengeId,
        userId: userId,
        points: pointsForCheckIn,
        message: 'Check-in realizado com sucesso! Você ganhou $pointsForCheckIn pontos.',
        createdAt: normalizedDate,
        streak: streak,
        totalPoints: 0, // Será calculado separadamente se necessário
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao registrar check-in: $e');
      debugPrint('❌ [DIAGNÓSTICO] Erro fatal no processo de check-in: $e');
      LogUtils.error('recordChallengeCheckIn', error: e, stackTrace: stackTrace);
      
      return CheckInResult(
        challengeId: challengeId,
        userId: userId,
        points: 0,
        message: 'Erro ao registrar check-in: ${e.toString()}',
        createdAt: DateTime.now(),
        streak: 0,
      );
    }
  }
  
  /// Métodos auxiliares para extração segura de valores do mapa de resposta
  
  /// Extrai um valor String de um mapa com verificação de tipo
  String? _safeGetString(Map map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
  
  /// Extrai um valor int de um mapa com verificação de tipo
  int _safeGetInt(Map map, String key, {int defaultValue = 0}) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }
  
  /// Extrai um valor bool de um mapa com verificação de tipo
  bool _safeGetBool(Map map, String key, {bool defaultValue = false}) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return defaultValue;
  }

  /// Calcula pontos para um treino com base na duração
  int _calculatePointsForWorkout(int durationMinutes) {
    // Pontos base: 2 pontos por minuto
    final basePoints = durationMinutes * 2;
    
    // Bônus para treinos mais longos
    int bonusPoints = 0;
    if (durationMinutes >= 60) {
      bonusPoints += 50; // Bônus para treinos de 1h ou mais
    } else if (durationMinutes >= 45) {
      bonusPoints += 30; // Bônus para treinos de 45min ou mais
    } else if (durationMinutes >= 30) {
      bonusPoints += 15; // Bônus para treinos de 30min ou mais
    }
    
    return basePoints + bonusPoints;
  }

  /// Força a atualização do progresso do usuário buscando dados atualizados do banco de dados
  Future<void> _forceUpdateProgress(String userId, String challengeId) async {
    try {
      debugPrint('🔄 Forçando atualização do progresso para userId=$userId no desafio=$challengeId');
      debugPrint('🔄 [DIAGNÓSTICO] Iniciando forceUpdateProgress para usuário: $userId, desafio: $challengeId');
      
      // Limpar cache
      debugPrint('🔄 [DIAGNÓSTICO] Limpando cache das tabelas de progresso e check-ins');
      await _client.from(_challengeProgressTable).select('id').limit(1);
      await _client.from(_challengeCheckInsTable).select('id').limit(1);
      
      // Forçar recálculo do progresso usando uma RPC com validação de UUIDs
      debugPrint('🔄 [DIAGNÓSTICO] Chamando RPC recalculate_user_challenge_progress');
      await _client.rpcWithValidUuids(
        'recalculate_user_challenge_progress', 
        params: {
          'user_id_param': userId,
          'challenge_id_param': challengeId,
        }
      );
      
      debugPrint('✅ Progresso atualizado com sucesso');
      debugPrint('✅ [DIAGNÓSTICO] Progresso do usuário recalculado com sucesso');
      
      // Verificar os dados atualizados para confirmar
      try {
        debugPrint('🔄 [DIAGNÓSTICO] Verificando progresso atualizado');
        final progress = await getUserProgress(challengeId: challengeId, userId: userId);
        if (progress != null) {
          debugPrint('✅ [DIAGNÓSTICO] Progresso verificado: ${progress.points} pontos, ${progress.checkInsCount} check-ins');
        } else {
          debugPrint('⚠️ [DIAGNÓSTICO] Progresso não encontrado após atualização');
        }
      } catch (e) {
        debugPrint('⚠️ [DIAGNÓSTICO] Erro ao verificar progresso atualizado: $e');
      }
    } catch (e) {
      debugPrint('❌ Erro ao forçar atualização do progresso: $e');
      debugPrint('❌ [DIAGNÓSTICO] Falha ao recalcular progresso: $e');
    }
  }
  
  @override
  Future<void> addBonusPoints(
    String userId,
    String challengeId,
    int points,
    String reason,
    String userName,
    String? userPhotoUrl,
  ) async {
    try {
      final bonusData = {
        'challenge_id': challengeId,
        'user_id': userId,
        'points': points,
        'reason': reason,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
      };
      
      await _client
          .from(_challengeBonusesTable)
          .insert(bonusData)
          ;
          
      // Atualizar os pontos no progresso
      await _client.rpcWithValidUuids(
        'add_bonus_points_to_progress', 
        params: {
          'challenge_id_param': challengeId,
          'user_id_param': userId,
          'points_param': points,
        }
      );
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar pontos de bônus');
    }
  }
  
  @override
  Future<Map<String, dynamic>> exportChallengeData(String challengeId) async {
    try {
      // Verificar se o usuário é admin
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw AppException(message: 'Apenas administradores podem exportar dados');
      }
      
      // Obter dados do desafio
      final challengeResponse = await _client
          .from(_challengesTable)
          .select()
          .eq('id', challengeId)
          .single()
          ;
          
      // Obter progresso dos participantes
      final progressResponse = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          ;
          
      // Obter check-ins
      final checkInsResponse = await _client
          .from(_challengeCheckInsTable)
          .select()
          .eq('challenge_id', challengeId)
          ;
          
      return {
        'challenge': challengeResponse,
        'progress': progressResponse,
        'check_ins': checkInsResponse,
        'exported_at': DateTime.now().toIso8601String(),
        'exported_by': _client.auth.currentUser?.id,
      };
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao exportar dados do desafio');
    }
  }
  
  @override
  Future<bool> enableNotifications(String challengeId, bool enable) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }
      
      // Atualizar preferência de notificação na tabela de participantes
      await _client
          .from(_challengeParticipantsTable)
          .update({'notifications_enabled': enable})
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
          
      return true;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao configurar notificações: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Método de utilidade para tratar erros
  AppException _handleError(dynamic error, StackTrace stackTrace, String defaultMessage) {
    LogUtils.error('$defaultMessage: $error', error: error, stackTrace: stackTrace);
    
    if (error is PostgrestException) {
      return AppException(
        message: error.message != '' ? error.message : defaultMessage,
        code: error.code != '' ? error.code : 'unknown_error',
      );
    } else if (error is AppException) {
      return error;
    } else {
      return AppException(
        message: defaultMessage,
        code: 'unknown_error',
      );
    }
  }

  /// Limpa o cache relacionado a um desafio específico
  Future<void> clearCache(String challengeId) async {
    try {
      debugPrint('🧹 Limpando cache para o desafio: $challengeId');
      
      // Limpar cache de todas as tabelas relevantes
      await _client.from(_challengesTable).select('id').limit(1);
      await _client.from(_challengeProgressTable).select('id').limit(1);
      await _client.from(_challengeCheckInsTable).select('id').limit(1);
      await _client.from(_challengeParticipantsTable).select('id').limit(1);
      
      // Forçar pequeno atraso para garantir que o cache seja invalidado
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('✅ Cache limpo com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao limpar cache: $e');
    }
  }

  @override
  Future<List<Challenge>> getActiveParticipatingChallenges({required String userId}) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_challengesTable)
          .select('*, challenge_participants!inner(user_id)')
          .eq('challenge_participants.user_id', userId)
          .lt('start_date', now)
          .gt('end_date', now)
          .eq('active', true)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios ativos');
    }
  }
  
  @override
  Future<List<Challenge>> getParticipatingChallenges({required String userId}) async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select('*, challenge_participants!inner(user_id)')
          .eq('challenge_participants.user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios participantes');
    }
  }
  
  @override
  Future<List<Challenge>> getCreatedChallenges({required String userId}) async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('creator_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios criados');
    }
  }

  /// Método centralizado para interpretar qualquer tipo de resposta da função RPC
  /// Converte diferentes formatos de retorno em um CheckInResult padronizado
  CheckInResult parseRpcResponse(dynamic response, {
    required String challengeId,
    required String userId,
    required String workoutId,
    required DateTime checkInDate,
  }) {
    // Tratamento para resposta nula
    if (response == null) {
      debugPrint('⚠️ [PARSER] Resposta RPC nula');
      return CheckInResult(
        challengeId: challengeId,
        userId: userId,
        points: 0,
        message: 'Erro ao processar check-in: resposta vazia',
        createdAt: checkInDate,
        streak: 0,
      );
    }

    // CASO 1: Resposta é um valor booleano
    if (response is bool) {
      final success = response; // O booleano indica sucesso/falha
      debugPrint('✅ [PARSER] Resposta booleana: $success');
      
      return CheckInResult(
        challengeId: challengeId,
        userId: userId,
        points: success ? 10 : 0, // Valor padrão de pontos para respostas booleanas
        message: success ? 'Check-in realizado com sucesso!' : 'Falha ao registrar check-in',
        createdAt: checkInDate,
        streak: 0, // Será atualizado separadamente se necessário
      );
    }
    
    // CASO 2: Resposta é um objeto JSON/Map
    if (response is Map) {
      debugPrint('✅ [PARSER] Resposta é um Map com ${response.length} propriedades');
      
      // Acessar as propriedades com verificação de tipo
      final pointsEarned = _safeGetInt(response, 'points_earned');
      final streak = _safeGetInt(response, 'current_streak');
      final success = _safeGetBool(response, 'success', defaultValue: true);
      final message = _safeGetString(response, 'message') ?? 'Check-in processado com sucesso';
      
      debugPrint('✅ [PARSER] Valores extraídos: success=$success, points=$pointsEarned, streak=$streak');
      
      return CheckInResult(
        challengeId: challengeId,
        userId: userId,
        points: pointsEarned,
        message: message,
        createdAt: checkInDate,
        streak: streak,
      );
    }
    
    // CASO 3: Qualquer outro tipo de resposta
    debugPrint('⚠️ [PARSER] Tipo de resposta não esperado: ${response.runtimeType}');
    final resultStr = response.toString();
    debugPrint('⚠️ [PARSER] Valor da resposta como string: $resultStr');
    
    return CheckInResult(
      challengeId: challengeId,
      userId: userId,
      points: 0,
      message: 'Check-in processado, mas com formato de resposta inesperado (${response.runtimeType})',
      createdAt: checkInDate,
      streak: 0,
    );
  }

  /// Gets the total count of workout records for a challenge
  @override
  Future<int> getChallengeWorkoutsCount(String challengeId) async {
    try {
      final PostgrestResponse response = await _client
          .from('workout_records')
          .select()
          .eq('challenge_id', challengeId)
          .count();
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('❌ Erro ao contar registros de treino do desafio: $e');
      return 0;
    }
  }
  
  /// Checks the cache for workout records
  @override
  Future<List<WorkoutRecordWithUser>?> _checkCacheForWorkouts(String cacheKey) async {
    try {
      // Check if the cache entry exists
      final cacheResponse = await _client
          .from('cache_tracking')
          .select()
          .eq('resource_type', 'challenge_workouts')
          .eq('resource_id', cacheKey)
          .single();
      
      if (cacheResponse != null) {
        final lastUpdated = DateTime.parse(cacheResponse['last_updated']);
        final now = DateTime.now();
        
        // If cache is fresh (less than 5 minutes old)
        if (now.difference(lastUpdated).inMinutes < 5) {
          // Cache is valid, return the cached data
          final metadata = cacheResponse['metadata'] as Map<String, dynamic>;
          if (metadata.containsKey('data')) {
            final cachedData = metadata['data'] as List<dynamic>;
            return cachedData.map((item) => 
              WorkoutRecordWithUser.fromJson(item as Map<String, dynamic>)
            ).toList();
          }
        }
      }
      
      return null;
    } catch (e) {
      // Cache miss or error, just return null
      return null;
    }
  }
  
  /// Stores workout records in cache
  @override
  Future<void> _storeWorkoutsInCache(String cacheKey, List<WorkoutRecordWithUser> workouts) async {
    try {
      // Convert workouts to JSON format for caching
      final workoutsJson = workouts.map((workout) => {
        'id': workout.id,
        'user_id': workout.userId,
        'user_name': workout.userName,
        'user_photo_url': workout.userPhotoUrl,
        'workout_name': workout.workoutName,
        'workout_type': workout.workoutType,
        'date': workout.date.toIso8601String(),
        'duration_minutes': workout.durationMinutes,
        'image_urls': workout.imageUrls,
        'notes': workout.notes,
      }).toList();
      
      // Create or update cache entry
      await _client
          .from('cache_tracking')
          .upsert({
            'resource_type': 'challenge_workouts',
            'resource_id': cacheKey,
            'last_updated': DateTime.now().toIso8601String(),
            'version': 1,
            'metadata': {
              'data': workoutsJson,
              'timestamp': DateTime.now().toIso8601String(),
            }
          });
          
      debugPrint('✅ Dados de treino armazenados em cache: $cacheKey');
    } catch (e) {
      // If caching fails, just log it - this is not critical
      debugPrint('⚠️ Erro ao armazenar dados em cache: $e');
    }
  }

  /// Fetches all workout records for a specific challenge with user information
  /// Supports pagination with limit and offset parameters
  /// Uses cache to improve performance when reloading
  @override
  Future<List<WorkoutRecordWithUser>> getChallengeWorkoutRecords(
    String challengeId, {
    int limit = 20,
    int offset = 0,
    bool useCache = true,
  }) async {
    try {
      // Check cache first if enabled
      if (useCache) {
        final cacheKey = 'challenge_workouts_${challengeId}_${limit}_${offset}';
        final cachedData = await _checkCacheForWorkouts(cacheKey);
        if (cachedData != null) {
          debugPrint('✅ Usando dados em cache para treinos do desafio: $challengeId');
          return cachedData;
        }
      }

      // Usar função SQL personalizada para fazer o JOIN corretamente
      final response = await _client
          .rpc('get_workout_records_with_user_info', params: {
            'p_challenge_id': challengeId,
            'p_limit': limit,
            'p_offset': offset,
          });

      // Transform the response to match our model
      final List<WorkoutRecordWithUser> workoutRecords = [];
      
      for (final record in response) {
        workoutRecords.add(
          WorkoutRecordWithUser(
            id: record['id'] as String,
            userId: record['user_id'] as String,
            userName: record['user_name'] as String? ?? 'Usuário ${record['user_id']}',
            userPhotoUrl: record['user_photo_url'] as String?,
            workoutName: record['workout_name'] as String? ?? 'Treino sem nome',
            workoutType: record['workout_type'] as String? ?? 'Outro',
            date: DateTime.parse(record['date'] as String),
            durationMinutes: record['duration_minutes'] as int? ?? 0,
            imageUrls: record['image_urls'] != null 
                ? List<String>.from(record['image_urls'] as List) 
                : null,
            notes: record['notes'] as String?,
          ),
        );
      }
      
      // Store in cache if enabled
      if (useCache) {
        final cacheKey = 'challenge_workouts_${challengeId}_${limit}_${offset}';
        await _storeWorkoutsInCache(cacheKey, workoutRecords);
      }
      
      return workoutRecords;
    } catch (e) {
      debugPrint('❌ Erro ao buscar registros de treino do desafio: $e');
      throw Exception('Falha ao carregar os treinos do desafio: $e');
    }
  }
  
  /// Fetches workout records for a specific user in a specific challenge
  /// This is optimized to fetch only the workouts for a single user
  @override
  Future<List<WorkoutRecordWithUser>> getUserChallengeWorkoutRecords(
    String challengeId,
    String userId, {
    int limit = 50,
    bool useCache = false,
  }) async {
    try {
      debugPrint('🔍 Buscando treinos do usuário $userId no desafio $challengeId');
      
      // Cache key específico para treinos de um usuário no desafio
      final cacheKey = 'user_challenge_workouts_${challengeId}_${userId}';
      
      // Check cache first if enabled
      if (useCache) {
        final cachedData = await _checkCacheForWorkouts(cacheKey);
        if (cachedData != null) {
          debugPrint('✅ Usando dados em cache para treinos do usuário: $userId');
          return cachedData;
        }
      }
      
      // Usar função SQL personalizada para fazer o JOIN corretamente
      final response = await _client
          .rpc('get_workout_records_with_user_info', params: {
            'p_challenge_id': challengeId,
            'p_user_id': userId.trim(),
            'p_limit': limit,
            'p_offset': 0,
          });

      // Transform the response to match our model
      final List<WorkoutRecordWithUser> workoutRecords = [];
      
      debugPrint('🔍 Encontrados ${response.length} treinos para o usuário $userId');
      
      for (final record in response) {
        // Log para diagnóstico
        debugPrint('🔍 Processando record: ${record['id']}, user_id: ${record['user_id']}');
        
        final userName = record['user_name'] as String? ?? 'Usuário $userId';
        
        debugPrint('🔍 Nome do usuário encontrado: $userName');
        
        workoutRecords.add(
          WorkoutRecordWithUser(
            id: record['id'] as String,
            userId: record['user_id'] as String,
            userName: userName,
            userPhotoUrl: record['user_photo_url'] as String?,
            workoutName: record['workout_name'] as String? ?? 'Treino sem nome',
            workoutType: record['workout_type'] as String? ?? 'Outro',
            date: DateTime.parse(record['date'] as String),
            durationMinutes: record['duration_minutes'] as int? ?? 0,
            imageUrls: record['image_urls'] != null 
                ? List<String>.from(record['image_urls'] as List) 
                : null,
            notes: record['notes'] as String?,
          ),
        );
      }
      
      // Store in cache if enabled
      if (useCache) {
        await _storeWorkoutsInCache(cacheKey, workoutRecords);
      }
      
      return workoutRecords;
    } catch (e) {
      debugPrint('❌ Erro ao buscar registros de treino do usuário: $e');
      throw Exception('Falha ao carregar os treinos do usuário: $e');
    }
  }
} 