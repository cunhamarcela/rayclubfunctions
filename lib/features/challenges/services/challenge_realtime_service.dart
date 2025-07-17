// Flutter imports
import 'package:flutter/foundation.dart';
import 'dart:async';

// Package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports
import '../../../core/errors/app_exception.dart';
import '../models/challenge_progress.dart';
import '../models/challenge.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import '../../../utils/text_sanitizer.dart';

/// Provider para o serviço de tempo real de desafios
final challengeRealtimeServiceProvider = Provider<ChallengeRealtimeService>((ref) {
  final supabase = Supabase.instance.client;
  final repository = ref.watch(challengeRepositoryProvider);
  return ChallengeRealtimeService(supabase, repository);
});

/// Classe para armazenar parâmetros de usuário e desafio para providers family
class UserChallengeParams {
  final String userId;
  final String challengeId;
  
  const UserChallengeParams({
    required this.userId,
    required this.challengeId,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChallengeParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          challengeId == other.challengeId;
  
  @override
  int get hashCode => userId.hashCode ^ challengeId.hashCode;
}

/// Serviço centralizado para gerenciar streams em tempo real relacionados a desafios
class ChallengeRealtimeService {
  final SupabaseClient _supabase;
  final ChallengeRepository _repository;
  final Map<String, Timer> _timers = {};
  
  ChallengeRealtimeService(this._supabase, this._repository);
  
  /// Observa atualizações em tempo real do ranking de um desafio
  Stream<List<ChallengeProgress>> watchChallengeParticipants(String challengeId) {
    final channelKey = 'challenge_$challengeId';
    
    // Criar stream controller
    final _controller = StreamController<List<ChallengeProgress>>.broadcast(
      onCancel: () {
        debugPrint('🛑 ChallengeRealtimeService - Stream fechado: $channelKey');
      },
    );
    
    // Instead of using realtime channels which seem to have compatibility issues,
    // we'll use a periodic timer to poll for updates
    final timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_controller.isClosed) {
        timer.cancel();
        _timers.remove(channelKey);
        return;
      }
      
      try {
        final ranking = await _repository.getChallengeProgress(challengeId);
        _controller.add(ranking);
      } catch (e) {
        debugPrint('❌ Erro ao atualizar ranking via timer: $e');
      }
    });
    
    // Store the timer for later cancellation
    _timers[channelKey] = timer;
    
    // Load initial data immediately
    _repository.getChallengeProgress(challengeId).then((ranking) {
      if (!_controller.isClosed) {
        _controller.add(ranking);
      }
    }).catchError((e) {
      debugPrint('❌ Erro ao carregar ranking inicial: $e');
      if (!_controller.isClosed) {
        _controller.addError(e);
      }
    });
    
