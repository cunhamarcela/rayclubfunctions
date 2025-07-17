// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/check_in_error_log.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

/// Provider para AdminRepository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AdminRepository(supabase);
});

/// Repositório para funções administrativas
class AdminRepository {
  final SupabaseClient _supabase;
  
  AdminRepository(this._supabase);
  
  /// Executa diagnóstico do sistema e tenta recuperar registros com problemas
  Future<Map<String, dynamic>> runSystemDiagnostics({int daysBack = 7}) async {
    try {
      final response = await _supabase.rpc(
        'diagnose_and_recover_workout_records', 
        params: {'days_back': daysBack}
      );
      
      return response;
    } catch (e) {
      debugPrint('Erro ao executar diagnóstico: $e');
      return {
        'error': e.toString(),
        'recovered_count': 0,
        'missing_count': 0,
        'failed_count': 0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Tenta reprocessar um treino específico
  Future<bool> retryProcessingForWorkout(String workoutId) async {
    try {
      final response = await _supabase.rpc(
        'retry_workout_processing',
        params: {'_workout_id': workoutId}
      );
      
      return response == true;
    } catch (e) {
      debugPrint('Erro ao tentar reprocessar treino: $e');
      return false;
    }
  }
  
  /// Obtém logs de erro do sistema
  Future<List<CheckInErrorLog>> getErrorLogs({
    String? userId,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
        .from('check_in_error_logs')
        .select();
        
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
      
      return (response as List)
        .map((json) => CheckInErrorLog.fromJson(json))
        .toList();
    } catch (e) {
      debugPrint('Erro ao obter logs de erro: $e');
      return [];
    }
  }
  
  /// Obtém resumo de erros agrupados por usuário
  Future<List<Map<String, dynamic>>> getErrorSummaryByUser() async {
    try {
      final response = await _supabase.rpc(
        'get_error_summary_by_user',
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao obter resumo de erros: $e');
      return [];
    }
  }
  
  /// Obtém treinos com processamento pendente
  Future<List<Map<String, dynamic>>> getPendingWorkoutsProcessing() async {
    try {
      final response = await _supabase
        .from('workout_processing_queue')
        .select('*, workout_records(*)')
        .or('processed_for_ranking.eq.false,processed_for_dashboard.eq.false')
        .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao obter treinos pendentes: $e');
      return [];
    }
  }
} 