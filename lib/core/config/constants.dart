class AppConstants {
  // API Endpoints
  static const String apiBaseEndpoint = '/api';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String challengesEndpoint = '/challenges';
  static const String workoutsEndpoint = '/workouts';

  // Storage Paths
  static const String userAvatarsPath = 'avatars';
  static const String challengeImagesPath = 'challenges';
  static const String workoutImagesPath = 'workouts';

  // Cache Keys
  static const String userCacheKey = 'user_cache';
  static const String tokenCacheKey = 'token_cache';
  static const String settingsCacheKey = 'settings_cache';

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int cacheExpirationHours = 24;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const int animationDurationMs = 300;
}