    return _controller.stream;
  }
  
  /// Observa atualizações em tempo real do ranking de um grupo específico em um desafio
  Stream<List<ChallengeProgress>> watchGroupRanking(String challengeId, String groupId) {
    final channelKey = 'group_${groupId}_challenge_$challengeId';
    
    // Criar stream controller
    final _controller = StreamController<List<ChallengeProgress>>.broadcast(
      onCancel: () {
        debugPrint('🛑 ChallengeRealtimeService - Stream fechado: $channelKey');
      },
    );
    
    // Use polling instead of realtime subscription
    final timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_controller.isClosed) {
        timer.cancel();
        _timers.remove(channelKey);
        return;
      }
      
      try {
        final ranking = await _repository.getChallengeProgress(challengeId);
        final filteredRanking = await _filterRankingByGroup(ranking, groupId);
        _controller.add(filteredRanking);
      } catch (e) {
        debugPrint('❌ Erro ao atualizar ranking de grupo via timer: $e');
      }
    });
    
    // Store the timer for later cancellation
    _timers[channelKey] = timer;
    
    // Load initial data immediately
    _repository.getChallengeProgress(challengeId).then((ranking) async {
      if (!_controller.isClosed) {
        final filteredRanking = await _filterRankingByGroup(ranking, groupId);
        _controller.add(filteredRanking);
      }
    }).catchError((e) {
      debugPrint('❌ Erro ao carregar ranking inicial do grupo: $e');
      if (!_controller.isClosed) {
        _controller.addError(e);
      }
    });
    
    return _controller.stream;
  }
  
  /// Filtra o ranking para exibir apenas participantes de um grupo específico
  Future<List<ChallengeProgress>> _filterRankingByGroup(List<ChallengeProgress> ranking, String groupId) async {
    try {
      // Obter todos os membros do grupo
      final groupMembers = await _repository.getGroupMembers(groupId);
      
      // Filtrar o ranking para incluir apenas os membros do grupo
      final filteredRanking = ranking.where((progress) => 
        groupMembers.contains(progress.userId)).toList();
      
      return filteredRanking;
    } catch (e) {
      debugPrint('❌ Erro ao filtrar ranking por grupo: $e');
      // Em caso de erro, retornar o ranking original
      return ranking;
    }
  }
  
  /// Cancela a inscrição em um stream de desafio ou grupo específico
  void cancelSubscription(String challengeId, {String? groupId}) {
    final channelKey = groupId != null 
        ? 'group_${groupId}_challenge_$challengeId'
        : 'challenge_$challengeId';
        
    if (_timers.containsKey(channelKey)) {
      debugPrint('🛑 ChallengeRealtimeService - Cancelando timer para: $channelKey');
      _timers[channelKey]?.cancel();
      _timers.remove(channelKey);
    }
  }
  
  /// Cancela todas as inscrições (usado no dispose do ViewModel)
  void cancelAllSubscriptions() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    debugPrint('🛑 ChallengeRealtimeService - Todos os timers cancelados');
  }
  
  /// Métodos adicionais incorporados do RealtimeChallengeService
  
  /// Observar atualizações em tempo real dos detalhes de um desafio
  Stream<Challenge?> watchChallenge(String challengeId) {
    try {
      return _supabase
          .from('challenges')
          .stream(primaryKey: ['id'])
          .eq('id', challengeId)
          .map((data) {
            if (data is List && data.isNotEmpty) {
              return Challenge.fromJson(data.first as Map<String, dynamic>);
            }
            return null;
          });
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService.watchChallenge erro: $e');
      return Stream.error('Falha ao observar detalhes do desafio: $e');
    }
  }
  
  /// Observar atualizações em tempo real da contagem de check-ins de um usuário
  Stream<int> watchUserCheckInsCount(String userId, String challengeId) {
    try {
      return _supabase
          .from('challenge_check_ins')
          .stream(primaryKey: ['id'])
          .map((data) {
            if (data is List) {
              // Filtrar os dados manualmente no cliente
              final filteredData = data.where((item) => 
                item['user_id'] == userId && item['challenge_id'] == challengeId).toList();
              return filteredData.length;
            }
            return 0;
          });
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService.watchUserCheckInsCount erro: $e');
      return Stream.error('Falha ao observar check-ins do usuário: $e');
    }
  }
  
  /// Observar atualizações em tempo real do progresso de um usuário em um desafio
  Stream<ChallengeProgress?> watchUserProgress(String userId, String challengeId) {
    try {
      return _supabase
          .from('challenge_progress')
          .stream(primaryKey: ['id'])
          .map((data) {
            if (data is List && data.isNotEmpty) {
              // Filtrar os dados manualmente no cliente
              final filteredData = data.where((item) => 
                item['user_id'] == userId && item['challenge_id'] == challengeId).toList();
              
              if (filteredData.isNotEmpty) {
                return ChallengeProgress.fromJson(filteredData.first as Map<String, dynamic>);
              }
            }
            return null;
          });
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService.watchUserProgress erro: $e');
      return Stream.error('Falha ao observar progresso do usuário: $e');
    }
  }
  
  /// Observar atualizações em tempo real dos desafios em que um usuário está participando
  Stream<List<Challenge>> watchUserChallenges(String userId) {
    try {
      return _supabase
          .from('challenges')
          .stream(primaryKey: ['id'])
          .map((data) {
            if (data is List) {
              // Filtrar os desafios onde o usuário é participante
              return data
                  .where((item) => (item['participants'] as List?)?.contains(userId) ?? false)
                  .map((item) => Challenge.fromJson(item as Map<String, dynamic>))
                  .toList();
            }
            return <Challenge>[];
          });
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService.watchUserChallenges erro: $e');
      return Stream.error('Falha ao observar desafios do usuário: $e');
    }
  }
  
  /// Atualiza o progresso de um usuário em um desafio
  Future<ChallengeProgress?> updateProgress({
    required String challengeId,
    required Map<String, dynamic> updateData,
    required Function(ChallengeProgress) onOptimisticUpdate,
  }) async {
    try {
      // Get user ID from updateData or fetch current user
      final userId = updateData['user_id'] ?? _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(message: 'Usuário não autenticado');
      }
      
      // Get current progress to create optimistic update
      final currentProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      if (currentProgress == null) {
        throw AppException(message: 'Progresso não encontrado');
      }
      
      // Create optimistic update
      final optimisticProgress = currentProgress.copyWith(
        points: updateData['points'] ?? currentProgress.points,
        completionPercentage: updateData['completion_percentage'] ?? currentProgress.completionPercentage,
      );
      
      // Apply optimistic update to UI
      onOptimisticUpdate(optimisticProgress);
      
      // Update in repository
      await _supabase
          .from('challenge_progress')
          .update(updateData)
          .eq('challenge_id', challengeId)
          .eq('user_id', userId);
      
      // Fetch the actual updated progress
      final updatedProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      return updatedProgress;
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService - Erro ao atualizar progresso: $e');
      throw AppException(message: 'Falha ao atualizar progresso: ${e.toString()}');
    }
  }

  Future<void> _handleChallengeCheckIn(dynamic payload) async {
    try {
      if (payload == null || payload['new'] == null) {
        debugPrint('❌ ChallengeRealtimeService - Payload de check-in inválido');
        return;
      }
      
      final data = payload['new'] as Map<String, dynamic>;
      final userId = data['user_id'] as String?;
      final desafioId = data['challenge_id'] as String?;
      
      if (userId == null || desafioId == null) {
        debugPrint('❌ ChallengeRealtimeService - IDs de usuário ou desafio nulos');
        return;
      }

      // Buscar progresso atualizado do usuário
      final currentProgress = await _repository.getUserProgress(
        challengeId: desafioId,
        userId: userId,
      );

      // Log do progresso atualizado
      if (currentProgress != null) {
        debugPrint('✅ ChallengeRealtimeService - Check-in registrado: ${currentProgress.points} pontos');
      } else {
        debugPrint('⚠️ ChallengeRealtimeService - Check-in registrado mas progresso não encontrado');
      }
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService - Erro ao processar check-in: $e');
    }
  }

  Future<void> _handleParticipantAdded(dynamic payload) async {
    try {
      if (payload == null || payload['new'] == null) {
        debugPrint('❌ ChallengeRealtimeService - Payload de participante inválido');
        return;
      }
      
      final data = payload['new'] as Map<String, dynamic>;
      final userId = data['user_id'] as String?;
      final desafioId = data['challenge_id'] as String?;
      
      if (userId == null || desafioId == null) {
        debugPrint('❌ ChallengeRealtimeService - IDs de usuário ou desafio nulos');
        return;
      }

      // Buscar progresso atualizado do usuário para o desafio
      final updatedProgress = await _repository.getUserProgress(
        challengeId: desafioId,
        userId: userId,
      );

      // Log do participante adicionado
      if (updatedProgress != null) {
        debugPrint('✅ ChallengeRealtimeService - Novo participante: ${updatedProgress.userName}');
      } else {
        debugPrint('⚠️ ChallengeRealtimeService - Participante adicionado mas progresso não encontrado');
      }
    } catch (e) {
      debugPrint('❌ ChallengeRealtimeService - Erro ao processar novo participante: $e');
    }
  }
}

