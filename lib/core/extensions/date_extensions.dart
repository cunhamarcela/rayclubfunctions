/// Extensões para facilitar a manipulação de DateTime com o Supabase
extension DateTimeSupabaseExtension on DateTime {
  /// Retorna uma string ISO8601 com o fuso horário de Brasília (UTC-3)
  /// para envio ao Supabase
  String toSupabaseString() {
    // Garantir que a data tenha informação de timezone de Brasília (UTC-3)
    final dateWithTimezone = toUtc().add(const Duration(hours: -3));
    return dateWithTimezone.toIso8601String();
  }
  
  /// Retorna apenas a data no formato ISO (YYYY-MM-DD)
  String toIsoDateString() {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
  
  /// Normaliza a data para o início do dia (00:00:00) com timezone
  DateTime toStartOfDayWithTimezone() {
    return DateTime.utc(year, month, day, 0, 0, 0).add(const Duration(hours: -3));
  }
  
  /// Normaliza a data para o fim do dia (23:59:59) com timezone
  DateTime toEndOfDayWithTimezone() {
    return DateTime.utc(year, month, day, 23, 59, 59, 999).add(const Duration(hours: -3));
  }
}

/// Extensão para String para facilitar a conversão de strings ISO8601 do Supabase
extension StringDateTimeExtension on String {
  /// Converte uma string ISO8601 recebida do Supabase para DateTime local
  DateTime toDateTimeFromSupabase() {
    return DateTime.parse(this);
  }
} 