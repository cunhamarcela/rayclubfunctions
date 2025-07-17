// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/features/goals/repositories/water_intake_repository.dart';

/// Estado do WaterViewModel
class WaterState {
  /// Dados atuais de ingestão de água
  final WaterIntake? waterIntake;
  
  /// Indica se está carregando
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;

  /// Construtor
  WaterState({
    this.waterIntake,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Cria uma cópia do estado com novos valores
  WaterState copyWith({
    WaterIntake? waterIntake,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WaterState(
      waterIntake: waterIntake ?? this.waterIntake,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ViewModel para gerenciar a ingestão de água
/// PATCH: Corrigir bug 2 - Garantir persistência dos dados de água no Supabase
class WaterViewModel extends StateNotifier<WaterState> {
  /// Repositório de ingestão de água
  final WaterIntakeRepository _repository;
  
  /// ID do usuário atual
  final String _userId;

  /// Construtor
  WaterViewModel(this._repository, this._userId) : super(WaterState());

  /// Carrega os dados de ingestão de água
  Future<void> loadWaterIntake() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final today = DateTime.now();
      final waterIntake = await _repository.getWaterIntakeForDate(_userId, today);
      
      state = state.copyWith(
        waterIntake: waterIntake,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao carregar dados de água',
      );
    }
  }

  /// Adiciona um copo de água
  Future<void> addGlass() async {
    if (state.isLoading) return;
    
    final currentIntake = state.waterIntake;
    final int currentCups = currentIntake?.cups ?? 0;
    final int newCups = currentCups + 1;
    final int goal = currentIntake?.goal ?? 8; // Meta padrão de 8 copos se não definida
    
    // Atualiza o estado otimisticamente
    if (currentIntake != null) {
      state = state.copyWith(
        waterIntake: currentIntake.copyWith(cups: newCups),
      );
    }
    
    try {
      // PATCH: Corrigir bug 2 - Persistir dados de água no Supabase
      final today = DateTime.now();
      final updatedIntake = await _repository.insertOrUpdateWaterIntake(
        userId: _userId,
        date: today,
        cups: newCups,
        goal: goal,
        notes: currentIntake?.notes,
      );
      
      // Atualiza o estado com os dados retornados do servidor
      state = state.copyWith(
        waterIntake: updatedIntake,
      );
      
      debugPrint('✅ Copo de água adicionado e persistido no Supabase');
    } catch (e) {
      // Reverte a atualização otimista em caso de erro
      state = state.copyWith(
        waterIntake: currentIntake,
        errorMessage: e is AppException ? e.message : 'Erro ao adicionar copo de água',
      );
      
      debugPrint('❌ Erro ao adicionar copo de água: $e');
    }
  }

  /// Remove um copo de água
  Future<void> removeGlass() async {
    if (state.isLoading) return;
    
    final currentIntake = state.waterIntake;
    final int currentCups = currentIntake?.cups ?? 0;
    
    // Não permite valores negativos
    if (currentCups <= 0) return;
    
    final int newCups = currentCups - 1;
    final int goal = currentIntake?.goal ?? 8; // Meta padrão de 8 copos se não definida
    
    // Atualiza o estado otimisticamente
    if (currentIntake != null) {
      state = state.copyWith(
        waterIntake: currentIntake.copyWith(cups: newCups),
      );
    }
    
    try {
      // PATCH: Corrigir bug 2 - Persistir dados de água no Supabase
      final today = DateTime.now();
      final updatedIntake = await _repository.insertOrUpdateWaterIntake(
        userId: _userId,
        date: today,
        cups: newCups,
        goal: goal,
        notes: currentIntake?.notes,
      );
      
      // Atualiza o estado com os dados retornados do servidor
      state = state.copyWith(
        waterIntake: updatedIntake,
      );
      
      debugPrint('✅ Copo de água removido e persistido no Supabase');
    } catch (e) {
      // Reverte a atualização otimista em caso de erro
      state = state.copyWith(
        waterIntake: currentIntake,
        errorMessage: e is AppException ? e.message : 'Erro ao remover copo de água',
      );
      
      debugPrint('❌ Erro ao remover copo de água: $e');
    }
  }

  /// Atualiza a meta diária de copos de água
  Future<void> updateGoal(int newGoal) async {
    if (state.isLoading || newGoal < 1) return;
    
    final currentIntake = state.waterIntake;
    final int currentCups = currentIntake?.cups ?? 0;
    
    // Atualiza o estado otimisticamente
    if (currentIntake != null) {
      state = state.copyWith(
        waterIntake: currentIntake.copyWith(goal: newGoal),
      );
    }
    
    try {
      // PATCH: Corrigir bug 2 - Persistir meta de água no Supabase
      final today = DateTime.now();
      final updatedIntake = await _repository.insertOrUpdateWaterIntake(
        userId: _userId,
        date: today,
        cups: currentCups,
        goal: newGoal,
        notes: currentIntake?.notes,
      );
      
      // Atualiza o estado com os dados retornados do servidor
      state = state.copyWith(
        waterIntake: updatedIntake,
      );
      
      debugPrint('✅ Meta de água atualizada e persistida no Supabase');
    } catch (e) {
      // Reverte a atualização otimista em caso de erro
      state = state.copyWith(
        waterIntake: currentIntake,
        errorMessage: e is AppException ? e.message : 'Erro ao atualizar meta de água',
      );
      
      debugPrint('❌ Erro ao atualizar meta de água: $e');
    }
  }
}

/// Provider para o WaterViewModel
final waterViewModelProvider = StateNotifierProvider<WaterViewModel, WaterState>((ref) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id ?? '';
  
  return WaterViewModel(repository, userId);
}); 