// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import '../models/water_intake_mapper.dart';

/// Interface do repositório para consumo de água
abstract class WaterIntakeRepository {
  /// Obtém o registro de consumo de água do dia atual
  Future<WaterIntake> getTodayWaterIntake();
  
  /// Adiciona um copo de água ao consumo do dia
  Future<WaterIntake> addGlass();
  
  /// Remove um copo de água do consumo do dia
  Future<WaterIntake> removeGlass();
  
  /// Atualiza a meta diária de copos
  Future<WaterIntake> updateDailyGoal(int newGoal);
  
  /// Obtém o histórico de consumo de água para um intervalo de datas
  Future<List<WaterIntake>> getWaterIntakeHistory({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Obtém o registro de consumo de água para uma data específica
  Future<WaterIntake?> getWaterIntakeByDate(DateTime date);
  
  /// Obtém estatísticas de consumo de água para o período
  Future<WaterIntakeStats> getWaterIntakeStats({
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Modelo para estatísticas de consumo de água
class WaterIntakeStats {
  final int totalGlasses;
  final int daysTracked;
  final int daysGoalReached;
  final double averageGlassesPerDay;
  final double goalAchievementRate;
  final int totalMilliliters;
  
  WaterIntakeStats({
    required this.totalGlasses,
    required this.daysTracked,
    required this.daysGoalReached,
    required this.averageGlassesPerDay,
    required this.goalAchievementRate,
    required this.totalMilliliters,
  });
}

/// Implementação mock do repositório para desenvolvimento
class MockWaterIntakeRepository implements WaterIntakeRepository {
  WaterIntake? _todayIntake;
  
  @override
  Future<WaterIntake> getTodayWaterIntake() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_todayIntake == null) {
      // Criar um registro para hoje se não existir
      _todayIntake = WaterIntake(
        id: 'water-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user123',
        date: DateTime.now(),
        currentGlasses: 5, // Já consumiu 5 copos (para demonstração)
        dailyGoal: 8,
        createdAt: DateTime.now(),
      );
    }
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> addGlass() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Incrementar o contador de copos
    _todayIntake = intake.copyWith(
      currentGlasses: intake.currentGlasses + 1,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> removeGlass() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Não permitir valores negativos
    if (intake.currentGlasses <= 0) {
      return intake;
    }
    
    // Decrementar o contador de copos
    _todayIntake = intake.copyWith(
      currentGlasses: intake.currentGlasses - 1,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> updateDailyGoal(int newGoal) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Não permitir valores negativos ou zero
    if (newGoal <= 0) {
      throw ValidationException(
        message: 'A meta diária deve ser maior que zero',
        code: 'invalid_goal',
      );
    }
    
    // Atualizar a meta diária
    _todayIntake = intake.copyWith(
      dailyGoal: newGoal,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }
  
  @override
  Future<List<WaterIntake>> getWaterIntakeHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Gerar dados de exemplo para o intervalo
    final history = <WaterIntake>[];
    
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Gerar dados aleatórios para demonstração
      final glasses = 3 + (currentDate.day % 6); // Entre 3 e 8 copos
      final goal = 8;
      
      history.add(WaterIntake(
        id: 'water-${currentDate.millisecondsSinceEpoch}',
        userId: 'user123',
        date: currentDate,
        currentGlasses: glasses,
        dailyGoal: goal,
        createdAt: currentDate,
        updatedAt: currentDate.add(const Duration(hours: 20)), // Simulando atualização à noite
      ));
      
      // Avançar para o próximo dia
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    }
    
    return history;
  }
  
  @override
  Future<WaterIntake?> getWaterIntakeByDate(DateTime date) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Verificar se é hoje
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    if (isToday && _todayIntake != null) {
      return _todayIntake;
    }
    
    // Simular dados para data específica
    final glasses = 3 + (date.day % 6); // Entre 3 e 8 copos
    
    return WaterIntake(
      id: 'water-${date.millisecondsSinceEpoch}',
      userId: 'user123',
      date: date,
      currentGlasses: glasses,
      dailyGoal: 8,
      createdAt: date,
      updatedAt: date.add(const Duration(hours: 20)),
    );
  }
  
  @override
  Future<WaterIntakeStats> getWaterIntakeStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Obter o histórico para calcular estatísticas
    final history = await getWaterIntakeHistory(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Calcular estatísticas
    final totalGlasses = history.fold<int>(0, (sum, item) => sum + item.currentGlasses);
    final daysTracked = history.length;
    final daysGoalReached = history.where((item) => item.isGoalReached).length;
    
    return WaterIntakeStats(
      totalGlasses: totalGlasses,
      daysTracked: daysTracked,
      daysGoalReached: daysGoalReached,
      averageGlassesPerDay: daysTracked > 0 ? totalGlasses / daysTracked : 0,
      goalAchievementRate: daysTracked > 0 ? daysGoalReached / daysTracked : 0,
      totalMilliliters: totalGlasses * 250, // Considerando 250ml por copo
    );
  }
}

/// Implementação com Supabase
class SupabaseWaterIntakeRepository implements WaterIntakeRepository {
  final SupabaseClient _supabaseClient;

  SupabaseWaterIntakeRepository(this._supabaseClient);

  @override
  Future<WaterIntake> getTodayWaterIntake() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Tentar buscar o registro de hoje
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      if (response != null) {
        debugPrint('✅ WaterIntakeRepository: Registro encontrado com ID: ${response['id']}');
        return WaterIntakeMapper.fromJson(response);
      }
      
      // Se não existir, criar um novo registro
      // Não incluímos o ID, deixamos o Supabase gerar automaticamente
      final insertData = {
        'user_id': userId,
        'date': todayStr,
        'cups': 0,
        'goal': 8, // Valor padrão
        'glass_size': 250, // Valor padrão
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final inserted = await _supabaseClient
          .from('water_intake')
          .insert(insertData)
          .select()
          .single();
      
      debugPrint('✅ WaterIntakeRepository: Registro criado com ID: ${inserted['id']}');
      return WaterIntakeMapper.fromJson(inserted);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getTodayWaterIntake();
    }
  }

  // PATCH: Corrigir bug 2 - Função para garantir que o registro de água seja persistido corretamente
  Future<WaterIntake> insertOrUpdateWaterIntake({
    required String userId,
    required DateTime date,
    required int cups,
    required int goal,
    String? notes,
  }) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException(
          message: 'ID do usuário não pode ser vazio',
          code: 'invalid_user_id',
        );
      }
      
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar registro existente
        final updated = await _supabaseClient
            .from('water_intake')
            .update({
              'cups': cups,
              'goal': goal,
              'notes': notes,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro atualizado com ID: ${updated['id']}');
        return WaterIntakeMapper.fromJson(updated);
      } else {
        // Criar novo registro
        final insertData = {
          'user_id': userId,
          'date': dateStr,
          'cups': cups,
          'goal': goal,
          'notes': notes,
          'glass_size': 250, // Valor padrão
          'created_at': DateTime.now().toIso8601String(),
        };
        
        final inserted = await _supabaseClient
            .from('water_intake')
            .insert(insertData)
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro criado com ID: ${inserted['id']}');
        return WaterIntakeMapper.fromJson(inserted);
      }
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao salvar registro de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> addGlass() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      // Determinar número atual de copos e meta
      final currentGlasses = existing != null ? (existing['cups'] as int? ?? 0) : 0;
      final goal = existing != null ? (existing['goal'] as int? ?? 8) : 8;
      final notes = existing != null ? (existing['notes'] as String?) : null;
      
      // PATCH: Corrigir bug 2 - Usar a função insertOrUpdateWaterIntake para garantir persistência
      return insertOrUpdateWaterIntake(
        userId: userId,
        date: today,
        cups: currentGlasses + 1,
        goal: goal,
        notes: notes,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao adicionar copo de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> removeGlass() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      // Determinar valores atuais
      int currentGlasses = 0;
      int goal = 8;
      String? notes;
      
      if (existing != null) {
        currentGlasses = existing['cups'] as int? ?? 0;
        goal = existing['goal'] as int? ?? 8;
        notes = existing['notes'] as String?;
      }
      
      // Garantir que não fique negativo
      final newGlassCount = (currentGlasses > 0) ? currentGlasses - 1 : 0;
      
      // PATCH: Corrigir bug 2 - Usar a função insertOrUpdateWaterIntake para garantir persistência
      return insertOrUpdateWaterIntake(
        userId: userId,
        date: today,
        cups: newGlassCount,
        goal: goal,
        notes: notes,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao remover copo de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> updateDailyGoal(int newGoal) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Não permitir valores negativos ou zero
      if (newGoal <= 0) {
        throw ValidationException(
          message: 'A meta diária deve ser maior que zero',
          code: 'invalid_goal',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar a meta diária
        final updated = await _supabaseClient
            .from('water_intake')
            .update({
              'goal': newGoal,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro atualizado com ID: ${updated['id']}');
        return WaterIntakeMapper.fromJson(updated);
      } else {
        // Criar um novo registro se não existir
        final insertData = {
          'user_id': userId,
          'date': todayStr,
          'cups': 0,
          'goal': newGoal, 
          'glass_size': 250, // Valor padrão
          'created_at': DateTime.now().toIso8601String(),
        };
        
        final inserted = await _supabaseClient
            .from('water_intake')
            .insert(insertData)
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro criado com ID: ${inserted['id']}');
        return WaterIntakeMapper.fromJson(inserted);
      }
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar meta diária: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<WaterIntake>> getWaterIntakeHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Formatar datas para string no formato do Supabase
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      // Buscar registros no intervalo de datas
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .gte('date', startDateStr)
          .lte('date', endDateStr)
          .order('date');
      
      // Converter para lista de objetos WaterIntake
      return response
          .map<WaterIntake>((json) => WaterIntakeMapper.fromJson(json))
          .toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getWaterIntakeHistory(
        startDate: startDate, 
        endDate: endDate,
      );
    }
  }
  
  @override
  Future<WaterIntake?> getWaterIntakeByDate(DateTime date) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se é hoje
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      if (isToday) {
        return getTodayWaterIntake();
      }
      
      // Formatar data para string no formato do Supabase
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Buscar registro para a data específica
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();
      
      if (response != null) {
        debugPrint('✅ WaterIntakeRepository: Registro encontrado: ${response['id']}');
        return WaterIntakeMapper.fromJson(response);
      }
      
      return null;
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getWaterIntakeByDate(date);
    }
  }
  
  @override
  Future<WaterIntakeStats> getWaterIntakeStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Obter o histórico para calcular estatísticas
      final history = await getWaterIntakeHistory(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (history.isEmpty) {
        return WaterIntakeStats(
          totalGlasses: 0,
          daysTracked: 0,
          daysGoalReached: 0,
          averageGlassesPerDay: 0,
          goalAchievementRate: 0,
          totalMilliliters: 0,
        );
      }
      
      // Calcular estatísticas
      final totalGlasses = history.fold<int>(0, (sum, item) => sum + item.currentGlasses);
      final daysTracked = history.length;
      final daysGoalReached = history.where((item) => item.isGoalReached).length;
      final averageGlassSize = history.isEmpty 
          ? 250 
          : history.first.glassSize; // Usar o tamanho do primeiro registro
      
      return WaterIntakeStats(
        totalGlasses: totalGlasses,
        daysTracked: daysTracked,
        daysGoalReached: daysGoalReached,
        averageGlassesPerDay: daysTracked > 0 ? totalGlasses / daysTracked : 0,
        goalAchievementRate: daysTracked > 0 ? daysGoalReached / daysTracked : 0,
        totalMilliliters: totalGlasses * averageGlassSize,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getWaterIntakeStats(
        startDate: startDate, 
        endDate: endDate,
      );
    }
  }
}

/// Provider para o repositório de consumo de água
final waterIntakeRepositoryProvider = Provider<WaterIntakeRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseWaterIntakeRepository(supabase);
}); 