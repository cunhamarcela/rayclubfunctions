// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../workout/models/workout_record.dart';
import '../models/challenge.dart';
import '../../profile/repositories/profile_repository.dart';
import '../constants/challenge_rpc_params.dart';
import '../../../utils/datetime_extensions.dart';
import '../../../utils/log_utils.dart';

/// Provider para o serviço de integração entre treinos e desafios
final workoutChallengeServiceProvider = Provider<WorkoutChallengeService>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final supabase = Supabase.instance.client;
  return WorkoutChallengeService(challengeRepository, supabase);
});

/// Serviço responsável por processar a conclusão de treinos e atualizar desafios
class WorkoutChallengeService {
  final ChallengeRepository _repository;
  final SupabaseClient _supabase;
  
  // Constants for point allocation
  static const int _kDefaultPrivateChallengePoints = 10;
  static const int _kWeeklyStreakBonusPoints = 50;
  static const int _kStreakBonusFrequency = 7; // Every 7 days
  
  WorkoutChallengeService(this._repository, this._supabase);

  /// Process a completed workout, checking for active challenges and awarding points
  /// Returns the total points earned from all challenges
  Future<int> processWorkoutCompletion({
    required WorkoutRecord record,
    required String userId,
  }) async {
    try {
      debugPrint('🎯 Processando treino concluído para desafios: ${record.workoutName}');
      
      // Verify the workout is completed
      if (!record.isCompleted) {
        debugPrint('⚠️ Treino não está marcado como completo, pulando processamento de desafios');
        return 0;
      }
      
      // Aceitar treinos de qualquer duração
      
      // ✅ IMPORTANTE: Verificar se o treino já tem um desafio atribuído
      if (record.challengeId != null && record.challengeId!.isNotEmpty) {
        debugPrint('✓ Treino já tem challengeId atribuído: ${record.challengeId}');
        
        // Buscar o desafio correspondente
        final challenge = await _repository.getChallengeById(record.challengeId!);
        if (challenge != null) {
          debugPrint('✓ Desafio encontrado: ${challenge.title}');
          
          // Buscar dados de perfil para o check-in
          final userProfile = await _supabase
              .from('profiles')
              .select('name, profile_image_url')
              .eq('id', userId)
              .maybeSingle();
          
          final userName = userProfile?['name'] as String? ?? 'Usuário';
          final userPhotoUrl = userProfile?['profile_image_url'] as String?;
          
          // Processar o check-in para este desafio específico
          final pointsEarned = await _processChallengeCheckIn(
            challenge: challenge,
            record: record,
            userId: userId,
            userName: userName,
            userPhotoUrl: userPhotoUrl,
          );
          
          debugPrint('✅ Check-in processado para desafio específico. Pontos: $pointsEarned');
          return pointsEarned;
        }
      }
      
      // Get active challenges for the user
      final activeUserChallenges = await _repository.getUserActiveChallenges(userId);
      debugPrint('🎯 Usuário participa de ${activeUserChallenges.length} desafios ativos');
      
      if (activeUserChallenges.isEmpty) {
        debugPrint('ℹ️ Usuário não participa de nenhum desafio ativo');
        return 0;
      }
      
      // Obter informações do perfil do usuário para incluir no check-in
      final userProfile = await _supabase
          .from('profiles')
          .select('name, profile_image_url')
          .eq('id', userId)
          .maybeSingle();
      
      final userName = userProfile != null ? userProfile['name'] as String? : null;
      final userPhotoUrl = userProfile != null ? userProfile['profile_image_url'] as String? : null;
      
      debugPrint('👤 Informações do usuário: nome = ${userName ?? "N/A"}, foto = ${userPhotoUrl ?? "N/A"}');
      
      int totalPointsEarned = 0;
      
      // Process each challenge
      for (final challenge in activeUserChallenges) {
        try {
          final pointsForThisChallenge = await _processChallengeCheckIn(
            challenge: challenge,
            record: record,
            userId: userId,
            userName: userName ?? 'Participante',
            userPhotoUrl: userPhotoUrl,
          );
          
          totalPointsEarned += pointsForThisChallenge;
          debugPrint('✅ Pontos para desafio ${challenge.title}: $pointsForThisChallenge (total: $totalPointsEarned)');
        } catch (e) {
          debugPrint('❌ Erro ao processar desafio ${challenge.id}: $e');
          // Continue with other challenges even if one fails
          continue;
        }
      }
      
      return totalPointsEarned;
    } catch (e) {
      debugPrint('❌ Erro ao processar treino para desafios: $e');
      throw AppException(code: 'challenge_processing_error', message: 'Erro ao processar treino para desafios');
    }
  }
  
