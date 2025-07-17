// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/challenges/models/challenge_participation_model.dart';
import 'package:ray_club_app/core/providers/supabase_client_provider.dart';

/// Interface do repositório para participação em desafios
abstract class ChallengeParticipationRepository {
  /// Obtém os desafios ativos do usuário
  Future<List<ChallengeParticipation>> getUserActiveChallenges();
  
  /// Obtém os desafios concluídos pelo usuário
  Future<List<ChallengeParticipation>> getUserCompletedChallenges();
  
  /// Atualiza o progresso do usuário em um desafio
  Future<ChallengeParticipation> updateUserProgress(String challengeId, double progress);
}

/// Implementação mock do repositório para desenvolvimento
class MockChallengeParticipationRepository implements ChallengeParticipationRepository {
  final List<ChallengeParticipation> _mockParticipations = [];
  
  MockChallengeParticipationRepository() {
    _initMockData();
  }
  
  void _initMockData() {
    final now = DateTime.now();
    
    // Desafio ativo
    _mockParticipations.add(
      ChallengeParticipation(
        id: 'cp-1',
        challengeId: 'challenge-1',
        userId: 'user123',
        challengeName: 'Desafio de Verão 2025',
        currentProgress: 45.0,
        rank: 12,
        totalParticipants: 230,
        isCompleted: false,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 18)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    );
    
    // Desafios concluídos
    _mockParticipations.add(
      ChallengeParticipation(
        id: 'cp-2',
        challengeId: 'challenge-2',
        userId: 'user123',
        challengeName: 'Maratona Fitness',
        currentProgress: 100.0,
        rank: 8,
        totalParticipants: 186,
        isCompleted: true,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 30)),
        completionDate: now.subtract(const Duration(days: 35)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    );
    
    _mockParticipations.add(
      ChallengeParticipation(
        id: 'cp-3',
        challengeId: 'challenge-3',
        userId: 'user123',
        challengeName: 'Desafio 30 Dias',
        currentProgress: 100.0,
        rank: 3,
        totalParticipants: 145,
        isCompleted: true,
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 60)),
        completionDate: now.subtract(const Duration(days: 63)),
        createdAt: now.subtract(const Duration(days: 90)),
      ),
    );
  }

  @override
  Future<List<ChallengeParticipation>> getUserActiveChallenges() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    
    return _mockParticipations
        .where((p) => 
            !p.isCompleted && 
            p.startDate.isBefore(now) && 
            p.endDate.isAfter(now))
        .toList();
  }

  @override
  Future<List<ChallengeParticipation>> getUserCompletedChallenges() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockParticipations
        .where((p) => p.isCompleted)
        .toList();
  }

  @override
  Future<ChallengeParticipation> updateUserProgress(String challengeId, double progress) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockParticipations.indexWhere((p) => p.challengeId == challengeId);
    
    if (index == -1) {
      throw NotFoundException(
        message: 'Participação em desafio não encontrada',
        code: 'participation_not_found',
      );
    }
    
    final participation = _mockParticipations[index];
    
    // Verificar se o desafio está ativo
    if (participation.isCompleted) {
      throw ValidationException(
        message: 'Não é possível atualizar progresso de um desafio já concluído',
        code: 'challenge_already_completed',
      );
    }
    
    final now = DateTime.now();
    if (now.isAfter(participation.endDate)) {
      throw ValidationException(
        message: 'Não é possível atualizar progresso de um desafio encerrado',
        code: 'challenge_ended',
      );
    }
    
    // Calcular novo ranking (simplificado para mock)
    final isCompleted = progress >= 100.0;
    
    final updated = participation.copyWith(
      currentProgress: progress,
      isCompleted: isCompleted,
      completionDate: isCompleted ? now : null,
      updatedAt: now,
    );
    
    // Atualizar na coleção mock
    _mockParticipations[index] = updated;
    
    return updated;
  }
}

/// Implementação com Supabase
class SupabaseChallengeParticipationRepository implements ChallengeParticipationRepository {
  final SupabaseClient _supabaseClient;

  SupabaseChallengeParticipationRepository(this._supabaseClient);

  @override
  Future<List<ChallengeParticipation>> getUserActiveChallenges() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('challenge_participants')
          .select('*, challenges!inner(name, start_date, end_date)')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .lt('challenges.start_date', now)
          .gt('challenges.end_date', now)
          .order('challenges.end_date', ascending: true);
      
      return response
          .map((json) => _mapResponseToParticipation(json))
          .toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockChallengeParticipationRepository().getUserActiveChallenges();
    }
  }

  @override
  Future<List<ChallengeParticipation>> getUserCompletedChallenges() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('challenge_participants')
          .select('*, challenges!inner(name, start_date, end_date)')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .order('completion_date', ascending: false);
      
      return response
          .map((json) => _mapResponseToParticipation(json))
          .toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockChallengeParticipationRepository().getUserCompletedChallenges();
    }
  }

  @override
  Future<ChallengeParticipation> updateUserProgress(String challengeId, double progress) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Buscar informações atuais da participação
      final participationResponse = await _supabaseClient
          .from('challenge_participants')
          .select('*, challenges!inner(name, start_date, end_date)')
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .single();
      
      final participation = _mapResponseToParticipation(participationResponse);
      
      // Verificar se o desafio está ativo
      if (participation.isCompleted) {
        throw ValidationException(
          message: 'Não é possível atualizar progresso de um desafio já concluído',
          code: 'challenge_already_completed',
        );
      }
      
      final now = DateTime.now();
      if (now.isAfter(participation.endDate)) {
        throw ValidationException(
          message: 'Não é possível atualizar progresso de um desafio encerrado',
          code: 'challenge_ended',
        );
      }
      
      // Calcular se o desafio foi concluído
      final isCompleted = progress >= 100.0;
      final updates = {
        'current_progress': progress,
        'is_completed': isCompleted,
        'updated_at': now.toIso8601String(),
      };
      
      if (isCompleted) {
        updates['completion_date'] = now.toIso8601String();
      }
      
      // Atualizar o progresso
      final response = await _supabaseClient
          .from('challenge_participants')
          .update(updates)
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .select('*, challenges!inner(name, start_date, end_date)')
          .single();
      
      return _mapResponseToParticipation(response);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar progresso: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  /// Mapeia a resposta da API para o modelo ChallengeParticipation
  ChallengeParticipation _mapResponseToParticipation(Map<String, dynamic> json) {
    final challengeData = json['challenges'] as Map<String, dynamic>;
    
    return ChallengeParticipation(
      id: json['id'],
      challengeId: json['challenge_id'],
      userId: json['user_id'],
      challengeName: challengeData['name'],
      currentProgress: json['current_progress'].toDouble(),
      rank: json['rank'],
      totalParticipants: json['total_participants'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      startDate: DateTime.parse(challengeData['start_date']),
      endDate: DateTime.parse(challengeData['end_date']),
      completionDate: json['completion_date'] != null 
          ? DateTime.parse(json['completion_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}

/// Provider para o repositório de participação em desafios
final challengeParticipationRepositoryProvider = Provider<ChallengeParticipationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseChallengeParticipationRepository(supabase);
}); 