// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_fitness_data.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_period.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_fitness_repository.dart';

/// Provider para o ViewModel do dashboard fitness
final dashboardFitnessViewModelProvider = 
    StateNotifierProvider<DashboardFitnessViewModel, AsyncValue<DashboardFitnessData>>((ref) {
  final repository = ref.watch(dashboardFitnessRepositoryProvider);
  return DashboardFitnessViewModel(repository);
});

/// Provider para detalhes de um dia específico
final dayDetailsProvider = 
    StateNotifierProvider.family<DayDetailsViewModel, AsyncValue<DayDetailsData>, DateTime>((ref, date) {
  final repository = ref.watch(dashboardFitnessRepositoryProvider);
  return DayDetailsViewModel(repository, date);
});

/// ViewModel para gerenciar o estado do dashboard fitness com filtros de período
class DashboardFitnessViewModel extends StateNotifier<AsyncValue<DashboardFitnessData>> {
  final DashboardFitnessRepository _repository;
  DateTime _currentMonth = DateTime.now();
  
  // Propriedades de filtro de período
  DashboardPeriod _selectedPeriod = DashboardPeriod.thisMonth;
  DateRange? _customRange;

  DashboardFitnessViewModel(this._repository) : super(const AsyncValue.loading()) {
    // Carrega os dados automaticamente ao inicializar
    _initializeWithLatestMonth();
  }

  /// Período selecionado atualmente
  DashboardPeriod get selectedPeriod => _selectedPeriod;
  
  /// Range personalizado (quando período é custom)
  DateRange? get customRange => _customRange;
  
  /// Retorna a lista de períodos disponíveis
  List<DashboardPeriod> get availablePeriods => [
    DashboardPeriod.thisWeek,
    DashboardPeriod.lastWeek,
    DashboardPeriod.thisMonth,
    DashboardPeriod.lastMonth,
    DashboardPeriod.last30Days,
    DashboardPeriod.last3Months,
    DashboardPeriod.thisYear,
    DashboardPeriod.custom,
  ];
  
  /// Verifica se o período atual é personalizado
  bool get isCustomPeriod => _selectedPeriod == DashboardPeriod.custom;
  
  /// Retorna o texto descritivo do período atual
  String get currentPeriodDescription {
    if (_selectedPeriod == DashboardPeriod.custom && _customRange != null) {
      return _customRange!.formattedRange;
    }
    return _selectedPeriod.description;
  }

  /// Atualiza o período selecionado
  Future<void> updatePeriod(DashboardPeriod period, [DateRange? customRange]) async {
    if (_selectedPeriod == period && _customRange == customRange) {
      debugPrint('📅 Período já está selecionado: ${period.displayName}');
      return;
    }
    
    debugPrint('📅 Atualizando período: ${_selectedPeriod.displayName} → ${period.displayName}');
    
    _selectedPeriod = period;
    _customRange = customRange;
    
    // Recarrega os dados com o novo período
    await loadDashboardData();
  }

  /// Inicializa o dashboard com o mês que tem treinos mais recentes
  Future<void> _initializeWithLatestMonth() async {
    try {
      // Detectar o mês com treinos mais recentes
      final latestMonth = await _repository.getLatestWorkoutMonth();
      _currentMonth = latestMonth;
      
      debugPrint('📊 Dashboard inicializado para mês com treinos: ${_currentMonth.month}/${_currentMonth.year}');
      
      // Carregar os dados para esse mês
      await loadDashboardData();
    } catch (e) {
      debugPrint('❌ Erro ao detectar mês com treinos, usando mês atual: $e');
      // Em caso de erro, usar mês atual
      _currentMonth = DateTime.now();
      await loadDashboardData();
    }
  }

  /// Mês atual sendo exibido
  DateTime get currentMonth => _currentMonth;

  /// Carrega dados do dashboard baseado no período selecionado
  Future<void> loadDashboardData({DateTime? month}) async {
    try {
      if (month != null) {
        _currentMonth = month;
      }

      state = const AsyncValue.loading();
      
      debugPrint('📊 Carregando dashboard fitness para período: ${_selectedPeriod.displayName}');
      
      // Calcula o range de datas baseado no período selecionado
      final dateRange = _selectedPeriod.calculateDateRange(_customRange);
      
      debugPrint('📅 Período calculado: ${dateRange.formattedRange}');
      
      final data = await _repository.getDashboardFitnessData(
        period: _selectedPeriod,
        customRange: _customRange,
      );
      
      state = AsyncValue.data(data);
      
      debugPrint('✅ Dashboard fitness carregado com sucesso');
      debugPrint('✅ - Calendário: ${data.calendar.days.length} dias');
      debugPrint('✅ - Treinos na semana: ${data.progress.week.workouts}');
      debugPrint('✅ - Treinos no mês: ${data.progress.month.workouts}');
      debugPrint('✅ - Streak atual: ${data.progress.streak.current} dias');
      
    } on AppException catch (e) {
      debugPrint('❌ Erro AppException no dashboard fitness: ${e.message}');
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ Erro genérico no dashboard fitness: $e');
      state = AsyncValue.error(
        AppException(
          message: 'Erro ao carregar dashboard fitness',
          code: 'LOAD_ERROR',
          originalError: e,
        ),
        stackTrace,
      );
    }
  }

