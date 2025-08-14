// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_period.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/utils/json_utils.dart';

/// Provider para o repositório do dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return DashboardRepository(supabaseClient);
});

/// Classe responsável por acessar dados do dashboard no Supabase
class DashboardRepository {
  /// Cliente Supabase para comunicação com o backend
  final SupabaseClient _client;
  
  /// Construtor da classe
  DashboardRepository(this._client);

  /// Obtém os dados do dashboard a partir do Supabase
  /// [userId] - ID do usuário para buscar os dados
  /// [period] - Período para filtrar os dados (opcional, padrão: este mês)
  /// [customRange] - Range personalizado se period for custom
  Future<DashboardData> getDashboardData(
    String userId, {
    DashboardPeriod period = DashboardPeriod.thisMonth,
    DateRange? customRange,
  }) async {
    try {
      // Calcula as datas baseado no período selecionado
      final dateRange = period.calculateDateRange(customRange);
      
      debugPrint('📊 Dashboard: Buscando dados para período ${period.displayName}');
      debugPrint('📅 Período: ${dateRange.formattedRange}');
      
      // Use a função atualizada get_dashboard_core_with_period para obter dados
      final response = await _client.rpc('get_dashboard_core_with_period', params: {
        'user_id_param': userId,
        'start_date_param': dateRange.start.toIso8601String().split('T')[0],
        'end_date_param': dateRange.end.toIso8601String().split('T')[0],
      });
      
      // Converte a resposta JSON para o modelo DashboardData
      final dashboardData = DashboardData.fromJson(response);
      
      debugPrint('✅ Dashboard: Dados carregados - ${dashboardData.totalWorkouts} treinos');
      
      return dashboardData;
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados do dashboard: $e');
      throw AppException(
        message: 'Não foi possível carregar os dados do dashboard',
        code: 'dashboard_fetch_error',
        originalError: e,
      );
    }
  }
  
  /// Obtém os dados do dashboard com o método legado (compatibilidade)
  /// [userId] - ID do usuário para buscar os dados
  @Deprecated('Use getDashboardData com período. Será removido em versões futuras.')
  Future<DashboardData> getDashboardDataLegacy(String userId) async {
    return getDashboardData(userId, period: DashboardPeriod.thisMonth);
  }
  
  /// Atualiza o consumo de água do usuário
  /// [userId] - ID do usuário
  /// [waterIntakeId] - ID do registro de água
  /// [cups] - Novo número de copos consumidos
  Future<void> updateWaterIntake(
    String userId,
    String waterIntakeId,
    int cups,
  ) async {
    try {
      await _client
          .from('water_intake')
          .update({
            'cups': cups,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', waterIntakeId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Erro ao atualizar consumo de água: $e');
      throw AppException(
        message: 'Não foi possível atualizar o consumo de água',
        code: 'water_intake_update_error',
        originalError: e,
      );
    }
  }
  
  /// Cria um registro de consumo de água para hoje se não existir
  /// [userId] - ID do usuário
  Future<String?> createWaterIntakeForToday(String userId) async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Verificar se já existe um registro para hoje
      final existing = await _client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', formattedDate)
          .maybeSingle();
      
      // Se já existe, retornar o ID do registro existente
      if (existing != null) {
        return existing['id'] as String?;
      }
      
      // Não incluir o ID e deixar o Supabase gerar automaticamente
      final insertData = {
        'user_id': userId,
        'date': formattedDate,
        'cups': 0,
        'goal': 8,
        'glass_size': 250,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _client
          .from('water_intake')
          .insert(insertData)
          .select()
          .single();
      
      return response['id'] as String?;
    } catch (e) {
      debugPrint('Error getting water intake: $e');
      throw AppException(
        message: 'Erro ao buscar registro de água: $e',
        code: 'water_intake_error',
      );
    }
  }

  /// Força a atualização manual do dashboard diretamente nas tabelas
  Future<bool> forceManualDashboardUpdate(String userId, {int? workoutsToAdd = 1}) async {
    try {
      debugPrint('🔄 [MANUAL_UPDATE] Iniciando atualização manual do dashboard para usuário: $userId');
      final supabase = Supabase.instance.client;
      
      // 1. Verificar se o usuário já tem registro em user_progress
      final userProgress = await supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (userProgress == null) {
        debugPrint('🔄 [MANUAL_UPDATE] Criando registro inicial em user_progress');
        // Não existe entry para este usuário, criar um novo
        await supabase.from('user_progress').insert({
          'user_id': userId,
          'workouts': workoutsToAdd ?? 1,
          'points': 10, // Pontos base para um novo treino
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        debugPrint('✅ [MANUAL_UPDATE] Registro inicial criado em user_progress');
        return true;
      }
      
      // 2. Atualizar o registro existente
      debugPrint('🔄 [MANUAL_UPDATE] Atualizando registro existente');
      
      // Recuperar valores atuais
      final currentWorkouts = userProgress['workouts'] as int? ?? 0;
      final currentPoints = userProgress['points'] as int? ?? 0;
      
      // Atualizar com novos valores
      await supabase.from('user_progress').update({
        'workouts': currentWorkouts + (workoutsToAdd ?? 1),
        'points': currentPoints + 10, // Adicionar 10 pontos por treino
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
      
      debugPrint('✅ [MANUAL_UPDATE] Atualização manual concluída com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [MANUAL_UPDATE] Erro na atualização manual: $e');
      return false;
    }
  }
} 