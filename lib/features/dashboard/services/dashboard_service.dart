import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final Supabase _supabase;
  final String _userId;

  DashboardService({required Supabase supabase, required String userId})
      : _supabase = supabase,
        _userId = userId;

  /// Busca as estatísticas do dashboard para o usuário
  Future<DashboardStats> getStats() async {
    try {
      debugPrint('🔄 Carregando dados do dashboard para usuário: $_userId');
      
      // Usar valores padrão para todos os campos para evitar nulls
      int workoutCount = 0;
      int streakDays = 0;
      int totalWorkoutMinutes = 0;
      int totalCalories = 0;
      String? activeChallengeId;
      String? activeChallengeName;

      try {
        // Obter estatísticas do dashboard via função RPC específica
        final response = await _supabase
            .rpc('get_user_dashboard_stats', params: {'user_id_param': _userId});

        if (response != null && response is Map) {
          // Usar conversões seguras com valores padrão
          workoutCount = response['workout_count'] as int? ?? 0;
          streakDays = response['streak_days'] as int? ?? 0;
          totalWorkoutMinutes = response['total_minutes'] as int? ?? 0;
          totalCalories = response['total_calories'] as int? ?? 0;
          
          // Tratar campos que podem ser nulos
          final challengeId = response['active_challenge_id'];
          final challengeName = response['active_challenge_name'];
          
          // Usar somente se os dois valores estiverem presentes e não forem nulos
          if (challengeId != null && challengeId.toString().isNotEmpty &&
              challengeName != null && challengeName.toString().isNotEmpty) {
            activeChallengeId = challengeId.toString();
            activeChallengeName = challengeName.toString();
          }
        }
      } catch (e) {
        debugPrint('Erro ao processar desafio atual: $e');
        // Continuar com os valores padrão em caso de erro
      }

      debugPrint('✅ Dados carregados com sucesso:');
      debugPrint('✅ - Progresso: $workoutCount treinos, $streakDays dias de streak');
      
      // Criar e retornar o objeto com os dados
      return DashboardStats(
        totalWorkouts: workoutCount,
        activeStreakDays: streakDays,
        totalWorkoutMinutes: totalWorkoutMinutes,
        totalCaloriesBurned: totalCalories,
        activeChallengeId: activeChallengeId,
        activeChallengeName: activeChallengeName,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar estatísticas do dashboard: $e');
      LogUtils.error('Erro ao carregar dashboard', error: e, stackTrace: stackTrace);
      
      // Retornar valores padrão em caso de erro
      return DashboardStats.empty();
    }
  }
} 