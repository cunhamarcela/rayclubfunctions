/// Define constantes para os nomes de parâmetros usados nas funções RPC relacionadas a desafios
/// Centraliza as definições para evitar erros de digitação e inconsistências
class ChallengeRpcParams {
  // Nome da função de registro de check-in no Supabase
  static const String recordChallengeCheckInFunction = 'record_challenge_check_in_v2';
  
  // Nomes dos parâmetros para record_challenge_check_in_v2
  static const String challengeIdParam = '_challenge_id';
  static const String dateParam = '_date';
  static const String durationMinutesParam = '_duration_minutes';
  static const String userIdParam = '_user_id';
  static const String workoutIdParam = '_workout_id';
  static const String workoutNameParam = '_workout_name';
  static const String workoutTypeParam = '_workout_type';
  
  // Campos na resposta de record_challenge_check_in
  static const String successField = 'success';
  static const String messageField = 'message';
  static const String pointsEarnedField = 'points_earned';
  static const String streakField = 'streak';
  static const String checkInIdField = 'check_in_id';
  static const String currentPointsField = 'current_points';
  static const String isAlreadyCheckedInField = 'is_already_checked_in';
  
  // Outras funções
  static const String hasCheckedInTodayFunction = 'has_checked_in_today';
  static const String getCurrentStreakFunction = 'get_current_streak';
  
  // Nomes de funções usadas para dashboard e progressos
  static const String getDashboardStatsFunction = 'get_user_dashboard_stats';
  static const String updateChallengeRankingFunction = 'update_challenge_ranking';
  
  // Prevenir instanciação da classe
  ChallengeRpcParams._();
} 