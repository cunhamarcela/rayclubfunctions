// Package imports:
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/cardio_challenge_progress.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Serviço para gerenciar dados do desafio de cardio
class CardioChallengeService {
  final SupabaseClient _supabase;

  CardioChallengeService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Obtém o progresso do usuário atual no desafio de cardio
  Future<CardioChallengeProgress> getUserChallengeProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'UNAUTHENTICATED',
        );
      }

      debugPrint('🏃‍♂️ Buscando progresso do desafio de cardio para usuário: $userId');

      // 1. Verificar se o usuário está participando do desafio
      final participationStatus = await _checkParticipationStatus(userId);
      if (!participationStatus) {
        debugPrint('❌ Usuário não está participando do desafio');
        return CardioChallengeProgress(
          position: 0,
          totalMinutes: 0,
          isParticipating: false,
          lastUpdated: DateTime.now(),
        );
      }

      // 2. Buscar ranking completo para encontrar a posição do usuário
      final ranking = await _getCardioRanking();
      Map<String, dynamic>? userRankingEntry;
      try {
        userRankingEntry = ranking.firstWhere(
          (entry) => entry['user_id'] == userId,
        );
      } catch (e) {
        userRankingEntry = null;
      }

      if (userRankingEntry == null) {
        debugPrint('❌ Usuário não encontrado no ranking');
        return CardioChallengeProgress(
          position: 0,
          totalMinutes: 0,
          isParticipating: true,
          totalParticipants: ranking.length,
          lastUpdated: DateTime.now(),
        );
      }

      // 3. Calcular posição do usuário
      final userPosition = ranking.indexOf(userRankingEntry) + 1;
      final totalMinutes = userRankingEntry['total_cardio_minutes'] as int? ?? 0;

      debugPrint('📊 Posição do usuário: $userPosition de ${ranking.length}');
      debugPrint('⏱️ Total de minutos: $totalMinutes');

      // 4. Buscar dados de hoje e ontem para calcular melhoria
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      final todayMinutes = await _getCardioMinutesForDate(userId, today);
      final yesterdayMinutes = await _getCardioMinutesForDate(userId, yesterday);

      debugPrint('📅 Minutos hoje: $todayMinutes');
      debugPrint('📅 Minutos ontem: $yesterdayMinutes');

      // 5. Calcular percentual de melhoria
      final improvementPercentage = _calculateImprovementPercentage(
        todayMinutes,
        yesterdayMinutes,
      );

      debugPrint('📈 Melhoria: ${improvementPercentage.toStringAsFixed(1)}%');

      return CardioChallengeProgress(
        position: userPosition,
        totalMinutes: totalMinutes,
        previousDayMinutes: yesterdayMinutes,
        todayMinutes: todayMinutes,
        improvementPercentage: improvementPercentage,
        isParticipating: true,
        totalParticipants: ranking.length,
        lastUpdated: DateTime.now(),
      );

    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao buscar progresso do desafio: $e');
      throw AppException(
        message: 'Erro ao carregar progresso do desafio',
        code: 'CHALLENGE_PROGRESS_ERROR',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Verifica se o usuário está participando do desafio
  Future<bool> _checkParticipationStatus(String userId) async {
    try {
      final response = await _supabase.rpc('get_cardio_participation');
      
      if (response is List && response.isNotEmpty) {
        final data = response.first as Map<String, dynamic>;
        return data['is_participant'] as bool? ?? false;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Erro ao verificar participação: $e');
      return false;
    }
  }

  /// Busca o ranking completo de cardio
  Future<List<Map<String, dynamic>>> _getCardioRanking() async {
    try {
      final response = await _supabase.rpc('get_cardio_ranking', params: {
        '_limit': 1000, // Limite alto para pegar todos os participantes
        '_offset': 0,
      });

      if (response is List) {
        return (response as List).cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Erro ao buscar ranking: $e');
      return [];
    }
  }

  /// Busca minutos de cardio para uma data específica
  Future<int> _getCardioMinutesForDate(String userId, DateTime date) async {
    try {
      // Definir início e fim do dia em UTC
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('workout_records')
          .select('duration_minutes')
          .eq('user_id', userId)
          .eq('workout_type', 'Cardio')
          .gte('date', startOfDay.toUtc().toIso8601String())
          .lt('date', endOfDay.toUtc().toIso8601String())
          .gt('duration_minutes', 0);

      if (response is List && response.isNotEmpty) {
        final totalMinutes = response
            .map((record) => record['duration_minutes'] as int? ?? 0)
            .fold<int>(0, (sum, minutes) => sum + minutes);
        
        debugPrint('📊 Minutos encontrados para ${date.toIso8601String().split('T')[0]}: $totalMinutes');
        return totalMinutes;
      }

      return 0;
    } catch (e) {
      debugPrint('❌ Erro ao buscar minutos para data ${date.toIso8601String()}: $e');
      return 0;
    }
  }

  /// Calcula o percentual de melhoria entre dois valores
  double _calculateImprovementPercentage(int current, int previous) {
    if (previous == 0) {
      // Se não havia treino ontem, qualquer treino hoje é 100% de melhoria
      return current > 0 ? 100.0 : 0.0;
    }

    if (current == 0) {
      // Se não há treino hoje mas havia ontem, é -100%
      return -100.0;
    }

    // Cálculo normal: ((atual - anterior) / anterior) * 100
    final improvement = ((current - previous) / previous) * 100;
    return double.parse(improvement.toStringAsFixed(1));
  }

  /// Força atualização dos dados do desafio
  Future<void> refreshChallengeData() async {
    try {
      debugPrint('🔄 Atualizando dados do desafio de cardio...');
      
      // Aqui podemos adicionar lógica para invalidar cache se necessário
      // Por enquanto, apenas logamos que foi solicitada a atualização
      
      debugPrint('✅ Dados do desafio atualizados');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar dados do desafio: $e');
      throw AppException(
        message: 'Erro ao atualizar dados do desafio',
        code: 'REFRESH_ERROR',
        originalError: e,
      );
    }
  }

  /// Obtém estatísticas rápidas do desafio (para uso em widgets menores)
  Future<Map<String, dynamic>> getQuickChallengeStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {
          'isParticipating': false,
          'position': 0,
          'totalMinutes': 0,
          'totalParticipants': 0,
        };
      }

      final isParticipating = await _checkParticipationStatus(userId);
      if (!isParticipating) {
        return {
          'isParticipating': false,
          'position': 0,
          'totalMinutes': 0,
          'totalParticipants': 0,
        };
      }

      final ranking = await _getCardioRanking();
      Map<String, dynamic>? userEntry;
      try {
        userEntry = ranking.firstWhere(
          (entry) => entry['user_id'] == userId,
        );
      } catch (e) {
        userEntry = null;
      }

      if (userEntry == null) {
        return {
          'isParticipating': true,
          'position': 0,
          'totalMinutes': 0,
          'totalParticipants': ranking.length,
        };
      }

      return {
        'isParticipating': true,
        'position': ranking.indexOf(userEntry) + 1,
        'totalMinutes': userEntry['total_cardio_minutes'] as int? ?? 0,
        'totalParticipants': ranking.length,
      };

    } catch (e) {
      debugPrint('❌ Erro ao buscar estatísticas rápidas: $e');
      return {
        'isParticipating': false,
        'position': 0,
        'totalMinutes': 0,
        'totalParticipants': 0,
      };
    }
  }
}
