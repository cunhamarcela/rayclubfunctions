// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';

/// **SERVIÇO DE CHECK-IN DE METAS - RAY CLUB**
/// 
/// **Data:** 30 de Janeiro de 2025 às 16:45
/// **Objetivo:** Gerenciar check-ins manuais para metas medidas em dias
/// **Funcionalidade:** Usar função SQL register_goal_checkin criada no backend
class GoalCheckinService {
  final SupabaseClient _supabase;

  GoalCheckinService(this._supabase);

  /// **REGISTRAR CHECK-IN MANUAL**
  /// Para metas medidas em "days" (bolinhas de check)
  /// Usa a função SQL register_goal_checkin() criada no backend
  Future<bool> registerCheckin({
    required String goalId,
    required String userId,
  }) async {
    try {
      debugPrint('🎯 [GoalCheckinService] Registrando check-in manual...');
      debugPrint('📊 Goal: $goalId - User: $userId');

      // Chamar função SQL register_goal_checkin
      final response = await _supabase.rpc('register_goal_checkin', params: {
        'p_goal_id': goalId,
        'p_user_id': userId,
      });

      final success = response as bool? ?? false;

      if (success) {
        debugPrint('✅ [GoalCheckinService] Check-in registrado com sucesso');
        return true;
      } else {
        debugPrint('⚠️ [GoalCheckinService] Check-in não pôde ser registrado (meta já completa ou não encontrada)');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [GoalCheckinService] Erro ao registrar check-in: $e');
      throw AppException(
        message: 'Erro ao registrar check-in: ${e.toString()}',
        code: 'checkin_error',
      );
    }
  }

  /// **VERIFICAR PROGRESSO DA META**
  /// Busca informações atualizadas da meta
  Future<Map<String, dynamic>?> getGoalProgress({
    required String goalId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('user_goals')
          .select('id, title, target, progress, measurement_type, completed_at')
          .eq('id', goalId)
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('❌ [GoalCheckinService] Erro ao buscar progresso: $e');
      return null;
    }
  }

  /// **VERIFICAR SE PODE FAZER CHECK-IN**
  /// Valida se a meta aceita check-ins manuais
  Future<bool> canCheckin({
    required String goalId,
    required String userId,
  }) async {
    try {
      final goal = await getGoalProgress(goalId: goalId, userId: userId);
      
      if (goal == null) return false;
      
      // Só pode fazer check-in se:
      // 1. A meta é medida em dias
      // 2. A meta não está concluída
      // 3. O progresso ainda não atingiu o target
      final measurementType = goal['measurement_type'] as String?;
      final completedAt = goal['completed_at'];
      final progress = (goal['progress'] as num?)?.toDouble() ?? 0.0;
      final target = (goal['target'] as num?)?.toDouble() ?? 0.0;
      
      return measurementType == 'days' && 
             completedAt == null && 
             progress < target;
             
    } catch (e) {
      debugPrint('❌ [GoalCheckinService] Erro ao verificar check-in: $e');
      return false;
    }
  }

  /// **ESTATÍSTICAS DE CHECK-INS**
  /// Retorna estatísticas de check-ins do usuário
  Future<Map<String, int>> getCheckinStats({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();

      final response = await _supabase
          .from('user_goals')
          .select('id, title, progress, target, completed_at')
          .eq('user_id', userId)
          .eq('measurement_type', 'days')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final goals = response as List<dynamic>;
      
      int totalGoals = goals.length;
      int completedGoals = goals.where((g) => g['completed_at'] != null).length;
      int totalCheckins = goals.fold<int>(
        0, 
        (sum, g) => sum + ((g['progress'] as num?)?.toInt() ?? 0),
      );

      return {
        'total_goals': totalGoals,
        'completed_goals': completedGoals,
        'total_checkins': totalCheckins,
        'completion_rate': totalGoals > 0 
            ? ((completedGoals / totalGoals) * 100).round()
            : 0,
      };
    } catch (e) {
      debugPrint('❌ [GoalCheckinService] Erro ao buscar estatísticas: $e');
      return {
        'total_goals': 0,
        'completed_goals': 0,
        'total_checkins': 0,
        'completion_rate': 0,
      };
    }
  }
}

