// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Project imports:
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/challenges/repositories/challenge_repository.dart';
import '../../features/challenges/providers/challenge_providers.dart';
import '../../features/nutrition/repositories/meal_repository.dart';
import '../../features/nutrition/repositories/meal_repository_interface.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/profile/repositories/supabase_profile_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/http_service.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_service.dart';
import '../config/app_config.dart';
import './service_providers.dart' as service_providers;
import '../errors/error_logger.dart';
import '../errors/error_handler.dart';
import '../providers/supabase_providers.dart';

// Exportar os novos providers
export './shared_state_provider.dart';
export '../events/app_event_bus.dart';
export '../../features/challenges/providers/challenge_providers.dart';

// Core Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences deve ser inicializado antes do uso');
});

// Supabase Client Provider
final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseService(supabaseClient);
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Repository Providers
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient);
});

// MealRepository Provider
final mealRepositoryProvider = Provider<MealRepositoryInterface>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return MealRepository(supabaseClient);
});

// Um exemplo de provider para um repositório de usuário
final userRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(supabase);
});

// Provider específico para o ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // Reutilizamos a mesma implementação do userRepositoryProvider
  return ref.watch(userRepositoryProvider);
});

// Service Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return ref.watch(service_providers.storageServiceProvider);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    enabled: AppConfig.analyticsEnabled,
    key: AppConfig.analyticsKey,
  );
});

// Adicionando o provider para o ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider para HttpService
final httpServiceProvider = Provider<HttpService>((ref) {
  final dio = ref.watch(dioProvider);
  return HttpService(dio: dio);
});

// Provider para NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NotificationService(supabase: supabase);
});

/// Provider do erro handler global
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final remoteLoggingService = ref.watch(service_providers.remoteLoggingServiceProvider);
  
  // Inicializa o ErrorLogger para registro automático de erros
  ErrorLogger.initialize();
  
  return ErrorHandler(remoteLoggingService: remoteLoggingService);
});
