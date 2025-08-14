/// Enum para filtros de período das metas
enum GoalPeriodFilter {
  currentWeek('current_week', 'Semana Atual'),
  lastWeek('last_week', 'Semana Passada'),
  last4Weeks('last_4_weeks', 'Últimas 4 Semanas'),
  allTime('all_time', 'Todas as Metas');

  const GoalPeriodFilter(this.value, this.displayName);

  final String value;
  final String displayName;

  static GoalPeriodFilter fromString(String value) {
    return GoalPeriodFilter.values.firstWhere(
      (filter) => filter.value == value,
      orElse: () => GoalPeriodFilter.currentWeek,
    );
  }
} 