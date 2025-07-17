// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app;
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/core/services/connectivity_service.dart';
import '../models/advanced_settings_state.dart';
import 'advanced_settings_repository.dart';

/// Provider para o repositório de configurações avançadas
final advancedSettingsRepositoryProvider = Provider<AdvancedSettingsRepository>((ref) {
  final supabase = Supabase.instance.client;
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.read(Provider((ref) => throw UnimplementedError()));
  
  return SupabaseAdvancedSettingsRepository(
    supabase: supabase,
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
});

/// Implementação do repositório de configurações avançadas usando Supabase
class SupabaseAdvancedSettingsRepository implements AdvancedSettingsRepository {
  final SupabaseClient _supabase;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  
  /// Nome da tabela de configurações no Supabase
  static const String _tableName = 'user_settings';
  
  /// Chave para o cache local das configurações
  static const String _cacheKey = 'user_advanced_settings';
  
  /// Construtor
  SupabaseAdvancedSettingsRepository({
    required SupabaseClient supabase,
    required CacheService cacheService,
    required ConnectivityService connectivityService,
  }) : _supabase = supabase,
       _cacheService = cacheService,
       _connectivityService = connectivityService;
  
  @override
  Future<AdvancedSettingsState> loadSettings(String userId) async {
    try {
      // Primeiro tenta carregar do cache
      final cachedSettings = await _cacheService.get('${_cacheKey}_$userId');
      AdvancedSettingsState settings;
      
      if (cachedSettings != null) {
        // Se encontrar no cache, usa os dados
        settings = AdvancedSettingsState.fromJson(jsonDecode(cachedSettings));
      } else {
        // Configuração padrão se não houver cache
        settings = const AdvancedSettingsState();
      }
      
      // Verifica se tem conexão para sincronizar com o servidor
      if (await _connectivityService.hasConnection()) {
        try {
          // Carrega configurações do servidor
          final response = await _supabase
              .from(_tableName)
              .select()
              .eq('user_id', userId)
              .maybeSingle();
          
          if (response != null) {
            // Converte para o modelo de configurações
            final serverSettings = _mapResponseToSettings(response);
            
            // Atualiza o cache
            await _cacheService.set(
              '${_cacheKey}_$userId',
              jsonEncode(serverSettings.toJson()),
              expiry: const Duration(days: 7),
            );
            
            return serverSettings;
          }
        } catch (e) {
          // Se falhar ao carregar do servidor, continua usando os dados em cache
          print('Erro ao carregar configurações do servidor: $e');
        }
      }
      
      return settings;
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao carregar configurações',
        code: '500',
      );
    }
  }
  
  @override
  Future<void> saveSettings(String userId, AdvancedSettingsState settings) async {
    try {
      // Salva no cache local primeiro para resposta imediata
      await _cacheService.set(
        '${_cacheKey}_$userId',
        jsonEncode(settings.toJson()),
        expiry: const Duration(days: 7),
      );
      
      // Verifica se tem conexão para sincronizar com o servidor
      if (await _connectivityService.hasConnection()) {
        // Prepara os dados para o servidor
        final data = {
          'user_id': userId,
          'language_code': settings.languageCode,
          'theme_mode': settings.themeMode.index,
          'privacy_settings': settings.privacySettings.toJson(),
          'notification_settings': settings.notificationSettings.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        // Salva no servidor com upsert
        await _supabase
            .from(_tableName)
            .upsert(data, onConflict: 'user_id');
        
        // Atualiza a data de última sincronização
        final updatedSettings = settings.copyWith(
          lastSyncedAt: DateTime.now(),
        );
        
        // Atualiza o cache com a nova data de sincronização
        await _cacheService.set(
          '${_cacheKey}_$userId',
          jsonEncode(updatedSettings.toJson()),
          expiry: const Duration(days: 7),
        );
      }
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao salvar configurações',
        code: '500',
      );
    }
  }
  
  @override
  Future<void> updateLanguage(String userId, String languageCode) async {
    try {
      // Carrega configurações atuais
      final settings = await loadSettings(userId);
      
      // Atualiza o idioma
      final updatedSettings = settings.copyWith(languageCode: languageCode);
      
      // Salva as configurações atualizadas
      await saveSettings(userId, updatedSettings);
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao atualizar idioma',
        code: '500',
      );
    }
  }
  
  @override
  Future<void> updateThemeMode(String userId, ThemeMode themeMode) async {
    try {
      // Carrega configurações atuais
      final settings = await loadSettings(userId);
      
      // Atualiza o modo de tema
      final updatedSettings = settings.copyWith(themeMode: themeMode);
      
      // Salva as configurações atualizadas
      await saveSettings(userId, updatedSettings);
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao atualizar tema',
        code: '500',
      );
    }
  }
  
  @override
  Future<void> updatePrivacySettings(String userId, PrivacySettings privacySettings) async {
    try {
      // Carrega configurações atuais
      final settings = await loadSettings(userId);
      
      // Atualiza as configurações de privacidade
      final updatedSettings = settings.copyWith(privacySettings: privacySettings);
      
      // Salva as configurações atualizadas
      await saveSettings(userId, updatedSettings);
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao atualizar configurações de privacidade',
        code: '500',
      );
    }
  }
  
  @override
  Future<void> updateNotificationSettings(String userId, NotificationSettings notificationSettings) async {
    try {
      // Carrega configurações atuais
      final settings = await loadSettings(userId);
      
      // Atualiza as configurações de notificação
      final updatedSettings = settings.copyWith(notificationSettings: notificationSettings);
      
      // Salva as configurações atualizadas
      await saveSettings(userId, updatedSettings);
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao atualizar configurações de notificação',
        code: '500',
      );
    }
  }
  
  @override
  Future<DateTime> syncSettings(String userId) async {
    try {
      // Verifica se tem conexão
      if (!await _connectivityService.hasConnection()) {
        throw app.StorageException(
          message: 'Sem conexão com a internet',
          code: 'no_connection',
        );
      }
      
      // Carrega configurações do cache
      final cachedSettings = await _cacheService.get('${_cacheKey}_$userId');
      if (cachedSettings == null) {
        // Se não houver cache, carrega do servidor
        final settings = await loadSettings(userId);
        return settings.lastSyncedAt ?? DateTime.now();
      }
      
      final localSettings = AdvancedSettingsState.fromJson(jsonDecode(cachedSettings));
      
      // Carrega configurações do servidor
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Se não existir no servidor, envia as configurações locais
        await saveSettings(userId, localSettings);
        return DateTime.now();
      }
      
      // Converte a resposta do servidor para o modelo
      final serverSettings = _mapResponseToSettings(response);
      
      // Verifica qual é mais recente
      final serverUpdatedAt = DateTime.parse(response['updated_at'] ?? DateTime.now().toIso8601String());
      final localLastSyncedAt = localSettings.lastSyncedAt;
      
      if (localLastSyncedAt == null || serverUpdatedAt.isAfter(localLastSyncedAt)) {
        // Servidor tem dados mais recentes, atualiza o local
        await _cacheService.set(
          '${_cacheKey}_$userId',
          jsonEncode(serverSettings.toJson()),
          expiry: const Duration(days: 7),
        );
        return serverUpdatedAt;
      } else {
        // Local tem dados mais recentes, atualiza o servidor
        await saveSettings(userId, localSettings);
        return DateTime.now();
      }
    } catch (e) {
      if (e is app.StorageException) {
        rethrow;
      }
      throw app.StorageException(
        message: 'Erro ao sincronizar configurações',
        code: '500',
      );
    }
  }
  
  /// Converte a resposta do Supabase para o modelo de configurações
  AdvancedSettingsState _mapResponseToSettings(Map<String, dynamic> response) {
    try {
      // Extrai o modo de tema
      final themeModeIndex = response['theme_mode'] ?? 0;
      final themeMode = ThemeMode.values[themeModeIndex];
      
      // Extrai configurações de privacidade
      final privacySettingsMap = response['privacy_settings'] ?? {};
      PrivacySettings privacySettings;
      try {
        privacySettings = PrivacySettings.fromJson(
          privacySettingsMap is String 
              ? jsonDecode(privacySettingsMap) 
              : privacySettingsMap
        );
      } catch (e) {
        privacySettings = const PrivacySettings();
      }
      
      // Extrai configurações de notificação
      final notificationSettingsMap = response['notification_settings'] ?? {};
      NotificationSettings notificationSettings;
      try {
        notificationSettings = NotificationSettings.fromJson(
          notificationSettingsMap is String 
              ? jsonDecode(notificationSettingsMap) 
              : notificationSettingsMap
        );
      } catch (e) {
        notificationSettings = const NotificationSettings();
      }
      
      // Cria o objeto de configurações
      return AdvancedSettingsState(
        languageCode: response['language_code'] ?? 'pt_BR',
        themeMode: themeMode,
        privacySettings: privacySettings,
        notificationSettings: notificationSettings,
        lastSyncedAt: DateTime.parse(response['updated_at'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      // Em caso de erro, retorna configurações padrão
      return const AdvancedSettingsState();
    }
  }
} 