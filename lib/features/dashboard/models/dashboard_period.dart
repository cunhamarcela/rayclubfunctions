// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_period.freezed.dart';
part 'dashboard_period.g.dart';

/// Enum que representa os tipos de período disponíveis para o dashboard
enum DashboardPeriod {
  /// Esta semana (segunda a domingo)
  @JsonValue('thisWeek')
  thisWeek,
  
  /// Semana passada
  @JsonValue('lastWeek')
  lastWeek,
  
  /// Este mês (mês atual completo)
  @JsonValue('thisMonth')
  thisMonth,
  
  /// Mês passado
  @JsonValue('lastMonth')
  lastMonth,
  
  /// Últimos 30 dias
  @JsonValue('last30Days')
  last30Days,
  
  /// Últimos 3 meses
  @JsonValue('last3Months')
  last3Months,
  
  /// Este ano (ano atual completo)
  @JsonValue('thisYear')
  thisYear,
  
  /// Período personalizado (usuário escolhe datas)
  @JsonValue('custom')
  custom,
}

/// Extensão para adicionar métodos utilitários ao enum DashboardPeriod
extension DashboardPeriodExtension on DashboardPeriod {
  /// Retorna o texto para exibição na UI
  String get displayName {
    switch (this) {
      case DashboardPeriod.thisWeek:
        return 'Esta semana';
      case DashboardPeriod.lastWeek:
        return 'Semana passada';
      case DashboardPeriod.thisMonth:
        return 'Este mês';
      case DashboardPeriod.lastMonth:
        return 'Mês passado';
      case DashboardPeriod.last30Days:
        return 'Últimos 30 dias';
      case DashboardPeriod.last3Months:
        return 'Últimos 3 meses';
      case DashboardPeriod.thisYear:
        return 'Este ano';
      case DashboardPeriod.custom:
        return 'Personalizado';
    }
  }
  
  /// Retorna uma descrição breve do período
  String get description {
    switch (this) {
      case DashboardPeriod.thisWeek:
        return 'Segunda a domingo desta semana';
      case DashboardPeriod.lastWeek:
        return 'Segunda a domingo da semana passada';
      case DashboardPeriod.thisMonth:
        return 'Do dia 1º até hoje deste mês';
      case DashboardPeriod.lastMonth:
        return 'Todo o mês passado';
      case DashboardPeriod.last30Days:
        return 'Últimos 30 dias corridos';
      case DashboardPeriod.last3Months:
        return 'Últimos 3 meses completos';
      case DashboardPeriod.thisYear:
        return 'Do dia 1º de janeiro até hoje';
      case DashboardPeriod.custom:
        return 'Período escolhido por você';
    }
  }
  
  /// Calcula as datas de início e fim para o período
  DateRange calculateDateRange([DateRange? customRange]) {
    final now = DateTime.now();
    
    switch (this) {
      case DashboardPeriod.thisWeek:
        final weekStart = _getStartOfWeek(now);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return DateRange(start: weekStart, end: weekEnd);
        
      case DashboardPeriod.lastWeek:
        final thisWeekStart = _getStartOfWeek(now);
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
        return DateRange(start: lastWeekStart, end: lastWeekEnd);
        
      case DashboardPeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        return DateRange(start: monthStart, end: monthEnd);
        
      case DashboardPeriod.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        return DateRange(start: lastMonthStart, end: lastMonthEnd);
        
      case DashboardPeriod.last30Days:
        final endDate = now;
        final startDate = now.subtract(const Duration(days: 30));
        return DateRange(start: startDate, end: endDate);
        
      case DashboardPeriod.last3Months:
        final endDate = DateTime(now.year, now.month + 1, 0);
        final startDate = DateTime(now.year, now.month - 2, 1);
        return DateRange(start: startDate, end: endDate);
        
      case DashboardPeriod.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31);
        return DateRange(start: yearStart, end: yearEnd);
        
      case DashboardPeriod.custom:
        if (customRange == null) {
          // Fallback para este mês se não tiver range customizado
          return DashboardPeriod.thisMonth.calculateDateRange();
        }
        return customRange;
    }
  }
  
  /// Helper para calcular o início da semana (segunda-feira)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }
}

/// Modelo que representa um período de datas
@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    /// Data de início do período
    required DateTime start,
    
    /// Data de fim do período
    required DateTime end,
  }) = _DateRange;
  
  /// Conversor de JSON para DateRange
  factory DateRange.fromJson(Map<String, dynamic> json) => _$DateRangeFromJson(json);
}

/// Extensão para adicionar métodos utilitários ao DateRange
extension DateRangeExtension on DateRange {
  /// Retorna o número de dias no período
  int get durationInDays {
    return end.difference(start).inDays + 1;
  }
  
  /// Retorna uma descrição formatada do período
  String get formattedRange {
    final startFormatted = '${start.day}/${start.month}/${start.year}';
    final endFormatted = '${end.day}/${end.month}/${end.year}';
    return '$startFormatted - $endFormatted';
  }
  
  /// Verifica se uma data está dentro do período
  bool contains(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    
    return (dateOnly.isAfter(startOnly) || dateOnly.isAtSameMomentAs(startOnly)) &&
           (dateOnly.isBefore(endOnly) || dateOnly.isAtSameMomentAs(endOnly));
  }
} 