/// Stream provider para observar ranking de um desafio em tempo real
final realtimeChallengeRankingProvider = StreamProvider.family<List<ChallengeProgress>, String>((ref, challengeId) {
  final service = ref.watch(challengeRealtimeServiceProvider);
  return service.watchChallengeParticipants(challengeId);
});

/// Stream provider para observar detalhes de um desafio em tempo real
final realtimeChallengeProvider = StreamProvider.family<Challenge?, String>((ref, challengeId) {
  final service = ref.watch(challengeRealtimeServiceProvider);
  return service.watchChallenge(challengeId);
});

/// Stream provider para observar contagem de check-ins do usuário em tempo real
final realtimeUserCheckInsProvider = StreamProvider.family<int, UserChallengeParams>((ref, params) {
  final service = ref.watch(challengeRealtimeServiceProvider);
  return service.watchUserCheckInsCount(params.userId, params.challengeId);
});

/// Stream provider para observar progresso do usuário em um desafio em tempo real
final realtimeUserProgressProvider = StreamProvider.family<ChallengeProgress?, UserChallengeParams>((ref, params) {
  final service = ref.watch(challengeRealtimeServiceProvider);
  return service.watchUserProgress(params.userId, params.challengeId);
});

/// Provider de stream de ranking filtrado por grupo
final realtimeGroupRankingProvider = StreamProvider.family<List<ChallengeProgress>, Map<String, String>>((ref, params) {
  final service = ref.watch(challengeRealtimeServiceProvider);
  final challengeId = params['challengeId'] ?? '';
  final groupId = params['groupId'] ?? '';
  
  if (challengeId.isEmpty || groupId.isEmpty) {
    return Stream.value([]);
  }
  
  return service.watchGroupRanking(challengeId, groupId);
}); 