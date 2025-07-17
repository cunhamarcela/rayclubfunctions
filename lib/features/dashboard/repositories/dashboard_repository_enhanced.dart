// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/error_handler.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';

/// Provider para o repositório do dashboard aprimorado
final dashboardRepositoryEnhancedProvider = Provider<DashboardRepositoryEnhanced>((ref) {
  return DashboardRepositoryEnhanced();
});

/// Repositório para buscar dados aprimorados do dashboard
class DashboardRepositoryEnhanced {
  final _supabase = Supabase.instance.client;
  
  /// Busca todos os dados do dashboard usando a função get_dashboard_data
  /// 
  /// Esta função chama a RPC function do Supabase que retorna:
  /// - user_progress: Progresso geral do usuário
  /// - water_intake: Consumo de água do dia
  /// - goals: Metas do usuário
  /// - recent_workouts: Últimos 10 treinos
  /// - current_challenge: Desafio ativo
  /// - challenge_progress: Progresso no desafio
  /// - redeemed_benefits: Benefícios resgatados
  Future<DashboardDataEnhanced> getDashboardData() async {
    try {
      // Obter ID do usuário autenticado
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppError(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      // Chamar a função RPC do Supabase
      final response = await _supabase.rpc(
        'get_dashboard_data',
        params: {
          'user_id_param': userId,
        },
      ).single();
      
      // Verificar se houve resposta
      if (response == null) {
        throw AppError(
          message: 'Nenhum dado retornado do servidor',
          code: 'NO_DATA',
        );
      }
      
      // Converter resposta para o modelo
      return DashboardDataEnhanced.fromJson(response as Map<String, dynamic>);
      
    } on PostgrestException catch (e) {
      // Se a função get_dashboard_data não existir, retornar dados padrão
      if (e.code == 'function_not_found' || e.message.contains('function') || e.message.contains('not exist')) {
        return _createFallbackData();
      }
      
      // Outros erros do Supabase
      throw AppError(
        message: 'Erro ao buscar dados do dashboard: ${e.message}',
        code: e.code ?? 'DATABASE_ERROR',
        details: {'error': e.message},
      );
    } on DioException catch (e) {
      // Tratar erros de rede
      throw AppError(
        message: 'Erro de conexão ao buscar dados do dashboard',
        code: 'NETWORK_ERROR',
        details: {'error': e.message},
      );
    } catch (e) {
      // Para outros erros, também tentar retornar dados padrão
      if (e.toString().contains('function') || e.toString().contains('not exist')) {
        return _createFallbackData();
      }
      
      // Outros erros
      throw AppError(
        message: 'Erro inesperado ao buscar dados do dashboard: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Cria dados padrão quando a função get_dashboard_data não está disponível
  DashboardDataEnhanced _createFallbackData() {
    final now = DateTime.now();
    
    return DashboardDataEnhanced(
      userProgress: UserProgressData(
        id: '',
        userId: _supabase.auth.currentUser?.id ?? '',
        totalWorkouts: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalPoints: 0,
        daysTrainedThisMonth: 0,
        workoutTypes: {},
        createdAt: now,
        updatedAt: now,
      ),
      waterIntake: WaterIntakeData(
        id: '',
        userId: _supabase.auth.currentUser?.id ?? '',
        date: now,
        cups: 0,
        goal: 8,
        createdAt: now,
        updatedAt: now,
      ),
      nutritionData: NutritionData(
        id: '',
        userId: _supabase.auth.currentUser?.id ?? '',
        date: now,
        caloriesConsumed: 0,
        caloriesGoal: 2000,
        proteins: 0.0,
        carbs: 0.0,
        fats: 0.0,
        createdAt: now,
        updatedAt: now,
      ),
      goals: [],
      recentWorkouts: [],
      currentChallenge: null,
      challengeProgress: null,
      redeemedBenefits: [],
      lastUpdated: now,
    );
  }
  
  /// Atualiza o consumo de água do dia
  Future<void> updateWaterIntake(int cups) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppError(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      // Upsert na tabela water_intake
      await _supabase.from('water_intake').upsert({
        'user_id': userId,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'cups': cups,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,date');
      
    } on PostgrestException catch (e) {
      throw AppError(
        message: 'Erro ao atualizar consumo de água',
        code: e.code ?? 'DATABASE_ERROR',
        details: {'error': e.message},
      );
    }
  }
  
  /// Marca uma meta como completa
  Future<void> completeGoal(String goalId) async {
    try {
      await _supabase
          .from('user_goals')
          .update({
            'is_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
          
    } on PostgrestException catch (e) {
      throw AppError(
        message: 'Erro ao completar meta',
        code: e.code ?? 'DATABASE_ERROR',
        details: {'error': e.message},
      );
    }
  }
  
  /// Atualiza o progresso de uma meta
  Future<void> updateGoalProgress(String goalId, double currentValue) async {
    try {
      await _supabase
          .from('user_goals')
          .update({
            'current_value': currentValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goalId);
          
    } on PostgrestException catch (e) {
      throw AppError(
        message: 'Erro ao atualizar progresso da meta',
        code: e.code ?? 'DATABASE_ERROR',
        details: {'error': e.message},
      );
    }
  }
} 