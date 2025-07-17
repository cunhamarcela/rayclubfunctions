// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_fitness_data.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

/// Provider para o repositório do dashboard fitness
final dashboardFitnessRepositoryProvider = Provider<DashboardFitnessRepository>((ref) {
  return DashboardFitnessRepository(
    client: Supabase.instance.client,
    ref: ref,
  );
});

/// Repositório para gerenciar dados do dashboard fitness
class DashboardFitnessRepository {
  final SupabaseClient _client;
  final Ref _ref;

  DashboardFitnessRepository({
    required SupabaseClient client,
    required Ref ref,
  }) : _client = client, _ref = ref;

  /// Busca dados completos do dashboard fitness
  Future<DashboardFitnessData> getDashboardFitnessData({DateTime? month}) async {
    try {
      // Obter o usuário autenticado
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );

      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('🏃‍♂️ Buscando dados do dashboard fitness para usuário: $userId');

      // Usar o mês atual se não for especificado
      final targetMonth = month ?? DateTime.now();

      // Chamar a função SQL com os 3 parâmetros corretos
      final response = await _client.rpc(
        'get_dashboard_fitness',
        params: {
          'user_id_param': userId,
          'month_param': targetMonth.month,
          'year_param': targetMonth.year,
        },
      );

      if (response == null) {
        throw AppException(
          message: 'Dados do dashboard não encontrados',
          code: 'DATA_NOT_FOUND',
        );
      }

      debugPrint('✅ Dados do dashboard fitness carregados com sucesso');
      
      // Converter a resposta para o modelo
      return DashboardFitnessData.fromJson(response as Map<String, dynamic>);
      
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar dashboard fitness: $e');
      throw AppException(
        message: 'Erro ao carregar dados do dashboard',
        code: 'LOAD_ERROR',
        originalError: e,
      );
    }
  }

  /// Busca detalhes de um dia específico
  Future<DayDetailsData> getDayDetails({required DateTime date}) async {
    try {
      // Obter o usuário autenticado
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );

      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('📅 Buscando detalhes do dia ${date.toIso8601String().split('T')[0]}');

      // Chamar a função SQL para detalhes do dia
      final response = await _client.rpc(
        'get_day_details',
        params: {
          'user_id_param': userId,
          'date_param': date.toIso8601String().split('T')[0],
        },
      );

      if (response == null) {
        throw AppException(
          message: 'Detalhes do dia não encontrados',
          code: 'DATA_NOT_FOUND',
        );
      }

      debugPrint('✅ Detalhes do dia carregados com sucesso');
      
      // Converter a resposta para o modelo
      return DayDetailsData.fromJson(response as Map<String, dynamic>);
      
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar detalhes do dia: $e');
      throw AppException(
        message: 'Erro ao carregar detalhes do dia',
        code: 'LOAD_ERROR',
        originalError: e,
      );
    }
  }

  /// Força atualização dos dados do dashboard
  Future<void> refreshDashboardData() async {
    try {
      // Obter o usuário autenticado
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );

      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('🔄 Atualizando dados do dashboard fitness...');

      // Chamar a função de atualização (se existir)
      await _client.rpc(
        'refresh_dashboard_data',
        params: {'p_user_id': userId},
      );

      debugPrint('✅ Dados do dashboard fitness atualizados');
      
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao atualizar dashboard fitness: $e');
      throw AppException(
        message: 'Erro ao atualizar dados do dashboard',
        code: 'REFRESH_ERROR',
        originalError: e,
      );
    }
  }

  /// Busca o mês com treinos mais recentes para exibir por padrão
  Future<DateTime> getLatestWorkoutMonth() async {
    try {
      // Obter o usuário autenticado
      final authState = _ref.read(authViewModelProvider);
      final userId = authState.maybeWhen(
        authenticated: (user) => user.id,
        orElse: () => null,
      );

      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }

      debugPrint('🔍 Buscando mês com treinos mais recentes...');

      // Buscar o treino mais recente
      final response = await _client
          .from('workout_records')
          .select('date')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final latestWorkoutDate = DateTime.parse(response.first['date']);
        debugPrint('✅ Treino mais recente encontrado: ${latestWorkoutDate.toIso8601String()}');
        return DateTime(latestWorkoutDate.year, latestWorkoutDate.month);
      } else {
        debugPrint('ℹ️ Nenhum treino encontrado, usando mês atual');
        return DateTime.now();
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao buscar mês com treinos: $e');
      // Em caso de erro, retorna o mês atual
      return DateTime.now();
    }
  }
} 