  /// Navega para o mês anterior
  Future<void> goToPreviousMonth() async {
    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    await loadDashboardData(month: previousMonth);
  }

  /// Navega para o próximo mês
  Future<void> goToNextMonth() async {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    await loadDashboardData(month: nextMonth);
  }

  /// Navega para o mês atual ou mês com treinos mais recentes
  Future<void> goToCurrentMonth() async {
    try {
      // Detectar o mês com treinos mais recentes
      final latestMonth = await _repository.getLatestWorkoutMonth();
      await loadDashboardData(month: latestMonth);
    } catch (e) {
      // Em caso de erro, usar mês atual
      await loadDashboardData(month: DateTime.now());
    }
  }

  /// Força atualização dos dados
  Future<void> refreshData() async {
    try {
      debugPrint('🔄 Atualizando dados do dashboard fitness...');
      
      // Primeiro, atualiza os dados no backend
      await _repository.refreshDashboardData();
      
      // Depois, recarrega os dados na tela
      await loadDashboardData();
      
      debugPrint('✅ Dados do dashboard fitness atualizados');
      
    } on AppException catch (e) {
      debugPrint('❌ Erro ao atualizar dashboard fitness: ${e.message}');
      // Não atualiza o estado de erro aqui, apenas loga
    } catch (e) {
      debugPrint('❌ Erro genérico ao atualizar dashboard fitness: $e');
      // Não atualiza o estado de erro aqui, apenas loga
    }
  }

  /// Obtém os dados do calendário para um dia específico
  CalendarDayData? getDayData(DateTime date) {
    return state.whenOrNull(
      data: (data) {
        try {
          return data.calendar.days.firstWhere(
            (day) => 
              day.date.year == date.year &&
              day.date.month == date.month &&
              day.date.day == date.day,
          );
        } catch (e) {
          return null;
        }
      },
    );
  }

  /// Verifica se uma data está no período atual sendo exibido
  bool isInCurrentPeriod(DateTime date) {
    if (_selectedPeriod == DashboardPeriod.custom && _customRange != null) {
      return date.isAfter(_customRange!.start.subtract(const Duration(days: 1))) &&
             date.isBefore(_customRange!.end.add(const Duration(days: 1)));
    }
    
    // Para períodos não personalizados, usar lógica do período
    final range = _selectedPeriod.calculateDateRange(_customRange);
    return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
           date.isBefore(range.end.add(const Duration(days: 1)));
  }

  /// Verifica se uma data está no mês atual sendo exibido
  bool isInCurrentMonth(DateTime date) {
    return date.year == _currentMonth.year && date.month == _currentMonth.month;
  }

  /// Verifica se uma data é hoje
  bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  /// Verifica se uma data é no futuro
  bool isFuture(DateTime date) {
    final today = DateTime.now();
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }
}

/// ViewModel para detalhes de um dia específico
class DayDetailsViewModel extends StateNotifier<AsyncValue<DayDetailsData>> {
  final DashboardFitnessRepository _repository;
  final DateTime _date;

  DayDetailsViewModel(this._repository, this._date) : super(const AsyncValue.loading()) {
    loadDayDetails();
  }

  /// Data do dia
  DateTime get date => _date;

  /// Carrega detalhes do dia
  Future<void> loadDayDetails() async {
    try {
      state = const AsyncValue.loading();
      
      debugPrint('📅 Carregando detalhes do dia ${_date.toIso8601String().split('T')[0]}');
      
      final data = await _repository.getDayDetails(date: _date);
      
      state = AsyncValue.data(data);
      
      debugPrint('✅ Detalhes do dia carregados com sucesso');
      debugPrint('✅ - Total de treinos: ${data.totalWorkouts}');
      debugPrint('✅ - Total de minutos: ${data.totalMinutes}');
      debugPrint('✅ - Total de pontos: ${data.totalPoints}');
      
    } on AppException catch (e) {
      debugPrint('❌ Erro AppException nos detalhes do dia: ${e.message}');
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stackTrace) {
      debugPrint('❌ Erro genérico nos detalhes do dia: $e');
      state = AsyncValue.error(
        AppException(
          message: 'Erro ao carregar detalhes do dia',
          code: 'LOAD_ERROR',
          originalError: e,
        ),
        stackTrace,
      );
    }
  }

  /// Força atualização dos detalhes do dia
  Future<void> refreshDayDetails() async {
    await loadDayDetails();
  }
} 