import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/challenges/models/challenge.dart';
import '../features/challenges/models/challenge_progress.dart';
import '../features/challenges/repositories/challenge_repository.dart';
import '../features/challenges/providers/challenge_providers.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../core/errors/app_exception.dart';
import '../features/workout/models/workout_record.dart';
import '../core/providers/providers.dart';
import '../features/profile/repositories/profile_repository.dart';
import '../features/profile/models/profile_model.dart';
import '../features/profile/providers/profile_providers.dart';

/// Provider para o serviço de integração entre treinos e desafios
final workoutChallengeServiceProvider = Provider<WorkoutChallengeService>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  return WorkoutChallengeService(
    challengeRepository: challengeRepository,
    authRepository: authRepository,
    profileRepository: profileRepository,
    ref: ref,
  );
});

/// Serviço responsável por processar a conclusão de treinos e atualizar desafios
class WorkoutChallengeService {
  final ChallengeRepository _challengeRepository;
  final IAuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final Ref _ref;
  final supabase = Supabase.instance.client;

  WorkoutChallengeService({
    required ChallengeRepository challengeRepository,
    required IAuthRepository authRepository,
    required ProfileRepository profileRepository,
    required Ref ref,
  })  : _challengeRepository = challengeRepository,
        _authRepository = authRepository,
        _profileRepository = profileRepository,
        _ref = ref;

  /// Processa a conclusão de um treino para desafios ativos
  /// Verifica todos os desafios ativos do usuário e registra o check-in
  /// Retorna a quantidade total de pontos ganhos
  Future<int> processWorkoutCompletion(WorkoutRecord workout) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      debugPrint('❌ Usuário não autenticado ao processar treino');
      return 0;
    }

    try {
      /* 
      * CACHE INTELIGENTE DE PERFIL
      * 
      * Implementação que otimiza o carregamento do perfil:
      * 1. Primeiro tenta obter o perfil do cache via Provider
      * 2. Se não estiver disponível, só então busca do repositório
      * 
      * Benefícios:
      * - Reduz chamadas ao banco de dados
      * - Melhora performance em uso contínuo
      * - Mantém consistência de dados entre diferentes partes do app
      * - Reduz consumo de rede e bateria
      */
      
      // Buscar o perfil do usuário - primeiro verificar se já está em cache
      Profile? userProfile;
      
      // Tentar obter do provider se disponível (cache)
      try {
        userProfile = _ref.read(currentProfileProvider).valueOrNull;
        debugPrint('🔄 Perfil obtido do cache: ${userProfile != null ? 'Sim' : 'Não'}');
      } catch (e) {
        debugPrint('⚠️ Provider de perfil não disponível: $e');
      }
      
      // Se não estiver em cache, buscar do repositório
      if (userProfile == null) {
        debugPrint('🔄 Buscando perfil do repositório...');
        userProfile = await _profileRepository.getProfileById(user.id);
      }
      
      final userName = userProfile?.name ?? 'Usuário';
      final userPhotoUrl = userProfile?.photoUrl;
      
      debugPrint('👤 Informações do usuário: nome = $userName, foto = ${userPhotoUrl ?? 'N/A'}');
      
      // Validação de dados do usuário
      if (userName.isEmpty) {
        debugPrint('⚠️ Nome do usuário vazio ou nulo. Usando valor padrão.');
      }
      
      // Buscar todos os desafios ativos que o usuário está participando
      final userChallenges = await _challengeRepository.getUserActiveChallenges(user.id);
      
      debugPrint('📊 Processando ${userChallenges.length} desafios ativos para o treino ${workout.workoutName}');
      
      if (userChallenges.isEmpty) {
        debugPrint('ℹ️ Usuário não está participando de nenhum desafio ativo');
        return 0;
      }

      int totalPointsAwarded = 0;

      // Para cada desafio ativo, registrar o check-in
      for (final challenge in userChallenges) {
        try {
          // Verificar se o tipo de treino satisfaz os requisitos do desafio
          final matchesRequirements = challenge.requirements == null || 
                                    challenge.requirements!.isEmpty || 
                                    challenge.requirements!.contains(workout.workoutType);
                                    
          if (!matchesRequirements) {
            debugPrint('ℹ️ Treino não satisfaz os requisitos do desafio ${challenge.title}');
            continue;
          }
          
          // Formatar a data corretamente usando nossa extensão
          final formattedDate = workout.date.toIso8601DateString();
          debugPrint('📅 Data formatada para verificação: $formattedDate');
          
          debugPrint('🎯 Registrando check-in via RPC para desafio: ${challenge.id}');
          
          // Registrar o check-in para este desafio
          final checkInResult = await _challengeRepository.recordChallengeCheckIn(
            challengeId: challenge.id, 
            userId: user.id,
            workoutId: workout.id,
            workoutName: workout.workoutName,
            workoutType: workout.workoutType,
            date: workout.date,
            durationMinutes: workout.durationMinutes,
          );
          
          // Somar pontos apenas se o check-in for bem-sucedido
          if (checkInResult.points > 0) {
            totalPointsAwarded += checkInResult.points;
            debugPrint('✅ Check-in registrado para o desafio ${challenge.title} - Pontos: ${checkInResult.points}');
          } else {
            debugPrint('ℹ️ Check-in não registrado: ${checkInResult.message}');
          }
        } catch (e) {
          debugPrint('❌ Erro ao processar desafio ${challenge.id}: $e');
          // Continuar para o próximo desafio mesmo se houver erro
        }
      }
      
      debugPrint('✅ Desafios processados com sucesso. Pontos ganhos: $totalPointsAwarded');
      return totalPointsAwarded;
    } catch (e) {
      debugPrint('❌ Erro ao processar treino para desafios: $e');
      throw AppException(
        message: 'Erro ao processar treino para desafios: ${e.toString()}',
        code: 'challenge_processing_error',
      );
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

/// Exceção específica para erros de autenticação
class AuthException extends AppException {
  AuthException({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalError: originalError,
          stackTrace: stackTrace,
          code: 'auth_error',
        );
}

/// Date formatting helper.
extension DateTimeHelpers on DateTime {
  String toIso8601DateString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
} 