  /// Process a check-in for a specific challenge
  /// Returns the points earned for this challenge
  Future<int> _processChallengeCheckIn({
    required Challenge challenge,
    required WorkoutRecord record,
    required String userId,
    required String userName,
    String? userPhotoUrl,
  }) async {
    try {
      // Usar a extensão para garantir timezone correto
      final formattedDate = record.date.toSupabaseString();
      debugPrint('📅 Data formatada com timezone para verificação: $formattedDate');
      
      // Verificar se o record já tem um challengeId e se é igual ao que estamos processando
      if (record.challengeId != null && record.challengeId != challenge.id) {
        debugPrint('⚠️ Registro já associado a outro desafio (${record.challengeId}). Pulando processamento para ${challenge.id}');
        return 0;
      }
      
      // Se o record não tem challengeId ainda, atualizar no banco
      if (record.challengeId == null) {
        debugPrint('🔄 Atualizando registro do treino com ID do desafio: ${challenge.id}');
        
        try {
          // Usar RPC em vez de atualização direta para melhor consistência
          await _supabase.rpc('update_workout_and_refresh', params: {
            'p_workout_record_id': record.id,
            'p_user_id': userId,
            'p_challenge_id': challenge.id,
            'p_workout_name': record.workoutName,
            'p_workout_type': record.workoutType,
            'p_duration_minutes': record.durationMinutes,
            'p_date': record.date.toIso8601String(),
            'p_notes': record.notes ?? '',
          });
        } catch (e) {
          debugPrint('⚠️ Erro ao atualizar challenge_id no registro: $e');
          // Continuar mesmo com erro para tentar registrar o check-in
        }
      }
      
      // Verificar se já existe check-in para essa data usando a função RPC
      try {
        final checkResult = await _supabase.rpc(
          'has_checked_in_today',
          params: {
            '_user_id': userId,
            '_challenge_id': challenge.id
          },
        );
        
        // Verificação segura do resultado
        final bool hasCheckedIn = checkResult is bool ? checkResult : false;
        
        if (hasCheckedIn) {
          debugPrint('ℹ️ Usuário já fez check-in hoje para o desafio ${challenge.id}');
          return 0; // No points for duplicate check-ins
        }
      } catch (e) {
        // Se houver erro na função RPC, verificar diretamente no banco
        debugPrint('⚠️ Erro ao verificar check-in via RPC: $e. Tentando verificação direta.');
        final today = DateTime(record.date.year, record.date.month, record.date.day);
        final hasCheckedInDirectly = await _checkDirectlyInDatabase(
          userId: userId, 
          challengeId: challenge.id, 
          date: today
        );
        
        if (hasCheckedInDirectly) {
          debugPrint('ℹ️ Verificação direta: usuário já fez check-in hoje.');
          return 0;
        }
      }
      
      debugPrint('🎯 Registrando check-in via RPC para desafio: ${challenge.id}');
      
      // Usar a função record_challenge_check_in para registrar o check-in
      final response = await _supabase.rpc(
        ChallengeRpcParams.recordChallengeCheckInFunction,
        params: {
          ChallengeRpcParams.challengeIdParam: challenge.id,
          ChallengeRpcParams.userIdParam: userId,
          ChallengeRpcParams.workoutIdParam: record.id,
          ChallengeRpcParams.workoutNameParam: record.workoutName,
          ChallengeRpcParams.workoutTypeParam: record.workoutType,
          ChallengeRpcParams.dateParam: formattedDate,
          ChallengeRpcParams.durationMinutesParam: record.durationMinutes,
        },
      );
      
      debugPrint('🔍 Tipo de resposta: ${response.runtimeType}');
      debugPrint('🔍 Valor da resposta: $response');
      
      // Usar o parser centralizado para interpretar o resultado com segurança
      final parsedResult = parseChallengeRpcResponse(response);
      
      // Verificar sucesso da operação
      final success = parsedResult['success'] as bool;
      if (!success) {
        debugPrint('⚠️ Check-in não registrado: ${parsedResult['message']}');
        return 0;
      }
      
      // Retornar os pontos ganhos
      final pointsAwarded = parsedResult['points_earned'] as int;
      final message = parsedResult['message'] as String;
      
      debugPrint('✅ Check-in processado: $message. Pontos ganhos: $pointsAwarded');
      return pointsAwarded;
    } catch (e) {
      debugPrint('❌ Erro ao registrar check-in: $e');
      // Em caso de erro, retornamos 0 pontos para não quebrar o fluxo do app
      return 0;
    }
  }
  
