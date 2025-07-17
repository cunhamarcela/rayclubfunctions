// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';

/// Provider para o ViewModel de consumo de água
final waterIntakeViewModelProvider = 
    StateNotifierProvider<WaterIntakeViewModel, AsyncValue<WaterIntakeData>>((ref) {
  return WaterIntakeViewModel();
});

/// ViewModel para gerenciar o consumo de água
class WaterIntakeViewModel extends StateNotifier<AsyncValue<WaterIntakeData>> {
  final _supabase = Supabase.instance.client;
  
  WaterIntakeViewModel() : super(const AsyncValue.loading()) {
    loadWaterIntake();
  }
  
  /// Carrega os dados de consumo de água do dia
  Future<void> loadWaterIntake() async {
    try {
      state = const AsyncValue.loading();
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'AUTH_ERROR',
        );
      }
      
      // Busca registro do dia atual
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();
      
      WaterIntakeData waterIntake;
      
      if (response != null) {
        // Se existe registro, usa ele
        waterIntake = WaterIntakeData.fromJson(response);
      } else {
        // Se não existe, cria um novo registro
        final newRecord = {
          'user_id': userId,
          'date': today,
          'cups': 0,
          'goal': 8,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await _supabase.from('water_intake').insert(newRecord);
        
        waterIntake = WaterIntakeData(
          id: '',
          userId: userId,
          date: DateTime.now(),
          cups: 0,
          goal: 8,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      state = AsyncValue.data(waterIntake);
      
    } on PostgrestException catch (e) {
      state = AsyncValue.error(
        AppException(
          message: 'Erro ao carregar dados de água',
          code: e.code ?? 'DATABASE_ERROR',
          originalError: e.message,
        ),
        StackTrace.current,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AppException(
          message: 'Erro inesperado',
          code: 'UNKNOWN_ERROR',
          originalError: e.toString(),
        ),
        stackTrace,
      );
    }
  }
  
  /// Incrementa o consumo de água
  Future<void> incrementWater() async {
    state.whenData((waterIntake) async {
      final newCups = waterIntake.cups + 1;
      await updateWaterIntake(newCups);
    });
  }
  
  /// Decrementa o consumo de água
  Future<void> decrementWater() async {
    state.whenData((waterIntake) async {
      final newCups = (waterIntake.cups - 1).clamp(0, 999);
      await updateWaterIntake(newCups);
    });
  }
  
  /// Atualiza a meta de água
  Future<void> updateGoal(int newGoal) async {
    try {
      state.whenData((waterIntake) async {
        // Atualiza localmente
        state = AsyncValue.data(
          waterIntake.copyWith(
            goal: newGoal,
            updatedAt: DateTime.now(),
          ),
        );
        
        // Salva no banco
        await _supabase
            .from('water_intake')
            .update({
              'goal': newGoal,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', waterIntake.userId)
            .eq('date', DateTime.now().toIso8601String().split('T')[0]);
      });
    } catch (e) {
      // Se falhar, recarrega
      await loadWaterIntake();
    }
  }
  
  /// Atualiza o consumo de água
  Future<void> updateWaterIntake(int cups) async {
    try {
      state.whenData((waterIntake) async {
        // Atualiza localmente primeiro
        state = AsyncValue.data(
          waterIntake.copyWith(
            cups: cups,
            updatedAt: DateTime.now(),
          ),
        );
        
        // Salva no banco
        await _supabase
            .from('water_intake')
            .update({
              'cups': cups,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', waterIntake.userId)
            .eq('date', DateTime.now().toIso8601String().split('T')[0]);
            
        // Se atingiu a meta, podemos dar pontos ou registrar conquista
        if (cups == waterIntake.goal) {
          await _recordWaterGoalAchievement();
        }
      });
    } catch (e) {
      // Se falhar, recarrega
      await loadWaterIntake();
    }
  }
  
  /// Registra conquista de meta de água
  Future<void> _recordWaterGoalAchievement() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // Verifica se já registrou hoje
      final today = DateTime.now().toIso8601String().split('T')[0];
      final existing = await _supabase
          .from('user_achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_type', 'water_goal')
          .eq('date', today)
          .maybeSingle();
          
      if (existing == null) {
        // Registra nova conquista
        await _supabase.from('user_achievements').insert({
          'user_id': userId,
          'achievement_type': 'water_goal',
          'date': today,
          'points': 5, // 5 pontos por atingir meta de água
          'created_at': DateTime.now().toIso8601String(),
        });
        
        // Atualiza pontos do usuário
        await _supabase.rpc('increment_user_points', params: {
          'user_id_param': userId,
          'points_param': 5,
        });
      }
    } catch (e) {
      // Não bloqueia o fluxo se falhar ao registrar conquista
      print('Erro ao registrar conquista de água: $e');
    }
  }
} 