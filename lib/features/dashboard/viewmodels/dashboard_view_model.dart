// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_period.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Provider para o DashboardViewModel
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardData>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Verifica se tem usuário autenticado
  final userId = authState.maybeWhen(
    authenticated: (user) => user.id,
    orElse: () => null,
  );
  
  return DashboardViewModel(repository, userId);
});

/// ViewModel para os dados do dashboard
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardData>> {
  /// Repositório para acesso aos dados
  final DashboardRepository _repository;
  
  /// ID do usuário atual
  final String? _userId;
  
  /// Período atualmente selecionado
  DashboardPeriod _selectedPeriod = DashboardPeriod.thisMonth;
  
  /// Range personalizado se o período for custom
  DateRange? _customRange;
  
  /// Getter para o período atual
  DashboardPeriod get selectedPeriod => _selectedPeriod;
  
  /// Getter para o range personalizado
  DateRange? get customRange => _customRange;
  
  /// Getter para as datas calculadas do período atual
  DateRange get currentDateRange => _selectedPeriod.calculateDateRange(_customRange);
  
  /// Construtor que inicializa o estado como loading e carrega os dados
  DashboardViewModel(this._repository, this._userId) 
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      debugPrint('📊 Dashboard inicializado para usuário: $_userId');
      debugPrint('📅 Período inicial: ${_selectedPeriod.displayName}');
      loadDashboardData();
    } else {
      debugPrint('❌ Dashboard inicializado sem usuário autenticado');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
    }
  }
  
  /// Carrega os dados do dashboard com o período atual
  Future<void> loadDashboardData() async {
    if (_userId == null) {
      debugPrint('❌ Tentativa de carregar dashboard sem usuário');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
      return;
    }
    
    // Marca como carregando
    state = const AsyncValue.loading();
    
    try {
      debugPrint('🔄 Carregando dados do dashboard para usuário: $_userId');
      debugPrint('📅 Período: ${_selectedPeriod.displayName}');
      
      // Carrega os dados do dashboard com o período atual
      final dashboardData = await _repository.getDashboardData(
        _userId!,
        period: _selectedPeriod,
        customRange: _customRange,
      );
      
      // Atualiza o estado com os novos dados
      state = AsyncValue.data(dashboardData);
      
      debugPrint('✅ Dados do dashboard carregados com sucesso:');
      debugPrint('✅ - Período: ${_selectedPeriod.displayName}');
      debugPrint('✅ - Total de treinos: ${dashboardData.totalWorkouts}');
      debugPrint('✅ - Duração total: ${dashboardData.totalDuration} minutos');
      debugPrint('✅ - Dias treinados: ${dashboardData.daysTrainedThisMonth}');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar dados do dashboard: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// Força uma atualização dos dados do dashboard
  Future<void> refreshData() async {
    try {
      await loadDashboardData();
      debugPrint('✅ Dados do dashboard atualizados com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar dados do dashboard: $e');
    }
  }
  
  /// Atualiza o período selecionado e recarrega os dados
  /// [period] - Novo período a ser selecionado
  /// [customRange] - Range personalizado se period for custom
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
} 