  /// Método auxiliar para extrair valores de mapas com segurança
  T? _safeGetField<T>(Map map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is T) return value;
    
    // Conversões especiais
    if (T == int && value is String) {
      try {
        return int.parse(value) as T;
      } catch (_) {
        return null;
      }
    }
    
    if (T == bool && (value is String || value is num)) {
      if (value is String) return (value.toLowerCase() == 'true') as T;
      if (value is num) return (value != 0) as T;
    }
    
    return null;
  }
  
  /// Função centralizada para interpretar resultados de funções RPC relacionadas a desafios
  /// Padroniza o tratamento de diferentes tipos de resposta
  Map<String, dynamic> parseChallengeRpcResponse(dynamic response) {
    debugPrint('🔍 [PARSER] Interpretando resposta RPC: $response (${response.runtimeType})');
    
    // Caso 1: Resposta nula
    if (response == null) {
      debugPrint('⚠️ [PARSER] Resposta nula');
      return {
        'success': false,
        'points_earned': 0,
        'message': 'Resposta vazia da função'
      };
    }
    
    // Caso 2: Resposta booleana 
    if (response is bool) {
      final success = response;
      debugPrint('✅ [PARSER] Resposta booleana: $success');
      
      return {
        'success': success,
        'points_earned': success ? 10 : 0, // Valor padrão para respostas booleanas
        'message': success ? 'Check-in registrado com sucesso' : 'Falha ao registrar check-in'
      };
    }
    
    // Caso 3: Resposta é um Map (objeto JSON)
    if (response is Map) {
      debugPrint('✅ [PARSER] Resposta é um Map com ${response.length} propriedades');
      
      // Extrair campos com segurança
      final success = _safeGetField<bool>(response, 'success') ?? true;
      final pointsEarned = _safeGetField<int>(response, 'points_earned') ?? 0;
      final message = _safeGetField<String>(response, 'message') ?? 'Check-in processado';
      
      debugPrint('✅ [PARSER] Valores extraídos: success=$success, points=$pointsEarned');
      
      return {
        'success': success,
        'points_earned': pointsEarned,
        'message': message,
        // Preservar outras propriedades do map original, com conversão segura de tipos
        ...Map.fromEntries(response.entries
            .where((e) => e.key != 'success' && e.key != 'points_earned' && e.key != 'message')
            .map((e) => MapEntry<String, dynamic>(e.key.toString(), e.value))
        )
      };
    }
    
    // Caso 4: Outro tipo de resposta
    debugPrint('⚠️ [PARSER] Tipo de resposta não esperado: ${response.runtimeType}');
    
    return {
      'success': true, // Assumir sucesso por segurança
      'points_earned': 0,
      'message': 'Formato de resposta não reconhecido (${response.runtimeType})'
    };
  }
  
  /// Verificação direta de check-ins no banco de dados
  Future<bool> _checkDirectlyInDatabase({
    required String userId,
    required String challengeId,
    required DateTime date,
  }) async {
    try {
      // Usar as extensões para timezone correto
      final startDate = date.toStartOfDayWithTimezone();
      final endDate = date.toEndOfDayWithTimezone();
      
      debugPrint('🔍 Verificando check-in diretamente no banco: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}');
      
      // Consulta direta à tabela de check-ins
      final response = await _supabase
          .from('challenge_check_ins')
          .select('id')
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .gte('check_in_date', startDate.toIso8601String())
          .lte('check_in_date', endDate.toIso8601String())
          .gte('duration_minutes', 45);
          
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Erro na verificação direta de check-in: $e');
      return false; // Em caso de erro, assumimos que não há check-in
    }
  }
  
  /// Check for and apply streak bonuses
  /// Returns bonus points awarded (0 if no bonus)
  Future<int> _checkAndApplyStreakBonus(String userId, String challengeId) async {
    try {
      // Get all check-ins for this challenge by this user, ordered by date
      final checkIns = await _supabase
          .from('challenge_check_ins')
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .order('check_in_date', ascending: false);
      
      // If not enough check-ins for a streak, return early
      if (checkIns.length < _kStreakBonusFrequency) {
        return 0;
      }
      
      // Count consecutive days (taking into account one check-in per day)
      final dates = checkIns.map((c) => DateTime.parse(c['check_in_date'] as String).toUtc().toString().split(' ')[0]).toList();
      final uniqueDates = dates.toSet().toList(); // Remove duplicates
      uniqueDates.sort(); // Sort in ascending order
      
      // Check if the user recently completed a streak of kStreakBonusFrequency unique days
      if (uniqueDates.length % _kStreakBonusFrequency == 0) {
        debugPrint('🔥 Usuário completou streak de $_kStreakBonusFrequency dias no desafio $challengeId!');
        
        // Record the streak bonus
        await _supabase.from('challenge_streaks').insert({
          'user_id': userId,
          'challenge_id': challengeId,
          'streak_date': DateTime.now().toUtc().toIso8601String(),
          'streak_count': uniqueDates.length,
          'bonus_points': _kWeeklyStreakBonusPoints,
        });
        
        return _kWeeklyStreakBonusPoints;
      }
      
      return 0;
    } catch (e) {
      debugPrint('⚠️ Erro ao verificar streak bonus: $e');
      return 0; // Fail gracefully for streak bonuses
    }
  }
  
  /// Update the user's progress in a challenge with new points
  Future<void> _updateUserChallengeProgress({
    required String userId,
    required String challengeId, 
    required int pointsToAdd,
    required String userName,
    String? userPhotoUrl,
  }) async {
    try {
      // Get current progress
      final progress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (progress != null) {
        // Update existing progress
        final newPoints = progress.points + pointsToAdd;
        await _repository.updateUserProgress(
          challengeId: challengeId,
          userId: userId,
          userName: userName,
          userPhotoUrl: userPhotoUrl,
          points: newPoints,
          completionPercentage: progress.completionPercentage,
        );
      } else {
        // Create new progress entry if one doesn't exist
        // (should not happen normally as users should have progress created when joining)
        await _repository.createUserProgress(
          challengeId: challengeId,
          userId: userId,
          userName: userName,
          userPhotoUrl: userPhotoUrl,
          points: pointsToAdd,
          completionPercentage: 0.05, // Starting percentage
        );
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao atualizar progresso do usuário no desafio: $e');
      // Don't rethrow - we want this to fail gracefully
    }
  }
}

/// Exceção específica para erros no processamento de desafios
class ChallengeProcessingException extends AppException {
  ChallengeProcessingException({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: 'challenge_processing_error',
        );
} 