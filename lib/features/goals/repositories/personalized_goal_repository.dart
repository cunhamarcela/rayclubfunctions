import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/goals/models/personalized_goal.dart';
import 'package:ray_club_app/services/supabase_service.dart';

/// Repositório para gerenciar metas personalizáveis
class PersonalizedGoalRepository {
  final SupabaseService _supabaseService;

  PersonalizedGoalRepository(this._supabaseService);

  /// Obter meta ativa do usuário
  Future<GoalStatus?> getUserActiveGoal(String userId) async {
    try {
      final response = await _supabaseService.client
          .rpc('get_user_active_goal', params: {'p_user_id': userId});

      if (response == null) {
        throw AppException(message: 'Resposta nula do servidor');
      }

      final data = response as Map<String, dynamic>;
      
      if (!data['success']) {
        if (!data['has_goal']) {
          return null; // Usuário não tem meta ativa
        }
        throw AppException(message: data['message'] ?? 'Erro ao buscar meta');
      }

      final goalData = data['goal'] as Map<String, dynamic>;
      
      final goal = PersonalizedGoal(
        id: goalData['id'],
        userId: userId,
        presetType: PersonalizedGoalPresetType.fromString(
          goalData['preset_type'] ?? 'custom'
        ),
        title: goalData['title'],
        description: goalData['description'],
        measurementType: PersonalizedGoalMeasurementType.fromString(
          goalData['measurement_type']
        ),
        targetValue: (goalData['target_value'] as num).toDouble(),
        currentProgress: (goalData['current_progress'] as num).toDouble(),
        unitLabel: goalData['unit_label'],
        incrementStep: (goalData['increment_step'] as num?)?.toDouble() ?? 1.0,
        weekStartDate: DateTime.parse(goalData['week_start_date']),
        weekEndDate: DateTime.parse(goalData['week_end_date']),
        isActive: goalData['is_active'] ?? true,
        isCompleted: goalData['is_completed'] ?? false,
        completedAt: goalData['completed_at'] != null 
            ? DateTime.parse(goalData['completed_at']) 
            : null,
        createdAt: DateTime.parse(goalData['created_at']),
        updatedAt: goalData['updated_at'] != null 
            ? DateTime.parse(goalData['updated_at']) 
            : null,
      );

      return GoalStatus(
        goal: goal,
        checkinsToday: goalData['checkins_today'] ?? 0,
        progressToday: (goalData['progress_today'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Erro ao buscar meta ativa: $e');
    }
  }

  /// Criar meta pré-estabelecida
  Future<PersonalizedGoal> createPresetGoal(
    String userId, 
    PersonalizedGoalPresetType presetType
  ) async {
    try {
      final response = await _supabaseService.client
          .rpc('create_preset_goal', params: {
            'p_user_id': userId,
            'p_preset_type': presetType.value,
          });

      if (response == null) {
        throw AppException(message: 'Resposta nula do servidor');
      }

      final data = response as Map<String, dynamic>;
      
      if (!data['success']) {
        throw AppException(message: data['error'] ?? 'Erro ao criar meta');
      }

      // Buscar a meta completa que foi criada
      final goalStatus = await getUserActiveGoal(userId);
      if (goalStatus == null) {
        throw AppException(message: 'Meta criada mas não encontrada');
      }

      return goalStatus.goal;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Erro ao criar meta pré-estabelecida: $e');
    }
  }

  /// Criar meta personalizada
  Future<PersonalizedGoal> createCustomGoal(
    String userId, 
    CreateGoalData goalData
  ) async {
    try {
      // Desativar meta atual se existir
      await _deactivateCurrentGoal(userId);

      // Criar nova meta personalizada
      final result = await _supabaseService.client
          .from('personalized_weekly_goals')
          .insert({
            'user_id': userId,
            'goal_preset_type': goalData.presetType.value,
            'goal_title': goalData.title,
            'goal_description': goalData.description,
            'measurement_type': goalData.measurementType.value,
            'target_value': goalData.targetValue,
            'unit_label': goalData.unitLabel,
            'increment_step': goalData.incrementStep,
          })
          .select()
          .single();

      return _mapToPersonalizedGoal(result, userId);
    } catch (e) {
      throw AppException(message: 'Erro ao criar meta personalizada: $e');
    }
  }

  /// Registrar check-in
  Future<GoalApiResponse> registerCheckIn(
    String userId, 
    String goalId, 
    {String? notes}
  ) async {
    try {
      final response = await _supabaseService.client
          .rpc('register_goal_checkin', params: {
            'p_goal_id': goalId,
            'p_user_id': userId,
            'p_notes': notes,
          });

      if (response == null) {
        throw AppException(message: 'Resposta nula do servidor');
      }

      return GoalApiResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Erro ao registrar check-in: $e');
    }
  }

  /// Adicionar progresso numérico
  Future<GoalApiResponse> addProgress(
    String userId, 
    String goalId, 
    double valueAdded, 
    {String? notes}
  ) async {
    try {
      final response = await _supabaseService.client
          .rpc('add_goal_progress', params: {
            'p_goal_id': goalId,
            'p_user_id': userId,
            'p_value_added': valueAdded,
            'p_notes': notes,
            'p_source': 'manual',
          });

      if (response == null) {
        throw AppException(message: 'Resposta nula do servidor');
      }

      return GoalApiResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Erro ao adicionar progresso: $e');
    }
  }

  /// Buscar check-ins da semana
  Future<List<GoalCheckIn>> getWeeklyCheckIns(
    String userId, 
    String goalId
  ) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final result = await _supabaseService.client
          .from('goal_check_ins')
          .select()
          .eq('user_id', userId)
          .eq('goal_id', goalId)
          .gte('check_in_date', startOfWeek.toIso8601String().split('T')[0])
          .lte('check_in_date', endOfWeek.toIso8601String().split('T')[0])
          .order('check_in_date', ascending: true);

      return (result as List<dynamic>)
          .map((json) => _mapToGoalCheckIn(json))
          .toList();
    } catch (e) {
      throw AppException(message: 'Erro ao buscar check-ins: $e');
    }
  }

  /// Buscar entradas de progresso da semana
  Future<List<GoalProgressEntry>> getWeeklyProgressEntries(
    String userId, 
    String goalId
  ) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final result = await _supabaseService.client
          .from('goal_progress_entries')
          .select()
          .eq('user_id', userId)
          .eq('goal_id', goalId)
          .gte('entry_date', startOfWeek.toIso8601String().split('T')[0])
          .lte('entry_date', endOfWeek.toIso8601String().split('T')[0])
          .order('entry_date', ascending: true);

      return (result as List<dynamic>)
          .map((json) => _mapToGoalProgressEntry(json))
          .toList();
    } catch (e) {
      throw AppException(message: 'Erro ao buscar entradas de progresso: $e');
    }
  }

  /// Desativar meta atual
  Future<void> _deactivateCurrentGoal(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    await _supabaseService.client
        .from('personalized_weekly_goals')
        .update({'is_active': false})
        .eq('user_id', userId)
        .eq('week_start_date', startOfWeek.toIso8601String().split('T')[0])
        .eq('is_active', true);
  }

  /// Mapear dados do banco para PersonalizedGoal
  PersonalizedGoal _mapToPersonalizedGoal(
    Map<String, dynamic> data, 
    String userId
  ) {
    return PersonalizedGoal(
      id: data['id'],
      userId: userId,
      presetType: PersonalizedGoalPresetType.fromString(
        data['goal_preset_type'] ?? 'custom'
      ),
      title: data['goal_title'],
      description: data['goal_description'],
      measurementType: PersonalizedGoalMeasurementType.fromString(
        data['measurement_type']
      ),
      targetValue: (data['target_value'] as num).toDouble(),
      currentProgress: (data['current_progress'] as num).toDouble(),
      unitLabel: data['unit_label'],
      incrementStep: (data['increment_step'] as num?)?.toDouble() ?? 1.0,
      weekStartDate: DateTime.parse(data['week_start_date']),
      weekEndDate: DateTime.parse(data['week_end_date']),
      isActive: data['is_active'] ?? true,
      isCompleted: data['is_completed'] ?? false,
      completedAt: data['completed_at'] != null 
          ? DateTime.parse(data['completed_at']) 
          : null,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : null,
    );
  }

  /// Mapear dados do banco para GoalCheckIn
  GoalCheckIn _mapToGoalCheckIn(Map<String, dynamic> data) {
    return GoalCheckIn(
      id: data['id'],
      goalId: data['goal_id'],
      userId: data['user_id'],
      checkInDate: DateTime.parse(data['check_in_date']),
      checkInTime: DateTime.parse(data['check_in_time']),
      notes: data['notes'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  /// Mapear dados do banco para GoalProgressEntry
  GoalProgressEntry _mapToGoalProgressEntry(Map<String, dynamic> data) {
    return GoalProgressEntry(
      id: data['id'],
      goalId: data['goal_id'],
      userId: data['user_id'],
      valueAdded: (data['value_added'] as num).toDouble(),
      entryDate: DateTime.parse(data['entry_date']),
      entryTime: DateTime.parse(data['entry_time']),
      notes: data['notes'],
      source: data['source'] ?? 'manual',
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  // TODO: Implementar streams quando necessário
  // Os métodos de stream foram temporariamente removidos para resolver 
  // problemas de compilação. Podem ser adicionados depois.
} 