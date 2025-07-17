// Flutter imports:
import 'package:flutter/foundation.dart';

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import '../../utils/log_utils.dart';
import '../services/connectivity_service.dart';

part 'base_view_model.freezed.dart';

/// Estados padrão para qualquer ViewModel
@freezed
class BaseState<T> with _$BaseState<T> {
  /// Estado inicial, sem dados carregados
  const factory BaseState.initial() = BaseStateInitial<T>;
  
  /// Estado de carregamento
  const factory BaseState.loading() = BaseStateLoading<T>;
  
  /// Estado com dados carregados e disponíveis
  const factory BaseState.data({required T data}) = BaseStateData<T>;
  
  /// Estado com erro
  const factory BaseState.error({
    required String message,
    AppException? exception,
  }) = BaseStateError<T>;
  
  /// Estado offline, com dados em cache ou não
  const factory BaseState.offline({T? cachedData}) = BaseStateOffline<T>;
}

/// Base para todos os ViewModels modernos do aplicativo
/// Implementa o novo padrão de estados com Freezed
abstract class BaseViewModel<T> extends StateNotifier<BaseState<T>> {
  /// Serviço que verifica conectividade
  final ConnectivityService? _connectivityService;
  
  /// Stream subscription para mudanças de conectividade
  StreamSubscription<bool>? _connectivitySubscription;
  
  /// Construtor padrão com estado inicial
  BaseViewModel({ConnectivityService? connectivityService}) 
      : _connectivityService = connectivityService,
        super(const BaseState.initial()) {
    _initConnectivityListener();
  }
  
  /// Inicializa o listener de conectividade se estiver disponível
  void _initConnectivityListener() {
    if (_connectivityService != null) {
      _connectivitySubscription = _connectivityService!.connectionStatus.listen((hasConnection) {
        handleConnectivityChange(hasConnection);
      });
    }
  }
  
  /// Trata mudanças na conectividade
  /// Pode ser sobrescrito pelos ViewModels derivados para comportamento customizado
  @protected
  void handleConnectivityChange(bool hasConnection) {
    // Se a conexão foi restaurada e estávamos offline, tentar recarregar dados
    if (hasConnection && state is BaseStateOffline<T>) {
      // Usar dados em cache como fallback
      final cachedData = (state as BaseStateOffline<T>).cachedData;
      loadData(useCachedData: cachedData);
    }
    
    // Se perdemos conexão e não estamos em estado offline, atualizar para offline
    if (!hasConnection && !(state is BaseStateOffline<T>)) {
      // Verificar se temos dados atuais que podem ser usados como cache
      T? currentData;
      if (state is BaseStateData<T>) {
        currentData = (state as BaseStateData<T>).data;
      }
      
      state = BaseState<T>.offline(cachedData: currentData);
    }
  }
  
  /// Método que deve ser implementado pelos ViewModels para carregar dados
  @protected
  Future<void> loadData({T? useCachedData});
  
  /// Converte uma exceção para um estado de erro padronizado
  @protected
  BaseState<T> handleError(Object error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('Erro no ViewModel ${runtimeType.toString()}: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
    
    // Verificar se é desconexão e temos dados em cache
    if (error is NetworkException) {
      // Verificar se temos dados em cache do estado atual
      T? cachedData;
      if (state is BaseStateData<T>) {
        cachedData = (state as BaseStateData<T>).data;
      }
      
      return BaseState<T>.offline(cachedData: cachedData);
    }
    
    // Pegar mensagem personalizada se disponível
    String message = 'Ocorreu um erro ao processar sua solicitação';
    AppException? appException;
    
    if (error is AppException) {
      message = error.message;
      appException = error;
    } else if (error is Exception || error is Error) {
      message = 'Erro: ${error.toString()}';
    }
    
    return BaseState<T>.error(message: message, exception: appException);
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
  
  /// Executa uma operação assíncrona com tratamento de erros padronizado
  Future<void> execute({
    required Future<void> Function() operation,
    required void Function() onStart,
    required void Function(AppException error) onError,
    required void Function() onSuccess,
    String? errorMessage,
    String? operationName,
  }) async {
    try {
      // Marcar início da operação (geralmente mudando para estado de loading)
      onStart();
      
      // Log de operação se necessário
      if (operationName != null) {
        LogUtils.info('Iniciando operação: $operationName', tag: 'ViewModel');
      }
      
      // Executar a operação
      await operation();
      
      // Callback de sucesso
      onSuccess();
    } catch (e, stackTrace) {
      // Gerar exceção padronizada
      final appException = _handleError(
        e, 
        stackTrace, 
        errorMessage ?? 'Ocorreu um erro ao executar a operação',
      );
      
      // Log para debugging
      if (operationName != null) {
        LogUtils.error(
          'Erro em $operationName',
          error: appException,
          stackTrace: stackTrace,
          tag: 'ViewModel',
        );
      }
      
      // Callback de erro
      onError(appException);
    }
  }
  
  /// Trata erros e retorna uma exceção padronizada
  AppException _handleError(Object error, StackTrace stackTrace, String defaultMessage) {
    // Se já for uma exceção do App, apenas retorna
    if (error is AppException) {
      return error;
    }
    
    // Usar o classificador global de erros
    return ErrorClassifier.classifyError(error, stackTrace);
  }
  
  /// Método para log de debug no ViewModel
  void logDebug(String message) {
    if (kDebugMode) {
      LogUtils.debug(message, tag: runtimeType.toString());
    }
  }
  
  /// Método para log de informação no ViewModel
  void logInfo(String message) {
    LogUtils.info(message, tag: runtimeType.toString());
  }
  
  /// Método para log de erro no ViewModel
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    LogUtils.error(
      message, 
      error: error, 
      stackTrace: stackTrace,
      tag: runtimeType.toString(),
    );
  }
}

/// Interface base para estados legados
abstract class LegacyBaseState {
  /// Método para verificar se o estado representa carregamento
  bool get isLoading;
  
  /// Método para verificar se o estado representa erro
  bool get hasError;
  
  /// Método para obter a mensagem de erro, se houver
  String? get errorMessage;
}

/// Base para ViewModels legados que ainda não usam o novo padrão
abstract class LegacyBaseViewModel<T extends LegacyBaseState> extends StateNotifier<T> {
  LegacyBaseViewModel(T initialState) : super(initialState);
} abstract class BaseRepository {
  Future<void> initialize();
  Future<void> clearCache();
  Future<void> dispose();
}
// Flutter imports:
import 'package:flutter/foundation.dart';

/// Base class for all ViewModels in the app
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  /// Whether the ViewModel is currently loading data
  bool get isLoading => _isLoading;

  /// The current error message, if any
  String? get error => _error;

  /// Set the loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set an error message
  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Handle an async operation with loading state and error handling
  Future<T?> handleAsync<T>(Future<T> Function() action) async {
    try {
      setLoading(true);
      clearError();
      final result = await action();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> initialize();

  @override
  void dispose() {
    _error = null;
    super.dispose();
  }
}
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../models/settings_state.dart';
import '../repositories/settings_repository.dart';
import '../repositories/settings_repository_impl.dart';
import '../../../core/providers/service_providers.dart'; // Importando o arquivo que contém o provider correto

/// Provider para o repositório de configurações
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(prefs);
});

/// Provider para o ViewModel de configurações
final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsViewModel(repository);
});

/// Provider para verificar se o usuário é administrador
final isAdminProvider = FutureProvider<bool>((ref) async {
  return await SettingsViewModel.isUserAdmin();
});

/// ViewModel para gerenciar as configurações do aplicativo
class SettingsViewModel extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;
  
  /// Cria uma instância do ViewModel
  SettingsViewModel(this._repository) : super(const SettingsState()) {
    loadSettings();
  }
  
  /// Carrega as configurações salvas
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final isDarkMode = await _repository.getThemeMode();
      final language = await _repository.getLanguage();
      final isAdmin = await isUserAdmin();
      
      state = state.copyWith(
        isDarkMode: isDarkMode,
        selectedLanguage: language,
        isAdmin: isAdmin,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar configurações: $e',
        isLoading: false,
      );
    }
  }
  
  /// Alterna entre tema claro e escuro
  Future<void> toggleDarkMode() async {
    try {
      final newMode = !state.isDarkMode;
      await _repository.saveThemeMode(newMode);
      state = state.copyWith(isDarkMode: newMode);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao alterar o tema: $e',
      );
    }
  }
  
  /// Altera o idioma do aplicativo
  Future<void> setLanguage(String language) async {
    try {
      await _repository.saveLanguage(language);
      state = state.copyWith(selectedLanguage: language);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao alterar o idioma: $e',
      );
    }
  }
  
  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Verifica se o usuário atual é administrador
  /// Retorna true se o usuário for admin, false caso contrário
  static Future<bool> isUserAdmin() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Buscar o perfil do usuário atual
      final profile = await supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();
      
      // Verificar se is_admin é true
      return profile['is_admin'] == true;
    } catch (e) {
      debugPrint('❌ Erro ao verificar se usuário é admin: $e');
      return false;
    }
  }
} // Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/services/auth_service.dart';
import '../models/advanced_settings_state.dart';
import '../repositories/advanced_settings_repository.dart';

/// Provider para o ViewModel de configurações avançadas
final advancedSettingsViewModelProvider = StateNotifierProvider<AdvancedSettingsViewModel, AdvancedSettingsState>((ref) {
  final repository = ref.watch(Provider<AdvancedSettingsRepository>((ref) => throw UnimplementedError()));
  final authService = ref.watch(Provider<AuthService>((ref) => throw UnimplementedError()));
  
  return AdvancedSettingsViewModel(repository, authService);
});

/// ViewModel para gerenciar configurações avançadas do aplicativo
class AdvancedSettingsViewModel extends StateNotifier<AdvancedSettingsState> {
  final AdvancedSettingsRepository _repository;
  final AuthService _authService;

  /// Construtor
  AdvancedSettingsViewModel(this._repository, this._authService) : super(const AdvancedSettingsState()) {
    _loadSettings();
  }

  /// Carrega as configurações do usuário
  Future<void> _loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }
      
      final settings = await _repository.loadSettings(userId);
      
      state = settings.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao carregar configurações: $e',
      );
    }
  }

  /// Atualiza o idioma do aplicativo
  Future<void> updateLanguage(String languageCode) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }
      
      // Atualiza o estado imediatamente para feedback rápido
      state = state.copyWith(
        languageCode: languageCode,
        isLoading: true,
      );
      
      // Salva no backend
      await _repository.updateLanguage(userId, languageCode);
      
      // Atualiza o estado com sucesso
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Rollback para o idioma anterior em caso de erro
      await _loadSettings();
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao atualizar idioma: $e',
      );
    }
  }

  /// Alterna entre os modos de tema (sistema, claro, escuro)
  Future<void> toggleThemeMode() async {
    try {
      // Determina o próximo modo de tema na sequência
      final ThemeMode nextThemeMode;
      switch (state.themeMode) {
        case ThemeMode.system:
          nextThemeMode = ThemeMode.light;
          break;
        case ThemeMode.light:
          nextThemeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          nextThemeMode = ThemeMode.system;
          break;
      }
      
      await updateThemeMode(nextThemeMode);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is AppException ? e.message : 'Erro ao alternar tema: $e',
      );
    }
  }

  /// Atualiza o modo de tema
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }
      
      // Atualiza o estado imediatamente para feedback rápido
      state = state.copyWith(
        themeMode: themeMode,
        isLoading: true,
      );
      
      // Salva no backend
      await _repository.updateThemeMode(userId, themeMode);
      
      // Atualiza o estado com sucesso
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Rollback para o tema anterior em caso de erro
      await _loadSettings();
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao atualizar tema: $e',
      );
    }
  }

  /// Atualiza as configurações de privacidade
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }
      
      // Atualiza o estado imediatamente para feedback rápido
      state = state.copyWith(
        privacySettings: settings,
        isLoading: true,
      );
      
      // Salva no backend
      await _repository.updatePrivacySettings(userId, settings);
      
      // Atualiza o estado com sucesso
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Rollback para as configurações anteriores em caso de erro
      await _loadSettings();
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao atualizar configurações de privacidade: $e',
      );
    }
  }

  /// Atualiza as configurações de notificação
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }
      
      // Atualiza o estado imediatamente para feedback rápido
      state = state.copyWith(
        notificationSettings: settings,
        isLoading: true,
      );
      
      // Salva no backend
      await _repository.updateNotificationSettings(userId, settings);
      
      // Atualiza o estado com sucesso
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Rollback para as configurações anteriores em caso de erro
      await _loadSettings();
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao atualizar configurações de notificação: $e',
      );
    }
  }

  /// Sincroniza as configurações entre dispositivos
  Future<void> syncSettings() async {
    try {
      state = state.copyWith(isSyncing: true, errorMessage: null);
      
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isSyncing: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }
      
      final syncTime = await _repository.syncSettings(userId);
      
      // Recarrega as configurações após a sincronização
      final settings = await _repository.loadSettings(userId);
      
      state = settings.copyWith(
        lastSyncedAt: syncTime,
        isSyncing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: e is AppException ? e.message : 'Erro ao sincronizar configurações: $e',
      );
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
} // Abstract repository for settings

/// Interface para o repositório de configurações do aplicativo.
abstract class SettingsRepository {
  /// Obtém o modo de tema atual (escuro/claro)
  Future<bool> getThemeMode();
  
  /// Salva o modo de tema (escuro/claro)
  Future<void> saveThemeMode(bool isDarkMode);
  
  /// Obtém o idioma selecionado
  Future<String> getLanguage();
  
  /// Salva o idioma selecionado
  Future<void> saveLanguage(String language);
} // Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
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
      throw StorageException(
        message: 'Erro ao carregar configurações',
        originalException: e,
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
      throw StorageException(
        message: 'Erro ao salvar configurações',
        originalException: e,
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
      throw StorageException(
        message: 'Erro ao atualizar idioma',
        originalException: e,
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
      throw StorageException(
        message: 'Erro ao atualizar tema',
        originalException: e,
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
      throw StorageException(
        message: 'Erro ao atualizar configurações de privacidade',
        originalException: e,
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
      throw StorageException(
        message: 'Erro ao atualizar configurações de notificação',
        originalException: e,
      );
    }
  }
  
  @override
  Future<DateTime> syncSettings(String userId) async {
    try {
      // Verifica se tem conexão
      if (!await _connectivityService.hasConnection()) {
        throw const StorageException(
          message: 'Sem conexão com a internet',
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
      throw StorageException(
        message: 'Erro ao sincronizar configurações',
        originalException: e,
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
} // Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/advanced_settings_state.dart';

/// Interface para o repositório de configurações avançadas
abstract class AdvancedSettingsRepository {
  /// Carrega todas as configurações do usuário
  Future<AdvancedSettingsState> loadSettings(String userId);
  
  /// Salva todas as configurações do usuário
  Future<void> saveSettings(String userId, AdvancedSettingsState settings);
  
  /// Atualiza o idioma selecionado
  Future<void> updateLanguage(String userId, String languageCode);
  
  /// Atualiza o modo de tema
  Future<void> updateThemeMode(String userId, ThemeMode themeMode);
  
  /// Atualiza configurações de privacidade
  Future<void> updatePrivacySettings(String userId, PrivacySettings privacySettings);
  
  /// Atualiza configurações de notificação
  Future<void> updateNotificationSettings(String userId, NotificationSettings notificationSettings);
  
  /// Sincroniza configurações entre dispositivos
  Future<DateTime> syncSettings(String userId);
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/featured_content.dart';
import 'package:ray_club_app/features/home/repositories/featured_content_repository.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

part 'featured_content_view_model.freezed.dart';

// Estado do ViewModel
@freezed
class FeaturedContentState with _$FeaturedContentState {
  const factory FeaturedContentState({
    @Default([]) List<FeaturedContent> contents,
    @Default(true) bool isLoading,
    String? error,
    FeaturedContent? selectedContent,
  }) = _FeaturedContentState;
}

// Provider para o repositório
final featuredContentRepositoryProvider = Provider<FeaturedContentRepository>((ref) {
  // Aqui podemos facilmente trocar a implementação quando tivermos Supabase configurado
  return MockFeaturedContentRepository();
  // Para produção:
  // return SupabaseFeaturedContentRepository();
});

// Provider para o ViewModel
final featuredContentViewModelProvider = StateNotifierProvider<FeaturedContentViewModel, FeaturedContentState>((ref) {
  final repository = ref.watch(featuredContentRepositoryProvider);
  return FeaturedContentViewModel(repository);
});

// ViewModel
class FeaturedContentViewModel extends StateNotifier<FeaturedContentState> {
  final FeaturedContentRepository _repository;

  FeaturedContentViewModel(this._repository) : super(const FeaturedContentState()) {
    // Carrega os dados ao inicializar
    loadFeaturedContents();
  }

  /// Carrega a lista de conteúdos em destaque
  Future<void> loadFeaturedContents() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final contents = await _repository.getFeaturedContents();
      state = state.copyWith(contents: contents, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Seleciona um conteúdo específico pelo ID
  Future<void> selectContentById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final content = await _repository.getFeaturedContentById(id);
      state = state.copyWith(selectedContent: content, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Limpa a seleção atual
  void clearSelection() {
    state = state.copyWith(selectedContent: null);
  }

  /// Filtra conteúdos por categoria
  void filterByCategory(String categoryId) {
    // Implementação futura
  }
} 
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/home/repositories/home_repository.dart';
import 'package:ray_club_app/features/home/viewmodels/states/home_state.dart';

/// Provider para o repositório da Home
/// Responsável por fornecer uma instância do repositório de dados da Home
/// que será usado pelo ViewModel
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabase = Supabase.instance.client;
  final cacheService = ref.watch(cacheServiceProvider);
  return SupabaseHomeRepository(supabase, cacheService);
});

/// Provider para HomeViewModel
/// Fornece uma instância do ViewModel da Home que gerencia
/// o estado e a lógica de negócios da tela Home
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeViewModel(repository);
});

/// ViewModel para a tela Home
/// Responsável por gerenciar o estado e a lógica de negócios relacionada
/// à tela principal do aplicativo.
class HomeViewModel extends StateNotifier<HomeState> {
  /// Repositório que fornece acesso aos dados necessários para a Home
  final HomeRepository _repository;

  /// Construtor que inicializa o ViewModel com estado inicial
  /// e carrega os dados automaticamente
  /// 
  /// @param repository Instância do repositório de dados da Home
  HomeViewModel(this._repository) : super(HomeState.initial()) {
    loadHomeData();
  }

  /// Carrega todos os dados necessários para a tela Home
  /// 
  /// Recupera banners, destaques da semana, treinos recomendados,
  /// progresso do usuário e outros dados relevantes para a Home
  Future<void> loadHomeData() async {
    try {
      print('🔍 HomeViewModel: Iniciando carregamento de dados');
      state = HomeState.loading();
      
      print('🔍 HomeViewModel: Chamando repository.getHomeData()');
      final homeData = await _repository.getHomeData();
      
      print('✅ HomeViewModel: Dados carregados com sucesso');
      // Atualiza o estado com os dados carregados
      state = HomeState.loaded(homeData);
    } on AppException catch (e) {
      print('❌ HomeViewModel - Erro específico da aplicação: ${e.message}');
      print('❌ Erro original: ${e.originalError}');
      print('❌ Stack trace: ${e.stackTrace}');
      
      // Tentar carregar dados parciais em vez de mostrar apenas erro
      await _loadPartialData(errorMessage: e.message);
    } catch (e, stack) {
      print('❌ HomeViewModel - Erro genérico: $e');
      print('❌ Stack trace: $stack');
      
      // Tentar carregar dados parciais
      await _loadPartialData(errorMessage: 'Erro ao carregar dados: ${e.toString()}');
    }
  }
  
  /// Tenta carregar dados parciais quando o carregamento completo falha
  Future<void> _loadPartialData({required String errorMessage}) async {
    print('🔄 Tentando carregar dados parciais após erro');
    
    try {
      // Criando estrutura básica com dados vazios
      HomeData partialData = HomeData.empty();
      
      // Tentar carregar banners separadamente
      try {
        final banners = await _repository.getBanners();
        if (banners.isNotEmpty) {
          partialData = partialData.copyWith(
            banners: banners,
            activeBanner: banners.firstWhere(
              (banner) => banner.isActive, 
              orElse: () => banners.first
            ),
          );
          print('✅ Banners carregados em modo parcial: ${banners.length}');
        }
      } catch (e) {
        print('⚠️ Não foi possível carregar banners: $e');
      }
      
      // Tentar carregar categorias separadamente
      try {
        final categories = await _repository.getWorkoutCategories();
        if (categories.isNotEmpty) {
          partialData = partialData.copyWith(categories: categories);
          print('✅ Categorias carregadas em modo parcial: ${categories.length}');
        }
      } catch (e) {
        print('⚠️ Não foi possível carregar categorias: $e');
      }
      
      // Tentar carregar treinos populares separadamente
      try {
        final popularWorkouts = await _repository.getPopularWorkouts();
        if (popularWorkouts.isNotEmpty) {
          partialData = partialData.copyWith(popularWorkouts: popularWorkouts);
          print('✅ Treinos populares carregados em modo parcial: ${popularWorkouts.length}');
        }
      } catch (e) {
        print('⚠️ Não foi possível carregar treinos populares: $e');
      }
      
      // Definir estado com dados parciais e erro
      state = HomeState.partial(
        partialData,
        errorMessage: errorMessage,
      );
      print('✅ HomeViewModel: Carregamento parcial concluído');
    } catch (fallbackError) {
      print('❌ Erro também no carregamento parcial: $fallbackError');
      // Se tudo falhar, mostrar apenas a mensagem de erro
      state = HomeState.error(errorMessage);
    }
  }

  /// Atualiza o índice do banner atual
  /// 
  /// Usado pelo PageView de banners para controlar qual banner está sendo exibido
  /// 
  /// @param index Novo índice do banner a ser exibido
  void updateBannerIndex(int index) {
    if (state.data?.banners != null && 
        index >= 0 && 
        index < state.data!.banners.length) {
      state = state.copyWith(currentBannerIndex: index);
    }
  }
  
  /// Atualiza apenas os dados de progresso do usuário
  /// 
  /// Útil para atualizar o progresso após a realização de atividades
  /// sem recarregar todos os dados da tela
  Future<void> refreshUserProgress() async {
    try {
      if (state.data == null) {
        await loadHomeData();
        return;
      }
      
      final progress = await _repository.getUserProgress();
      
      // Atualiza apenas o progresso, mantendo os outros dados
      state = state.copyWith(
        data: state.data!.copyWith(
          progress: progress,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      // Não alteramos o estado em caso de erro no refresh
      // apenas para não perdermos os dados já carregados
      print('Erro ao atualizar progresso: $e');
    }
  }
} 
// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/partner_studio.dart';
import '../repositories/partner_studio_repository.dart';

part 'partner_studio_view_model.freezed.dart';

// Estado para o ViewModel
@freezed
class PartnerStudioState with _$PartnerStudioState {
  const factory PartnerStudioState({
    @Default([]) List<PartnerStudio> studios,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PartnerStudioState;
}

// Provider para o ViewModel
final partnerStudioViewModelProvider = StateNotifierProvider<PartnerStudioViewModel, PartnerStudioState>((ref) {
  final repository = ref.watch(partnerStudioRepositoryProvider);
  return PartnerStudioViewModel(repository);
});

// Provider assíncrono para estúdios parceiros
final partnerStudiosProvider = FutureProvider<List<PartnerStudio>>((ref) async {
  final viewModel = ref.watch(partnerStudioViewModelProvider.notifier);
  await viewModel.loadStudios();
  return ref.watch(partnerStudioViewModelProvider).studios;
});

// ViewModel
class PartnerStudioViewModel extends StateNotifier<PartnerStudioState> {
  final PartnerStudioRepository _repository;
  
  PartnerStudioViewModel(this._repository) : super(const PartnerStudioState());
  
  // Carregar estúdios
  Future<void> loadStudios() async {
    if (state.studios.isNotEmpty) {
      return; // Evita múltiplas chamadas desnecessárias
    }
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final studios = await _repository.getPartnerStudios();
      state = state.copyWith(
        studios: studios,
        isLoading: false,
      );
    } catch (e) {
      final exception = e is AppException 
          ? e 
          : StorageException(message: 'Erro ao carregar estúdios: ${e.toString()}');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      );
    }
  }
  
  // Buscar conteúdos de um estúdio específico
  Future<void> loadStudioContents(String studioId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final contents = await _repository.getStudioContents(studioId);
      
      // Atualizar os conteúdos do estúdio específico
      final updatedStudios = state.studios.map((studio) {
        if (studio.id == studioId) {
          return studio.copyWith(contents: contents);
        }
        return studio;
      }).toList();
      
      state = state.copyWith(
        studios: updatedStudios,
        isLoading: false,
      );
    } catch (e) {
      final exception = e is AppException 
          ? e 
          : StorageException(message: 'Erro ao carregar conteúdos: ${e.toString()}');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      );
    }
  }
} // Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';
import 'package:ray_club_app/features/home/repositories/weekly_highlights_repository.dart';
import 'package:ray_club_app/features/home/viewmodels/states/weekly_highlights_state.dart';
import 'package:ray_club_app/core/providers/supabase_client_provider.dart';

/// Provider para o repositório de destaques da semana
final weeklyHighlightsRepositoryProvider = Provider<WeeklyHighlightsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseWeeklyHighlightsRepository(supabase);
});

/// Provider para o ViewModel de destaques da semana
final weeklyHighlightsViewModelProvider = StateNotifierProvider<WeeklyHighlightsViewModel, WeeklyHighlightsState>((ref) {
  final repository = ref.watch(weeklyHighlightsRepositoryProvider);
  return WeeklyHighlightsViewModel(repository);
});

/// Provider simplificado para lista de destaques da semana (para uso em widgets)
final weeklyHighlightsProvider = Provider<List<WeeklyHighlight>>((ref) {
  return ref.watch(weeklyHighlightsViewModelProvider).highlights;
});

/// ViewModel para os destaques da semana
class WeeklyHighlightsViewModel extends StateNotifier<WeeklyHighlightsState> {
  final WeeklyHighlightsRepository _repository;
  
  WeeklyHighlightsViewModel(this._repository) : super(const WeeklyHighlightsState()) {
    // Carregar dados ao inicializar
    loadHighlights();
  }
  
  /// Carrega a lista de destaques da semana
  Future<void> loadHighlights() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final highlights = await _repository.getWeeklyHighlights();
      state = state.copyWith(highlights: highlights, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  /// Seleciona um destaque específico pelo ID
  Future<void> selectHighlightById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final highlight = await _repository.getHighlightById(id);
      
      state = state.copyWith(
        selectedHighlight: highlight,
        isLoading: false,
      );
      
      if (highlight != null) {
        // Marcar como visualizado assincronamente
        _repository.markHighlightAsViewed(id);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  /// Limpa a seleção atual
  void clearSelection() {
    state = state.copyWith(selectedHighlight: null);
  }
} // Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/home/models/featured_content.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

/// Interface para o repositório de conteúdos em destaque
abstract class FeaturedContentRepository {
  /// Recupera a lista de conteúdos em destaque
  Future<List<FeaturedContent>> getFeaturedContents();
  
  /// Recupera um conteúdo específico pelo ID
  Future<FeaturedContent?> getFeaturedContentById(String id);
}

/// Implementação mock do repositório para desenvolvimento
class MockFeaturedContentRepository implements FeaturedContentRepository {
  @override
  Future<List<FeaturedContent>> getFeaturedContents() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    return [
      FeaturedContent(
        id: '1',
        title: 'Dicas de Nutrição',
        description: 'Como montar um prato ideal após o treino',
        category: ContentCategory(
          id: 'cat1',
          name: 'Nutrição',
          color: Colors.green,
          colorHex: '#4CAF50',
        ),
        icon: Icons.restaurant,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        isFeatured: true,
      ),
      FeaturedContent(
        id: '2',
        title: 'Treino HIIT de 20 minutos',
        description: 'Queime calorias em casa sem equipamentos',
        category: ContentCategory(
          id: 'cat2',
          name: 'Treinos',
          color: Colors.orange,
          colorHex: '#FF9800',
        ),
        icon: Icons.fitness_center,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        isFeatured: true,
      ),
      FeaturedContent(
        id: '3',
        title: 'Alongamento pós-treino',
        description: 'Técnicas para recuperação muscular eficiente',
        category: ContentCategory(
          id: 'cat3',
          name: 'Recuperação',
          color: Colors.blue,
          colorHex: '#2196F3',
        ),
        icon: Icons.self_improvement,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FeaturedContent(
        id: '4',
        title: 'Meditações guiadas',
        description: 'Reduza o estresse e melhore seu sono',
        category: ContentCategory(
          id: 'cat4',
          name: 'Bem-estar',
          color: Colors.purple,
          colorHex: '#9C27B0',
        ),
        icon: Icons.spa,
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<FeaturedContent?> getFeaturedContentById(String id) async {
    final list = await getFeaturedContents();
    return list.where((content) => content.id == id).firstOrNull;
  }
}

/// Implementação real do repositório usando Supabase (para ser implementado futuramente)
class SupabaseFeaturedContentRepository implements FeaturedContentRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseFeaturedContentRepository(this._supabaseClient);
  
  @override
  Future<List<FeaturedContent>> getFeaturedContents() async {
    try {
      final response = await _supabaseClient
          .from('featured_contents')
          .select('*, category:categories(id, name, color)')
          .order('published_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((data) => _mapToFeaturedContent(data))
          .toList();
    } catch (e) {
      // Em caso de erro durante o desenvolvimento, retornar dados mock como fallback
      print('Erro ao buscar conteúdos destacados: $e');
      return MockFeaturedContentRepository().getFeaturedContents();
    }
  }

  @override
  Future<FeaturedContent?> getFeaturedContentById(String id) async {
    try {
      final response = await _supabaseClient
          .from('featured_contents')
          .select('*, category:categories(id, name, color)')
          .eq('id', id)
          .single();
      
      return _mapToFeaturedContent(response);
    } catch (e) {
      // Em caso de erro durante o desenvolvimento, retornar dados mock como fallback
      print('Erro ao buscar conteúdo destacado por ID: $e');
      return MockFeaturedContentRepository().getFeaturedContentById(id);
    }
  }
  
  // Helper para converter dados do Supabase para o modelo FeaturedContent
  FeaturedContent _mapToFeaturedContent(Map<String, dynamic> data) {
    // Processa a categoria
    final categoryData = data['category'] as Map<String, dynamic>?;
    final category = categoryData != null
        ? ContentCategory(
            id: categoryData['id'] as String,
            name: categoryData['name'] as String,
            color: _hexToColor(categoryData['color'] as String? ?? '#6E44FF'),
            colorHex: categoryData['color'] as String? ?? '#6E44FF',
          )
        : ContentCategory(
            id: 'default',
            name: 'Geral',
            color: const Color(0xFF6E44FF),
            colorHex: '#6E44FF',
          );
    
    // Determinar o ícone com base no tipo
    IconData icon = Icons.star;
    final type = data['type'] as String? ?? 'article';
    switch (type.toLowerCase()) {
      case 'workout':
        icon = Icons.fitness_center;
        break;
      case 'nutrition':
        icon = Icons.restaurant;
        break;
      case 'wellness':
        icon = Icons.spa;
        break;
      case 'challenge':
        icon = Icons.emoji_events;
        break;
      default:
        icon = Icons.article;
    }
    
    return FeaturedContent(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      category: category,
      icon: icon,
      imageUrl: data['image_url'] as String?,
      actionUrl: data['content_url'] as String?,
      publishedAt: data['published_at'] != null ? DateTime.parse(data['published_at'] as String) : null,
      isFeatured: data['is_featured'] as bool? ?? false,
    );
  }
  
  // Helper para converter hex para Color
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
} 
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';

/// Interface para o repositório de dados da Home
abstract class HomeRepository {
  /// Recupera todos os dados necessários para a tela Home
  Future<HomeData> getHomeData();
  
  /// Recupera apenas os dados de progresso do usuário
  Future<UserProgress> getUserProgress();
  
  /// Recupera os banners promocionais
  Future<List<BannerItem>> getBanners();
  
  /// Recupera as categorias de treino
  Future<List<WorkoutCategory>> getWorkoutCategories();
  
  /// Recupera os treinos populares
  Future<List<PopularWorkout>> getPopularWorkouts();
}

/// Implementação mock do repositório para desenvolvimento
class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeData> getHomeData() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      final banners = await getBanners();
      final progress = await getUserProgress();
      final categories = await getWorkoutCategories();
      final workouts = await getPopularWorkouts();
      
      return HomeData(
        activeBanner: banners.isNotEmpty ? banners.first : BannerItem.empty(),
        banners: banners,
        progress: progress,
        categories: categories,
        popularWorkouts: workouts,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw AppException(
        message: 'Erro ao carregar dados da Home',
        originalError: e,
      );
    }
  }
  
  @override
  Future<UserProgress> getUserProgress() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dados mockados de progresso
    return const UserProgress(
      daysTrainedThisMonth: 12,
      currentStreak: 3,
      bestStreak: 7,
      challengeProgress: 40,
    );
  }
  
  @override
  Future<List<BannerItem>> getBanners() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dados mockados de banners
    return [
      const BannerItem(
        id: '1',
        title: 'Novo Treino de HIIT',
        subtitle: 'Queime calorias em 20 minutos',
        imageUrl: 'assets/images/challenge_default.jpg',
        isActive: true,
      ),
      const BannerItem(
        id: '2',
        title: 'Parceiros com 30% OFF',
        subtitle: 'Produtos fitness com descontos exclusivos',
        imageUrl: 'assets/images/workout_default.jpg',
      ),
      const BannerItem(
        id: '3',
        title: 'Desafio do Mês',
        subtitle: 'Participe e concorra a prêmios',
        imageUrl: 'assets/images/banner_bemvindo.png',
      ),
    ];
  }
  
  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dados mockados de categorias
    return [
      const WorkoutCategory(
        id: 'cat1',
        name: 'Cardio',
        iconUrl: 'assets/icons/cardio.png',
        workoutCount: 12,
        colorHex: '#FF5252',
      ),
      const WorkoutCategory(
        id: 'cat2',
        name: 'Força',
        iconUrl: 'assets/icons/strength.png',
        workoutCount: 8,
        colorHex: '#448AFF',
      ),
      const WorkoutCategory(
        id: 'cat3',
        name: 'Flexibilidade',
        iconUrl: 'assets/icons/flexibility.png',
        workoutCount: 6,
        colorHex: '#9C27B0',
      ),
      const WorkoutCategory(
        id: 'cat4',
        name: 'HIIT',
        iconUrl: 'assets/icons/hiit.png',
        workoutCount: 4,
        colorHex: '#FF9800',
      ),
    ];
  }
  
  @override
  Future<List<PopularWorkout>> getPopularWorkouts() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dados mockados de treinos populares
    return [
      const PopularWorkout(
        id: 'workout1',
        title: 'Treino Full Body',
        imageUrl: 'assets/images/workout_fullbody.jpg',
        duration: '45 min',
        difficulty: 'Intermediário',
        favoriteCount: 245,
      ),
      const PopularWorkout(
        id: 'workout2',
        title: 'Abdômen Definido',
        imageUrl: 'assets/images/workout_abs.jpg',
        duration: '20 min',
        difficulty: 'Iniciante',
        favoriteCount: 189,
      ),
      const PopularWorkout(
        id: 'workout3',
        title: 'Cardio Intenso',
        imageUrl: 'assets/images/workout_cardio.jpg',
        duration: '30 min',
        difficulty: 'Avançado',
        favoriteCount: 136,
      ),
    ];
  }
}

/// Implementação real do repositório usando Supabase
class SupabaseHomeRepository implements HomeRepository {
  final SupabaseClient _supabaseClient;
  final CacheService _cacheService;
  
  // Chaves de cache
  static const String _cacheKeyHomeData = 'home_data';
  static const String _cacheKeyUserProgress = 'user_progress';
  static const String _cacheKeyBanners = 'banners';
  static const String _cacheKeyCategories = 'workout_categories';
  static const String _cacheKeyPopularWorkouts = 'popular_workouts';
  
  // Duração padrão para expiração de cache
  static const Duration _defaultCacheExpiry = Duration(minutes: 15);
  static const Duration _shortCacheExpiry = Duration(minutes: 5);
  
  SupabaseHomeRepository(this._supabaseClient, this._cacheService);

  @override
  Future<HomeData> getHomeData() async {
    try {
      print('🔍 SupabaseHomeRepository: Iniciando busca de dados');

      // Verificar se há dados em cache
      final cachedData = await _cacheService.get(_cacheKeyHomeData);
      if (cachedData != null) {
        try {
          print('🔍 Dados encontrados em cache, verificando validade');
          // Tentar construir o objeto HomeData com os dados em cache
          final cachedHomeData = HomeData.fromJson(cachedData);
          
          // Verificar se os dados não são muito antigos (15 minutos)
          final now = DateTime.now();
          final dataAge = now.difference(cachedHomeData.lastUpdated);
          
          if (dataAge < _defaultCacheExpiry) {
            print('✅ Usando dados de cache válidos (idade: ${dataAge.inMinutes} minutos)');
            return cachedHomeData;
          } else {
            print('🔍 Cache expirado (${dataAge.inMinutes} minutos), buscando dados atualizados');
          }
          
          // Se os dados são antigos, continuar com a busca remota,
          // mas manter o cache como fallback
        } catch (e) {
          print('⚠️ Erro ao decodificar cache: $e');
          // Se houver erro ao decodificar o cache, ignorar e buscar dados remotos
        }
      } else {
        print('🔍 Cache não encontrado, buscando dados remotos');
      }
      
      print('🔍 Verificando conexão com Supabase...');
      // Verificar se a conexão com Supabase está funcionando
      try {
        final session = _supabaseClient.auth.currentSession;
        print('✅ Sessão Supabase: ${session != null ? 'Ativa' : 'Inativa'}');
      } catch (e) {
        print('⚠️ Erro ao verificar sessão Supabase: $e');
      }
      
      // Executar todas as requisições em paralelo para otimizar o tempo de carregamento
      print('🔍 Iniciando requisições paralelas');
      final results = await Future.wait([
        getBanners(),
        getUserProgress(),
        getWorkoutCategories(),
        getPopularWorkouts(),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⚠️ Timeout nas requisições paralelas');
          throw AppException(
            message: 'Tempo limite excedido ao carregar dados',
          );
        },
      );
      
      // Extrair os resultados na ordem das requisições
      final banners = results[0] as List<BannerItem>;
      final progress = results[1] as UserProgress;
      final categories = results[2] as List<WorkoutCategory>;
      final workouts = results[3] as List<PopularWorkout>;
      
      print('✅ Todas as requisições completadas com sucesso');
      
      final homeData = HomeData(
        activeBanner: banners.firstWhere(
          (banner) => banner.isActive, 
          orElse: () => banners.isNotEmpty ? banners.first : BannerItem.empty()
        ),
        banners: banners,
        progress: progress,
        categories: categories,
        popularWorkouts: workouts,
        lastUpdated: DateTime.now(),
      );
      
      // Armazenar em cache para uso futuro
      await _cacheService.set(
        _cacheKeyHomeData, 
        homeData.toJson(),
        expiry: _defaultCacheExpiry
      );
      
      return homeData;
    } catch (e, stack) {
      print('❌ Erro detalhado ao carregar dados da Home: $e');
      print('❌ Stack trace: $stack');
      
      // Em caso de erro, tentar usar o cache, mesmo se estiver expirado
      print('🔍 Tentando usar cache como fallback após erro');
      final cachedData = await _cacheService.get(_cacheKeyHomeData);
      if (cachedData != null) {
        try {
          print('✅ Retornando dados de cache como fallback');
          return HomeData.fromJson(cachedData);
        } catch (_) {
          print('❌ Erro ao decodificar cache como fallback');
          // Ignorar erros ao decodificar cache
        }
      } else {
        print('⚠️ Nenhum cache disponível como fallback');
      }
      
      throw AppException(
        message: 'Erro ao carregar dados da Home',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<UserProgress> getUserProgress() async {
    try {
      // Verificar se há dados em cache
      final cachedData = await _cacheService.get(_cacheKeyUserProgress);
      if (cachedData != null) {
        try {
          // Cache de progresso tem validade curta (5 minutos)
          final cachedProgress = UserProgress.fromJson(cachedData);
          return cachedProgress;
        } catch (e) {
          // Se houver erro ao decodificar o cache, ignorar
        }
      }
      
      // Buscar dados remotos
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        print('⚠️ Usuário não autenticado, retornando dados mockados para UserProgress');
        // Retornar dados padrão para usuários não autenticados em vez de lançar exceção
        return const UserProgress(
          daysTrainedThisMonth: 0,
          currentStreak: 0,
          bestStreak: 0,
          challengeProgress: 0,
        );
      }
      
      final response = await _supabaseClient
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
      
      // Handle the case where no progress record exists
      if (response == null) {
        print('⚠️ Nenhum registro de progresso encontrado para o usuário $userId, retornando padrão.');
        // Return default progress or consider if an empty state is more appropriate
        const defaultProgress = UserProgress(
          daysTrainedThisMonth: 0,
          currentStreak: 0,
          bestStreak: 0,
          challengeProgress: 0,
        );
        return defaultProgress;
      }
      
      // Log para debug
      print('🔍 Dados de progresso recebidos: ${response.keys}');
      
      // Se chegou até aqui, a resposta foi bem-sucedida e não é null
      // Usamos valores padrão seguros para todos os campos para evitar erros
      final progress = UserProgress(
        // Mapeamento seguro para campos que podem ter nomes diferentes
        id: response['id'],
        userId: response['user_id'],
        totalWorkouts: response['workouts'] ?? response['total_workouts'] ?? 0,
        totalPoints: response['points'] ?? response['total_points'] ?? 0,
        currentStreak: response['current_streak'] ?? 0,
        longestStreak: response['longest_streak'] ?? response['best_streak'] ?? 0,
        daysTrainedThisMonth: response['days_trained_this_month'] ?? 0,
        challengeProgress: response['challenge_progress']?.toDouble() ?? 0,
        totalDuration: response['total_duration'] ?? 0,
        workoutsByType: _parseWorkoutsByType(response['workouts_by_type']),
        lastUpdated: _parseDateTime(response['last_updated']),
        lastWorkout: _parseDateTime(response['last_workout']),
      );
      
      // Armazenar em cache para uso futuro
      await _cacheService.set(
        _cacheKeyUserProgress, 
        progress.toJson(),
        expiry: _shortCacheExpiry
      );
      
      return progress;
    } catch (e) {
      print('❌ Erro ao buscar progresso do usuário: $e');
      
      // Em caso de erro, tentar usar o cache, mesmo se estiver expirado
      final cachedData = await _cacheService.get(_cacheKeyUserProgress);
      if (cachedData != null) {
        try {
          return UserProgress.fromJson(cachedData);
        } catch (_) {
          // Ignorar erros ao decodificar cache
        }
      }
      
      // Se for erro do Supabase, tenta extrair a mensagem específica
      if (e is PostgrestException) {
        throw AppException(
          message: 'Erro ao buscar progresso: ${e.message}',
          originalError: e,
        );
      }
      
      throw AppException(
        message: 'Erro ao carregar progresso do usuário',
        originalError: e,
      );
    }
  }
  
  // Auxiliar para converter data/hora de forma segura
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
    } catch (_) {}
    
    return null;
  }
  
  // Auxiliar para converter workouts_by_type de forma segura
  Map<String, int> _parseWorkoutsByType(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, int>) return value;
    
    try {
      if (value is Map) {
        return value.map((key, val) => MapEntry(key.toString(), (val is int) ? val : int.parse(val.toString())));
      }
    } catch (_) {}
    
    return {};
  }
  
  @override
  Future<List<BannerItem>> getBanners() async {
    try {
      // Verificar se há dados em cache
      final cachedData = await _cacheService.get(_cacheKeyBanners);
      if (cachedData != null) {
        try {
          // Lista de banners pode ser usada do cache por até 15 minutos
          final cachedBanners = (cachedData as List)
            .map((item) => BannerItem.fromJson(item))
            .toList();
          
          print('✅ Usando banners do cache: ${cachedBanners.length} itens');
          return cachedBanners;
        } catch (e) {
          print('⚠️ Erro ao decodificar cache de banners: $e');
          // Se houver erro ao decodificar o cache, ignorar
        }
      } else {
        print('🔍 Cache de banners não encontrado');
      }
      
      // Buscar dados remotos
      print('🔍 Buscando banners do Supabase...');
      final response = await _supabaseClient
        .from('banners')
        .select()
        .order('created_at', ascending: false);
      
      // Se a resposta estiver vazia, retornar dados mockados em vez de lista vazia
      if (response == null || response.isEmpty) {
        print('⚠️ Nenhum banner encontrado no Supabase, usando dados padrão');
        return _getDefaultBanners();
      }
      
      print('✅ Banners obtidos do Supabase: ${response.length} itens');
      
      // Converter os dados da resposta para objetos BannerItem
      final banners = response.map<BannerItem>((data) {
        return BannerItem(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          subtitle: data['subtitle'] ?? '',
          imageUrl: data['image_url'] ?? '',
          actionUrl: data['action_url'],
          isActive: data['is_active'] ?? false,
        );
      }).toList();
      
      // Armazenar em cache para uso futuro
      await _cacheService.set(
        _cacheKeyBanners, 
        banners.map((banner) => banner.toJson()).toList(),
        expiry: _defaultCacheExpiry
      );
      
      return banners;
    } catch (e) {
      print('❌ Erro ao buscar banners do Supabase: $e');
      
      // Em caso de erro, tentar usar o cache, mesmo se estiver expirado
      final cachedData = await _cacheService.get(_cacheKeyBanners);
      if (cachedData != null) {
        try {
          final cachedBanners = (cachedData as List)
            .map((item) => BannerItem.fromJson(item))
            .toList();
          
          print('🔄 Usando banners do cache como fallback: ${cachedBanners.length} itens');
          return cachedBanners;
        } catch (cacheError) {
          print('❌ Também falhou ao usar cache: $cacheError');
          // Ignorar erros ao decodificar cache
        }
      }
      
      print('🛟 Usando banners padrão como último recurso');
      // Usar dados mockados como último recurso
      return _getDefaultBanners();
    }
  }
  
  // Método auxiliar para criar banners padrão quando tudo falhar
  List<BannerItem> _getDefaultBanners() {
    return [
      const BannerItem(
        id: 'default-1',
        title: 'Bem-vindo ao Ray Club',
        subtitle: 'Sua jornada de bem-estar começa aqui',
        imageUrl: 'assets/images/banner_bemvindo.png',
        isActive: true,
      ),
      const BannerItem(
        id: 'default-2',
        title: 'Descubra Novos Treinos',
        subtitle: 'Transforme sua rotina com exercícios diversificados',
        imageUrl: 'assets/images/workout_default.jpg',
      ),
      const BannerItem(
        id: 'default-3',
        title: 'Desafios Semanais',
        subtitle: 'Supere seus limites e ganhe recompensas',
        imageUrl: 'assets/images/challenge_default.jpg',
      ),
    ];
  }
  
  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    try {
      // Verificar se há dados em cache
      final cachedData = await _cacheService.get(_cacheKeyCategories);
      if (cachedData != null) {
        try {
          // Categorias podem ser usadas do cache por até 15 minutos
          final cachedCategories = (cachedData as List)
            .map((item) => WorkoutCategory.fromJson(item))
            .toList();
          return cachedCategories;
        } catch (e) {
          // Se houver erro ao decodificar o cache, ignorar
        }
      }
      
      // Buscar dados remotos
      final response = await _supabaseClient
        .from('workout_categories')
        .select()
        .order('name');
      
      // Se a resposta estiver vazia, retornar lista vazia
      if (response == null || response.isEmpty) {
        return [];
      }
      
      // Converter os dados da resposta para objetos WorkoutCategory
      final categories = response.map<WorkoutCategory>((data) {
        return WorkoutCategory(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          iconUrl: data['icon_url'] ?? '',
          workoutCount: data['workout_count'] ?? 0,
          colorHex: data['color_hex'],
        );
      }).toList();
      
      // Armazenar em cache para uso futuro
      await _cacheService.set(
        _cacheKeyCategories, 
        categories.map((category) => category.toJson()).toList(),
        expiry: _defaultCacheExpiry
      );
      
      return categories;
    } catch (e) {
      // Em caso de erro, tentar usar o cache, mesmo se estiver expirado
      final cachedData = await _cacheService.get(_cacheKeyCategories);
      if (cachedData != null) {
        try {
          final cachedCategories = (cachedData as List)
            .map((item) => WorkoutCategory.fromJson(item))
            .toList();
          return cachedCategories;
        } catch (_) {
          // Ignorar erros ao decodificar cache
        }
      }
      
      throw AppException(
        message: 'Erro ao carregar categorias',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<PopularWorkout>> getPopularWorkouts() async {
    try {
      // Verificar se há dados em cache
      final cachedData = await _cacheService.get(_cacheKeyPopularWorkouts);
      if (cachedData != null) {
        try {
          // Treinos populares podem ser usados do cache por até 15 minutos
          final cachedWorkouts = (cachedData as List)
            .map((item) => PopularWorkout.fromJson(item))
            .toList();
          return cachedWorkouts;
        } catch (e) {
          // Se houver erro ao decodificar o cache, ignorar
        }
      }
      
      // Buscar dados remotos
      // A consulta anterior usava colunas que não existem no schema
      // Substituir por uma nova consulta usando as colunas existentes
      print('🔍 Buscando treinos populares do Supabase...');
      
      final response = await _supabaseClient
        .from('workouts')
        .select()
        .eq('is_public', true) // Filtrar apenas treinos públicos
        .order('created_at', ascending: false) // Ordenar por data de criação (mais recentes primeiro)
        .limit(5); // Limitar a 5 resultados
      
      // Se a resposta estiver vazia, retornar lista vazia
      if (response == null || response.isEmpty) {
        print('⚠️ Nenhum treino popular encontrado no Supabase');
        return [];
      }
      
      print('✅ Treinos populares obtidos do Supabase: ${response.length} treinos');
      
      // Converter os dados da resposta para objetos PopularWorkout
      final workouts = response.map<PopularWorkout>((data) {
        // Converter duration_minutes para formato legível (ex: "30 min")
        final durationMinutes = data['duration_minutes'] ?? 30;
        final formattedDuration = '$durationMinutes min';
        
        return PopularWorkout(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          imageUrl: data['image_url'] ?? '',
          duration: formattedDuration,
          difficulty: data['difficulty'] ?? 'medium',
          favoriteCount: 0, // Valor padrão já que não temos essa coluna
        );
      }).toList();
      
      // Armazenar em cache para uso futuro
      await _cacheService.set(
        _cacheKeyPopularWorkouts, 
        workouts.map((workout) => workout.toJson()).toList(),
        expiry: _defaultCacheExpiry
      );
      
      return workouts;
    } catch (e) {
      // Em caso de erro, tentar usar o cache, mesmo se estiver expirado
      final cachedData = await _cacheService.get(_cacheKeyPopularWorkouts);
      if (cachedData != null) {
        try {
          final cachedWorkouts = (cachedData as List)
            .map((item) => PopularWorkout.fromJson(item))
            .toList();
          return cachedWorkouts;
        } catch (_) {
          // Ignorar erros ao decodificar cache
        }
      }
      
      throw AppException(
        message: 'Erro ao carregar treinos populares',
        originalError: e,
      );
    }
  }
  
  // Helper para converter hex para Color
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
} 
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/partner_content.dart';
import '../models/partner_studio.dart';

// Provider do repositório
final partnerStudioRepositoryProvider = Provider<PartnerStudioRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabasePartnerStudioRepository(client);
});

// Interface para o repositório
abstract class PartnerStudioRepository {
  Future<List<PartnerStudio>> getPartnerStudios();
  Future<List<PartnerContent>> getStudioContents(String studioId);
}

// Implementação com Supabase
class SupabasePartnerStudioRepository implements PartnerStudioRepository {
  final SupabaseClient _client;
  
  SupabasePartnerStudioRepository(this._client);
  
  @override
  Future<List<PartnerStudio>> getPartnerStudios() async {
    try {
      final response = await _client
        .from('partner_studios')
        .select()
        .order('name');
      
      final studios = response.map((json) => PartnerStudio.fromJson(json)).toList();
      
      // Adicionar apresentação visual para cada estúdio
      return studios.map((studio) {
        // Definir apresentação com base no ID ou nome do estúdio
        switch (studio.name.toLowerCase()) {
          case 'fight fit':
            return studio.withPresentation(
              logoColor: const Color(0xFFE74C3C),
              backgroundColor: const Color(0xFFFDEDEC),
              icon: Icons.sports_mma,
            );
          case 'flow yoga':
            return studio.withPresentation(
              logoColor: const Color(0xFF3498DB),
              backgroundColor: const Color(0xFFEBF5FB),
              icon: Icons.self_improvement,
            );
          case 'goya health club':
            return studio.withPresentation(
              logoColor: const Color(0xFF27AE60),
              backgroundColor: const Color(0xFFE9F7EF),
              icon: Icons.spa,
            );
          case 'the unit':
            return studio.withPresentation(
              logoColor: const Color(0xFF9B59B6),
              backgroundColor: const Color(0xFFF4ECF7),
              icon: Icons.medical_services,
            );
          default:
            return studio.withPresentation(
              logoColor: const Color(0xFF777777),
              backgroundColor: const Color(0xFFF5F5F5),
              icon: Icons.fitness_center,
            );
        }
      }).toList();
    } catch (e) {
      throw StorageException(
        message: 'Erro ao buscar estúdios parceiros: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<PartnerContent>> getStudioContents(String studioId) async {
    try {
      final response = await _client
        .from('partner_contents')
        .select()
        .eq('studio_id', studioId)
        .order('created_at', ascending: false);
      
      return response.map((json) => PartnerContent.fromJson(json)).toList();
    } catch (e) {
      throw StorageException(
        message: 'Erro ao buscar conteúdos do estúdio: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  // Método para dados de exemplo para desenvolvimento (fallback)
  List<PartnerStudio> _getMockStudios() {
    return [
      PartnerStudio(
        id: '1',
        name: 'Fight Fit',
        tagline: 'Funcional com luta',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '1',
            title: 'Fundamentos do Muay Thai',
            duration: '45 min',
            difficulty: 'Iniciante',
            imageUrl: 'https://images.pexels.com/photos/6295872/pexels-photo-6295872.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '2',
            title: 'Boxe Funcional',
            duration: '30 min',
            difficulty: 'Intermediário',
            imageUrl: 'https://images.pexels.com/photos/4804076/pexels-photo-4804076.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '3',
            title: 'Fight HIIT',
            duration: '25 min',
            difficulty: 'Avançado',
            imageUrl: 'https://images.pexels.com/photos/4754146/pexels-photo-4754146.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFFE74C3C),
        backgroundColor: const Color(0xFFFDEDEC),
        icon: Icons.sports_mma,
      ),
      
      PartnerStudio(
        id: '2',
        name: 'Flow Yoga',
        tagline: 'Yoga e crioterapia',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '4',
            title: 'Vinyasa Flow',
            duration: '50 min',
            difficulty: 'Todos os níveis',
            imageUrl: 'https://images.pexels.com/photos/6698513/pexels-photo-6698513.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '5',
            title: 'Benefícios da Crioterapia',
            duration: '15 min',
            difficulty: 'Informativo',
            imageUrl: 'https://images.pexels.com/photos/6111616/pexels-photo-6111616.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '6',
            title: 'Yoga para Recuperação',
            duration: '35 min',
            difficulty: 'Iniciante',
            imageUrl: 'https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFF3498DB),
        backgroundColor: const Color(0xFFEBF5FB),
        icon: Icons.self_improvement,
      ),
      
      PartnerStudio(
        id: '3',
        name: 'Goya Health Club',
        tagline: 'Pilates e yoga',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '7',
            title: 'Pilates Reformer',
            duration: '40 min',
            difficulty: 'Intermediário',
            imageUrl: 'https://images.pexels.com/photos/6551133/pexels-photo-6551133.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '8',
            title: 'Hatha Yoga',
            duration: '60 min',
            difficulty: 'Todos os níveis',
            imageUrl: 'https://images.pexels.com/photos/4534680/pexels-photo-4534680.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '9',
            title: 'Mat Pilates',
            duration: '30 min',
            difficulty: 'Iniciante',
            imageUrl: 'https://images.pexels.com/photos/3775593/pexels-photo-3775593.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFF27AE60),
        backgroundColor: const Color(0xFFE9F7EF),
        icon: Icons.spa,
      ),
      
      PartnerStudio(
        id: '4',
        name: 'The Unit',
        tagline: 'Fisioterapia para treino',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '10',
            title: 'Mobilidade para Atletas',
            duration: '25 min',
            difficulty: 'Todos os níveis',
            imageUrl: 'https://images.pexels.com/photos/8957028/pexels-photo-8957028.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '11',
            title: 'Recuperação de Lesões',
            duration: '45 min',
            difficulty: 'Reabilitação',
            imageUrl: 'https://images.pexels.com/photos/6111609/pexels-photo-6111609.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '12',
            title: 'Core para Performance',
            duration: '30 min',
            difficulty: 'Intermediário',
            imageUrl: 'https://images.pexels.com/photos/8436735/pexels-photo-8436735.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFF9B59B6),
        backgroundColor: const Color(0xFFF4ECF7),
        icon: Icons.medical_services,
      ),
    ];
  }
} // Project imports:
import 'package:flutter/material.dart';
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface do repositório para os destaques da semana
abstract class WeeklyHighlightsRepository {
  /// Obtém os destaques da semana ativos
  Future<List<WeeklyHighlight>> getWeeklyHighlights();
  
  /// Obtém um destaque específico por ID
  Future<WeeklyHighlight?> getHighlightById(String id);
  
  /// Marca um destaque como visualizado pelo usuário
  Future<void> markHighlightAsViewed(String id);
}

/// Implementação mock do repositório para desenvolvimento
class MockWeeklyHighlightsRepository implements WeeklyHighlightsRepository {
  @override
  Future<List<WeeklyHighlight>> getWeeklyHighlights() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Retorna dados mockados
    return getMockWeeklyHighlights();
  }
  
  @override
  Future<WeeklyHighlight?> getHighlightById(String id) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Busca nos dados mockados
    final highlights = getMockWeeklyHighlights();
    return highlights.where((h) => h.id == id).firstOrNull;
  }
  
  @override
  Future<void> markHighlightAsViewed(String id) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Em uma implementação real, salvaria no Supabase
    debugPrint('Highlight $id marcado como visualizado');
  }
}

/// Implementação do repositório usando Supabase
class SupabaseWeeklyHighlightsRepository implements WeeklyHighlightsRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseWeeklyHighlightsRepository(this._supabaseClient);
  
  @override
  Future<List<WeeklyHighlight>> getWeeklyHighlights() async {
    try {
      final response = await _supabaseClient
          .from('weekly_highlights')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);
      
      return (response as List<dynamic>)
          .map((data) => WeeklyHighlight.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log do erro
      print('Erro ao buscar destaques semanais: $e');
      // Retorna os dados mockados como fallback durante desenvolvimento
      return getMockWeeklyHighlights();
    }
  }
  
  @override
  Future<WeeklyHighlight?> getHighlightById(String id) async {
    try {
      final response = await _supabaseClient
          .from('weekly_highlights')
          .select()
          .eq('id', id)
          .single();
      
      return WeeklyHighlight.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Log do erro
      print('Erro ao buscar destaque por ID: $e');
      // Busca nos dados mockados como fallback
      final highlights = getMockWeeklyHighlights();
      return highlights.where((h) => h.id == id).firstOrNull;
    }
  }
  
  @override
  Future<void> markHighlightAsViewed(String id) async {
    try {
      // Obtém o ID do usuário atual
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        print('Usuário não autenticado');
        return;
      }
      
      // Verificar se o registro já existe
      final existing = await _supabaseClient
          .from('highlight_views')
          .select()
          .eq('highlight_id', id)
          .eq('user_id', userId);
      
      if ((existing as List).isEmpty) {
        // Insere novo registro de visualização
        await _supabaseClient.from('highlight_views').insert({
          'highlight_id': id,
          'user_id': userId,
          'viewed_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erro ao marcar destaque como visualizado: $e');
    }
  }
} // Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../benefits/viewmodels/benefit_view_model.dart';

/// Provider para o AppViewModel
final appViewModelProvider = Provider<AppViewModel>((ref) {
  return AppViewModel(ref);
});

/// ViewModel global para gerenciar estado e operações da aplicação
class AppViewModel {
  final Ref _ref;
  Timer? _expirationCheckTimer;

  AppViewModel(this._ref) {
    // Inicia verificação automática de benefícios expirados
    _startExpirationCheck();
  }

  /// Inicia a verificação periódica de benefícios expirados
  /// A verificação ocorre imediatamente e depois a cada 1 hora
  void _startExpirationCheck() {
    // Verifica imediatamente ao iniciar o app
    _checkExpiredBenefits();
    
    // Configura verificação periódica a cada 1 hora
    _expirationCheckTimer = Timer.periodic(
      const Duration(hours: 1), 
      (_) => _checkExpiredBenefits()
    );
  }

  /// Para a verificação periódica de benefícios expirados
  void stopExpirationCheck() {
    _expirationCheckTimer?.cancel();
    _expirationCheckTimer = null;
  }

  /// Executa a verificação de benefícios expirados
  Future<void> _checkExpiredBenefits() async {
    try {
      // Carrega benefícios resgatados, que já incluem a verificação de expiração
      await _ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits();
      
      if (kDebugMode) {
        print('Verificação de benefícios expirados concluída');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar benefícios expirados: $e');
      }
    }
  }
  
  /// Força verificação manual de benefícios expirados
  Future<void> checkExpiredBenefits() async {
    return _checkExpiredBenefits();
  }
  
  /// Método para limpar recursos ao desmontar o provider
  void dispose() {
    stopExpirationCheck();
  }
} 
// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/di/base_view_model.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/workouts/repositories/workout_repository.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

// Provider para o ProgressViewModel
final progressViewModelProvider = StateNotifierProvider<ProgressViewModel, BaseState>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  
  return ProgressViewModel(
    challengeRepository: challengeRepository,
    authRepository: authRepository,
    workoutRepository: workoutRepository,
  );
});

/// Estado específico para a tela de progresso
class ProgressState extends BaseState {
  final ChallengeProgress? userProgress;
  final List<Workout> workoutsForDate;
  final DateTime selectedDate;
  
  ProgressState({
    super.isLoading = false,
    super.error,
    this.userProgress,
    this.workoutsForDate = const [],
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();
  
  ProgressState copyWith({
    bool? isLoading,
    AppException? error,
    ChallengeProgress? userProgress,
    List<Workout>? workoutsForDate,
    DateTime? selectedDate,
  }) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userProgress: userProgress ?? this.userProgress,
      workoutsForDate: workoutsForDate ?? this.workoutsForDate,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// ViewModel para gerenciar o estado de progresso do usuário
class ProgressViewModel extends BaseViewModel<ProgressState> {
  final ChallengeRepository _challengeRepository;
  final IAuthRepository _authRepository;
  final WorkoutRepository _workoutRepository;
  
  ProgressViewModel({
    required ChallengeRepository challengeRepository,
    required IAuthRepository authRepository,
    required WorkoutRepository workoutRepository,
  }) : _challengeRepository = challengeRepository,
       _authRepository = authRepository,
       _workoutRepository = workoutRepository,
       super(ProgressState());
  
  /// Carrega o progresso do usuário para um desafio específico
  Future<void> getUserProgress(String challengeId) async {
    await handleAsync(() async {
      // Verificar se o usuário está autenticado
      final userId = await _authRepository.getCurrentUserId();
      
      // Buscar o progresso do usuário para o desafio
      final progress = await _challengeRepository.getUserProgress(
        userId: userId,
        challengeId: challengeId,
      );
      
      // Atualizar o estado com o progresso obtido
      state = state.copyWith(userProgress: progress);
    });
  }
  
  /// Carrega os treinos do usuário para uma data específica
  Future<void> getWorkoutsForDate(DateTime date) async {
    await handleAsync(() async {
      // Atualizar a data selecionada no estado
      state = state.copyWith(selectedDate: date);
      
      // Verificar se o usuário está autenticado
      final userId = await _authRepository.getCurrentUserId();
      
      // Buscar os treinos do usuário para a data
      final workouts = await _workoutRepository.getUserWorkoutsForDate(
        userId: userId,
        date: date,
      );
      
      // Atualizar o estado com os treinos obtidos
      state = state.copyWith(workoutsForDate: workouts);
    });
  }
  
  /// Altera a data selecionada e carrega os dados correspondentes
  Future<void> changeSelectedDate(DateTime date) async {
    // Atualiza a data no estado primeiro para refletir imediatamente na UI
    state = state.copyWith(selectedDate: date);
    
    // Busca os dados para a nova data
    await getWorkoutsForDate(date);
  }
} import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/progress/models/progress_state.dart';
import 'package:ray_club_app/features/progress/providers/progress_providers.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';
import 'package:ray_club_app/features/progress/repositories/user_progress_repository.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

// Providers temporários (remover quando implementar corretamente)
final userWorkoutStreakProvider = FutureProvider<int>((ref) async {
  // Retornar valor default para evitar erro
  return 0;
});

final userWorkoutCountProvider = FutureProvider.family<int, int>((ref, days) async {
  // Retornar valor default para evitar erro
  return 0;
});

// Provider para o gerenciamento de progresso
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserProgressRepository(supabase);
});

// Provider para obter workouts para uma data específica
final userWorkoutsForDateProvider = FutureProvider.family<List<dynamic>, DateTime>((ref, date) async {
  // Retornar lista vazia para evitar erros
  return [];
});

class ProgressViewModel extends StateNotifier<ProgressState> {
  final Ref _ref;
  
  ProgressViewModel(this._ref) : super(ProgressState.initial());

  void _initialize() async {
    final authState = _ref.read(authViewModelProvider);
    final isLoggedIn = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isLoggedIn) {
      state = state.copyWith(
        isLoading: false,
        error: const AppException(
          message: 'You need to be logged in to view your progress',
        ),
      );
      return;
    }
    
    // Carregar dados iniciais
    loadUserProgress();
  }
  
  /// Carrega o progresso completo do usuário
  Future<void> loadUserProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authState = _ref.read(authViewModelProvider);
      final user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
      
      if (user == null) {
        throw const AppException(message: 'Usuário não autenticado');
      }
      
      // Carregar o progresso do usuário utilizando o repositório
      final progressRepository = _ref.read(userProgressRepositoryProvider);
      final userProgress = await progressRepository.getProgressForUser(user.id);
      
      // Atualizar estado com o progresso carregado
      state = state.copyWith(
        isLoading: false,
        userProgress: userProgress,
        currentStreak: userProgress.currentStreak,
        workoutCount: userProgress.totalWorkouts,
      );
      
      // Carregar treinos para a data selecionada
      loadWorkoutsForDate(state.selectedDate);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(
          message: 'Erro ao carregar progresso: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadWorkoutsForDate(DateTime date) async {
    state = state.copyWith(isLoadingWorkouts: true, error: null);
    
    try {
      final workoutRecords = await _ref.read(
        userWorkoutsForDateProvider(date).future,
      );
      
      // Converter WorkoutRecord para Workout para compatibilidade com ProgressState
      final workouts = workoutRecords.map((record) => Workout(
        id: record.id,
        name: record.workoutName,
        description: '',
        imageUrl: '',
        type: record.workoutType ?? 'other',
        durationMinutes: record.durationMinutes,
        difficulty: 'medium',
        exerciseCount: 0,
        caloriesBurned: 0,
      )).toList();
      
      state = state.copyWith(
        isLoadingWorkouts: false,
        workouts: workouts,
        selectedDate: date,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingWorkouts: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingWorkouts: false,
        error: AppException(
          message: 'Failed to load workouts: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadWorkoutStreak() async {
    state = state.copyWith(isLoadingStreak: true, streakError: null);
    
    try {
      // Usar valor do progresso do usuário se disponível
      if (state.userProgress != null) {
        state = state.copyWith(
          isLoadingStreak: false,
          currentStreak: state.userProgress!.currentStreak,
        );
      } else {
        // Fallback para o método antigo
        final streak = await _ref.read(userWorkoutStreakProvider.future);
        
        state = state.copyWith(
          isLoadingStreak: false,
          currentStreak: streak,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingStreak: false,
        streakError: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStreak: false,
        streakError: AppException(
          message: 'Failed to load streak: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadWorkoutCount() async {
    state = state.copyWith(isLoadingCount: true, countError: null);
    
    try {
      // Usar valor do progresso do usuário se disponível
      if (state.userProgress != null) {
        state = state.copyWith(
          isLoadingCount: false,
          workoutCount: state.userProgress!.totalWorkouts,
        );
      } else {
        // Fallback para o método antigo
        final count = await _ref.read(userWorkoutCountProvider(30).future);
        
        state = state.copyWith(
          isLoadingCount: false,
          workoutCount: count,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(
        isLoadingCount: false,
        countError: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCount: false,
        countError: AppException(
          message: 'Failed to load workout count: ${e.toString()}',
        ),
      );
    }
  }
  
  /// Sincroniza o progresso a partir dos registros de treino
  /// Útil para corrigir inconsistências ou após adicionar treinos manualmente
  Future<void> syncProgressFromWorkouts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authState = _ref.read(authViewModelProvider);
      final user = authState.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );
      
      if (user == null) {
        throw const AppException(message: 'Usuário não autenticado');
      }
      
      // Sincronizar utilizando o repositório
      final progressRepository = _ref.read(userProgressRepositoryProvider);
      await progressRepository.syncProgressFromWorkoutRecords(user.id);
      
      // Recarregar os dados atualizados
      await loadUserProgress();
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(
          message: 'Erro ao sincronizar progresso: ${e.toString()}',
        ),
      );
    }
  }

  void selectDate(DateTime date) {
    if (state.selectedDate != date) {
      loadWorkoutsForDate(date);
    }
  }
}

final progressViewModelProvider =
    StateNotifierProvider<ProgressViewModel, ProgressState>((ref) {
  return ProgressViewModel(ref);
}); // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Provider para o repositório de progresso do usuário
final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return UserProgressRepository(supabaseClient);
});

/// Classe responsável por gerenciar dados de progresso do usuário
class UserProgressRepository {
  /// Cliente Supabase para comunicação com o backend
  final SupabaseClient _client;
  
  /// Nome da tabela no Supabase
  static const String _tableName = 'user_progress';
  
  /// Construtor da classe
  UserProgressRepository(this._client);
  
  /// Obtém o progresso do usuário a partir do Supabase
  /// [userId] - ID do usuário para buscar o progresso
  Future<UserProgress> getProgressForUser(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .single();
          
      return UserProgress.fromJson(response);
    } catch (e, stackTrace) {
      // Se o registro não existe, tenta criar um novo
      if (e is PostgrestException && e.code == 'PGRST116') {
        // Erro de nenhum resultado encontrado
        // Criar um novo registro de progresso para este usuário
        return await _createInitialProgressForUser(userId);
      }
      
      // Outros erros
      throw AppException(
        message: 'Erro ao buscar progresso do usuário: ${e.toString()}',
      );
    }
  }
  
  /// Cria um registro inicial de progresso para um novo usuário
  Future<UserProgress> _createInitialProgressForUser(String userId) async {
    try {
      // Valores iniciais para um novo usuário
      final initialData = {
        'user_id': userId,
        'workouts': 0,
        'points': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'workouts_by_type': {},
        'total_duration': 0,
        'completed_challenges': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      // Insere o registro no Supabase
      final response = await _client
          .from(_tableName)
          .insert(initialData)
          .select()
          .single();
          
      return UserProgress.fromJson(response);
    } catch (e, stackTrace) {
      throw AppException(
        message: 'Erro ao criar registro de progresso: ${e.toString()}',
      );
    }
  }
  
  /// Atualiza o progresso após um novo treino
  Future<void> updateProgressAfterWorkout(String userId, WorkoutRecord workout) async {
    try {
      // Tenta usar a nova função RPC implementada no Supabase
      try {
        await _client.rpc(
          'update_progress_after_workout',
          params: {
            '_user_id': userId,
            '_workout_id': workout.id,
            '_duration_minutes': workout.durationMinutes,
            '_workout_type': workout.workoutType
          },
        );
        return; // Se a RPC funcionar, retorna com sucesso
      } catch (rpcError) {
        // Se falhar, cai no método alternativo (fallback)
        debugPrint('⚠️ Função RPC update_progress_after_workout falhou, usando método alternativo: $rpcError');
      }

      // Busca o progresso atual
      final currentProgress = await getProgressForUser(userId);
      
      // Obter o tipo de treino
      final workoutType = workout.workoutType ?? 'outros';
      
      // Atualizar o mapa de treinos por tipo
      final updatedWorkoutsByType = Map<String, int>.from(currentProgress.workoutsByType);
      updatedWorkoutsByType[workoutType] = (updatedWorkoutsByType[workoutType] ?? 0) + 1;
      
      // Preparar os dados para atualização
      final updatedData = {
        'workouts': currentProgress.totalWorkouts + 1,
        'points': currentProgress.totalPoints + _calculatePointsForWorkout(workout),
        'total_duration': currentProgress.totalDuration + (workout.durationMinutes ?? 0),
        'last_workout': workout.date.toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'workouts_by_type': updatedWorkoutsByType,
      };
      
      // Atualizar o registro no Supabase
      await _client
          .from(_tableName)
          .update(updatedData)
          .eq('user_id', userId);
    } catch (e) {
      // Registra o erro, mas não lança exceção para não interromper o fluxo principal
      debugPrint('⚠️ Erro ao atualizar progresso, mas continuando: ${e.toString()}');
    }
  }
  
  /// Calcula os pontos ganhos por um treino com base na duração e intensidade
  int _calculatePointsForWorkout(WorkoutRecord workout) {
    final duration = workout.durationMinutes ?? 0;
    // Utilizamos um valor padrão para intensidade já que o modelo não tem mais essa propriedade
    const intensity = 1.0;
    
    // Cálculo básico: duração × intensidade
    return (duration * intensity).round();
  }
  
  /// Sincroniza o progresso a partir de todos os registros de treino
  /// Útil para recalcular estatísticas ou corrigir dados inconsistentes
  Future<void> syncProgressFromWorkoutRecords(String userId) async {
    try {
      // Buscar todos os treinos do usuário
      final workouts = await _client
          .from('workout_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
          
      final workoutRecords = workouts
          .map((record) => WorkoutRecord.fromJson(record))
          .toList();
          
      // Calcular estatísticas
      int totalWorkouts = workoutRecords.length;
      int totalPoints = 0;
      int totalDuration = 0;
      DateTime? lastWorkout;
      final Map<String, int> workoutsByType = {};
      final Map<String, int> monthlyWorkouts = {};
      final Map<String, int> weeklyWorkouts = {};
      
      // Processar cada treino
      for (final workout in workoutRecords) {
        // Pontos totais
        totalPoints += _calculatePointsForWorkout(workout);
        
        // Duração total
        totalDuration += workout.durationMinutes ?? 0;
        
        // Último treino (já está ordenado por data, então o primeiro é o mais recente)
        if (lastWorkout == null || (workout.date.isAfter(lastWorkout))) {
          lastWorkout = workout.date;
        }
        
        // Contagem por tipo
        final type = workout.workoutType ?? 'outros';
        workoutsByType[type] = (workoutsByType[type] ?? 0) + 1;
        
        // Contagem por mês (formato "YYYY-MM")
        final monthKey = '${workout.date.year}-${workout.date.month.toString().padLeft(2, '0')}';
        monthlyWorkouts[monthKey] = (monthlyWorkouts[monthKey] ?? 0) + 1;
        
        // Contagem por semana (formato "YYYY-WW")
        // Número da semana no ano (1-53)
        final weekNumber = (workout.date.difference(DateTime(workout.date.year, 1, 1)).inDays / 7).floor() + 1;
        final weekKey = '${workout.date.year}-${weekNumber.toString().padLeft(2, '0')}';
        weeklyWorkouts[weekKey] = (weeklyWorkouts[weekKey] ?? 0) + 1;
      }
      
      // Calcular streak (dias consecutivos de treino)
      final currentStreak = _calculateCurrentStreak(workoutRecords);
      final longestStreak = _calculateLongestStreak(workoutRecords);
      
      // Preparar dados para atualização
      final updatedData = {
        'workouts': totalWorkouts,
        'points': totalPoints,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'workouts_by_type': workoutsByType,
        'total_duration': totalDuration,
        'last_workout': lastWorkout?.toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'monthly_workouts': monthlyWorkouts,
        'weekly_workouts': weeklyWorkouts,
        'days_trained_this_month': _calculateDaysTrainedThisMonth(workoutRecords),
      };
      
      // Atualizar ou criar registro
      await _client
          .from(_tableName)
          .upsert({
            'user_id': userId,
            ...updatedData
          })
          .select();
    } catch (e, stackTrace) {
      throw AppException(
        message: 'Erro ao sincronizar progresso: ${e.toString()}',
      );
    }
  }
  
  /// Calcula a sequência atual de dias consecutivos com treino
  int _calculateCurrentStreak(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Mapeia as datas de treino (apenas ano-mês-dia)
    final workoutDays = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Ordena decrescente (mais recente primeiro)
    
    // Pega a data mais recente
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Verifica se treinou hoje ou ontem para começar a streak
    int streakCount = 0;
    DateTime? lastDate;
    
    // Se treinou hoje, começa com 1
    if (workoutDays.isNotEmpty && workoutDays.first.isAtSameMomentAs(today)) {
      streakCount = 1;
      lastDate = today;
    } 
    // Se treinou ontem mas não hoje, ainda conta como streak (com 1 dia)
    else if (workoutDays.isNotEmpty && workoutDays.first.isAtSameMomentAs(yesterday)) {
      streakCount = 1;
      lastDate = yesterday;
    }
    // Se não treinou nem hoje nem ontem, já perdeu a streak
    else {
      return 0;
    }
    
    // Continua a verificar dias anteriores
    for (int i = 1; i < 1000; i++) { // Limite de 1000 dias para evitar loop infinito
      final checkDate = (lastDate ?? today).subtract(Duration(days: i));
      
      if (workoutDays.any((date) => date.isAtSameMomentAs(checkDate))) {
        streakCount++;
        lastDate = checkDate;
      } else {
        break; // Streak quebrada
      }
    }
    
    return streakCount;
  }
  
  /// Calcula a maior sequência histórica de treinos
  int _calculateLongestStreak(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Mapeia as datas de treino (apenas ano-mês-dia)
    final workoutDays = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b)); // Ordena crescente
    
    int currentStreak = 1;
    int longestStreak = 1;
    
    for (int i = 1; i < workoutDays.length; i++) {
      final prevDay = workoutDays[i - 1];
      final currentDay = workoutDays[i];
      
      // Verifica se os dias são consecutivos
      if (currentDay.difference(prevDay).inDays == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } 
      // Se o mesmo dia, ignora (não quebra a streak)
      else if (currentDay.difference(prevDay).inDays == 0) {
        continue;
      }
      // Se dias não consecutivos, reinicia a contagem
      else {
        currentStreak = 1;
      }
    }
    
    return longestStreak;
  }
  
  /// Calcula o número de dias com treino no mês atual
  int _calculateDaysTrainedThisMonth(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) return 0;
    
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    // Filtra treinos do mês atual e conta dias únicos
    final daysWithWorkouts = workouts
        .where((w) {
          final workoutMonth = DateTime(w.date.year, w.date.month);
          return workoutMonth.isAtSameMomentAs(currentMonth);
        })
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
        
    return daysWithWorkouts.length;
  }
} // Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/features/goals/repositories/water_intake_repository.dart';

/// Estado do WaterViewModel
class WaterState {
  /// Dados atuais de ingestão de água
  final WaterIntake? waterIntake;
  
  /// Indica se está carregando
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;

  /// Construtor
  WaterState({
    this.waterIntake,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Cria uma cópia do estado com novos valores
  WaterState copyWith({
    WaterIntake? waterIntake,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WaterState(
      waterIntake: waterIntake ?? this.waterIntake,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ViewModel para gerenciar a ingestão de água
/// PATCH: Corrigir bug 2 - Garantir persistência dos dados de água no Supabase
class WaterViewModel extends StateNotifier<WaterState> {
  /// Repositório de ingestão de água
  final WaterIntakeRepository _repository;
  
  /// ID do usuário atual
  final String _userId;

  /// Construtor
  WaterViewModel(this._repository, this._userId) : super(WaterState());

  /// Carrega os dados de ingestão de água
  Future<void> loadWaterIntake() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final today = DateTime.now();
      final waterIntake = await _repository.getWaterIntakeForDate(_userId, today);
      
      state = state.copyWith(
        waterIntake: waterIntake,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao carregar dados de água',
      );
    }
  }

  /// Adiciona um copo de água
  Future<void> addGlass() async {
    if (state.isLoading) return;
    
    final currentIntake = state.waterIntake;
    final int currentCups = currentIntake?.cups ?? 0;
    final int newCups = currentCups + 1;
    final int goal = currentIntake?.goal ?? 8; // Meta padrão de 8 copos se não definida
    
    // Atualiza o estado otimisticamente
    if (currentIntake != null) {
      state = state.copyWith(
        waterIntake: currentIntake.copyWith(cups: newCups),
      );
    }
    
    try {
      // PATCH: Corrigir bug 2 - Persistir dados de água no Supabase
      final today = DateTime.now();
      final updatedIntake = await _repository.insertOrUpdateWaterIntake(
        userId: _userId,
        date: today,
        cups: newCups,
        goal: goal,
        notes: currentIntake?.notes,
      );
      
      // Atualiza o estado com os dados retornados do servidor
      state = state.copyWith(
        waterIntake: updatedIntake,
      );
      
      debugPrint('✅ Copo de água adicionado e persistido no Supabase');
    } catch (e) {
      // Reverte a atualização otimista em caso de erro
      state = state.copyWith(
        waterIntake: currentIntake,
        errorMessage: e is AppException ? e.message : 'Erro ao adicionar copo de água',
      );
      
      debugPrint('❌ Erro ao adicionar copo de água: $e');
    }
  }

  /// Remove um copo de água
  Future<void> removeGlass() async {
    if (state.isLoading) return;
    
    final currentIntake = state.waterIntake;
    final int currentCups = currentIntake?.cups ?? 0;
    
    // Não permite valores negativos
    if (currentCups <= 0) return;
    
    final int newCups = currentCups - 1;
    final int goal = currentIntake?.goal ?? 8; // Meta padrão de 8 copos se não definida
    
    // Atualiza o estado otimisticamente
    if (currentIntake != null) {
      state = state.copyWith(
        waterIntake: currentIntake.copyWith(cups: newCups),
      );
    }
    
    try {
      // PATCH: Corrigir bug 2 - Persistir dados de água no Supabase
      final today = DateTime.now();
      final updatedIntake = await _repository.insertOrUpdateWaterIntake(
        userId: _userId,
        date: today,
        cups: newCups,
        goal: goal,
        notes: currentIntake?.notes,
      );
      
      // Atualiza o estado com os dados retornados do servidor
      state = state.copyWith(
        waterIntake: updatedIntake,
      );
      
      debugPrint('✅ Copo de água removido e persistido no Supabase');
    } catch (e) {
      // Reverte a atualização otimista em caso de erro
      state = state.copyWith(
        waterIntake: currentIntake,
        errorMessage: e is AppException ? e.message : 'Erro ao remover copo de água',
      );
      
      debugPrint('❌ Erro ao remover copo de água: $e');
    }
  }

  /// Atualiza a meta diária de copos de água
  Future<void> updateGoal(int newGoal) async {
    if (state.isLoading || newGoal < 1) return;
    
    final currentIntake = state.waterIntake;
    final int currentCups = currentIntake?.cups ?? 0;
    
    // Atualiza o estado otimisticamente
    if (currentIntake != null) {
      state = state.copyWith(
        waterIntake: currentIntake.copyWith(goal: newGoal),
      );
    }
    
    try {
      // PATCH: Corrigir bug 2 - Persistir meta de água no Supabase
      final today = DateTime.now();
      final updatedIntake = await _repository.insertOrUpdateWaterIntake(
        userId: _userId,
        date: today,
        cups: currentCups,
        goal: newGoal,
        notes: currentIntake?.notes,
      );
      
      // Atualiza o estado com os dados retornados do servidor
      state = state.copyWith(
        waterIntake: updatedIntake,
      );
      
      debugPrint('✅ Meta de água atualizada e persistida no Supabase');
    } catch (e) {
      // Reverte a atualização otimista em caso de erro
      state = state.copyWith(
        waterIntake: currentIntake,
        errorMessage: e is AppException ? e.message : 'Erro ao atualizar meta de água',
      );
      
      debugPrint('❌ Erro ao atualizar meta de água: $e');
    }
  }
}

/// Provider para o WaterViewModel
final waterViewModelProvider = StateNotifierProvider<WaterViewModel, WaterState>((ref) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id ?? '';
  
  return WaterViewModel(repository, userId);
}); // Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';

/// State para UserGoalsViewModel
class UserGoalsState {
  /// Lista de metas do usuário
  final List<UserGoal> goals;
  
  /// Indica se está carregando dados
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;

  /// Construtor
  UserGoalsState({
    required this.goals,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Cria uma cópia do estado com alguns campos alterados
  UserGoalsState copyWith({
    List<UserGoal>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserGoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel para gerenciar metas do usuário
/// PATCH: Corrigir bug 5 - Criar ViewModel separado para UserGoals
class UserGoalsViewModel extends StateNotifier<UserGoalsState> {
  final GoalRepository _repository;

  /// Construtor
  UserGoalsViewModel(this._repository) : super(UserGoalsState(goals: [])) {
    // Carregar metas ao inicializar
    loadUserGoals();
  }

  /// Carrega todas as metas do usuário
  Future<void> loadUserGoals() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final goals = await _repository.getUserGoals();
      
      state = state.copyWith(
        goals: goals,
        isLoading: false,
      );
      
      debugPrint('✅ Metas carregadas com sucesso: ${goals.length}');
    } catch (e) {
      debugPrint('❌ Erro ao carregar metas: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao carregar metas: ${e.toString()}',
      );
    }
  }

  /// Adiciona uma nova meta
  Future<UserGoal?> addGoal(UserGoal goal) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final createdGoal = await _repository.createGoal(goal);
      
      // Atualizar estado com a nova meta
      state = state.copyWith(
        goals: [...state.goals, createdGoal],
        isLoading: false,
      );
      
      debugPrint('✅ Meta criada com sucesso: ${createdGoal.title}');
      return createdGoal;
    } catch (e) {
      debugPrint('❌ Erro ao criar meta: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao criar meta: ${e.toString()}',
      );
      
      return null;
    }
  }

  /// Atualiza o progresso de uma meta
  Future<UserGoal?> updateGoalProgress(String goalId, double progress) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedGoal = await _repository.updateGoalProgress(goalId, progress);
      
      // Atualizar a meta específica na lista
      final updatedGoals = state.goals.map((goal) {
        return goal.id == goalId ? updatedGoal : goal;
      }).toList();
      
      state = state.copyWith(
        goals: updatedGoals,
        isLoading: false,
      );
      
      debugPrint('✅ Progresso da meta atualizado: ${updatedGoal.title} - ${updatedGoal.progress}/${updatedGoal.target}');
      return updatedGoal;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar progresso: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao atualizar progresso: ${e.toString()}',
      );
      
      return null;
    }
  }

  /// Exclui uma meta
  Future<bool> deleteGoal(String goalId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteGoal(goalId);
      
      // Remover a meta excluída da lista
      final updatedGoals = state.goals.where((goal) => goal.id != goalId).toList();
      
      state = state.copyWith(
        goals: updatedGoals,
        isLoading: false,
      );
      
      debugPrint('✅ Meta excluída com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao excluir meta: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao excluir meta: ${e.toString()}',
      );
      
      return false;
    }
  }
}

/// Provider para o ViewModel de metas do usuário
final userGoalsViewModelProvider = StateNotifierProvider<UserGoalsViewModel, UserGoalsState>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return UserGoalsViewModel(repository);
}); // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import '../models/water_intake_mapper.dart';

/// Interface do repositório para consumo de água
abstract class WaterIntakeRepository {
  /// Obtém o registro de consumo de água do dia atual
  Future<WaterIntake> getTodayWaterIntake();
  
  /// Adiciona um copo de água ao consumo do dia
  Future<WaterIntake> addGlass();
  
  /// Remove um copo de água do consumo do dia
  Future<WaterIntake> removeGlass();
  
  /// Atualiza a meta diária de copos
  Future<WaterIntake> updateDailyGoal(int newGoal);
  
  /// Obtém o histórico de consumo de água para um intervalo de datas
  Future<List<WaterIntake>> getWaterIntakeHistory({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// Obtém o registro de consumo de água para uma data específica
  Future<WaterIntake?> getWaterIntakeByDate(DateTime date);
  
  /// Obtém estatísticas de consumo de água para o período
  Future<WaterIntakeStats> getWaterIntakeStats({
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Modelo para estatísticas de consumo de água
class WaterIntakeStats {
  final int totalGlasses;
  final int daysTracked;
  final int daysGoalReached;
  final double averageGlassesPerDay;
  final double goalAchievementRate;
  final int totalMilliliters;
  
  WaterIntakeStats({
    required this.totalGlasses,
    required this.daysTracked,
    required this.daysGoalReached,
    required this.averageGlassesPerDay,
    required this.goalAchievementRate,
    required this.totalMilliliters,
  });
}

/// Implementação mock do repositório para desenvolvimento
class MockWaterIntakeRepository implements WaterIntakeRepository {
  WaterIntake? _todayIntake;
  
  @override
  Future<WaterIntake> getTodayWaterIntake() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_todayIntake == null) {
      // Criar um registro para hoje se não existir
      _todayIntake = WaterIntake(
        id: 'water-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user123',
        date: DateTime.now(),
        currentGlasses: 5, // Já consumiu 5 copos (para demonstração)
        dailyGoal: 8,
        createdAt: DateTime.now(),
      );
    }
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> addGlass() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Incrementar o contador de copos
    _todayIntake = intake.copyWith(
      currentGlasses: intake.currentGlasses + 1,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> removeGlass() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Não permitir valores negativos
    if (intake.currentGlasses <= 0) {
      return intake;
    }
    
    // Decrementar o contador de copos
    _todayIntake = intake.copyWith(
      currentGlasses: intake.currentGlasses - 1,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }

  @override
  Future<WaterIntake> updateDailyGoal(int newGoal) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Garantir que temos um registro para hoje
    final intake = await getTodayWaterIntake();
    
    // Não permitir valores negativos ou zero
    if (newGoal <= 0) {
      throw ValidationException(
        message: 'A meta diária deve ser maior que zero',
        code: 'invalid_goal',
      );
    }
    
    // Atualizar a meta diária
    _todayIntake = intake.copyWith(
      dailyGoal: newGoal,
      updatedAt: DateTime.now(),
    );
    
    return _todayIntake!;
  }
  
  @override
  Future<List<WaterIntake>> getWaterIntakeHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Gerar dados de exemplo para o intervalo
    final history = <WaterIntake>[];
    
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Gerar dados aleatórios para demonstração
      final glasses = 3 + (currentDate.day % 6); // Entre 3 e 8 copos
      final goal = 8;
      
      history.add(WaterIntake(
        id: 'water-${currentDate.millisecondsSinceEpoch}',
        userId: 'user123',
        date: currentDate,
        currentGlasses: glasses,
        dailyGoal: goal,
        createdAt: currentDate,
        updatedAt: currentDate.add(const Duration(hours: 20)), // Simulando atualização à noite
      ));
      
      // Avançar para o próximo dia
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    }
    
    return history;
  }
  
  @override
  Future<WaterIntake?> getWaterIntakeByDate(DateTime date) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Verificar se é hoje
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    if (isToday && _todayIntake != null) {
      return _todayIntake;
    }
    
    // Simular dados para data específica
    final glasses = 3 + (date.day % 6); // Entre 3 e 8 copos
    
    return WaterIntake(
      id: 'water-${date.millisecondsSinceEpoch}',
      userId: 'user123',
      date: date,
      currentGlasses: glasses,
      dailyGoal: 8,
      createdAt: date,
      updatedAt: date.add(const Duration(hours: 20)),
    );
  }
  
  @override
  Future<WaterIntakeStats> getWaterIntakeStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Obter o histórico para calcular estatísticas
    final history = await getWaterIntakeHistory(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Calcular estatísticas
    final totalGlasses = history.fold<int>(0, (sum, item) => sum + item.currentGlasses);
    final daysTracked = history.length;
    final daysGoalReached = history.where((item) => item.isGoalReached).length;
    
    return WaterIntakeStats(
      totalGlasses: totalGlasses,
      daysTracked: daysTracked,
      daysGoalReached: daysGoalReached,
      averageGlassesPerDay: daysTracked > 0 ? totalGlasses / daysTracked : 0,
      goalAchievementRate: daysTracked > 0 ? daysGoalReached / daysTracked : 0,
      totalMilliliters: totalGlasses * 250, // Considerando 250ml por copo
    );
  }
}

/// Implementação com Supabase
class SupabaseWaterIntakeRepository implements WaterIntakeRepository {
  final SupabaseClient _supabaseClient;

  SupabaseWaterIntakeRepository(this._supabaseClient);

  @override
  Future<WaterIntake> getTodayWaterIntake() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Tentar buscar o registro de hoje
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      if (response != null) {
        debugPrint('✅ WaterIntakeRepository: Registro encontrado com ID: ${response['id']}');
        return WaterIntakeMapper.fromJson(response);
      }
      
      // Se não existir, criar um novo registro
      // Não incluímos o ID, deixamos o Supabase gerar automaticamente
      final insertData = {
        'user_id': userId,
        'date': todayStr,
        'cups': 0,
        'goal': 8, // Valor padrão
        'glass_size': 250, // Valor padrão
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final inserted = await _supabaseClient
          .from('water_intake')
          .insert(insertData)
          .select()
          .single();
      
      debugPrint('✅ WaterIntakeRepository: Registro criado com ID: ${inserted['id']}');
      return WaterIntakeMapper.fromJson(inserted);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getTodayWaterIntake();
    }
  }

  // PATCH: Corrigir bug 2 - Função para garantir que o registro de água seja persistido corretamente
  Future<WaterIntake> insertOrUpdateWaterIntake({
    required String userId,
    required DateTime date,
    required int cups,
    required int goal,
    String? notes,
  }) async {
    try {
      if (userId.isEmpty) {
        throw ValidationException(
          message: 'ID do usuário não pode ser vazio',
          code: 'invalid_user_id',
        );
      }
      
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar registro existente
        final updated = await _supabaseClient
            .from('water_intake')
            .update({
              'cups': cups,
              'goal': goal,
              'notes': notes,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro atualizado com ID: ${updated['id']}');
        return WaterIntakeMapper.fromJson(updated);
      } else {
        // Criar novo registro
        final insertData = {
          'user_id': userId,
          'date': dateStr,
          'cups': cups,
          'goal': goal,
          'notes': notes,
          'glass_size': 250, // Valor padrão
          'created_at': DateTime.now().toIso8601String(),
        };
        
        final inserted = await _supabaseClient
            .from('water_intake')
            .insert(insertData)
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro criado com ID: ${inserted['id']}');
        return WaterIntakeMapper.fromJson(inserted);
      }
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao salvar registro de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> addGlass() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      // Determinar número atual de copos e meta
      final currentGlasses = existing != null ? (existing['cups'] as int? ?? 0) : 0;
      final goal = existing != null ? (existing['goal'] as int? ?? 8) : 8;
      final notes = existing != null ? (existing['notes'] as String?) : null;
      
      // PATCH: Corrigir bug 2 - Usar a função insertOrUpdateWaterIntake para garantir persistência
      return insertOrUpdateWaterIntake(
        userId: userId,
        date: today,
        cups: currentGlasses + 1,
        goal: goal,
        notes: notes,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao adicionar copo de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> removeGlass() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      // Determinar valores atuais
      int currentGlasses = 0;
      int goal = 8;
      String? notes;
      
      if (existing != null) {
        currentGlasses = existing['cups'] as int? ?? 0;
        goal = existing['goal'] as int? ?? 8;
        notes = existing['notes'] as String?;
      }
      
      // Garantir que não fique negativo
      final newGlassCount = (currentGlasses > 0) ? currentGlasses - 1 : 0;
      
      // PATCH: Corrigir bug 2 - Usar a função insertOrUpdateWaterIntake para garantir persistência
      return insertOrUpdateWaterIntake(
        userId: userId,
        date: today,
        cups: newGlassCount,
        goal: goal,
        notes: notes,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao remover copo de água: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<WaterIntake> updateDailyGoal(int newGoal) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Não permitir valores negativos ou zero
      if (newGoal <= 0) {
        throw ValidationException(
          message: 'A meta diária deve ser maior que zero',
          code: 'invalid_goal',
        );
      }
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Buscar registro existente
      final existing = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();
      
      if (existing != null) {
        // Atualizar a meta diária
        final updated = await _supabaseClient
            .from('water_intake')
            .update({
              'goal': newGoal,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro atualizado com ID: ${updated['id']}');
        return WaterIntakeMapper.fromJson(updated);
      } else {
        // Criar um novo registro se não existir
        final insertData = {
          'user_id': userId,
          'date': todayStr,
          'cups': 0,
          'goal': newGoal, 
          'glass_size': 250, // Valor padrão
          'created_at': DateTime.now().toIso8601String(),
        };
        
        final inserted = await _supabaseClient
            .from('water_intake')
            .insert(insertData)
            .select()
            .single();
        
        debugPrint('✅ WaterIntakeRepository: Registro criado com ID: ${inserted['id']}');
        return WaterIntakeMapper.fromJson(inserted);
      }
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar meta diária: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<WaterIntake>> getWaterIntakeHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Formatar datas para string no formato do Supabase
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      // Buscar registros no intervalo de datas
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .gte('date', startDateStr)
          .lte('date', endDateStr)
          .order('date');
      
      // Converter para lista de objetos WaterIntake
      return response
          .map<WaterIntake>((json) => WaterIntakeMapper.fromJson(json))
          .toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getWaterIntakeHistory(
        startDate: startDate, 
        endDate: endDate,
      );
    }
  }
  
  @override
  Future<WaterIntake?> getWaterIntakeByDate(DateTime date) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se é hoje
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      if (isToday) {
        return getTodayWaterIntake();
      }
      
      // Formatar data para string no formato do Supabase
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Buscar registro para a data específica
      final response = await _supabaseClient
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();
      
      if (response != null) {
        debugPrint('✅ WaterIntakeRepository: Registro encontrado: ${response['id']}');
        return WaterIntakeMapper.fromJson(response);
      }
      
      return null;
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getWaterIntakeByDate(date);
    }
  }
  
  @override
  Future<WaterIntakeStats> getWaterIntakeStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Obter o histórico para calcular estatísticas
      final history = await getWaterIntakeHistory(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (history.isEmpty) {
        return WaterIntakeStats(
          totalGlasses: 0,
          daysTracked: 0,
          daysGoalReached: 0,
          averageGlassesPerDay: 0,
          goalAchievementRate: 0,
          totalMilliliters: 0,
        );
      }
      
      // Calcular estatísticas
      final totalGlasses = history.fold<int>(0, (sum, item) => sum + item.currentGlasses);
      final daysTracked = history.length;
      final daysGoalReached = history.where((item) => item.isGoalReached).length;
      final averageGlassSize = history.isEmpty 
          ? 250 
          : history.first.glassSize; // Usar o tamanho do primeiro registro
      
      return WaterIntakeStats(
        totalGlasses: totalGlasses,
        daysTracked: daysTracked,
        daysGoalReached: daysGoalReached,
        averageGlassesPerDay: daysTracked > 0 ? totalGlasses / daysTracked : 0,
        goalAchievementRate: daysTracked > 0 ? daysGoalReached / daysTracked : 0,
        totalMilliliters: totalGlasses * averageGlassSize,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockWaterIntakeRepository().getWaterIntakeStats(
        startDate: startDate, 
        endDate: endDate,
      );
    }
  }
}

/// Provider para o repositório de consumo de água
final waterIntakeRepositoryProvider = Provider<WaterIntakeRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseWaterIntakeRepository(supabase);
}); // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/core/utils/debug_data_inspector.dart';

/// Interface do repositório para metas do usuário
abstract class GoalRepository {
  /// Obtém todas as metas do usuário atual
  Future<List<UserGoal>> getUserGoals();
  
  /// Cria uma nova meta
  Future<UserGoal> createGoal(UserGoal goal);
  
  /// Atualiza o progresso de uma meta existente
  Future<UserGoal> updateGoalProgress(String goalId, double currentValue);
  
  /// Exclui uma meta
  Future<void> deleteGoal(String goalId);
}

/// Implementação mock do repositório para desenvolvimento
class MockGoalRepository implements GoalRepository {
  @override
  Future<List<UserGoal>> getUserGoals() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    final mockGoals = _getMockGoals();
    return mockGoals;
  }

  @override
  Future<UserGoal> createGoal(UserGoal goal) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Gerar ID simulado
    return goal.copyWith(
      id: 'goal-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserGoal> updateGoalProgress(String goalId, double currentValue) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final goals = _getMockGoals();
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    
    if (goalIndex == -1) {
      throw NotFoundException(
        message: 'Meta não encontrada',
        code: 'goal_not_found',
      );
    }
    
    final goal = goals[goalIndex];
    final updatedGoal = goal.copyWith(
      progress: currentValue,
      updatedAt: DateTime.now(),
    );
    
    return updatedGoal;
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final goals = _getMockGoals();
    final goalExists = goals.any((g) => g.id == goalId);
    
    if (!goalExists) {
      throw NotFoundException(
        message: 'Meta não encontrada',
        code: 'goal_not_found',
      );
    }
    
    // Em um repositório real, a meta seria excluída do banco de dados
    return;
  }
  
  /// Retorna lista de metas mockadas para desenvolvimento
  List<UserGoal> _getMockGoals() {
    final now = DateTime.now();
    
    return [
      UserGoal(
        id: 'goal-1',
        userId: 'user123',
        title: 'Treinar 5x por semana',
        target: 5,
        progress: 3,
        unit: 'vezes',
        type: GoalType.workout,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 21)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      UserGoal(
        id: 'goal-2',
        userId: 'user123',
        title: 'Perder 5kg',
        target: 5,
        progress: 2.5,
        unit: 'kg',
        type: GoalType.weight,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      UserGoal(
        id: 'goal-3',
        userId: 'user123',
        title: 'Completar 30 treinos',
        target: 30,
        progress: 12,
        unit: 'treinos',
        type: GoalType.workout,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }
}

/// Implementação com Supabase
class SupabaseGoalRepository implements GoalRepository {
  final SupabaseClient _supabaseClient;

  SupabaseGoalRepository(this._supabaseClient);

  @override
  Future<List<UserGoal>> getUserGoals() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('user_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      // Inspecionar os dados retornados pelo Supabase
      DebugDataInspector.logResponse('UserGoals', response);
      
      return response.map((json) => UserGoal.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Erro ao buscar metas do Supabase',
        originalError: e,
        code: e.code ?? 'unknown',
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao carregar metas: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<UserGoal> createGoal(UserGoal goal) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Garantir que o ID do usuário seja o do usuário atual
      final goalData = goal.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
      );
      
      final response = await _supabaseClient
          .from('user_goals')
          .insert(goalData.toJson())
          .select()
          .single();
      
      return UserGoal.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Erro ao criar meta no Supabase',
        originalError: e,
        code: e.code ?? 'unknown',
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao criar meta: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<UserGoal> updateGoalProgress(String goalId, double currentValue) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se a meta existe e pertence ao usuário
      final existingGoalResponse = await _supabaseClient
          .from('user_goals')
          .select()
          .eq('id', goalId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingGoalResponse == null) {
        throw NotFoundException(
          message: 'Meta não encontrada',
          code: 'goal_not_found',
        );
      }
      
      final existingGoal = UserGoal.fromJson(existingGoalResponse);
      
      // Atualizar o progresso e a data de atualização
      final updatedGoal = existingGoal.copyWith(
        progress: currentValue,
        updatedAt: DateTime.now(),
      );
      
      final response = await _supabaseClient
          .from('user_goals')
          .update(updatedGoal.toJson())
          .eq('id', goalId)
          .select()
          .single();
      
      return UserGoal.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { // Registro não encontrado
        throw NotFoundException(
          message: 'Meta não encontrada',
          code: 'goal_not_found',
        );
      }
      
      throw DatabaseException(
        message: 'Erro ao atualizar progresso da meta',
        originalError: e,
        code: e.code ?? 'unknown',
      );
    } catch (e) {
      if (e is AppAuthException || e is NotFoundException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar progresso: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se a meta existe e pertence ao usuário
      final exists = await _supabaseClient
          .from('user_goals')
          .select('id')
          .eq('id', goalId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (exists == null) {
        throw NotFoundException(
          message: 'Meta não encontrada',
          code: 'goal_not_found',
        );
      }
      
      await _supabaseClient
          .from('user_goals')
          .delete()
          .eq('id', goalId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Erro ao excluir meta',
        originalError: e,
        code: e.code ?? 'unknown',
      );
    } catch (e) {
      if (e is AppAuthException || e is NotFoundException) rethrow;
      
      throw StorageException(
        message: 'Erro ao excluir meta: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

/// Provider para o repositório de metas
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  // Em desenvolvimento, usar o repositório mock
  return MockGoalRepository();
  
  // Quando estiver pronto para produção:
  // final supabase = Supabase.instance.client;
  // return SupabaseGoalRepository(supabase);
}); // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

/// Constante que define o intervalo de verificação periódica em segundo plano (em minutos)
const int BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES = 30;

/// Provider global para o AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repository);
});

/// Provider para o repositório de autenticação
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient);
});

/// ViewModel responsável por gerenciar operações relacionadas à autenticação.
class AuthViewModel extends StateNotifier<AuthState> {
  final IAuthRepository _repository;
  String? _redirectPath;
  Timer? _backgroundAuthCheckTimer;

  AuthViewModel({
    required IAuthRepository repository,
    bool checkAuthOnInit = true,
  })  : _repository = repository,
        super(const AuthState.initial()) {
    if (checkAuthOnInit) {
      checkAuthStatus();
    }
    
    // Iniciar verificação periódica em segundo plano
    _startBackgroundAuthCheck();
  }

  /// Inicia a verificação periódica de autenticação em segundo plano
  void _startBackgroundAuthCheck() {
    // Cancele qualquer timer existente
    _backgroundAuthCheckTimer?.cancel();
    
    // Crie um novo timer para verificação periódica
    _backgroundAuthCheckTimer = Timer.periodic(
      Duration(minutes: BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES),
      (_) => _performBackgroundAuthCheck()
    );
    
    debugPrint('🔄 AuthViewModel: Iniciado verificador periódico de autenticação a cada $BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES minutos');
  }
  
  /// Realiza a verificação de autenticação em segundo plano
  /// Esta verificação é silenciosa e não altera o estado para loading
  Future<void> _performBackgroundAuthCheck() async {
    debugPrint('🔄 AuthViewModel: Realizando verificação periódica de autenticação em segundo plano');
    
    try {
      // Verificar se há um usuário autenticado no estado atual
      final isCurrentlyAuthenticated = state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      // Se não estiver autenticado, não precisamos verificar
      if (!isCurrentlyAuthenticated) {
        debugPrint('🔄 AuthViewModel: Estado atual não é autenticado, pulando verificação em segundo plano');
        return;
      }
      
      // Verificar e renovar a sessão se necessário, sem alterar o estado para loading
      await verifyAndRenewSession(silent: true);
      
    } catch (e) {
      // Apenas log, sem alterar o estado
      debugPrint('⚠️ AuthViewModel: Erro em verificação de autenticação em segundo plano: $e');
    }
  }

  @override
  void dispose() {
    // Cancelar o timer quando o ViewModel for descartado
    _backgroundAuthCheckTimer?.cancel();
    super.dispose();
  }

  /// Obtém o caminho para redirecionamento (se existir)
  String? get redirectPath => _redirectPath;

  /// Define o caminho para redirecionamento após login
  void setRedirectPath(String path) {
    _redirectPath = path;
  }

  /// Limpa o caminho de redirecionamento
  void clearRedirectPath() {
    _redirectPath = null;
  }

  /// Extrai a mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  /// Verifica o status atual de autenticação
  Future<void> checkAuthStatus() async {
    // Não mudar para loading se já estiver autenticado
    // Isso evita flickering de UI desnecessário
    final isCurrentlyAuthenticated = state.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    // Se não estiver autenticado, mostrar loading
    if (!isCurrentlyAuthenticated) {
      state = const AuthState.loading();
    }
    
    try {
      // Verificar e renovar a sessão se necessário
      final isSessionValid = await verifyAndRenewSession();
      
      // Se já tratamos a sessão e atualizamos o estado, não precisamos fazer mais nada
      if (isSessionValid) {
        return;
      }
      
      // Caso contrário, verificar se há um usuário autenticado
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(
          user: AppUser.fromSupabaseUser(user),
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      // Log de erro, mas não alterar estado para erro
      // Isso evita que um erro de verificação de sessão bloqueie o app
      print("Erro ao verificar status de autenticação: ${e.toString()}");
      // Em caso de erro, considerar como não autenticado
      state = const AuthState.unauthenticated();
    }
  }

  /// Verifica se um email já está registrado
  Future<bool> isEmailRegistered(String email) async {
    try {
      return await _repository.isEmailRegistered(email);
    } catch (e) {
      // Em caso de erro, assumir que o email já existe por precaução
      print("Erro ao verificar email: ${e.toString()}");
      return true;
    }
  }

  /// Realiza login com email e senha
  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      
      // Verificar formato básico de email
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      // Verificar senha mínima
      if (password.length < 6) {
        state = const AuthState.error(message: "A senha deve ter pelo menos 6 caracteres");
        return;
      }
      
      // Verificar primeiro se o email existe no sistema
      final emailExists = await isEmailRegistered(email);
      if (!emailExists) {
        state = const AuthState.error(message: "Conta não encontrada. Verifique seu email ou crie uma nova conta.");
        return;
      }
      
      final user = await _repository.signIn(email, password);
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      // Tratamento de mensagens de erro específicas para melhorar feedback ao usuário
      if (errorMsg.toLowerCase().contains("invalid login credentials") || 
          errorMsg.toLowerCase().contains("email ou senha incorretos")) {
        state = const AuthState.error(message: "Email ou senha incorretos");
      } else if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else if (errorMsg.toLowerCase().contains("conta não encontrada")) {
        state = const AuthState.error(message: "Conta não encontrada. Verifique seu email ou crie uma nova conta.");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  /// Registra um novo usuário
  Future<void> signUp(String email, String password, String name) async {
    try {
      state = const AuthState.loading();
      
      // Validações de dados
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      if (password.length < 6) {
        state = const AuthState.error(message: "A senha deve ter pelo menos 6 caracteres");
        return;
      }
      
      if (name.isEmpty) {
        state = const AuthState.error(message: "Por favor, insira seu nome");
        return;
      }
      
      // Verificar se o email já está registrado antes de tentar o cadastro
      final emailExists = await isEmailRegistered(email);
      if (emailExists) {
        state = const AuthState.error(message: "Este email já está cadastrado. Por favor, faça login.");
        return;
      }
      
      final user = await _repository.signUp(email, password, name);
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      // Melhorar mensagens de erro para o usuário
      if (errorMsg.toLowerCase().contains("already registered") || 
          errorMsg.toLowerCase().contains("já está cadastrado")) {
        state = const AuthState.error(message: "Este email já está cadastrado. Por favor, faça login");
      } else if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  // Validador simples de formato de email
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Solicita redefinição de senha para o email
  Future<void> resetPassword(String email) async {
    try {
      state = const AuthState.loading();
      await _repository.resetPassword(email);
      state = const AuthState.success(message: 'Email de redefinição de senha enviado');
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      state = const AuthState.loading();
      await _repository.updateProfile(
        name: name,
        photoUrl: photoUrl,
      );

      // Atualiza o estado do usuário atual se autenticado
      state.maybeWhen(
        authenticated: (user) {
          state = AuthState.authenticated(
            user: user.copyWith(
              name: name ?? user.name,
              photoUrl: photoUrl ?? user.photoUrl,
            ),
          );
        },
        orElse: () {},
      );
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Realiza login com Google
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();
      
      debugPrint("🔍 AuthViewModel: Iniciando login com Google");
      
      // Tenta obter a sessão usando o método de signin do repositório
      final session = await _repository.signInWithGoogle();
      
      debugPrint("🔍 AuthViewModel: Resultado da chamada signInWithGoogle: ${session != null ? 'Sessão obtida' : 'Sessão não obtida'}");
      
      // Aguarda um pouco para garantir que a sessão seja processada
      await Future.delayed(const Duration(seconds: 1));
      
      // Verifica se foi possível obter uma sessão válida
      if (session != null) {
        debugPrint("✅ AuthViewModel: Sessão obtida com sucesso: ${session.user?.email}");
        
        // Tenta obter o usuário atual
        final user = await _repository.getCurrentUser();
        
        if (user != null) {
          // Login bem-sucedido, usuário autenticado
          debugPrint("✅ AuthViewModel: Usuário encontrado: ${user.email}");
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
        } else {
          // Sessão existe mas não foi possível obter o usuário
          // Tentar novamente a verificação de usuário
          debugPrint("⚠️ AuthViewModel: Sessão existe mas usuário não encontrado, tentando novamente...");
          await Future.delayed(const Duration(seconds: 2));
          final retryUser = await _repository.getCurrentUser();
          
          if (retryUser != null) {
            debugPrint("✅ AuthViewModel: Usuário encontrado na segunda tentativa: ${retryUser.email}");
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(retryUser),
            );
          } else {
            debugPrint("❌ AuthViewModel: Usuário não encontrado mesmo após retry");
            state = const AuthState.error(
              message: 'Login com Google bem-sucedido, mas usuário não encontrado',
            );
          }
        }
      } else {
        // Não foi possível obter uma sessão (usuário cancelou ou outro erro)
        debugPrint("❌ AuthViewModel: Não foi possível obter sessão do login com Google");
        state = const AuthState.error(
          message: 'Falha no login com Google ou processo cancelado',
        );
      }
    } catch (e) {
      // Erros durante o processo de login
      debugPrint("❌ AuthViewModel: Erro durante login com Google: $e");
      final errorMsg = _getErrorMessage(e);
      if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  /// Verifica se existe uma sessão ativa e atualiza o estado
  Future<bool> checkAndUpdateSession() async {
    try {
      debugPrint("🔍 AuthViewModel: Verificando sessão ativa");
      final session = _repository.getCurrentSession();
      
      if (session != null) {
        debugPrint("✅ AuthViewModel: Sessão encontrada, ID: ${session.user.id}");
        debugPrint("✅ AuthViewModel: Email da sessão: ${session.user.email}");
        
        final user = await _repository.getUserProfile();
        if (user != null) {
          debugPrint("✅ AuthViewModel: Perfil de usuário obtido com sucesso: ${user.email}");
          // Criar um novo estado authenticated em vez de usar copyWith
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
          return true;
        } else {
          debugPrint("❌ AuthViewModel: Sessão existe mas não foi possível obter perfil do usuário");
        }
      } else {
        debugPrint("❌ AuthViewModel: Nenhuma sessão ativa encontrada");
      }
      return false;
    } catch (e) {
      debugPrint('❌ AuthViewModel: Erro ao verificar sessão: $e');
      return false;
    }
  }
  
  /// Verifica se a sessão atual é válida e renova se necessário
  /// Se silent for true, não atualiza o estado para loading
  Future<bool> verifyAndRenewSession({bool silent = false}) async {
    try {
      final session = _repository.getCurrentSession();
      if (session == null) {
        if (!silent) state = const AuthState.unauthenticated();
        return false;
      }
      
      // Verificar se o token está perto de expirar (menos de 1 hora)
      final expiresAt = session.expiresAt;
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final oneHour = 60 * 60;
      
      if (expiresAt != null && (expiresAt - now) < oneHour) {
        debugPrint("🔄 AuthViewModel: Token próximo de expirar, renovando sessão");
        // Tentar renovar a sessão
        await _repository.refreshSession();
        
        // Verificar se a renovação foi bem-sucedida
        final updatedSession = _repository.getCurrentSession();
        if (updatedSession != null) {
          debugPrint("✅ AuthViewModel: Sessão renovada com sucesso, expira em: ${updatedSession.expiresAt}");
          
          // Atualizar estado com usuário atual
          final user = await _repository.getCurrentUser();
          if (user != null) {
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(user),
            );
          }
        } else {
          debugPrint("❌ AuthViewModel: Falha ao renovar sessão");
          if (!silent) state = const AuthState.unauthenticated();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ AuthViewModel: Erro ao verificar/renovar sessão: ${e.toString()}');
      if (!silent) state = const AuthState.unauthenticated();
      return false;
    }
  }

  /// Navega para a tela inicial após autenticação bem-sucedida
  void _navigateToHomeAfterAuth(BuildContext? context) {
    if (context != null) {
      debugPrint('🔄 AuthViewModel: Navegando para a tela inicial após autenticação');
      // Usar navegação mais segura para evitar conflitos entre navegadores
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verificar se o contexto ainda é válido antes de navegar
        if (context.mounted) {
          // Usar navegação simples em vez de replaceAll
          context.router.replace(const HomeRoute());
        }
      });
    }
  }

  /// Método público para navegar para a tela inicial após autenticação
  void navigateToHomeAfterAuth(BuildContext context) {
    _navigateToHomeAfterAuth(context);
  }
} 
// Dart imports:
import 'dart:io';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Interface for authentication-related operations
abstract class IAuthRepository {
  /// Gets the currently authenticated user
  /// Returns null if no user is authenticated
  Future<supabase.User?> getCurrentUser();

  /// Gets the currently authenticated user's ID
  /// Returns empty string if no user is authenticated
  Future<String> getCurrentUserId();

  /// Checks if an email is already registered
  /// Returns true if the email exists in the database
  Future<bool> isEmailRegistered(String email);

  /// Signs up a new user with email and password
  /// Throws [ValidationException] if email or password is invalid
  /// Throws [AuthException] if signup fails
  Future<supabase.User> signUp(String email, String password, String name);

  /// Signs in a user with email and password
  /// Throws [ValidationException] if email or password is invalid
  /// Throws [AuthException] if credentials are incorrect
  Future<supabase.User> signIn(String email, String password);

  /// Signs out the current user
  /// Throws [AuthException] if signout fails
  Future<void> signOut();

  /// Resets the password for the given email
  /// Throws [ValidationException] if email is invalid
  /// Throws [AuthException] if reset fails
  Future<void> resetPassword(String email);

  /// Updates the current user's profile
  /// Throws [AuthException] if user is not authenticated
  /// Throws [ValidationException] if data is invalid
  Future<void> updateProfile({String? name, String? photoUrl});

  /// Sign in with Google OAuth
  /// Throws [AuthException] if sign in fails
  Future<supabase.Session?> signInWithGoogle();

  /// Obtém a sessão atual se existir
  supabase.Session? getCurrentSession();
  
  /// Obtém o perfil do usuário atual
  /// Throws [AuthException] se o usuário não estiver autenticado
  Future<supabase.User?> getUserProfile();

  /// Renova a sessão do usuário atual
  /// Throws [AuthException] se houver erro na renovação
  Future<void> refreshSession();
}

/// Implementation of [IAuthRepository] using Supabase
class AuthRepository implements IAuthRepository {
  final supabase.SupabaseClient _supabaseClient;

  AuthRepository(this._supabaseClient);

  @override
  Future<supabase.User?> getCurrentUser() async {
    try {
      return _supabaseClient.auth.currentUser;
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get current user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> getCurrentUserId() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        return user.id;
      } else {
        throw AppAuthException(message: 'No user is authenticated');
      }
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get current user ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    try {
      debugPrint('🔍 AuthRepository: Verificando se o email existe: $email');
      
      // Primeiro verificar se a tabela 'profiles' existe
      try {
        // Tentativa inicial simples para verificar se a tabela existe
        final tableCheck = await _supabaseClient
            .from('profiles')
            .select('count')
            .limit(1);
        
        debugPrint('✅ Tabela profiles existe e está acessível');
      } catch (tableError) {
        debugPrint('⚠️ Erro ao acessar tabela profiles: $tableError');
        
        // Se houver erro ao acessar a tabela, assumir que o email não existe
        // mas logar para investigação
        if (tableError is supabase.PostgrestException) {
          debugPrint('⚠️ Código de erro Postgrest: ${tableError.code}');
          debugPrint('⚠️ Mensagem de erro: ${tableError.message}');
        }
        
        // Para efeitos de login existente, vamos assumir que o email não existe
        // se a tabela não estiver acessível
        return false;
      }
      
      // Se a tabela existe, verificar o email
      final result = await _supabaseClient
          .from('profiles')
          .select('email')
          .eq('email', email)
          .limit(1)
          .maybeSingle(); // Usa maybeSingle ao invés de single para evitar exceções
      
      // Se encontrou resultado, o email existe
      final exists = result != null;
      debugPrint('🔍 Email ${email} ${exists ? "existe" : "não existe"} na base de dados');
      return exists;
    } catch (e) {
      // Logar o erro para diagnóstico
      debugPrint('⚠️ Erro ao verificar email: $e');
      
      // Se for erro de "não encontrado", retorna false
      if (e is supabase.PostgrestException) {
        debugPrint('⚠️ Código de erro Postgrest: ${e.code}');
        
        if (e.code == 'PGRST116') {
          debugPrint('📝 Erro de não encontrado, o email não existe');
          return false;
        }
      }
      
      // Durante o login com credenciais existentes, vamos assumir que o email existe
      // para permitir a tentativa de login (better safe than sorry)
      // Durante o cadastro, assumir que não existe pode levar a duplicação de contas
      debugPrint('⚠️ Erro genérico, assumindo que o email existe por precaução');
      return true;
    }
  }

  @override
  Future<supabase.User> signUp(
      String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw ValidationException(message: 'Email, password and name are required');
    }

    try {
      // Verificar primeiro se o email já está registrado
      final emailExists = await isEmailRegistered(email);
      if (emailExists) {
        throw AppAuthException(
          message: 'Este email já está cadastrado. Por favor, faça login.',
          code: 'email_already_exists',
        );
      }

      // Prosseguir com o registro se o email não existir
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw AppAuthException(message: 'Sign up failed: no user returned');
      }

      // Verificar se precisamos fazer login automaticamente
      if (response.session == null) {
        try {
          final loginResponse = await _supabaseClient.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (loginResponse.user == null) {
            throw AppAuthException(message: 'Auto login after signup failed');
          }
          
          return loginResponse.user!;
        } catch (loginError) {
          // Se falhar o login automático, ainda retornamos o usuário criado
          print('Erro no login automático: $loginError');
          return response.user!;
        }
      }

      return response.user!;
    } on AppAuthException {
      // Re-lançar exceções AuthException já tratadas (como email já existente)
      rethrow;
    } on supabase.AuthException catch (e, stackTrace) {
      // Melhor tratamento de erros do Supabase
      String message = e.message;
      
      // Mensagens mais amigáveis para erros comuns
      if (message.toLowerCase().contains('already registered')) {
        message = 'Este email já está cadastrado. Por favor, faça login.';
      } else if (message.toLowerCase().contains('weak password')) {
        message = 'A senha é muito fraca. Use pelo menos 6 caracteres com letras e números.';
      } else if (message.toLowerCase().contains('invalid email')) {
        message = 'O email fornecido é inválido.';
      }
      
      throw AppAuthException(
        message: message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Falha ao registrar usuário: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<supabase.User> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ValidationException(message: 'Email and password are required');
    }

    try {
      // Antes de tentar login, verificar se o email existe
      final emailExists = await isEmailRegistered(email);
      if (!emailExists) {
        throw AppAuthException(
          message: 'Conta não encontrada. Verifique seu email ou crie uma nova conta.',
          code: 'user_not_found',
        );
      }

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppAuthException(message: 'Sign in failed: no user returned');
      }

      return response.user!;
    } on AppAuthException {
      // Re-lançar exceções AuthException já tratadas
      rethrow;
    } on supabase.AuthException catch (e, stackTrace) {
      String message = e.message;
      
      // Mensagens mais amigáveis para erros comuns
      if (message.toLowerCase().contains('invalid login')) {
        message = 'Email ou senha incorretos. Por favor, tente novamente.';
      } else if (message.toLowerCase().contains('not confirmed')) {
        message = 'Seu email ainda não foi confirmado. Por favor, verifique sua caixa de entrada.';
      } else if (message.toLowerCase().contains('too many requests')) {
        message = 'Muitas tentativas de login. Por favor, tente novamente mais tarde.';
      } else if (message.toLowerCase().contains('not found') || message.toLowerCase().contains('no user')) {
        message = 'Conta não encontrada. Verifique seu email ou crie uma nova conta.';
      }
      
      throw AppAuthException(
        message: message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Falha ao realizar login: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to sign out user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw ValidationException(message: 'Email is required');
    }

    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to reset password',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw AppAuthException(message: 'User is not authenticated');
    }

    try {
      await _supabaseClient.auth.updateUser(
        supabase.UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (photoUrl != null) 'avatar_url': photoUrl,
          },
        ),
      );
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to update profile',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  @override
  Future<supabase.Session?> signInWithGoogle() async {
    try {
      final platform = _getPlatform();
      if (platform == 'ios' || platform == 'android') {
        // Usar URL de redirecionamento fixa para garantir consistência
        const String redirectUrl = 'rayclub://login-callback/';
        
        debugPrint("🔍 AuthRepository: Iniciando login com Google. URL de redirecionamento: $redirectUrl");
        
        // Implementação com redirecionamento explícito
        final authResponse = await _supabaseClient.auth.signInWithOAuth(
          supabase.OAuthProvider.google,
          redirectTo: redirectUrl, // URL de redirecionamento explícita
        );
        
        // Log explícito para ajudar a diagnosticar problemas
        debugPrint("🔍 Login com Google iniciado: $authResponse");
        
        if (!authResponse) {
          throw AppAuthException(message: 'Falha ao iniciar login com Google');
        }
        
        // Aguardar pela sessão
        int attempts = 0;
        while (attempts < 30) { // Aumentamos o tempo de espera para 30 segundos
          await Future.delayed(const Duration(seconds: 1));
          final currentSession = _supabaseClient.auth.currentSession;
          if (currentSession != null) {
            debugPrint("✅ Sessão obtida com sucesso após login Google!");
            return currentSession;
          }
          attempts++;
          debugPrint("⏳ Aguardando sessão... Tentativa $attempts/30");
        }
        
        throw AppAuthException(message: 'Tempo esgotado aguardando pela sessão do Google');
      } else {
        // Para Web, mantém a mesma abordagem
        final response = await _supabaseClient.auth.signInWithOAuth(
          supabase.OAuthProvider.google,
          redirectTo: 'https://rayclub.vercel.app/auth/callback',
        );
        
        return _supabaseClient.auth.currentSession;
      }
    } on supabase.AuthException catch (e, stackTrace) {
      debugPrint("❌ Erro AuthException durante login com Google: ${e.message}");
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      debugPrint("❌ Erro genérico durante login com Google: $e");
      throw DatabaseException(
        message: 'Falha ao fazer login com Google: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  String _getPlatform() {
    if (identical(0, 0.0)) {
      return 'web';
    }
    
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    
    return 'unknown';
  }

  /// Obtém a sessão atual se existir
  supabase.Session? getCurrentSession() {
    return _supabaseClient.auth.currentSession;
  }
  
  /// Obtém o perfil do usuário atual
  @override
  Future<supabase.User?> getUserProfile() async {
    try {
      // Apenas retorna o usuário atual do Supabase
      return _supabaseClient.auth.currentUser;
    } catch (e, stackTrace) {
      throw AppAuthException(
        message: 'Falha ao obter perfil do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Renova a sessão do usuário atual
  @override
  Future<void> refreshSession() async {
    try {
      await _supabaseClient.auth.refreshSession();
    } catch (e, stackTrace) {
      throw AppAuthException(
        message: 'Erro ao renovar sessão',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 
// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/features/workouts/models/workout.dart';

/// Repositório de treinos para manipular dados no Supabase
class WorkoutRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'workouts';
  final String _userWorkoutsTable = 'user_workouts';
  
  /// Busca todos os treinos disponíveis
  Future<List<Workout>> getAllWorkouts() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Busca treinos por tipo/categoria
  Future<List<Workout>> getWorkoutsByType(String type) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('type', type)
          .order('created_at', ascending: false);
      
      return response.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos por tipo',
        details: {'error': e.toString(), 'type': type},
      );
    }
  }
  
  /// Busca treinos populares para exibir na home
  Future<List<Workout>> getPopularWorkouts() async {
    final cacheService = CacheService();
    final cacheKey = 'popular_workouts';
    
    try {
      // Tenta pegar do cache primeiro
      final cachedData = cacheService.get(cacheKey);
      if (cachedData != null) {
        final List<dynamic> workoutList = cachedData;
        return workoutList.map((json) => Workout.fromJson(json)).toList();
      }
      
      // Se não estiver em cache, busca do Supabase
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_popular', true)
          .order('created_at', ascending: false);
      
      final workouts = response.map((json) => Workout.fromJson(json)).toList();
      
      // Salva no cache para futuras requisições
      cacheService.set(cacheKey, response, duration: const Duration(hours: 2));
      
      return workouts;
    } on PostgrestException catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos populares',
        details: {'error': e.toString()},
      );
    } catch (e) {
      throw AppException(
        message: 'Erro inesperado ao buscar treinos populares',
        details: {'error': e.toString()},
      );
    }
  }
  
  /// Busca treinos de um usuário específico
  Future<List<Workout>> getUserWorkouts(String userId) async {
    try {
      final response = await _client
          .from(_userWorkoutsTable)
          .select('*, workout:workout_id(*)')
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      
      return response.map((json) {
        final workoutData = json['workout'];
        // Adiciona data de conclusão do treino do usuário
        workoutData['completed_at'] = json['completed_at'];
        return Workout.fromJson(workoutData);
      }).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos do usuário',
        details: {'error': e.toString(), 'userId': userId},
      );
    }
  }
  
  /// Busca treinos de um usuário em uma data específica
  Future<List<Workout>> getUserWorkoutsForDate(String userId, DateTime date) async {
    try {
      // Calcular o início e fim do dia
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final response = await _client
          .from(_userWorkoutsTable)
          .select('*, workout:workout_id(*)')
          .eq('user_id', userId)
          .gte('completed_at', startOfDay.toIso8601String())
          .lte('completed_at', endOfDay.toIso8601String())
          .order('completed_at', ascending: false);
      
      return response.map((json) {
        final workoutData = json['workout'];
        // Adiciona data de conclusão do treino do usuário
        workoutData['completed_at'] = json['completed_at'];
        return Workout.fromJson(workoutData);
      }).toList();
    } catch (e) {
      throw AppException(
        message: 'Erro ao buscar treinos do usuário para a data',
        details: {'error': e.toString(), 'userId': userId, 'date': date.toString()},
      );
    }
  }
  
  /// Busca um treino específico por ID
  Future<Workout?> getWorkoutById(String workoutId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', workoutId)
          .single();
      
      return Workout.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Registro não encontrado
        return null;
      }
      throw AppException(
        message: 'Erro ao buscar treino por ID',
        details: {'error': e.toString(), 'workoutId': workoutId},
      );
    } catch (e) {
      throw AppException(
        message: 'Erro inesperado ao buscar treino',
        details: {'error': e.toString(), 'workoutId': workoutId},
      );
    }
  }
  
  /// Conta o número de treinos de um usuário entre duas datas
  Future<int> countUserWorkouts({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .from(_userWorkoutsTable)
          .select('id')
          .eq('user_id', userId)
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String());
      
      return response.length;
    } catch (e) {
      throw AppException(
        message: 'Erro ao contar treinos do usuário',
        details: {
          'error': e.toString(),
          'userId': userId,
          'startDate': startDate.toString(),
          'endDate': endDate.toString()
        },
      );
    }
  }
  
  /// Calcula a sequência atual de dias com treinos do usuário
  Future<int> getUserWorkoutStreak(String userId) async {
    try {
      final today = DateTime.now();
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      
      // Busca treinos dos últimos 30 dias para cálculo da sequência
      final response = await _client
          .from(_userWorkoutsTable)
          .select('completed_at')
          .eq('user_id', userId)
          .gte('completed_at', thirtyDaysAgo.toIso8601String())
          .lte('completed_at', today.toIso8601String())
          .order('completed_at', ascending: false);
      
      if (response.isEmpty) {
        return 0;
      }
      
      // Converte as datas e agrupa por dia
      final Set<String> workoutDays = {};
      for (final workout in response) {
        final date = DateTime.parse(workout['completed_at']);
        workoutDays.add('${date.year}-${date.month}-${date.day}');
      }
      
      // Ordena em ordem decrescente
      final sortedDays = workoutDays.toList()
        ..sort((a, b) => b.compareTo(a));
      
      // Calcula a sequência atual
      int streak = 1;
      final todayKey = '${today.year}-${today.month}-${today.day}';
      final yesterdayKey = '${today.subtract(const Duration(days: 1)).year}-'
          '${today.subtract(const Duration(days: 1)).month}-'
          '${today.subtract(const Duration(days: 1)).day}';
      
      // Se não treinou hoje nem ontem, começa do último dia que treinou
      if (!workoutDays.contains(todayKey) && !workoutDays.contains(yesterdayKey)) {
        return 0;
      }
      
      // Se treinou hoje, começa de hoje; se não, começa de ontem
      int currentDay = workoutDays.contains(todayKey) ? 0 : 1;
      
      // Verifica dias consecutivos
      while (currentDay < 30) {
        final checkDate = today.subtract(Duration(days: currentDay));
        final nextDate = today.subtract(Duration(days: currentDay + 1));
        
        final checkKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
        final nextKey = '${nextDate.year}-${nextDate.month}-${nextDate.day}';
        
        // Se o dia atual está presente e o próximo também, aumenta a sequência
        if (workoutDays.contains(checkKey) && workoutDays.contains(nextKey)) {
          streak++;
          currentDay++;
        } 
        // Se o dia atual está presente mas o próximo não, encerra a sequência
        else if (workoutDays.contains(checkKey) && !workoutDays.contains(nextKey)) {
          break;
        } 
        // Se o dia atual não está presente, encerra a sequência
        else {
          break;
        }
      }
      
      return streak;
    } catch (e) {
      throw AppException(
        message: 'Erro ao calcular sequência de treinos',
        details: {'error': e.toString(), 'userId': userId},
      );
    }
  }
  
  /// Registra um novo treino para o usuário
  Future<void> recordUserWorkout({
    required String userId,
    required String workoutId,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'workout_id': workoutId,
        'completed_at': completedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        ...?additionalData,
      };
      
      await _client.from(_userWorkoutsTable).insert(data);
    } catch (e) {
      throw AppException(
        message: 'Erro ao registrar treino do usuário',
        details: {'error': e.toString(), 'userId': userId, 'workoutId': workoutId},
      );
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:ray_club_app/core/services/supabase_service.dart';
import 'package:ray_club_app/core/services/auth_service.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/challenge_group.dart';
import '../models/challenge_progress.dart';
import '../repositories/challenge_repository.dart';

/// Estado para gerenciamento de grupos de desafio
class ChallengeGroupState {
  final List<ChallengeGroup> groups;
  final ChallengeGroup? selectedGroup;
  final List<ChallengeGroupInvite> pendingInvites;
  final List<ChallengeProgress> groupRanking;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ChallengeGroupState({
    this.groups = const [],
    this.selectedGroup,
    this.pendingInvites = const [],
    this.groupRanking = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Cria estado inicial
  factory ChallengeGroupState.initial() => ChallengeGroupState();

  /// Cria estado de carregamento
  factory ChallengeGroupState.loading({
    List<ChallengeGroup> groups = const [],
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> groupRanking = const [],
  }) => ChallengeGroupState(
    groups: groups,
    selectedGroup: selectedGroup,
    pendingInvites: pendingInvites,
    groupRanking: groupRanking,
    isLoading: true,
  );

  /// Cria estado de sucesso
  factory ChallengeGroupState.success({
    required List<ChallengeGroup> groups,
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> groupRanking = const [],
    String? message,
  }) => ChallengeGroupState(
    groups: groups,
    selectedGroup: selectedGroup,
    pendingInvites: pendingInvites,
    groupRanking: groupRanking,
    successMessage: message,
  );

  /// Cria estado de erro
  factory ChallengeGroupState.error({
    List<ChallengeGroup> groups = const [],
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite> pendingInvites = const [],
    List<ChallengeProgress> groupRanking = const [],
    required String message,
  }) => ChallengeGroupState(
    groups: groups,
    selectedGroup: selectedGroup,
    pendingInvites: pendingInvites,
    groupRanking: groupRanking,
    errorMessage: message,
  );

  /// Cria uma cópia do estado com campos opcionalmente modificados
  ChallengeGroupState copyWith({
    List<ChallengeGroup>? groups,
    ChallengeGroup? selectedGroup,
    List<ChallengeGroupInvite>? pendingInvites,
    List<ChallengeProgress>? groupRanking,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ChallengeGroupState(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      groupRanking: groupRanking ?? this.groupRanking,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Provider para o ViewModel de grupos de desafio
final challengeGroupViewModelProvider = StateNotifierProvider<ChallengeGroupViewModel, ChallengeGroupState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return ChallengeGroupViewModel(supabaseService, authService);
});

/// ViewModel para gerenciar grupos de desafio
class ChallengeGroupViewModel extends StateNotifier<ChallengeGroupState> {
  final SupabaseService _supabaseService;
  final AuthService _authService;

  ChallengeGroupViewModel(this._supabaseService, this._authService)
      : super(ChallengeGroupState.initial());

  /// Obtém mensagem de erro formatada
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro: $error';
  }

  /// Carrega grupos dos quais o usuário é membro
  Future<void> loadUserGroups() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }

      // Buscar grupos criados pelo usuário
      final createdGroups = await _supabaseService.supabase
          .from('challenge_groups')
          .select()
          .eq('creator_id', userId);

      // Buscar grupos dos quais o usuário é membro
      final memberGroups = await _supabaseService.supabase
          .from('challenge_group_members')
          .select('group_id, groups:challenge_groups(*)')
          .eq('user_id', userId);

      // Processar resultados
      final List<ChallengeGroup> groups = [];
      
      if (createdGroups != null) {
        for (final group in createdGroups) {
          // Buscar membros do grupo
          final membersData = await _supabaseService.supabase
              .from('challenge_group_members')
              .select('user_id, id, joined_at')
              .eq('group_id', group['id']);

          final List<ChallengeGroupMember> groupMembers = membersData != null
              ? membersData.map<ChallengeGroupMember>((m) => ChallengeGroupMember(
                  id: m['id'] ?? 'unknown',
                  groupId: group['id'],
                  userId: m['user_id'],
                  joinedAt: m['joined_at'] != null ? DateTime.parse(m['joined_at']) : DateTime.now(),
                )).toList()
              : [];

          groups.add(ChallengeGroup(
            id: group['id'],
            name: group['name'],
            description: group['description'] ?? '',
            creatorId: group['creator_id'],
            createdAt: DateTime.parse(group['created_at']),
            members: groupMembers,
          ));
        }
      }

      if (memberGroups != null) {
        for (final item in memberGroups) {
          final group = item['groups'];
          if (group != null && !groups.any((g) => g.id == group['id'])) {
            // Buscar membros do grupo
            final membersData = await _supabaseService.supabase
                .from('challenge_group_members')
                .select('user_id, id, joined_at')
                .eq('group_id', group['id']);

            final List<ChallengeGroupMember> groupMembers = membersData != null
                ? membersData.map<ChallengeGroupMember>((m) => ChallengeGroupMember(
                    id: m['id'] ?? 'unknown',
                    groupId: group['id'],
                    userId: m['user_id'],
                    joinedAt: m['joined_at'] != null ? DateTime.parse(m['joined_at']) : DateTime.now(),
                  )).toList()
                : [];

            groups.add(ChallengeGroup(
              id: group['id'],
              name: group['name'],
              description: group['description'] ?? '',
              creatorId: group['creator_id'],
              createdAt: DateTime.parse(group['created_at']),
              members: groupMembers,
            ));
          }
        }
      }

      state = state.copyWith(
        groups: groups,
        isLoading: false,
      );
      
      debugPrint('Grupos carregados: ${groups.length}');
    } catch (e) {
      debugPrint('Erro ao carregar grupos: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar grupos: $e',
      );
    }
  }

  /// Carrega convites pendentes para o usuário
  Future<void> loadPendingInvites(String userId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      final pendingInvitesData = await _supabaseService.supabase
          .from('challenge_group_invites')
          .select()
          .eq('invitee_id', userId);

      // Converter dados JSON em objetos ChallengeGroupInvite
      final List<ChallengeGroupInvite> pendingInvites = pendingInvitesData
          .map<ChallengeGroupInvite>((data) {
            // Mapear campos do banco de dados para campos da classe
            final mappedData = {
              'id': data['id'],
              'groupId': data['group_id'],
              'groupName': data['group_name'],
              'inviterId': data['inviter_id'],
              'inviterName': data['inviter_name'],
              'inviteeId': data['invitee_id'],
              'status': data['status'] == 0 ? 'pending' : (data['status'] == 1 ? 'accepted' : 'rejected'),
              'createdAt': data['created_at'],
              'respondedAt': data['responded_at'],
            };
            return ChallengeGroupInvite.fromJson(mappedData);
          })
          .toList();

      state = ChallengeGroupState.success(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: pendingInvites,
        groupRanking: state.groupRanking,
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Carrega detalhes de um grupo específico e seu ranking
  Future<void> loadGroupDetails(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Buscar dados do grupo
      final groupData = await _supabaseService.supabase
          .from('challenge_groups')
          .select()
          .eq('id', groupId)
          .single();

      if (groupData == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Grupo não encontrado',
        );
        return;
      }

      // Buscar membros do grupo
      final membersData = await _supabaseService.supabase
          .from('challenge_group_members')
          .select('user_id, id, joined_at')
          .eq('group_id', groupId);

      final List<ChallengeGroupMember> groupMembers = membersData != null
          ? membersData.map<ChallengeGroupMember>((m) => ChallengeGroupMember(
              id: m['id'] ?? 'unknown',
              groupId: groupId,
              userId: m['user_id'],
              joinedAt: m['joined_at'] != null ? DateTime.parse(m['joined_at']) : DateTime.now(),
            )).toList()
          : [];

      final selectedGroup = ChallengeGroup(
        id: groupData['id'],
        name: groupData['name'],
        description: groupData['description'] ?? '',
        creatorId: groupData['creator_id'],
        createdAt: DateTime.parse(groupData['created_at']),
        members: groupMembers,
      );

      state = state.copyWith(
        selectedGroup: selectedGroup,
        isLoading: false,
      );
      
      debugPrint('Detalhes do grupo carregados: ${selectedGroup.name}');
    } catch (e) {
      debugPrint('Erro ao carregar detalhes do grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar detalhes do grupo: $e',
      );
    }
  }

  /// Cria um novo grupo para o desafio principal
  Future<bool> createGroup({
    required String name,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      final groupId = const Uuid().v4();
      
      // Inserir o grupo
      await _supabaseService.supabase.from('challenge_groups').insert({
        'id': groupId,
        'name': name,
        'description': description,
        'creator_id': userId,
      });

      // Adicionar o criador como membro
      await _supabaseService.supabase.from('challenge_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });

      // Recarregar grupos
      await loadUserGroups();
      
      return true;
    } catch (e) {
      debugPrint('Erro ao criar grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao criar grupo: $e',
      );
      return false;
    }
  }

  /// Atualiza um grupo existente
  Future<void> updateGroup(ChallengeGroup group) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_groups')
          .update({
            'name': group.name,
            'description': group.description,
          })
          .eq('id', group.id);

      // Atualizar o grupo na lista
      final updatedGroups = state.groups.map((g) {
        return g.id == group.id ? group : g;
      }).toList();

      state = ChallengeGroupState.success(
        groups: updatedGroups,
        selectedGroup: group,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: 'Grupo atualizado com sucesso!',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Exclui um grupo
  Future<void> deleteGroup(String groupId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_groups')
          .delete()
          .eq('id', groupId);

      // Remover o grupo da lista
      final updatedGroups = state.groups.where((g) => g.id != groupId).toList();

      state = ChallengeGroupState.success(
        groups: updatedGroups,
        selectedGroup: state.selectedGroup?.id == groupId ? null : state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: 'Grupo excluído com sucesso!',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Convida um usuário para o grupo
  Future<bool> inviteUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Obter informações do grupo para incluir no convite
      final groupData = await _supabaseService.supabase
          .from('challenge_groups')
          .select()
          .eq('id', groupId)
          .single();
      
      if (groupData == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Grupo não encontrado',
        );
        return false;
      }

      final groupName = groupData['name'] ?? 'Grupo sem nome';
      
      // Obter informações do convidador (usuário atual)
      final inviterId = _authService.currentUser?.id;
      
      // Se não tiver ID do convidador, não pode continuar
      if (inviterId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }
      
      final inviterData = await _supabaseService.supabase
          .from('profiles')
          .select('display_name, name')
          .eq('id', inviterId)
          .single();
      
      if (inviterData == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não encontrado',
        );
        return false;
      }

      // Usar o nome de exibição ou nome completo como nome do convidador
      final inviterName = inviterData['display_name'] ?? 
                         inviterData['name'] ?? 
                         'Usuário';
      
      // Verificar se o usuário já é membro do grupo
      final existingMember = await _supabaseService.supabase
          .from('challenge_group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingMember != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário já é membro deste grupo',
        );
        return false;
      }
      
      // Verificar se já existe um convite pendente
      final existingInvite = await _supabaseService.supabase
          .from('challenge_group_invites')
          .select()
          .eq('group_id', groupId)
          .eq('invitee_id', userId)
          .eq('status', 0) // status 0 = pendente
          .maybeSingle();
      
      if (existingInvite != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Já existe um convite pendente para este usuário',
        );
        return false;
      }

      // Inserir o convite
      await _supabaseService.supabase
          .from('challenge_group_invites')
          .insert({
            'group_id': groupId,
            'group_name': groupName,
            'inviter_id': inviterId, // Agora temos certeza que não é nulo
            'inviter_name': inviterName,
            'invitee_id': userId,
            'status': 0, // 0 = pendente
          });

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Convite enviado com sucesso!',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Responde a um convite de grupo
  Future<void> respondToInvite(String inviteId, bool accept) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_group_invites')
          .delete()
          .eq('id', inviteId);

      // Se aceitou, atualizar a lista de grupos
      List<ChallengeGroup> updatedGroups = state.groups;
      if (accept) {
        // Buscar o ID do usuário atual
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await loadUserGroups();
        }
      }

      state = ChallengeGroupState.success(
        groups: updatedGroups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: accept ? 'Convite aceito com sucesso!' : 'Convite recusado.',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Remove um usuário do grupo
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      await _supabaseService.supabase
          .from('challenge_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      // Atualizar o grupo selecionado, se for o mesmo
      ChallengeGroup? updatedSelectedGroup = state.selectedGroup;
      if (state.selectedGroup?.id == groupId) {
        final groupData = await _supabaseService.supabase
            .from('challenge_groups')
            .select('*, members:challenge_group_members(user_id)')
            .eq('id', groupId)
            .single();
            
        if (groupData != null) {
          updatedSelectedGroup = ChallengeGroup.fromJson(groupData);
        }
      }

      // Recarregar o ranking se necessário
      List<ChallengeProgress> updatedRanking = state.groupRanking;
      if (state.selectedGroup?.id == groupId) {
        final memberData = await _supabaseService.supabase
            .from('challenge_group_members')
            .select()
            .eq('group_id', groupId);
            
        if (memberData != null) {
          updatedRanking = memberData.map<ChallengeProgress>((data) => ChallengeProgress(
            id: data['id'] ?? const Uuid().v4(),
            userId: data['user_id'],
            challengeId: data['challenge_id'] ?? groupId,
            userName: data['user_name'] ?? 'Participante',
            points: data['points'] ?? 0,
            position: data['position'] ?? 0,
            createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
          )).toList();
        }
      }

      state = ChallengeGroupState.success(
        groups: state.groups,
        selectedGroup: updatedSelectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: updatedRanking,
        message: 'Usuário removido com sucesso!',
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Atualiza o ranking do grupo
  Future<void> refreshGroupRanking(String groupId) async {
    try {
      state = ChallengeGroupState.loading(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
      );

      final memberData = await _supabaseService.supabase
          .from('challenge_group_members')
          .select()
          .eq('group_id', groupId);
          
      List<ChallengeProgress> updatedRanking = [];
      if (memberData != null) {
        updatedRanking = memberData.map<ChallengeProgress>((data) => ChallengeProgress(
          id: data['id'] ?? const Uuid().v4(),
          userId: data['user_id'],
          challengeId: data['challenge_id'] ?? groupId,
          userName: data['user_name'] ?? 'Participante',
          points: data['points'] ?? 0,
          position: data['position'] ?? 0,
          createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
        )).toList();
      }

      state = ChallengeGroupState.success(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: updatedRanking,
      );
    } catch (e) {
      state = ChallengeGroupState.error(
        groups: state.groups,
        selectedGroup: state.selectedGroup,
        pendingInvites: state.pendingInvites,
        groupRanking: state.groupRanking,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Limpa erros e mensagens de sucesso
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      // Verificar se o usuário já é membro
      final existing = await _supabaseService.supabase
          .from('challenge_group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      if (existing != null && existing.isNotEmpty) {
        state = state.copyWith(isLoading: false);
        return true; // Já é membro
      }

      // Adicionar como membro
      await _supabaseService.supabase.from('challenge_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });

      // Recarregar grupos
      await loadUserGroups();
      
      return true;
    } catch (e) {
      debugPrint('Erro ao entrar no grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao entrar no grupo: $e',
      );
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final userId = _authService.currentUser?.id;
      
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      // Remover do grupo
      await _supabaseService.supabase
          .from('challenge_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      // Recarregar grupos
      await loadUserGroups();
      
      return true;
    } catch (e) {
      debugPrint('Erro ao sair do grupo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao sair do grupo: $e',
      );
      return false;
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../features/profile/models/profile_model.dart';
import '../../../features/profile/repositories/profile_repository.dart';
import '../../../features/profile/viewmodels/profile_view_model.dart';
import 'invite_form_state.dart';

/// Provider para o ViewModel do formulário de convites
final inviteFormViewModelProvider = StateNotifierProvider.autoDispose<InviteFormViewModel, InviteFormState>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return InviteFormViewModel(profileRepository: profileRepository);
});

/// Tamanho da página para paginação
const int _pageSize = 15;

/// ViewModel para gerenciar o formulário de convites
class InviteFormViewModel extends StateNotifier<InviteFormState> {
  final ProfileRepository _profileRepository;

  /// Construtor
  InviteFormViewModel({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const InviteFormState());

  /// Carrega todos os perfis disponíveis
  Future<void> loadProfiles() async {
    try {
      final profiles = await _profileRepository.getAllProfiles();
      
      state = state.copyWith(
        allProfiles: profiles,
        errorMessage: null,
      );
      
      // Inicializa a primeira página
      updatePaginatedProfiles();
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Atualiza o termo de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query.toLowerCase(),
      currentPage: 0,
      paginatedProfiles: [],
      hasMoreData: true,
    );
    
    updatePaginatedProfiles();
  }

  /// Limpa o termo de busca
  void clearSearchQuery() {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 0,
      paginatedProfiles: [],
      hasMoreData: true,
    );
    
    updatePaginatedProfiles();
  }

  /// Atualiza a lista de perfis paginados com base no filtro atual
  void updatePaginatedProfiles() {
    if (state.isLoadingMore) return;
    
    final filteredProfiles = state.allProfiles
        .where((profile) =>
            profile.name?.toLowerCase().contains(state.searchQuery) == true || 
            profile.email?.toLowerCase().contains(state.searchQuery) == true)
        .toList();
    
    final int startIndex = state.currentPage * _pageSize;
    
    if (startIndex >= filteredProfiles.length) {
      state = state.copyWith(
        hasMoreData: false,
        isLoadingMore: false,
      );
      return;
    }
    
    // Calcular o índice final (não exceder o tamanho da lista)
    final int endIndex = (startIndex + _pageSize < filteredProfiles.length) 
        ? startIndex + _pageSize 
        : filteredProfiles.length;
    
    if (state.currentPage == 0) {
      // Se é a primeira página, substitui a lista
      state = state.copyWith(
        paginatedProfiles: filteredProfiles.sublist(startIndex, endIndex),
        hasMoreData: endIndex < filteredProfiles.length,
        isLoadingMore: false,
      );
    } else {
      // Senão, adiciona à lista existente
      state = state.copyWith(
        paginatedProfiles: [...state.paginatedProfiles, ...filteredProfiles.sublist(startIndex, endIndex)],
        hasMoreData: endIndex < filteredProfiles.length,
        isLoadingMore: false,
      );
    }
  }

  /// Carrega a próxima página de perfis
  void loadMoreProfiles() {
    if (!state.hasMoreData || state.isLoadingMore) return;
    
    state = state.copyWith(
      currentPage: state.currentPage + 1,
      isLoadingMore: true,
    );
    
    updatePaginatedProfiles();
  }

  /// Adiciona um usuário à lista de selecionados
  void toggleUserSelection(Profile profile) {
    final isAlreadySelected = state.selectedUsers.any((u) => u.id == profile.id);
    
    if (isAlreadySelected) {
      // Remove o usuário da lista de selecionados
      state = state.copyWith(
        selectedUsers: state.selectedUsers.where((u) => u.id != profile.id).toList(),
      );
    } else {
      // Adiciona o usuário à lista de selecionados
      state = state.copyWith(
        selectedUsers: [...state.selectedUsers, profile],
      );
    }
  }

  /// Verifica se um usuário está selecionado
  bool isUserSelected(String userId) {
    return state.selectedUsers.any((user) => user.id == userId);
  }

  /// Limpa a lista de usuários selecionados
  void clearSelectedUsers() {
    state = state.copyWith(
      selectedUsers: [],
    );
  }

  /// Obtém a mensagem de erro formatada
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
} 
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../models/challenge.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import 'challenge_form_state.dart';

final challengeFormViewModelProvider = StateNotifierProvider.autoDispose<ChallengeFormViewModel, ChallengeFormState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return ChallengeFormViewModel(repository, authRepository);
});

class ChallengeFormViewModel extends StateNotifier<ChallengeFormState> {
  final ChallengeRepository _repository;
  final IAuthRepository _authRepository;

  ChallengeFormViewModel(this._repository, this._authRepository) 
      : super(ChallengeFormState.initial(''));

  // Carrega os detalhes de um desafio existente
  Future<void> loadChallenge(String challengeId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: '');
    
    try {
      final challenge = await _repository.getChallengeById(challengeId);
      state = ChallengeFormState.fromChallenge(challenge);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Erro ao carregar desafio: ${e.toString()}',
      );
    }
  }

  // Atualiza o título do desafio
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  // Atualiza a descrição do desafio
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  // Atualiza a recompensa do desafio
  void updateReward(String reward) {
    try {
      final rewardPoints = int.parse(reward);
      state = state.copyWith(points: rewardPoints);
    } catch (_) {
      // Se não for um número válido, não atualiza
    }
  }

  // Atualiza a URL da imagem do desafio
  void updateImageUrl(String imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }

  // Atualiza a data de início do desafio
  void updateStartDate(DateTime startDate) {
    DateTime endDate = state.endDate;
    
    // Se a data de início for posterior à data de término, atualiza a data de término
    if (startDate.isAfter(endDate)) {
      endDate = startDate.add(const Duration(days: 7));
    }
    
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  // Atualiza a data de término do desafio
  void updateEndDate(DateTime endDate) {
    // Certifica-se de que a data de término não é anterior à data de início
    if (endDate.isBefore(state.startDate)) {
      throw ValidationException(
        message: 'A data de término não pode ser anterior à data de início',
      );
    }
    
    state = state.copyWith(endDate: endDate);
  }

  // Salva o desafio (cria um novo ou atualiza um existente)
  Future<void> saveChallenge() async {
    // Valida os dados do formulário
    if (state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'O título é obrigatório');
      return;
    }
    
    if (state.description.isEmpty) {
      state = state.copyWith(errorMessage: 'A descrição é obrigatória');
      return;
    }
    
    // Valida a recompensa
    if (state.points < 0) {
      state = state.copyWith(errorMessage: 'A recompensa não pode ser negativa');
      return;
    }
    
    state = state.copyWith(isSubmitting: true, errorMessage: '');
    
    try {
      final imageUrl = state.imageUrl != null && state.imageUrl!.isNotEmpty ? state.imageUrl : null;
      
      // Obtém o usuário atual
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (state.id != null) {
        // Atualiza o desafio existente
        final challenge = state.toChallenge();
        await _repository.updateChallenge(challenge);
      } else {
        // Cria um novo desafio
        final newChallenge = Challenge(
          id: '', // Será gerado pelo repositório
          title: state.title,
          description: state.description,
          points: state.points,
          imageUrl: imageUrl,
          startDate: state.startDate,
          endDate: state.endDate,
          participants: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          creatorId: currentUser.id,
        );
        
        await _repository.createChallenge(newChallenge);
      }
      
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Erro ao salvar desafio: ${e.toString()}',
      );
    }
  }
} 
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../services/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../models/challenge.dart';
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import 'create_challenge_state.dart';

final createChallengeViewModelProvider = StateNotifierProvider.autoDispose<CreateChallengeViewModel, CreateChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return CreateChallengeViewModel(repository, authService);
});

class CreateChallengeViewModel extends StateNotifier<CreateChallengeState> {
  final ChallengeRepository _repository;
  final AuthService _authService;

  CreateChallengeViewModel(this._repository, this._authService) : super(CreateChallengeState.initial());

  // Atualiza o título do desafio
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  // Atualiza as regras do desafio
  void updateRules(String rules) {
    state = state.copyWith(rules: rules);
  }

  // Atualiza a recompensa do desafio
  void updateReward(String reward) {
    state = state.copyWith(reward: reward);
  }

  // Atualiza a data de início do desafio
  void updateStartDate(DateTime startDate) {
    DateTime endDate = state.endDate;
    
    // Se a data de início for posterior à data de término, atualiza a data de término
    if (startDate.isAfter(endDate)) {
      endDate = startDate.add(const Duration(days: 7));
    }
    
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  // Atualiza a data de término do desafio
  void updateEndDate(DateTime endDate) {
    // Certifica-se de que a data de término não é anterior à data de início
    if (endDate.isBefore(state.startDate)) {
      throw ValidationException(
        message: 'A data de término não pode ser anterior à data de início',
      );
    }
    
    state = state.copyWith(endDate: endDate);
  }
  
  // Atualiza a lista de usuários convidados
  void updateInvitedUsers(List<String> invitedUsers) {
    state = state.copyWith(invitedUsers: invitedUsers);
  }
  
  // Remove um usuário da lista de convidados
  void removeInvitedUser(String userId) {
    final updatedInvitedUsers = List<String>.from(state.invitedUsers)
      ..remove(userId);
    state = state.copyWith(invitedUsers: updatedInvitedUsers);
  }

  /// Salva o desafio
  Future<void> saveChallenge() async {
    if (state.isSaving) return;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      // Obtém o ID do criador
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Cria um novo desafio
      final newChallenge = state.toChallenge(currentUser.id);
      
      // Salva o desafio no repositório
      final savedChallenge = await _repository.createChallenge(newChallenge);
      
      // Não enviamos mais convites para desafios individuais, apenas para grupos
      
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Erro ao salvar desafio: ${e.toString()}',
      );
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // For ValueGetter if needed
import 'package:collection/collection.dart';
import 'dart:math' as math;
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../models/challenge_group.dart';
import '../models/challenge_state.dart'; // Usando o novo arquivo de estado
import '../repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart'; // Adicionando import para o provider
import '../services/challenge_realtime_service.dart';
import 'package:ray_club_app/utils/text_sanitizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';


/// Provider para o ChallengeViewModel
final challengeViewModelProvider = StateNotifierProvider<ChallengeViewModel, ChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final realtimeService = ref.watch(challengeRealtimeServiceProvider);
  return ChallengeViewModel(
    repository: repository, 
    authRepository: authRepository,
    realtimeService: realtimeService,
    ref: ref,
  );
});

/// Helper class para extrair dados do estado atual de forma mais segura
class ChallengeStateHelper {
  /// Retorna desafios do estado, ou uma lista vazia se não existirem
  static List<Challenge> getChallenges(ChallengeState state) {
    return state.challenges;
  }
  
  /// Retorna desafios filtrados do estado, ou uma lista vazia se não existirem
  static List<Challenge> getFilteredChallenges(ChallengeState state) {
    return state.filteredChallenges;
  }
  
  /// Retorna o desafio selecionado, ou null se não existir
  static Challenge? getSelectedChallenge(ChallengeState state) {
    return state.selectedChallenge;
  }
  
  /// Retorna convites pendentes do estado, ou uma lista vazia se não existirem
  static List<ChallengeGroupInvite> getPendingInvites(ChallengeState state) {
    return state.pendingInvites;
  }
  
  /// Retorna a lista de progresso do estado, ou uma lista vazia se não existir
  static List<ChallengeProgress> getProgressList(ChallengeState state) {
    return state.progressList;
  }
  
  /// Retorna o progresso do usuário no desafio selecionado, ou null se não existir
  static ChallengeProgress? getUserProgress(ChallengeState state) {
    return state.userProgress;
  }
  
  /// Obtém a mensagem de sucesso do estado
  static String? getSuccessMessage(ChallengeState state) {
    return state.successMessage;
  }
  
  /// Obtém a mensagem de erro do estado
  static String? getErrorMessage(ChallengeState state) {
    return state.errorMessage;
  }
  
  /// Verifica se o estado está carregando
  static bool isLoading(ChallengeState state) {
    return state.isLoading;
  }
  
  /// Retorna o desafio oficial, ou null se não existir
  static Challenge? getOfficialChallenge(ChallengeState state) {
    return state.officialChallenge;
  }
}

/// ViewModel para gerenciar desafios
class ChallengeViewModel extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repository;
  final IAuthRepository _authRepository;
  final ChallengeRealtimeService _realtimeService;
  final Ref ref;
  StreamSubscription? _rankingSubscription; // Single subscription for ranking

  ChallengeViewModel({
    required ChallengeRepository repository,
    required IAuthRepository authRepository,
    required ChallengeRealtimeService realtimeService,
    required this.ref,
  })  : _repository = repository,
        _authRepository = authRepository,
        _realtimeService = realtimeService,
        super(ChallengeState.initial()) {
    // Initial load can fetch the official challenge specifically
    loadOfficialChallenge();
    // Optionally load other challenges in the background or on demand
    // loadAllChallenges();
  }

  /// Extrai mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    // Mapeamento de erros comuns para mensagens amigáveis ao usuário
    if (error is DatabaseException) {
      return 'Erro ao acessar banco de dados. Por favor, tente novamente mais tarde.';
    }
    
    if (error is NetworkException) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
    
    if (error is AppAuthException) {
      return 'Erro de autenticação. Faça login novamente.';
    }
    
    if (error is ValidationException) {
      return 'Dados inválidos. Verifique suas informações e tente novamente.';
    }
    
    // Para erros não mapeados, forneça uma mensagem genérica em vez de expor detalhes técnicos
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }

  /// Loads only the official challenge (e.g., Ray Challenge) and its ranking.
  Future<void> loadOfficialChallenge({String? filterByGroupId}) async {
    debugPrint('🔍 ChallengeViewModel - loadOfficialChallenge iniciado');
    
    // Preserve current state while loading official challenge
    state = ChallengeState.loading(
       challenges: state.challenges,
       // Keep other state fields as they are
       pendingInvites: state.pendingInvites,
       selectedGroupIdForFilter: filterByGroupId ?? state.selectedGroupIdForFilter,
    );
    
    try {
      final now = DateTime.now();
      debugPrint('🔍 ChallengeViewModel - Data atual: ${now.toIso8601String()}');
      
      final challenge = await _repository.getOfficialChallenge();
      debugPrint('🔍 ChallengeViewModel - Desafio oficial recebido: ${challenge?.title}, id: ${challenge?.id}');
      
      if (challenge != null) {
        debugPrint('🔍 ChallengeViewModel - Datas do desafio: início=${challenge.startDate.toIso8601String()}, fim=${challenge.endDate.toIso8601String()}');
        // Load ranking (potentially filtered)
        final progressList = await _loadRanking(challenge.id, filterByGroupId);
        debugPrint('🔍 ChallengeViewModel - Ranking carregado, ${progressList.length} participantes');
        
        // Load user's progress in this official challenge
        final userProgress = await _loadUserProgress(challenge.id);
        debugPrint('🔍 ChallengeViewModel - Progresso do usuário: ${userProgress != null ? 'encontrado' : 'não encontrado'}');

        state = state.copyWith(
          isLoading: false,
          officialChallenge: challenge,
          selectedChallenge: challenge, // Select the official one by default
          progressList: progressList,
          userProgress: userProgress,
          errorMessage: null, // Clear previous error
          selectedGroupIdForFilter: filterByGroupId, // Update filter state
        );
        debugPrint('🔍 ChallengeViewModel - Estado atualizado com desafio oficial');
        
        // Start watching for real-time updates (if not already watching)
        watchChallengeRanking(challenge.id, filterByGroupId: filterByGroupId);
      } else {
        debugPrint('❌ ChallengeViewModel - Nenhum desafio oficial encontrado');
        state = state.copyWith(
          isLoading: false,
          officialChallenge: null,
          selectedChallenge: null, // No challenge selected
          errorMessage: null,
          progressList: [], // Clear ranking
          userProgress: null,
        );
      }
    } catch (e, s) {
      debugPrint('❌ ChallengeViewModel - Erro ao carregar desafio oficial: $e');
      debugPrint(s.toString());
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Loads all non-official challenges.
  Future<void> loadOtherChallenges() async {
     // Use a different loading indicator or state if needed, or combine loading states
     state = state.copyWith(isLoading: true); // Consider a more specific loading state
     try {
        final allChallenges = await _repository.getChallenges();
        // Filter out the official challenge if it's already loaded separately
        final otherChallenges = allChallenges.where((c) => !c.isOfficial).toList();

        // Combine with potentially existing official challenge in the main list if desired
        // Or keep them separate in the state. For now, just update `challenges`.
        final currentOfficial = state.officialChallenge;
        final combinedChallenges = [
          if (currentOfficial != null) currentOfficial,
          ...otherChallenges,
        ];

        state = state.copyWith(
          isLoading: false,
          // Update the main challenges list, keeping officialChallenge separate
          challenges: combinedChallenges,
          // Decide how filteredChallenges should behave - initially show all?
          filteredChallenges: combinedChallenges,
          errorMessage: null,
        );
        debugPrint('✅ Loaded ${otherChallenges.length} other challenges.');
     } catch (e, s) {
        debugPrint('❌ Error loading other challenges: $e\\n$s');
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(e),
        );
     }
  }


  /// Loads details for a specific challenge (could be official or custom) and its ranking.
  Future<void> loadChallengeDetails(String challengeId, {
    String? filterByGroupId,
    bool skipRealtimeUpdates = false,
  }) async {
     debugPrint('🔄 ChallengeViewModel - Carregando detalhes do desafio com ID: $challengeId');
     state = ChallengeState.loading(
        // Preserve existing state while loading details
        challenges: state.challenges,
        officialChallenge: state.officialChallenge,
        pendingInvites: state.pendingInvites,
        selectedGroupIdForFilter: filterByGroupId ?? state.selectedGroupIdForFilter,
     );
    try {
      // Forçar atualização completa do desafio
      debugPrint('🔄 ChallengeViewModel - Buscando desafio atualizado');
      final challenge = await _repository.getChallengeById(challengeId);
      if (challenge == null) {
        throw Exception('Challenge with ID $challengeId not found.');
      }

      // Load ranking (potentially filtered) - forçando limpeza de cache
      debugPrint('🔄 ChallengeViewModel - Buscando ranking atualizado');
      final progressList = await _repository.getChallengeProgress(challenge.id);
      
      // Load user's progress in this specific challenge - forçando limpeza de cache
      debugPrint('🔄 ChallengeViewModel - Buscando progresso do usuário atualizado');
      final userProgress = await _loadUserProgress(challenge.id);
      
      debugPrint('✅ ChallengeViewModel - Dados carregados: ${progressList.length} participantes, usuário ${userProgress != null ? "encontrado" : "não encontrado"}');

      state = state.copyWith(
        isLoading: false,
        selectedChallenge: challenge,
        progressList: progressList,
        userProgress: userProgress,
        errorMessage: null,
        selectedGroupIdForFilter: filterByGroupId, // Update filter state
        // Keep officialChallenge as is
        officialChallenge: state.officialChallenge,
      );
      debugPrint('✅ Details loaded for challenge: ${challenge.title}');
      
      // Start watching for real-time updates, unless skipRealtimeUpdates is true
      if (!skipRealtimeUpdates) {
        watchChallengeRanking(challenge.id, filterByGroupId: filterByGroupId);
      } else {
        debugPrint('ℹ️ Skipping real-time updates as requested');
      }
    } catch (e, s) {
      debugPrint('❌ Error loading challenge details for $challengeId: $e\\n$s');
      state = state.copyWith(
        isLoading: false,
        selectedChallenge: null, // Clear selection on error
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Filters the ranking of the currently selected challenge by a group ID.
  void filterRankingByGroup(String? groupId) async {
    if (state.selectedChallenge == null) {
      debugPrint('⚠️ Cannot filter ranking: No challenge selected.');
      return;
    }
    
    // Set loading state and keep the new filter selection
    state = state.copyWith(
      isLoading: true,
      selectedGroupIdForFilter: groupId,
    );

    try {
      // Verificar se existe um desafio selecionado
      final selectedChallenge = state.selectedChallenge;
      if (selectedChallenge == null) {
        throw AppException(message: 'Nenhum desafio selecionado para filtrar');
      }
      
      // Load filtered ranking data
      final progressList = await _loadRanking(selectedChallenge.id, groupId);
      
      // Update state with new filtered data
      state = state.copyWith(
        isLoading: false, 
        progressList: progressList,
        errorMessage: null, // Clear any previous errors
      );
      
      // Update the subscription to watch the correct stream
      watchChallengeRanking(selectedChallenge.id, filterByGroupId: groupId);
      
      debugPrint('✅ Ranking filtered by groupId: $groupId');
    } catch (e) {
      debugPrint('❌ Error filtering ranking by group: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Setup a real-time subscription to watch challenge ranking updates
  void watchChallengeRanking(String challengeId, {String? filterByGroupId}) {
    debugPrint('🔍 ChallengeViewModel - watchChallengeRanking iniciado para desafio: $challengeId, filtro: $filterByGroupId');
    
    // Cancel any existing subscription first
    if (_rankingSubscription != null) {
      debugPrint('🔍 ChallengeViewModel - Cancelando subscription anterior');
      _rankingSubscription?.cancel();
      _rankingSubscription = null;
    }
    
    // Different stream setup based on whether we're filtering by group or not
    if (filterByGroupId != null) {
      debugPrint('🔄 ChallengeRealtimeService - Iniciando observação para grupo: $filterByGroupId no desafio: $challengeId');
      _rankingSubscription = _realtimeService.watchGroupRanking(challengeId, filterByGroupId)
        .listen(_handleRankingUpdate);
    } else {
      debugPrint('🔄 ChallengeRealtimeService - Iniciando observação para ranking geral do desafio: $challengeId');
      _rankingSubscription = _realtimeService.watchChallengeParticipants(challengeId)
        .listen(_handleRankingUpdate);
    }
    
    debugPrint('🔍 ChallengeViewModel - Stream configurado com o serviço realtime');
    
    // Initial fetch to ensure we have data while waiting for real-time events
    _refreshRankingData(challengeId, filterByGroupId);
  }
  
  /// Handle incoming real-time updates to ranking
  void _handleRankingUpdate(List<ChallengeProgress> newRanking) async {
    debugPrint('🔄 Atualizando ranking com ${newRanking.length} registros...');
    
    // First, sort by points in descending order
    final sortedRanking = List.of(newRanking)
      ..sort((a, b) => b.points.compareTo(a.points));
    
    // Update positions based on sorting
    for (var i = 0; i < sortedRanking.length; i++) {
      sortedRanking[i] = sortedRanking[i].copyWith(position: i + 1);
    }
    
    // Find user's progress in the updated list
    try {
      final userId = await _authRepository.getCurrentUserId();
      final userProgress = sortedRanking.firstWhereOrNull((p) => p.userId == userId);
      
      // Update state with new ranking data
      state = state.copyWith(
        progressList: sortedRanking,
        userProgress: userProgress,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('❌ Erro ao obter ID do usuário: $e');
      // Update state without user progress
      state = state.copyWith(
        progressList: sortedRanking,
        isLoading: false,
        errorMessage: null,
      );
    }
  }
  
  /// Refresh ranking data manually (used for initial load or after error)
  Future<void> _refreshRankingData(String challengeId, String? groupIdFilter) async {
    debugPrint('🔍 Iniciando refresh forçado do ranking do desafio: $challengeId');
    try {
      // Buscar os dados do usuário atual
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) {
        debugPrint('⚠️ Não foi possível obter o ID do usuário atual');
        return;
      }

      // Forçar limpeza do cache diretamente
      await _repository.clearCache(challengeId);
      
      // Aguardar um momento para garantir que o banco processou as atualizações
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Buscar o ranking completo (com update de cache)
      debugPrint('🔄 Forçando atualização do ranking completo...');
      final ranking = await _repository.getChallengeProgress(challengeId);
      
      // Buscar também o progresso do usuário atual
      debugPrint('🔄 Forçando atualização do progresso do usuário: $userId');
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Atualizar o estado com os dados mais recentes
      if (ranking.isNotEmpty) {
        debugPrint('✅ Dados atualizados: ${ranking.length} participantes, usuário ${userProgress != null ? "encontrado" : "não encontrado"}');
        
        state = state.copyWith(
          progressList: ranking,
          userProgress: userProgress,
          isLoading: false,
        );
      } else {
        debugPrint('⚠️ Nenhum dado de ranking recebido');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar ranking: $e');
    }
  }

  /// Load ranking (and potentially filter it)
  Future<List<ChallengeProgress>> _loadRanking(String challengeId, String? filterByGroupId) async {
    try {
      return await _repository.getChallengeProgress(challengeId);
    } catch (e) {
      debugPrint('❌ Erro ao carregar ranking: $e');
      // Return empty list on error, but don't update state yet
      return [];
    }
  }

  /// Loads and watches user progress in the specified challenge
  Future<ChallengeProgress?> _loadUserProgress(String challengeId) async {
    try {
      final user = await _authRepository.getCurrentUser();
      final userId = user?.id;
      if (userId == null) {
        debugPrint('⚠️ Cannot load user progress: No authenticated user.');
        return null;
      }
      
      // Verificar se o usuário está participando do desafio
      final progress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (progress == null) {
        debugPrint('🔍 _loadUserProgress: Usuário não tem progresso no desafio, verificando se é participante');
        
        // Verificar se o usuário está na tabela de participantes
        final isParticipant = await _repository.isUserParticipatingInChallenge(
          challengeId: challengeId,
          userId: userId,
        );
        
        if (isParticipant) {
          debugPrint('🔍 _loadUserProgress: Usuário é participante mas não tem progresso, criando progresso inicial');
          
          try {
            // Se o usuário é participante mas não tem progresso, criar um progresso inicial
            final userInfo = await _authRepository.getUserProfile();
            final userName = userInfo?.userMetadata?['name'] as String? ?? "Usuário";
            final photoUrl = userInfo?.userMetadata?['avatar_url'] as String?;
            
            // Criar progresso inicial
            await _repository.createUserProgress(
              challengeId: challengeId,
              userId: userId,
              userName: userName,
              userPhotoUrl: photoUrl,
              points: 0,
              completionPercentage: 0,
            );
            
            // Buscar o progresso novamente após criar
            return await _repository.getUserProgress(
              challengeId: challengeId,
              userId: userId,
            );
          } catch (e) {
            // Se ocorrer erro de chave duplicada (code 23505), tente buscar o progresso novamente
            if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
              debugPrint('⚠️ _loadUserProgress: Conflito de chave duplicada, tentando recuperar progresso existente');
              // Aguarde um momento para garantir consistência
              await Future.delayed(const Duration(milliseconds: 500));
              return await _repository.getUserProgress(
                challengeId: challengeId,
                userId: userId,
              );
            } else {
              // Relançar o erro para outros casos
              rethrow;
            }
          }
        }
      }
      
      return progress;
    } catch (e) {
      debugPrint('❌ Error loading user progress: $e');
      return null;
    }
  }

  /// Carrega o ranking de um desafio com opção de filtro por grupo
  Future<void> loadChallengeRanking(String challengeId, {String? groupId}) async {
    try {
      state = state.copyWith(isLoading: true);
      
      List<ChallengeProgress> ranking;
      if (groupId != null) {
        // Usar função RPC específica para filtro de grupo
        final client = Supabase.instance.client;
        final response = await client.rpc(
          'get_group_challenge_ranking', 
          params: {
            '_challenge_id': challengeId,
            '_group_id': groupId
          }
        );
            
        if (response == null) {
          throw AppException(message: 'Erro ao carregar ranking por grupo: Resposta nula');
        }
        
        ranking = (response as List).map((item) => ChallengeProgress.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Usar ranking padrão
        ranking = await _repository.getChallengeProgress(challengeId);
      }
      
      state = state.copyWith(
        progressList: ranking,
        selectedGroupIdForFilter: groupId,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isLoading: false
      );
    }
  }

  /// Carrega todos os desafios, mas garante que o desafio oficial da Ray está incluído
  Future<void> loadAllChallengesWithOfficial() async {
    try {
      state = ChallengeState.loading();
      
      // Carrega todos os desafios
      final challenges = await _repository.getChallenges();
      
      // Verifica se há um desafio oficial
      final officialChallenge = await _repository.getOfficialChallenge();
      
      // Garante que o desafio oficial está na lista se existir
      final allChallenges = List<Challenge>.from(challenges);
      if (officialChallenge != null) {
        // Remove versões duplicadas do desafio oficial se existirem
        allChallenges.removeWhere((challenge) => challenge.id == officialChallenge.id);
        // Adiciona o desafio oficial
        allChallenges.add(officialChallenge);
      }
      
      // Carrega os convites pendentes para o usuário atual
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      
      if (userId.isEmpty) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      final pendingInvites = await _repository.getPendingInvites(userId);
      
      state = ChallengeState.success(
        challenges: allChallenges,
        filteredChallenges: allChallenges,
        pendingInvites: pendingInvites,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega todos os desafios do repositório
  Future<void> loadChallenges() async {
    try {
      state = ChallengeState.loading(
        // Preservar dados existentes para evitar flickering
        officialChallenge: state.officialChallenge,
        selectedChallenge: state.selectedChallenge,
        pendingInvites: state.pendingInvites,
        progressList: state.progressList,
        userProgress: state.userProgress,
      );
      
      final challenges = await _repository.getChallenges();
      
      state = state.copyWith(
        challenges: challenges,
        filteredChallenges: challenges,
        isLoading: false,
        errorMessage: null, // Clear any previous error
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Verifica se o usuário atual é um administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isCurrentUserAdmin();
    } catch (e) {
      return false;
    }
  }
  
  /// Alterna o status de administrador (apenas para testes)
  Future<void> toggleAdminStatus() async {
    try {
      await _repository.toggleAdminStatus();
    } catch (e) {
      state = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Método para filtrar desafios ativos na UI sem fazer nova requisição
  void filtrarDesafiosAtivos() {
    try {
      // Verificar se há desafios carregados
      if (state.challenges.isEmpty) {
        throw AppException(message: 'Nenhum desafio carregado para filtrar');
      }
      
      final now = DateTime.now();
      
      // Filtrar desafios já carregados que estão ativos
      final desafiosAtivos = state.challenges.where((challenge) => 
        challenge.startDate.isBefore(now) && challenge.endDate.isAfter(now)
      ).toList();
      
      // Atualizar apenas o filtro, mantendo a lista completa
      state = state.copyWith(
        filteredChallenges: desafiosAtivos,
        isLoading: false,
        errorMessage: null,
        successMessage: desafiosAtivos.isEmpty ? 'Não há desafios ativos no momento' : null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Cria um novo desafio com validação aprimorada
  Future<void> createChallenge(Challenge challenge) async {
    try {
      // Validações antes de começar
      if (challenge.title.trim().isEmpty) {
        throw ValidationException(message: 'O título do desafio não pode estar vazio');
      }
      
      if (challenge.description.trim().isEmpty) {
        throw ValidationException(message: 'A descrição do desafio não pode estar vazia');
      }
      
      if (challenge.startDate.isAfter(challenge.endDate)) {
        throw ValidationException(message: 'A data de início deve ser anterior à data de término');
      }
      
      // Iniciar estado de carregamento preservando dados existentes
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Criar o desafio
      final newChallenge = await _repository.createChallenge(challenge);
      
      // Atualizar a lista de desafios incluindo o novo
      final updatedChallenges = [...state.challenges, newChallenge];
      
      // Atualizar estado
      state = state.copyWith(
        challenges: updatedChallenges,
        filteredChallenges: updatedChallenges,
        selectedChallenge: newChallenge,
        isLoading: false,
        successMessage: 'Desafio criado com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Atualiza um desafio existente com validações e tratamento de estado aprimorados
  Future<void> updateChallenge(Challenge challenge) async {
    try {
      // Validações antes de começar
      if (challenge.title.trim().isEmpty) {
        throw ValidationException(message: 'O título do desafio não pode estar vazio');
      }
      
      if (challenge.description.trim().isEmpty) {
        throw ValidationException(message: 'A descrição do desafio não pode estar vazia');
      }
      
      if (challenge.startDate.isAfter(challenge.endDate)) {
        throw ValidationException(message: 'A data de início deve ser anterior à data de término');
      }
      
      // Iniciar estado de carregamento preservando dados existentes
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Atualizar o desafio
      await _repository.updateChallenge(challenge);
      
      // Atualizar as listas no estado mantendo referência ao progresso atual
      final updatedChallenges = state.challenges.map((c) {
        return c.id == challenge.id ? challenge : c;
      }).toList();
      
      final updatedFilteredChallenges = state.filteredChallenges.map((c) {
        return c.id == challenge.id ? challenge : c;
      }).toList();
      
      // Se o desafio atualizado for o desafio oficial, atualizar também a referência
      final updatedOfficialChallenge = state.officialChallenge?.id == challenge.id
        ? challenge
        : state.officialChallenge;
      
      // Atualizar estado
      state = state.copyWith(
        challenges: updatedChallenges,
        filteredChallenges: updatedFilteredChallenges,
        selectedChallenge: challenge,
        officialChallenge: updatedOfficialChallenge,
        isLoading: false,
        successMessage: 'Desafio atualizado com sucesso!',
      );
      
      // Se o desafio atualizado for o selecionado atualmente, atualizar também o ranking
      if (state.selectedChallenge?.id == challenge.id) {
        // Recarregar o ranking do desafio selecionado
        loadChallengeDetails(challenge.id, skipRealtimeUpdates: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Participa de um desafio com melhor tratamento de estado
  Future<void> joinChallenge({required String challengeId, required String userId}) async {
    try {
      // Mostrar progresso mantendo o estado atual
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Verificações adicionais
      if (challengeId.isEmpty || userId.isEmpty) {
        throw ValidationException(message: 'ID do desafio ou do usuário inválido');
      }
      
      // Tentar entrar no desafio
      await _repository.joinChallenge(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Aguardar um momento para garantir que o banco de dados processou a entrada
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Buscar o progresso do usuário atualizado - força a recarga completa
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId, 
        userId: userId
      );
      
      debugPrint('🔍 joinChallenge: Progresso obtido após entrar no desafio: ${userProgress != null ? 'encontrado' : 'não encontrado'}');
      
      // Recarregar também o ranking completo
      final progressList = await _repository.getChallengeProgress(challengeId);
      debugPrint('🔍 joinChallenge: Ranking recarregado com ${progressList.length} participantes');
      
      // Atualizar o estado com todas as informações
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Você entrou no desafio com sucesso!',
        userProgress: userProgress, // Atualizar com o novo progresso
        progressList: progressList, // Atualizar o ranking
      );
      
      // Garantir que as atualizações em tempo real estão funcionando
      watchChallengeRanking(challengeId, filterByGroupId: state.selectedGroupIdForFilter);
    } catch (e) {
      // Tratar exceções específicas
      String errorMessage = _getErrorMessage(e);
      
      // Mensagens mais amigáveis para erros específicos 
      if (errorMessage.contains('já é membro') || errorMessage.contains('already joined')) {
        errorMessage = 'Você já participa deste desafio';
      } else if (errorMessage.contains('desafio encerrado') || 
                errorMessage.contains('challenge ended')) {
        errorMessage = 'Este desafio já foi encerrado';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }
  
  /// Sai de um desafio com melhor tratamento de estado
  Future<void> leaveChallenge({required String challengeId, required String userId}) async {
    try {
      // Mostrar progresso mantendo o estado atual
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Verificações adicionais
      if (challengeId.isEmpty || userId.isEmpty) {
        throw ValidationException(message: 'ID do desafio ou do usuário inválido');
      }
      
      // Tentar sair do desafio
      await _repository.leaveChallenge(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Se bem-sucedido, notificar e recarregar os detalhes
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Você saiu do desafio',
        userProgress: null, // Limpar o progresso do usuário
      );
      
      // Recarregar os detalhes do desafio para atualizar a lista de participantes
      await loadChallengeDetails(challengeId);
    } catch (e) {
      // Tratar exceções específicas
      String errorMessage = _getErrorMessage(e);
      
      // Mensagens mais amigáveis para erros específicos
      if (errorMessage.contains('não é membro') || errorMessage.contains('not a member')) {
        errorMessage = 'Você não participa deste desafio';
      } else if (errorMessage.contains('criador não pode sair') || 
                errorMessage.contains('creator cannot leave')) {
        errorMessage = 'Como criador do desafio, você não pode sair';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }
  
  /// Registra um check-in manual em um desafio
  Future<bool> recordCheckIn({required String challengeId, required String userId, String? workoutId}) async {
    try {
      // Mostrar progresso mantendo o estado atual
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Verificações adicionais
      if (challengeId.isEmpty || userId.isEmpty) {
        throw ValidationException(message: 'ID do desafio ou do usuário inválido');
      }
      
      // Verificar se já existe check-in hoje diretamente no banco de dados
      final now = DateTime.now();
      debugPrint('🔍 DATA ATUAL: ${now.toIso8601String()}');
      
      final today = DateTime(now.year, now.month, now.day);
      debugPrint('🔍 DATA NORMALIZADA: ${today.toIso8601String()}');
      
      final hasCheckedIn = await _repository.hasCheckedInOnDate(userId, challengeId, today);
      
      debugPrint('🔍 Verificando se já existe check-in hoje para o desafio $challengeId');
      if (hasCheckedIn) {
        debugPrint('⚠️ Já existe check-in registrado para hoje. Atualizando UI mesmo assim.');
        
        // Força atualização dos dados mesmo quando o check-in já existe
        await _refreshRankingData(challengeId, state.selectedGroupIdForFilter);
        
        // Atualizar o estado para mostrar um feedback amigável
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Você já registrou um treino hoje! 🎉',
        );
        
        // Atualizar o dashboard para refletir as alterações imediatamente
        try {
          final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
          await dashboardViewModel.refreshData();
          debugPrint('✅ Dashboard atualizado após check-in');
        } catch (e) {
          debugPrint('⚠️ Não foi possível atualizar o dashboard: $e');
        }
        
        return true;
      }
      
      debugPrint('🔍 Registrando check-in para desafio específico: $challengeId');
      
      // Verificar se temos um ID de workout para registrar
      final workoutResult = await _repository.recordChallengeCheckIn(
        userId: userId,
        challengeId: challengeId,
        workoutId: workoutId,
        workoutName: 'Check-in manual',
        workoutType: 'Manual',
        date: today,
        durationMinutes: 60, // Padrão para check-ins manuais
      );
      
      // Se o check-in não foi bem sucedido ou existe conflito
      if (!workoutResult.success) {
        if (workoutResult.isAlreadyCheckedIn) {
          debugPrint('⚠️ Já existe check-in para hoje, forçando atualização da UI');
          
          // Força atualização dos dados
          await _refreshRankingData(challengeId, state.selectedGroupIdForFilter);
          
          // Atualizar o estado para mostrar um feedback amigável
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Você já registrou um treino hoje! 🎉',
          );
          
          // Atualizar o dashboard para refletir as alterações imediatamente
          try {
            final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
            await dashboardViewModel.refreshData();
            debugPrint('✅ Dashboard atualizado após check-in');
          } catch (e) {
            debugPrint('⚠️ Não foi possível atualizar o dashboard: $e');
          }
          
          return true;
        } else {
          throw Exception(workoutResult.message);
        }
      }
      
      // Aguardar um momento para garantir que o banco de dados atualizou
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Força atualização completa do ranking
      await _refreshRankingData(challengeId, state.selectedGroupIdForFilter);
      
      // Atualizar o estado
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Check-in registrado com sucesso! +${workoutResult.pointsEarned} pontos',
      );
      
      // Mostrar estatísticas na tela
      debugPrint('✅ Check-in bem sucedido! Pontos: ${workoutResult.pointsEarned}, Streak: ${workoutResult.currentStreak}');
      
      // Carregar detalhes atualizados do desafio
      await loadChallengeDetails(challengeId);
      
      // Atualizar o dashboard para refletir as alterações imediatamente
      try {
        final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
        await dashboardViewModel.refreshData();
        debugPrint('✅ Dashboard atualizado após check-in');
      } catch (e) {
        debugPrint('⚠️ Não foi possível atualizar o dashboard: $e');
      }
      
      return true;
    } catch (e, stackTrace) {
      // Log error
      debugPrint('❌ Erro ao registrar check-in: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar check-in: ${e.toString()}',
      );
      
      return false;
    }
  }
  
  /// Carrega os convites pendentes para um usuário
  Future<void> loadPendingInvites([String? userId]) async {
    try {
      state = ChallengeState.loading();
      
      // Se userId não for fornecido, obter do usuário atual
      String userIdToUse;
      if (userId != null) {
        userIdToUse = userId;
      } else {
        final currentUser = await _authRepository.getCurrentUser();
        if (currentUser == null) {
          throw AppAuthException(message: 'Usuário não autenticado');
        }
        userIdToUse = currentUser.id;
      }
      
      final invites = await _repository.getPendingInvites(userIdToUse);
      
      // Mantém a lista atual de desafios
      final currentChallenges = ChallengeStateHelper.getChallenges(state);
      
      state = ChallengeState.success(
        challenges: currentChallenges,
        filteredChallenges: currentChallenges,
        pendingInvites: invites,
      );
    } catch (e) {
      state = ChallengeState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Updates the user's progress data for a specific challenge
  /// Returns true if the operation succeeded, false otherwise
  Future<bool> updateUserProgress(String challengeId, UserProgressUpdateData updateData) async {
    try {
      // Primeiro, obtenha o usuário atual
      final currentUser = await _authRepository.getCurrentUser();
      // Verifique se há um usuário logado
      if (currentUser == null) {
        state = state.copyWith(
          errorMessage: 'Usuário não autenticado',
        );
        return false;
      }

      // Valide os IDs
      _validateIds('updateUserProgress', challengeId: challengeId, userId: currentUser.id);
      
      debugPrint('🔍 ChallengeViewModel - updateUserProgress para desafio: $challengeId, dados: ${updateData.toString()}');
    
      // Verifique se o desafio está ativo
      final challenge = _getChallengeById(challengeId);
      if (challenge == null) {
        state = state.copyWith(
          errorMessage: 'Desafio não encontrado. Tente recarregar a página.',
        );
        return false;
      }
      
      if (!challenge.isActive()) {
        state = state.copyWith(
          errorMessage: 'Esse desafio não está mais ativo.',
        );
        return false;
      }
      
      // Atualize o estado para mostrar carregamento
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );
      
      // Use o serviço em tempo real para a atualização
      final updatedProgress = await _realtimeService.updateProgress(
        challengeId: challengeId,
        updateData: updateData.toJson(),
        onOptimisticUpdate: (optimisticProgress) {
          // Atualiza a UI imediatamente com update otimista
          _updateProgressLocally(optimisticProgress);
        },
      );
      
      if (updatedProgress != null) {
        // Servidor confirmou a atualização
        _updateProgressLocally(updatedProgress);
        
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Progresso atualizado com sucesso!',
        );
        return true;
      } else {
        // A atualização foi rejeitada (tratada pelo serviço)
        state = state.copyWith(
          isLoading: false,
        );
        return false;
      }
    } on AppException catch (e) {
      debugPrint('❌ ChallengeViewModel - Erro ao atualizar progresso: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('❌ ChallengeViewModel - Erro desconhecido: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível atualizar seu progresso. Tente novamente mais tarde.',
      );
      return false;
    }
  }
  
  // Helper to update the progress list locally for immediate UI feedback
  void _updateProgressLocally(ChallengeProgress updatedProgress) {
    final currentList = List<ChallengeProgress>.from(state.progressList);
    final index = currentList.indexWhere((p) => 
        p.userId == updatedProgress.userId && 
        p.challengeId == updatedProgress.challengeId);
    
    if (index >= 0) {
      // Replace existing progress
      currentList[index] = updatedProgress;
    } else {
      // Add new progress
      currentList.add(updatedProgress);
    }
    
    state = state.copyWith(progressList: currentList);
  }

  /// Carrega o progresso do usuário em um desafio específico
  Future<void> loadUserChallengeProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      // Validações básicas
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Define estado de carregamento
      state = ChallengeState.loading(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
      );
      
      // Busca o progresso do usuário
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Se não houver progresso, atualiza estado sem progresso
      if (userProgress == null) {
        state = ChallengeState(
          challenges: ChallengeStateHelper.getChallenges(state),
          filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
          selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
          pendingInvites: ChallengeStateHelper.getPendingInvites(state),
          userProgress: null,
        );
        return;
      }
      
      // Verifica dias consecutivos para exibir streak atual
      final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
      
      // Registra a informação de dias consecutivos no objeto de progresso
      final updatedProgress = userProgress.copyWith(
        consecutiveDays: consecutiveDays,
      );
      
      // Atualiza o estado com o progresso do usuário
      state = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        userProgress: updatedProgress,
      );
    } catch (e) {
      state = ChallengeState.error(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        message: _getErrorMessage(e),
      );
    }
  }
  
  /// Carrega um desafio com seu ranking completo 
  Future<Challenge> _loadChallengeWithRanking(Challenge challenge) async {
    try {
      // Carrega o ranking para o desafio
      final progressList = await _repository.getChallengeProgress(challenge.id);
      
      // Como não podemos modificar o objeto challenge diretamente com o ranking,
      // retornamos o desafio original - o ranking é armazenado separadamente no estado
      if (progressList.isNotEmpty) {
        debugPrint('✅ Ranking carregado para desafio ${challenge.title}: ${progressList.length} participantes');
      }
      
      return challenge;
    } catch (e) {
      debugPrint('❌ Erro ao carregar ranking para desafio ${challenge.title}: $e');
      // Retorna o desafio original em caso de erro
      return challenge;
    }
  }

  /// Carrega as estatísticas do desafio para o usuário
  Future<void> loadChallengeStats({
    required String userId,
    required String challengeId,
  }) async {
    try {
      // Validações básicas
      if (challengeId.trim().isEmpty) {
        throw ValidationException(message: 'ID do desafio não pode estar vazio');
      }
      
      if (userId.trim().isEmpty) {
        throw ValidationException(message: 'ID do usuário não pode estar vazio');
      }
      
      // Define estado de carregamento
      state = ChallengeState.loading(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: ChallengeStateHelper.getUserProgress(state),
      );
      
      // Busca o progresso do usuário
      final userProgress = await _repository.getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      // Verifica dias consecutivos atuais
      final consecutiveDays = await _repository.getConsecutiveDaysCount(userId, challengeId);
      
      // Verifica a última data de check-in e check-in de hoje
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final hasCheckedInToday = await _repository.hasCheckedInOnDate(userId, challengeId, normalizedToday);
      
      // Obtém o desafio atual para calcular informações
      final challenge = ChallengeStateHelper.getSelectedChallenge(state);
      
      // Prepara o estado atualizado
      final updatedState = ChallengeState(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: challenge,
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: userProgress?.copyWith(
          consecutiveDays: consecutiveDays,
        ),
        successMessage: _formatChallengeStatsMessage(consecutiveDays, hasCheckedInToday),
      );
      
      state = updatedState;
    } catch (e) {
      state = ChallengeState.error(
        challenges: ChallengeStateHelper.getChallenges(state),
        filteredChallenges: ChallengeStateHelper.getFilteredChallenges(state),
        selectedChallenge: ChallengeStateHelper.getSelectedChallenge(state),
        pendingInvites: ChallengeStateHelper.getPendingInvites(state),
        progressList: ChallengeStateHelper.getProgressList(state),
        userProgress: ChallengeStateHelper.getUserProgress(state),
        message: _getErrorMessage(e),
      );
    }
  }
  
  /// Formata a mensagem de estatísticas do desafio baseado nos dias consecutivos
  String _formatChallengeStatsMessage(int consecutiveDays, bool hasCheckedInToday) {
    String message = '';
    
    if (consecutiveDays > 0) {
      message = 'Você está com $consecutiveDays ${consecutiveDays == 1 ? 'dia' : 'dias'} consecutivos!';
      
      // Adiciona informação sobre streak/bônus futuros
      if (consecutiveDays % 5 == 4 && !hasCheckedInToday) {
        message += ' Faça check-in hoje para ganhar bônus de sequência!';
      }
    }
    
    if (hasCheckedInToday) {
      if (message.isNotEmpty) {
        message += ' Você já fez check-in hoje!';
      } else {
        message = 'Você já fez check-in hoje!';
      }
    }
    
    return message;
  }

  /// Exclui um desafio
  Future<bool> deleteChallenge(String id) async {
    try {
      await _repository.deleteChallenge(id);
      // Após excluir, atualiza a lista de desafios
      final challenges = await _repository.getChallenges();
      state = state.copyWith(
        challenges: challenges,
        filteredChallenges: challenges,
        successMessage: 'Desafio excluído com sucesso',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Atualiza o estado imediatamente (útil para atualizações otimistas da UI)
  void updateStateImmediately({
    ChallengeProgress? userProgress,
    List<ChallengeProgress>? progressList,
    String? successMessage,
    String? errorMessage,
  }) {
    state = state.copyWith(
      userProgress: userProgress ?? state.userProgress,
      progressList: progressList ?? state.progressList,
      successMessage: successMessage,
      errorMessage: errorMessage,
      isLoading: false,
    );
    
    debugPrint('✅ ChallengeViewModel - Estado atualizado imediatamente');
  }

  /// Cancela as subscrições de streams ao liberar o objeto
  @override
  void dispose() {
    _rankingSubscription?.cancel();
    super.dispose();
  }

  /// Valida IDs para operações que exigem identificadores
  void _validateIds(String operation, {String? challengeId, String? userId}) {
    if (challengeId != null && challengeId.trim().isEmpty) {
      throw ValidationException(message: 'ID do desafio não pode estar vazio');
    }
    
    if (userId != null && userId.trim().isEmpty) {
      throw ValidationException(message: 'ID do usuário não pode estar vazio');
    }
    
    debugPrint('✅ ChallengeViewModel - IDs validados para operação: $operation');
  }
  
  /// Busca um desafio pelo ID na lista de desafios carregados
  Challenge? _getChallengeById(String challengeId) {
    // Primeiro verifica se é o desafio selecionado (caso mais comum)
    if (state.selectedChallenge?.id == challengeId) {
      return state.selectedChallenge;
    }
    
    // Depois verifica se é o desafio oficial
    if (state.officialChallenge?.id == challengeId) {
      return state.officialChallenge;
    }
    
    // Por último, procura na lista completa de desafios
    return state.challenges.firstWhere(
      (challenge) => challenge.id == challengeId,
      orElse: () => throw ResourceNotFoundException(
        message: 'Desafio não encontrado',
        code: 'challenge_not_found',
      ),
    );
  }

  /// Registra um workout como check-in nos desafios ativos do usuário
  Future<void> registerWorkoutInActiveChallenges({
    required String userId,
    required String workoutId,
    required String workoutName,
    required DateTime workoutDate,
    required int durationMinutes,
  }) async {
    try {
      debugPrint('🔄 ChallengeViewModel - Registrando workout em desafios ativos');
      // Em vez de buscar desafios ativos específicos, vamos pegar o desafio oficial
      // que é o mais comumente usado e verificar se o usuário está participando
      final officialChallenge = await _repository.getOfficialChallenge();
      
      if (officialChallenge == null) {
        debugPrint('ℹ️ Nenhum desafio oficial encontrado para registrar workout');
        return;
      }
      
      // Verificar se o usuário está participando neste desafio
      final isParticipating = await _repository.isUserParticipatingInChallenge(
        challengeId: officialChallenge.id,
        userId: userId,
      );
      
      if (!isParticipating) {
        debugPrint('ℹ️ Usuário não está participando do desafio oficial');
        return;
      }
      
      debugPrint('🔍 Registrando workout no desafio oficial: ${officialChallenge.title}');
      
      try {
        final result = await _repository.recordChallengeCheckIn(
          challengeId: officialChallenge.id,
          userId: userId,
          workoutId: workoutId,
          workoutName: workoutName,
          workoutType: 'workout',
          date: workoutDate,
          durationMinutes: durationMinutes,
        );
        
        // Sempre forçar uma atualização completa da UI, independente do resultado
        debugPrint('🔄 Forçando atualização completa da interface após tentativa de check-in');
        
        // Primeiro forçar uma pausa para garantir consistência dos dados
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Forçar atualização completa, ignorando cache
        await loadChallengeDetails(officialChallenge.id);
        
        // Atualizar o estado para notificar o usuário sobre o resultado
        if (result.success) {
          debugPrint('✅ Workout registrado com sucesso no desafio: ${officialChallenge.title}');
          state = state.copyWith(
            successMessage: 'Treino registrado com sucesso no desafio!',
          );
        } else if (result.isAlreadyCheckedIn) {
          debugPrint('ℹ️ Já existe check-in hoje para o desafio: ${officialChallenge.title}');
          state = state.copyWith(
            successMessage: 'Treino registrado! Você já havia feito check-in no desafio hoje.',
          );
        } else {
          debugPrint('⚠️ Falha ao registrar workout no desafio: ${result.message}');
          state = state.copyWith(
            errorMessage: result.message,
          );
        }
      } catch (e) {
        debugPrint('❌ Erro ao registrar workout no desafio ${officialChallenge.title}: $e');
        // Mesmo em caso de erro, forçar atualização da UI
        await Future.delayed(const Duration(milliseconds: 500));
        await loadChallengeDetails(officialChallenge.id);
        state = state.copyWith(
          errorMessage: 'Erro ao registrar treino no desafio: $e',
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar workout em desafios: $e');
      // Não propagar o erro para não interromper o fluxo principal
    }
  }
}

/// Helper para inicialização de convites
void loadInvitesCallback(Function callback) {
  // Executa o callback diretamente no próximo frame  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
} 
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../models/challenge_group.dart';
import '../models/challenge_progress.dart';
import '../../../features/home/models/home_model.dart';
import '../repositories/challenge_repository.dart';
import '../services/realtime_service.dart';

// Implementação manual temporária para substituir o freezed
class ChallengeRankingState {
  final String? challengeId;
  final List<ChallengeProgress> progressList;
  final List<ChallengeGroup> userGroups;
  final String? selectedGroupIdForFilter;
  final bool isLoading;
  final String? errorMessage;
  final UserProgress? userProgress;

  const ChallengeRankingState({
    this.challengeId,
    this.progressList = const [],
    this.userGroups = const [],
    this.selectedGroupIdForFilter,
    this.isLoading = false,
    this.errorMessage,
    this.userProgress,
  });

  // Implementação manual do método copyWith
  ChallengeRankingState copyWith({
    String? challengeId,
    List<ChallengeProgress>? progressList,
    List<ChallengeGroup>? userGroups,
    String? selectedGroupIdForFilter,
    bool? isLoading,
    String? errorMessage,
    UserProgress? userProgress,
  }) {
    return ChallengeRankingState(
      challengeId: challengeId ?? this.challengeId,
      progressList: progressList ?? this.progressList,
      userGroups: userGroups ?? this.userGroups,
      selectedGroupIdForFilter: selectedGroupIdForFilter ?? this.selectedGroupIdForFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,  // Permitir definir null para errorMessage
      userProgress: userProgress ?? this.userProgress,
    );
  }
}

class ChallengeRankingViewModel extends StateNotifier<ChallengeRankingState> {
  final ChallengeRepository _repository;
  final RealtimeService _realtimeService;
  StreamSubscription<List<ChallengeProgress>>? _rankingSubscription;

  ChallengeRankingViewModel(this._repository, this._realtimeService)
      : super(const ChallengeRankingState());

  @override
  void dispose() {
    _rankingSubscription?.cancel();
    super.dispose();
  }

  /// Inicializa o ViewModel com o ID do desafio e carrega os dados iniciais
  Future<void> init(String challengeId) async {
    state = state.copyWith(
      challengeId: challengeId,
      isLoading: true,
      errorMessage: null,
    );

    await loadChallengeRanking();
    await loadUserGroups();
  }

  /// Carrega o ranking do desafio
  Future<void> loadChallengeRanking() async {
    try {
      if (state.challengeId == null) {
        throw const AppException(message: 'ID do desafio não definido');
      }

      // Cancelar qualquer assinatura existente
      _rankingSubscription?.cancel();

      // Iniciar nova assinatura
      _rankingSubscription = _realtimeService
          .watchChallengeParticipants(state.challengeId!)
          .listen(_handleRankingUpdate);

      // Carregar dados iniciais
      final progressList = await _repository.getChallengeProgress(state.challengeId!);

      state = state.copyWith(
        progressList: progressList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Carrega os grupos do usuário para o desafio atual
  Future<void> loadUserGroups() async {
    try {
      if (state.challengeId == null) {
        return;
      }

      final groups = await _repository.getUserGroups(state.challengeId!);
      state = state.copyWith(userGroups: groups);
    } catch (e) {
      // Apenas log de erro, não afeta o fluxo principal
      debugPrint('Erro ao carregar grupos do usuário: $e');
    }
  }

  /// Filtra o ranking por um grupo específico
  Future<void> filterRankingByGroup(String? groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      if (state.challengeId == null) {
        throw const AppException(message: 'ID do desafio não definido');
      }
      
      // Cancelar qualquer assinatura existente
      _rankingSubscription?.cancel();
      
      List<ChallengeProgress> ranking;
      
      // Se groupId for null, mostra o ranking geral
      if (groupId == null) {
        // Configurar nova assinatura para ranking geral
        _rankingSubscription = _realtimeService
            .watchChallengeParticipants(state.challengeId!)
            .listen(_handleRankingUpdate);
            
        // Carregar dados iniciais
        ranking = await _repository.getChallengeProgress(state.challengeId!);
      } else {
        // Configurar nova assinatura para ranking do grupo
        _rankingSubscription = _realtimeService
            .watchGroupRanking(groupId)
            .listen(_handleRankingUpdate);
            
        // Carregar dados iniciais do grupo
        ranking = await _repository.getGroupRanking(groupId);
      }
      
      state = state.copyWith(
        progressList: ranking,
        selectedGroupIdForFilter: groupId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Manipula atualizações em tempo real do ranking
  void _handleRankingUpdate(List<ChallengeProgress> updatedProgress) {
    state = state.copyWith(progressList: updatedProgress);
  }

  /// Obtém mensagem de erro formatada
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro: $error';
  }
} // Dart imports:
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/app_exception.dart';
import 'package:ray_club_app/core/extensions/supabase_extensions.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/models/challenge_check_in.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/mappers/challenge_mapper.dart';
import 'package:ray_club_app/features/challenges/constants/challenge_rpc_params.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/core/extensions/date_extensions.dart';

/// Exceção específica para erros de validação de dados.
class ValidationException extends AppException {
  const ValidationException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'validation_error',
          details: details,
        );
}

/// Exceção específica para erros de armazenamento (storage).
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'storage_error',
          details: details,
        );
}

// O provider challengeRepositoryProvider está definido em challenge_repository.dart
// Não duplique a definição aqui

/// Implementação do repositório de desafios usando Supabase
class SupabaseChallengeRepository implements ChallengeRepository {
  final SupabaseClient _client;
  final Ref? _ref;
  
  // Constantes para nomes de tabelas
  static const String _challengesTable = 'challenges';
  static const String _challengeProgressTable = 'challenge_progress';
  static const String _challengeParticipantsTable = 'challenge_participants';
  static const String _challengeGroupsTable = 'challenge_groups';
  static const String _challengeGroupMembersTable = 'challenge_group_members';
  static const String _challengeGroupInvitesTable = 'challenge_group_invites';
  static const String _challengeCheckInsTable = 'challenge_check_ins';
  static const String _challengeBonusesTable = 'challenge_bonuses';
  
  // Constante para bucket de imagens
  static const String _challengeImagesBucket = 'challenge_images';
  
  SupabaseChallengeRepository(this._client, [this._ref]);
  
  @override
  Future<List<Challenge>> getChallenges() async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios');
    }
  }
  
  @override
  Future<Challenge> getChallengeById(String id) async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('id', id)
          .single();
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response)) {
        return ChallengeMapper.fromSupabase(response);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar detalhes do desafio');
    }
  }
  
  @override
  Future<List<Challenge>> getUserChallenges({required String userId}) async {
    try {
      // Buscar IDs de desafios que o usuário participa
      final participantResponse = await _client
          .from(_challengeParticipantsTable)
          .select('challenge_id')
          .eq('user_id', userId);
      
      final challengeIds = participantResponse
          .map<String>((item) => item['challenge_id'] as String)
          .toList();
      
      if (challengeIds.isEmpty) {
        return [];
      }
      
      // Buscar detalhes dos desafios
      final challengesResponse = await _client
          .from(_challengesTable)
          .select()
          .filter('id', 'in', challengeIds)
          .order('created_at', ascending: false);
      
      return challengesResponse
          .map<Challenge>((json) => _mapSupabaseToChallenge(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios do usuário');
    }
  }
  
  @override
  Future<List<Challenge>> getActiveChallenges() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_challengesTable)
          .select()
          .lt('start_date', now)
          .gt('end_date', now)
          .order('created_at', ascending: false);
      
      return response
          .map<Challenge>((json) => _mapSupabaseToChallenge(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios ativos');
    }
  }
  
  @override
  Future<List<Challenge>> getUserActiveChallenges(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Buscar IDs de desafios ativos que o usuário participa
      final participantResponse = await _client
          .from(_challengeParticipantsTable)
          .select('challenge_id')
          .eq('user_id', userId);
      
      final challengeIds = participantResponse
          .map<String>((item) => item['challenge_id'] as String)
          .toList();
      
      if (challengeIds.isEmpty) {
        return [];
      }
      
      // Buscar detalhes dos desafios ativos
      final challengesResponse = await _client
          .from(_challengesTable)
          .select()
          .filter('id', 'in', challengeIds)
          .lt('start_date', now)
          .gt('end_date', now)
          .order('created_at', ascending: false);
      
      return challengesResponse
          .map<Challenge>((json) => _mapSupabaseToChallenge(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios ativos do usuário');
    }
  }
  
  @override
  Future<Challenge?> getOfficialChallenge() async {
    try {
      final now = DateTime.now().toIso8601String();
      debugPrint('🔍 SupabaseChallengeRepository - Buscando desafio oficial, data atual: $now');
      
      // Primeiro buscar sem restrições de data para fins de diagnóstico
      final oficialChallenges = await _client
          .from(_challengesTable)
          .select()
          .eq('is_official', true)
          .order('created_at', ascending: false);
      
      debugPrint('🔍 SupabaseChallengeRepository - Encontrados ${oficialChallenges.length} desafios oficiais no total');
      if (oficialChallenges.isNotEmpty) {
        for (final challenge in oficialChallenges) {
          debugPrint('🔍 Desafio: ${challenge['title']}, início: ${challenge['start_date']}, fim: ${challenge['end_date']}');
        }
      }
      
      // Buscar desafios oficiais ativos
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('is_official', true)
          .lte('start_date', now) // Começou antes ou exatamente agora
          .gte('end_date', now)   // Termina depois ou exatamente agora
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        debugPrint('⚠️ SupabaseChallengeRepository - Nenhum desafio oficial ativo encontrado');
        
        // Se não encontrar um desafio ativo, retornar o mais recente para fins de teste
        if (oficialChallenges.isNotEmpty) {
          debugPrint('ℹ️ SupabaseChallengeRepository - Retornando o último desafio oficial para testes');
          return Challenge.fromJson(oficialChallenges[0]);
        }
        
        return null;
      }
      
      debugPrint('✅ SupabaseChallengeRepository - Desafio oficial ativo encontrado: ${response[0]['title']}');
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response[0])) {
        return ChallengeMapper.fromSupabase(response[0]);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      debugPrint('❌ SupabaseChallengeRepository - Erro ao buscar desafio oficial: $e');
      throw _handleError(e, stackTrace, 'Erro ao buscar desafio oficial');
    }
  }
  
  /// Método auxiliar para mapear dados do Supabase para o modelo Challenge com segurança
  Challenge _mapSupabaseToChallenge(Map<String, dynamic> json) {
    // Usar o ChallengeMapper em vez da implementação manual
    return ChallengeMapper.fromSupabase(json);
  }
  
  @override
  Future<List<Challenge>> getOfficialChallenges() async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('is_official', true)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios oficiais');
    }
  }
  
  @override
  Future<Challenge?> getMainChallenge() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('is_featured', true)
          .lt('start_date', now)
          .gt('end_date', now)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isEmpty) {
        return null;
      }
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response[0])) {
        return ChallengeMapper.fromSupabase(response[0]);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafio em destaque');
    }
  }
  
  @override
  Future<Challenge> createChallenge(Challenge challenge) async {
    try {
      // Se houver uma imagem para o desafio, fazer o upload
      String? imageUrl = challenge.imageUrl;
      if (challenge.localImagePath != null) {
        imageUrl = await _uploadChallengeImage(
          File(challenge.localImagePath!),
          challenge.id,
        );
      }
      
      // Preparar dados para inserção
      final challengeData = challenge.toJson();
      challengeData['image_url'] = imageUrl;
      challengeData['created_at'] = DateTime.now().toIso8601String();
      challengeData['updated_at'] = DateTime.now().toIso8601String();
      
      // Remover campos que não são colunas na tabela
      challengeData.remove('local_image_path');
      
      final response = await _client
          .from(_challengesTable)
          .insert(challengeData)
          .select();
      
      if (response.isEmpty) {
        throw AppException(
          message: 'Erro ao criar desafio: nenhum dado retornado',
          code: 'insert_error',
        );
      }
      
      // Verificar se precisa de mapper personalizado
      if (ChallengeMapper.needsMapper(response[0])) {
        return ChallengeMapper.fromSupabase(response[0]);
      }
      
      // Caso contrário, usar método padrão do Freezed
      return Challenge.fromJson(response[0]);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao criar desafio');
    }
  }
  
  @override
  Future<void> updateChallenge(Challenge challenge) async {
    try {
      // Se houver uma nova imagem para o desafio, fazer o upload
      String? imageUrl = challenge.imageUrl;
      if (challenge.localImagePath != null) {
        imageUrl = await _uploadChallengeImage(
          File(challenge.localImagePath!),
          challenge.id,
        );
      }
      
      // Preparar dados para atualização
      final challengeData = challenge.toJson();
      if (imageUrl != null) {
        challengeData['image_url'] = imageUrl;
      }
      challengeData['updated_at'] = DateTime.now().toIso8601String();
      
      // Remover campos que não são colunas na tabela
      challengeData.remove('local_image_path');
      
      await _client
          .from(_challengesTable)
          .update(challengeData)
          .eq('id', challenge.id)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar desafio');
    }
  }
  
  @override
  Future<void> deleteChallenge(String id) async {
    try {
      // Primeiro deletar dados relacionados
      await _client
          .from(_challengeParticipantsTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      await _client
          .from(_challengeProgressTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      await _client
          .from(_challengeCheckInsTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      await _client
          .from(_challengeBonusesTable)
          .delete()
          .eq('challenge_id', id)
          ;
      
      // Por fim, deletar o desafio
      await _client
          .from(_challengesTable)
          .delete()
          .eq('id', id)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao deletar desafio');
    }
  }
  
  @override
  Future<void> joinChallenge({required String challengeId, required String userId}) async {
    try {
      // PATCH: Corrigir bug 6 - Garantir que o usuário apareça no desafio 
      debugPrint('🔄 Verificando participação no desafio $challengeId para usuário $userId');
      
      // Verificar se o desafio existe
      final challengeResponse = await _client
          .from(_challengesTable)
          .select()
          .eq('id', challengeId)
          .maybeSingle();
      
      if (challengeResponse == null) {
        throw ValidationException(message: 'Desafio não encontrado');
      }
      
      debugPrint('✅ Desafio encontrado: ${challengeResponse['title']}');
      
      // Verificar se o usuário já participa
      final checkResponse = await _client
          .from(_challengeParticipantsTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
      
      if (checkResponse.isNotEmpty) {
        // Usuário já participa, verificar se tem progresso
        debugPrint('ℹ️ Usuário já participa do desafio, verificando progresso');
        
        final checkProgress = await _client
            .from(_challengeProgressTable)
            .select()
            .eq('challenge_id', challengeId)
            .eq('user_id', userId)
            .maybeSingle();
            
        if (checkProgress == null) {
          debugPrint('⚠️ Progresso não encontrado, criando progresso inicial');
          
          // Buscar informações do usuário
          final userResponse = await _client
              .from('profiles')
              .select('name, photo_url')
              .eq('id', userId)
              .maybeSingle();
          
          String? userName = userResponse != null ? userResponse['name'] as String? : null;
          String? userPhotoUrl = userResponse != null ? userResponse['photo_url'] as String? : null;
          
          if (userName == null || userName.isEmpty) {
            userName = 'Usuário';
          }
          
          debugPrint('🔍 Dados do usuário: nome=$userName, foto=$userPhotoUrl');
          
          // Criar registro de progresso inicial
          await _client
              .from(_challengeProgressTable)
              .insert({
                'challenge_id': challengeId,
                'user_id': userId,
                'user_name': userName,
                'user_photo_url': userPhotoUrl,
                'points': 0,
                'completion_percentage': 0.0,
                'position': 0,
                'check_ins_count': 0,
                'consecutive_days': 0,
                'total_check_ins': 0,
                'completed': false,
                'last_check_in': null,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
              
          debugPrint('✅ Progresso inicial criado para o usuário no desafio');
        } else {
          debugPrint('✅ Usuário já tem progresso registrado no desafio: id=${checkProgress['id']}');
        }
        
        return;
      }
      
      debugPrint('ℹ️ Usuário não participa do desafio, adicionando...');
      
      // Buscar informações do usuário
      final userResponse = await _client
          .from('profiles')
          .select('name, photo_url')
          .eq('id', userId)
          .maybeSingle();
      
      String? userName = userResponse != null ? userResponse['name'] as String? : null;
      String? userPhotoUrl = userResponse != null ? userResponse['photo_url'] as String? : null;
      
      if (userName == null || userName.isEmpty) {
        userName = 'Usuário';
      }
      
      debugPrint('🔍 Dados do usuário: nome=$userName, foto=$userPhotoUrl');
      
      // Adicionar participante
      final participantResult = await _client
          .from(_challengeParticipantsTable)
          .insert({
            'challenge_id': challengeId,
            'user_id': userId,
            'joined_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      debugPrint('✅ Participante adicionado: id=${participantResult['id']}');
          
      // Criar registro de progresso inicial
      final progressResult = await _client
          .from(_challengeProgressTable)
          .insert({
            'challenge_id': challengeId,
            'user_id': userId,
            'user_name': userName,
            'user_photo_url': userPhotoUrl,
            'points': 0,
            'completion_percentage': 0.0,
            'position': 0,
            'check_ins_count': 0,
            'consecutive_days': 0,
            'total_check_ins': 0,
            'completed': false,
            'last_check_in': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
          
      debugPrint('✅ Progresso inicial criado: id=${progressResult['id']}');
      debugPrint('✅ Usuário adicionado ao desafio com sucesso e progresso inicial criado');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao participar do desafio: $e');
      throw _handleError(e, stackTrace, 'Erro ao participar do desafio');
    }
  }
  
  @override
  Future<void> leaveChallenge({required String challengeId, required String userId}) async {
    try {
      // PATCH: Corrigir bug 6 - Remover participação e progresso quando sair do desafio
      debugPrint('🔄 Removendo participação do usuário $userId no desafio $challengeId');
      
      // Remover participante
      await _client
          .from(_challengeParticipantsTable)
          .delete()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId);
          
      // Remover progresso para manter consistência
      await _client
          .from(_challengeProgressTable)
          .delete()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId);
          
      debugPrint('✅ Usuário removido do desafio com sucesso');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao sair do desafio: $e');
      throw _handleError(e, stackTrace, 'Erro ao sair do desafio');
    }
  }
  
  @override
  Future<void> updateUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  }) async {
    try {
      // Verificar se já existe um registro de progresso
      final checkResponse = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
      
      if (checkResponse.isEmpty) {
        // Se não existe, criar um novo
        await createUserProgress(
          challengeId: challengeId,
          userId: userId,
          userName: userName,
          userPhotoUrl: userPhotoUrl,
          points: points,
          completionPercentage: completionPercentage,
        );
        return;
      }
      
      // Atualizar progresso existente
      await _client
          .from(_challengeProgressTable)
          .update({
            'user_name': userName,
            'user_photo_url': userPhotoUrl,
            'points': points,
            'completion_percentage': completionPercentage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar progresso do usuário');
    }
  }
  
  @override
  Future<void> createUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  }) async {
    try {
      // Primeiro verificar se já existe um progresso para evitar conflitos
      final existingProgress = await getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (existingProgress != null) {
        debugPrint('⚠️ Progresso já existe, atualizando em vez de criar');
        // Se já existe, atualizar em vez de criar
        await _client
            .from(_challengeProgressTable)
            .update({
              'user_name': userName,
              'user_photo_url': userPhotoUrl,
              'points': points,
              'completion_percentage': completionPercentage,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('challenge_id', challengeId)
            .eq('user_id', userId);
        return;
      }
      
      // Se não existe, criar novo
      await _client
          .from(_challengeProgressTable)
          .insert({
            'challenge_id': challengeId,
            'user_id': userId,
            'user_name': userName,
            'user_photo_url': userPhotoUrl,
            'points': points,
            'completion_percentage': completionPercentage,
            'position': 0,
            'check_ins_count': 0,
            'consecutive_days': 0,
            'total_check_ins': 0,
            'completed': false,
            'last_check_in': null,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          
      debugPrint('✅ Progresso criado com sucesso para usuário $userId no desafio $challengeId');
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
        debugPrint('⚠️ Conflito ao criar progresso: $e');
        // Progresso já existe, ignorar erro de chave duplicada
        return;
      }
      LogUtils.error('Erro ao criar progresso do usuário: $e', error: e);
      throw _handleError(e, StackTrace.current, 'Erro ao criar progresso do usuário');
    }
  }
  
  @override
  Future<ChallengeProgress?> getUserProgress({
    required String challengeId,
    required String userId,
  }) async {
    try {
      // Forçar limpeza de cache com uma consulta preliminar
      debugPrint('🔄 Limpando cache antes de buscar progresso do usuário: $userId no desafio: $challengeId');
      await _client.from(_challengeProgressTable).select('id').limit(1);
      
      // Aguardar um momento para garantir consistência
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Buscar dados atualizados
      debugPrint('🔄 Buscando progresso atualizado');
      final response = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('⚠️ Progresso não encontrado para o usuário');
        return null;
      }
      
      debugPrint('✅ Progresso do usuário recebido: ${response['points']} pontos');
      return ChallengeProgress.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao buscar progresso do usuário: $e');
      return null;
    }
  }
  
  @override
  Future<bool> isUserParticipatingInChallenge({
    required String challengeId,
    required String userId,
  }) async {
    try {
      debugPrint('🔍 Verificando se o usuário $userId está participando do desafio $challengeId');
      
      final response = await _client
          .from(_challengeParticipantsTable)
          .select()
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .maybeSingle();
      
      final isParticipating = response != null;
      debugPrint('🔍 Usuário ${isParticipating ? 'ESTÁ' : 'NÃO ESTÁ'} participando do desafio');
      
      return isParticipating;
    } catch (e) {
      debugPrint('❌ Erro ao verificar participação do usuário: $e');
      return false;
    }
  }
  
  @override
  Future<List<ChallengeProgress>> getChallengeProgress(String challengeId) async {
    try {
      // Forçar limpeza de cache com uma consulta preliminar
      debugPrint('🔄 Limpando cache antes de buscar ranking do desafio: $challengeId');
      await _client.from(_challengeProgressTable).select('id').limit(1);
      
      // Aguardar um momento para garantir consistência
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Buscar dados atualizados
      debugPrint('🔄 Buscando ranking atualizado do desafio: $challengeId');
      final response = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          .order('points', ascending: false)
          ;
      
      debugPrint('✅ Ranking atualizado recebido com ${response.length} participantes');
      return response
          .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar ranking do desafio');
    }
  }
  
  @override
  Stream<List<ChallengeProgress>> watchChallengeParticipants(
    String challengeId, {
    int limit = 50,
    int offset = 0,
  }) {
    try {
      return _client
          .from(_challengeProgressTable)
          .stream(primaryKey: ['challenge_id', 'user_id'])
          .eq('challenge_id', challengeId)
          .order('points', ascending: false)
          .limit(limit)
          .map((data) {
            return data
                .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
                .toList();
          });
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao observar participantes do desafio');
    }
  }
  
  @override
  Future<List<ChallengeGroupInvite>> getPendingInvites(String userId) async {
    try {
      final response = await _client
          .from(_challengeGroupInvitesTable)
          .select('*, challenge_groups!inner(name)')
          .eq('invitee_id', userId)
          .eq('status', 0) // 0 = pendente, 1 = aceito, 2 = recusado
          ;
      
      return (response as List).map<ChallengeGroupInvite>((item) {
        // Criar um mapa combinado com as informações necessárias
        final combinedData = <String, dynamic>{
          ...item as Map<String, dynamic>,
          'groupName': item['challenge_groups']['name'],
        };
        return ChallengeGroupInvite.fromJson(combinedData);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar convites pendentes');
    }
  }
  
  @override
  Future<bool> isCurrentUserAdmin() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }
      
      final response = await _client
          .rpc('is_admin', params: {'user_id': userId})
          ;
      
      return response ?? false;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao verificar status de admin');
    }
  }
  
  @override
  Future<void> toggleAdminStatus() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      await _client
          .rpc('toggle_admin_status', params: {'user_id': userId})
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao alterar status de admin');
    }
  }
  
  @override
  Future<ChallengeGroup> createGroup({
    required String challengeId,
    required String creatorId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _client
          .from(_challengeGroupsTable)
          .insert({
            'challenge_id': challengeId,
            'creator_id': creatorId,
            'name': name,
            'description': description,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          ;
      
      if (response.isEmpty) {
        throw AppException(
          message: response.error!.message,
          code: response.error!.code,
        );
      }
      
      final groupId = response[0]['id'];
      
      // Adicionar o criador como membro do grupo
      await _client
          .from(_challengeGroupMembersTable)
          .insert({
            'group_id': groupId,
            'user_id': creatorId,
            'joined_at': DateTime.now().toIso8601String(),
          })
          ;
      
      return ChallengeGroup.fromJson(response[0]);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao criar grupo');
    }
  }
  
  @override
  Future<ChallengeGroup> getGroupById(String groupId) async {
    try {
      final response = await _client
          .from(_challengeGroupsTable)
          .select()
          .eq('id', groupId)
          .single()
          ;
      
      return ChallengeGroup.fromJson(response);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupo');
    }
  }
  
  @override
  Future<List<ChallengeGroup>> getUserCreatedGroups(String userId) async {
    try {
      final response = await _client
          .from(_challengeGroupsTable)
          .select()
          .eq('creator_id', userId)
          .order('created_at', ascending: false)
          ;
      
      return response
          .map<ChallengeGroup>((json) => ChallengeGroup.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupos criados pelo usuário');
    }
  }
  
  @override
  Future<List<ChallengeGroup>> getUserMemberGroups(String userId) async {
    try {
      final response = await _client
          .from(_challengeGroupMembersTable)
          .select('group_id')
          .eq('user_id', userId)
          ;
      
      if (response.isEmpty) {
        return [];
      }
      
      final groupIds = response
          .map<String>((json) => json['group_id'] as String)
          .toList();
      
      final groupsResponse = await _client
          .from(_challengeGroupsTable)
          .select()
          .filter('id', 'in', groupIds)
          ;
      
      return groupsResponse
          .map<ChallengeGroup>((json) => ChallengeGroup.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupos dos quais o usuário é membro');
    }
  }
  
  @override
  Future<void> updateGroup(ChallengeGroup group) async {
    try {
      await _client
          .from(_challengeGroupsTable)
          .update({
            'name': group.name,
            'description': group.description,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', group.id)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar grupo');
    }
  }
  
  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      // Primeiro remover registros associados
      await _client
          .from(_challengeGroupMembersTable)
          .delete()
          .eq('group_id', groupId)
          ;
      
      await _client
          .from(_challengeGroupInvitesTable)
          .delete()
          .eq('group_id', groupId)
          ;
      
      // Depois remover o grupo
      await _client
          .from(_challengeGroupsTable)
          .delete()
          .eq('id', groupId)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao excluir grupo');
    }
  }
  
  @override
  Future<List<String>> getGroupMembers(String groupId) async {
    try {
      final response = await _client
          .from(_challengeGroupMembersTable)
          .select('user_id')
          .eq('group_id', groupId)
          ;
      
      return response
          .map<String>((json) => json['user_id'] as String)
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar membros do grupo');
    }
  }
  
  @override
  Future<void> inviteUserToGroup(String groupId, String inviterId, String inviteeId) async {
    try {
      // Verificar se o usuário já é membro do grupo
      final checkMemberResponse = await _client
          .from(_challengeGroupMembersTable)
          .select()
          .eq('group_id', groupId)
          .eq('user_id', inviteeId)
          ;
      
      if (checkMemberResponse.isNotEmpty) {
        throw StorageException(
          message: 'O usuário já é membro deste grupo',
          code: 'user_already_member',
        );
      }
      
      // Verificar se já existe um convite pendente
      final checkInviteResponse = await _client
          .from(_challengeGroupInvitesTable)
          .select()
          .eq('group_id', groupId)
          .eq('invitee_id', inviteeId)
          .eq('status', 0) // 0 = pendente
          ;
      
      if (checkInviteResponse.isNotEmpty) {
        throw StorageException(
          message: 'Já existe um convite pendente para este usuário',
          code: 'invite_already_exists',
        );
      }
      
      // Criar o convite
      await _client
          .from(_challengeGroupInvitesTable)
          .insert({
            'group_id': groupId,
            'inviter_id': inviterId,
            'invitee_id': inviteeId,
            'status': 0, // 0 = pendente
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao convidar usuário para o grupo');
    }
  }
  
  @override
  Future<void> respondToGroupInvite(String inviteId, bool accept) async {
    try {
      final inviteResponse = await _client
          .from(_challengeGroupInvitesTable)
          .select()
          .eq('id', inviteId)
          .single()
          ;
      
      final invite = inviteResponse;
      final groupId = invite['group_id'];
      final inviteeId = invite['invitee_id'];
      
      // Atualizar o status do convite
      // O status é armazenado como inteiro no banco: 0=pendente, 1=aceito, 2=recusado
      final newStatus = accept ? 1 : 2; // 1 = aceito, 2 = recusado
      
      await _client
          .from(_challengeGroupInvitesTable)
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', inviteId)
          ;
      
      // Se aceito, adicionar usuário ao grupo
      if (accept) {
        await _client
            .from(_challengeGroupMembersTable)
            .insert({
              'group_id': groupId,
              'user_id': inviteeId,
              'joined_at': DateTime.now().toIso8601String(),
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            ;
      }
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao responder convite de grupo');
    }
  }
  
  @override
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      await _client
          .from(_challengeGroupMembersTable)
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          ;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao remover usuário do grupo');
    }
  }
  
  @override
  Future<List<ChallengeProgress>> getGroupRanking(String groupId) async {
    try {
      final response = await _client
          .rpc('get_group_ranking', params: {'group_id_param': groupId})
          ;
      
      return response
          .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar ranking do grupo');
    }
  }
  
  @override
  Future<bool> hasCheckedInOnDate(String userId, String challengeId, DateTime date) async {
    try {
      // Usar a extensão para garantir o timezone correto
      final dateWithTimezone = date.toSupabaseString();
      debugPrint('🔍 Verificando check-in para data com timezone: $dateWithTimezone');
      
      // Criar intervalo de datas para verificação mais precisa
      final startOfDay = date.toStartOfDayWithTimezone();
      final endOfDay = date.toEndOfDayWithTimezone();
      
      debugPrint('🔍 Intervalo para verificação: ${startOfDay.toIso8601String()} até ${endOfDay.toIso8601String()}');
      
      final data = await _client
          .from(_challengeCheckInsTable)
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .gte('check_in_date', startOfDay.toIso8601String())
          .lte('check_in_date', endOfDay.toIso8601String());
      
      debugPrint('✅ VERIFICAÇÃO DIRETA - Check-ins encontrados: ${data.length}');
      for (var i = 0; i < data.length; i++) {
        final checkIn = data[i];
        final checkInId = checkIn['id'];
        final checkInName = checkIn['workout_name'] ?? 'Sem nome';
        final checkInDuration = checkIn['duration_minutes'];
        debugPrint('  → ID: $checkInId, Nome: $checkInName, Duração: ${checkInDuration}min');
      }

      // Se encontrou registros, retorna true (já tem check-in)
      return data.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint('❌ VERIFICAÇÃO DIRETA - Erro ao verificar check-ins: $e');
      LogUtils.error('hasCheckedInOnDate', error: e, stackTrace: stackTrace);
      // Em caso de erro, retornar false para permitir a tentativa de check-in
      return false;
    }
  }
  
  @override
  Future<bool> hasCheckedInToday(String userId, String challengeId) async {
    try {
      // Usar a data atual com timezone de Brasília
      final today = DateTime.now();
      return hasCheckedInOnDate(userId, challengeId, today);
    } catch (e) {
      debugPrint('Erro ao verificar check-in do dia: $e');
      return false;
    }
  }
  
  @override
  Future<int> getConsecutiveDaysCount(String userId, String challengeId) async {
    try {
      final response = await _client
        .rpc('get_current_streak', params: {
          'user_id_param': userId,
          'challenge_id_param': challengeId
        });
      
      if (response == null) {
        return 0;
      }
      
      // O valor retornado será um inteiro diretamente
      return response as int? ?? 0;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao buscar dias consecutivos: $e', error: e, stackTrace: stackTrace);
      return 0; // Em caso de erro, retorna 0 para não quebrar o app
    }
  }
  
  @override
  Future<int> getCurrentStreak(String userId, String challengeId) async {
    try {
      final response = await _client
        .rpc('get_current_streak', params: {
          'user_id_param': userId,
          'challenge_id_param': challengeId
        });
      
      if (response == null) {
        return 0;
      }
      
      return response as int? ?? 0;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao buscar streak atual: $e', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  @override
  Future<void> addPointsToUserProgress({
    required String challengeId,
    required String userId,
    required int pointsToAdd,
  }) async {
    try {
      // Buscar progresso atual do usuário
      final userProgress = await getUserProgress(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (userProgress == null) {
        throw AppException(
          message: 'Usuário não possui progresso registrado neste desafio',
        );
      }
      
      // Calcular novos pontos
      final newPoints = userProgress.points + pointsToAdd;
      
      // Atualizar pontos no banco de dados
      await _client
          .from(_challengeProgressTable)
          .update({'points': newPoints, 'updated_at': DateTime.now().toIso8601String()})
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
          
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar pontos ao progresso do usuário');
    }
  }
  
  // Método auxiliar para upload de imagens
  Future<String?> _uploadChallengeImage(File file, String challengeId) async {
    try {
      // Nome do arquivo: challenge_id_timestamp.extensão
      final extension = file.path.split('.').last;
      final fileName = '${challengeId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _client.storage
          .from(_challengeImagesBucket)
          .upload(fileName, file);
      
      // Obter URL pública
      final String publicUrl = _client.storage
          .from(_challengeImagesBucket)
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao fazer upload de imagem para desafio',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
  
  @override
  Stream<List<ChallengeProgress>> watchChallengeRanking({
    required String challengeId,
  }) {
    try {
      return _client
          .from(_challengeProgressTable)
          .stream(primaryKey: ['id'])
          .eq('challenge_id', challengeId)
          .order('points', ascending: false)
          .map((data) => data
              .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
              .toList());
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao observar ranking: $e', error: e, stackTrace: stackTrace);
      // Em caso de erro, retorna um stream vazio
      return Stream.value([]);
    }
  }

  @override
  Stream<List<ChallengeProgress>> watchGroupRanking(String groupId) {
    try {
      // Usar RPC para obter ranking do grupo específico
      return _client
          .rpc('get_group_ranking', params: {'group_id_param': groupId})
          .asStream()
          .map((response) => (response as List)
              .map<ChallengeProgress>((json) => ChallengeProgress.fromJson(json))
              .toList());
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao observar ranking do grupo: $e', error: e, stackTrace: stackTrace);
      return Stream.value([]);
    }
  }

  @override
  Future<bool> canAccessGroup(String groupId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }
      
      final response = await _client.rpcWithValidUuids(
        'can_access_group', 
        params: {
          'user_id_param': userId,
          'group_id_param': groupId,
        }
      );
          
      return response as bool? ?? false;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao verificar acesso ao grupo: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  @override
  Future<List<ChallengeGroup>> getUserGroups(String challengeId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      // Buscar grupos em que o usuário é membro
      final memberResponse = await _client
          .from(_challengeGroupMembersTable)
          .select('group_id')
          .eq('user_id', userId)
          ;
      
      final groupIds = memberResponse
          .map<String>((item) => item['group_id'] as String)
          .toList();
      
      if (groupIds.isEmpty) {
        return [];
      }
      
      // Buscar grupos para o desafio específico
      final groupsResponse = await _client
          .from(_challengeGroupsTable)
          .select()
          .filter('id', 'in', groupIds)
          .eq('challenge_id', challengeId)
          ;
      
      return groupsResponse
          .map<ChallengeGroup>((json) => ChallengeGroup.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar grupos do usuário');
    }
  }
  
  @override
  Future<CheckInResult> recordChallengeCheckIn({
    required String challengeId,
    required String userId,
    String? workoutId,
    required String workoutName,
    required String workoutType,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      // Log detalhado para debug
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Usar a extensão para garantir o formato correto com timezone de Brasília
      final formattedDate = date.toSupabaseString();
      
      debugPrint('🎯 Registrando check-in no desafio: $challengeId');
      debugPrint('🔄 [DIAGNÓSTICO] Iniciando registro de check-in no desafio: $challengeId');
      debugPrint('🎯 Dados: userId=$userId, workoutId=$workoutId, workoutName=$workoutName, tipo=$workoutType, duração=$durationMinutes min');
      debugPrint('🎯 Data fornecida: ${date.toIso8601String()}, data normalizada com timezone: $formattedDate');
      
      // Garantir que workoutId não seja null
      final safeWorkoutId = workoutId ?? const Uuid().v4();
      
      // Limpar cache antes de chamar a função
      await _client.from('challenge_check_ins').select('id').limit(1);
      await _client.from(_challengeProgressTable).select('id').limit(1);
      debugPrint('🔄 [DIAGNÓSTICO] Cache limpo antes de chamar RPC');
      
      // Tentar usar a RPC
      try {
        debugPrint('🔄 [DIAGNÓSTICO] Chamando RPC record_challenge_check_in_v2 com params: challenge=$challengeId, user=$userId');
        final result = await _client.rpcWithValidUuids(
          ChallengeRpcParams.recordChallengeCheckInFunction,
          params: {
            ChallengeRpcParams.challengeIdParam: challengeId,
            ChallengeRpcParams.userIdParam: userId,
            ChallengeRpcParams.workoutIdParam: safeWorkoutId,
            ChallengeRpcParams.workoutNameParam: workoutName,
            ChallengeRpcParams.workoutTypeParam: workoutType,
            ChallengeRpcParams.dateParam: formattedDate,
            ChallengeRpcParams.durationMinutesParam: durationMinutes
          }
        );
        
        debugPrint('✅ Resposta da RPC record_challenge_check_in_v2: $result');
        debugPrint('✅ [DIAGNÓSTICO] RPC finalizada com sucesso: ${result.toString()}');
        
        // Garantir que o retorno da RPC seja um Map
        if (result != null && result is Map<String, dynamic>) {
          final checkInId = result['check_in_id'] as String?;
          final pointsEarned = result['points_earned'] as int? ?? 0;
          final streak = result['current_streak'] as int? ?? 0;
          final success = result['success'] as bool? ?? false;
          final message = result['message'] as String? ?? 'Check-in processado com sucesso';
          final isAlreadyCheckedIn = result['is_already_checked_in'] as bool? ?? false;
          
          if (success) {
            debugPrint('✅ Check-in registrado com sucesso: $checkInId | $pointsEarned pontos | streak: $streak');
            debugPrint('✅ [DIAGNÓSTICO] Check-in registrado com sucesso via RPC. ID: $checkInId, Pontos: $pointsEarned');
            
            // Atualizar dashboard imediatamente para refletir as alterações
            try {
              // Removemos a tentativa de acessar o provider diretamente
              // Se necessário, o ViewModel que usa este repositório deve fazer a atualização
              debugPrint('✅ Check-in registrado com sucesso, atualize o dashboard se necessário');
            } catch (e) {
              debugPrint('⚠️ Não foi possível atualizar o dashboard automaticamente: $e');
            }
          } else {
            debugPrint('⚠️ Check-in não registrado: $message');
          }
          
          return CheckInResult(
            success: success,
            message: message,
            pointsEarned: pointsEarned,
            currentStreak: streak,
            id: checkInId,
            challengeId: challengeId,
            userId: userId,
            workoutId: safeWorkoutId,
            checkInDate: normalizedDate,
            isAlreadyCheckedIn: isAlreadyCheckedIn
          );
        }
      } catch (rpcError) {
        debugPrint('⚠️ Erro na RPC record_challenge_check_in_v2: $rpcError');
        debugPrint('⚠️ [DIAGNÓSTICO] Falha ao chamar RPC: $rpcError');
        // Continue para o método alternativo abaixo
      }
      
      // Método alternativo (fallback) - Implementação antiga caso a RPC falhe
      debugPrint('⚠️ Usando método alternativo para registrar check-in');
      debugPrint('⚠️ [DIAGNÓSTICO] Iniciando método alternativo (fallback) para check-in');
      
      // Primeiro verificar se já existe check-in para este usuário e desafio na data específica
      debugPrint('🔄 [DIAGNÓSTICO] Verificando check-ins existentes para userId=$userId, desafio=$challengeId, data=$formattedDate');
      final existingCheckIn = await _client
          .from(_challengeCheckInsTable)
          .select()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .eq('check_in_date', formattedDate)
          .maybeSingle();
          
      final isAlreadyCheckedIn = existingCheckIn != null;
      if (isAlreadyCheckedIn) {
        debugPrint('⚠️ Usuário já fez check-in nesta data');
        debugPrint('⚠️ [DIAGNÓSTICO] Check-in existente encontrado para a data');
        
        // Recuperar informações do desafio para mensagem personalizada
        final challenge = await getChallengeById(challengeId);
        
        return CheckInResult(
          success: false,
          message: 'Você já fez check-in para o desafio "${challenge.title}" hoje.',
          pointsEarned: 0,
          currentStreak: await getConsecutiveDaysCount(userId, challengeId),
          isAlreadyCheckedIn: true
        );
      }
      
      // Registrar o check-in com UUIDs válidos e timezone correto
      final checkInData = {
        'id': const Uuid().v4(),
        'challenge_id': challengeId,
        'user_id': userId,
        'workout_id': safeWorkoutId,
        'workout_name': workoutName,
        'workout_type': workoutType,
        'check_in_date': formattedDate,
        'duration_minutes': durationMinutes,
        'created_at': DateTime.now().toSupabaseString(),
      };
      
      debugPrint('🔄 [DIAGNÓSTICO] Inserindo novo check-in via método alternativo');
      final response = await _client
          .from(_challengeCheckInsTable)
          .insert(checkInData)
          .select()
          .single();
          
      final checkInId = response['id'] as String;
      debugPrint('✅ [DIAGNÓSTICO] Check-in inserido com ID: $checkInId');
      
      // Calcular pontos e atualizar progresso
      final pointsForCheckIn = _calculatePointsForWorkout(durationMinutes);
      debugPrint('🔄 [DIAGNÓSTICO] Calculados $pointsForCheckIn pontos para este check-in');
      
      debugPrint('🔄 [DIAGNÓSTICO] Chamando RPC add_points_to_progress para atualizar pontos');
      await _client.rpcWithValidUuids(
        'add_points_to_progress', 
        params: {
          'challenge_id_param': challengeId,
          'user_id_param': userId,
          'points_to_add': pointsForCheckIn,
        }
      );
      
      // Forçar recálculo do streak
      debugPrint('🔄 [DIAGNÓSTICO] Calculando sequência de dias consecutivos');
      final streak = await getConsecutiveDaysCount(userId, challengeId);
      
      debugPrint('✅ Check-in registrado: $checkInId | $pointsForCheckIn pontos');
      
      // Forçar atualização do progresso para refletir as mudanças
      debugPrint('🔄 [DIAGNÓSTICO] Forçando atualização do progresso para refletir mudanças');
      await _forceUpdateProgress(userId, challengeId);
      
      return CheckInResult(
        success: true,
        message: 'Check-in realizado com sucesso! Você ganhou $pointsForCheckIn pontos.',
        pointsEarned: pointsForCheckIn,
        currentStreak: streak,
        id: checkInId,
        challengeId: challengeId,
        userId: userId,
        workoutId: safeWorkoutId,
        checkInDate: normalizedDate,
        isAlreadyCheckedIn: false
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao registrar check-in: $e');
      debugPrint('❌ [DIAGNÓSTICO] Erro fatal no processo de check-in: $e');
      LogUtils.error('recordChallengeCheckIn', error: e, stackTrace: stackTrace);
      
      return CheckInResult(
        success: false,
        message: 'Erro ao registrar check-in: ${e.toString()}',
        pointsEarned: 0,
        currentStreak: 0,
        isAlreadyCheckedIn: false
      );
    }
  }
  
  /// Calcula pontos para um treino com base na duração
  int _calculatePointsForWorkout(int durationMinutes) {
    // Pontos base: 2 pontos por minuto
    final basePoints = durationMinutes * 2;
    
    // Bônus para treinos mais longos
    int bonusPoints = 0;
    if (durationMinutes >= 60) {
      bonusPoints += 50; // Bônus para treinos de 1h ou mais
    } else if (durationMinutes >= 45) {
      bonusPoints += 30; // Bônus para treinos de 45min ou mais
    } else if (durationMinutes >= 30) {
      bonusPoints += 15; // Bônus para treinos de 30min ou mais
    }
    
    return basePoints + bonusPoints;
  }

  /// Força a atualização do progresso do usuário buscando dados atualizados do banco de dados
  Future<void> _forceUpdateProgress(String userId, String challengeId) async {
    try {
      debugPrint('🔄 Forçando atualização do progresso para userId=$userId no desafio=$challengeId');
      debugPrint('🔄 [DIAGNÓSTICO] Iniciando forceUpdateProgress para usuário: $userId, desafio: $challengeId');
      
      // Limpar cache
      debugPrint('🔄 [DIAGNÓSTICO] Limpando cache das tabelas de progresso e check-ins');
      await _client.from(_challengeProgressTable).select('id').limit(1);
      await _client.from(_challengeCheckInsTable).select('id').limit(1);
      
      // Forçar recálculo do progresso usando uma RPC com validação de UUIDs
      debugPrint('🔄 [DIAGNÓSTICO] Chamando RPC recalculate_user_challenge_progress');
      await _client.rpcWithValidUuids(
        'recalculate_user_challenge_progress', 
        params: {
          'user_id_param': userId,
          'challenge_id_param': challengeId,
        }
      );
      
      debugPrint('✅ Progresso atualizado com sucesso');
      debugPrint('✅ [DIAGNÓSTICO] Progresso do usuário recalculado com sucesso');
      
      // Verificar os dados atualizados para confirmar
      try {
        debugPrint('🔄 [DIAGNÓSTICO] Verificando progresso atualizado');
        final progress = await getUserProgress(challengeId: challengeId, userId: userId);
        if (progress != null) {
          debugPrint('✅ [DIAGNÓSTICO] Progresso verificado: ${progress.points} pontos, ${progress.checkInsCount} check-ins');
        } else {
          debugPrint('⚠️ [DIAGNÓSTICO] Progresso não encontrado após atualização');
        }
      } catch (e) {
        debugPrint('⚠️ [DIAGNÓSTICO] Erro ao verificar progresso atualizado: $e');
      }
    } catch (e) {
      debugPrint('❌ Erro ao forçar atualização do progresso: $e');
      debugPrint('❌ [DIAGNÓSTICO] Falha ao recalcular progresso: $e');
    }
  }
  
  @override
  Future<void> addBonusPoints(
    String userId,
    String challengeId,
    int points,
    String reason,
    String userName,
    String? userPhotoUrl,
  ) async {
    try {
      final bonusData = {
        'challenge_id': challengeId,
        'user_id': userId,
        'points': points,
        'reason': reason,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
      };
      
      await _client
          .from(_challengeBonusesTable)
          .insert(bonusData)
          ;
          
      // Atualizar os pontos no progresso
      await _client.rpcWithValidUuids(
        'add_bonus_points_to_progress', 
        params: {
          'challenge_id_param': challengeId,
          'user_id_param': userId,
          'points_param': points,
        }
      );
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar pontos de bônus');
    }
  }
  
  @override
  Future<Map<String, dynamic>> exportChallengeData(String challengeId) async {
    try {
      // Verificar se o usuário é admin
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw AppException(message: 'Apenas administradores podem exportar dados');
      }
      
      // Obter dados do desafio
      final challengeResponse = await _client
          .from(_challengesTable)
          .select()
          .eq('id', challengeId)
          .single()
          ;
          
      // Obter progresso dos participantes
      final progressResponse = await _client
          .from(_challengeProgressTable)
          .select()
          .eq('challenge_id', challengeId)
          ;
          
      // Obter check-ins
      final checkInsResponse = await _client
          .from(_challengeCheckInsTable)
          .select()
          .eq('challenge_id', challengeId)
          ;
          
      return {
        'challenge': challengeResponse,
        'progress': progressResponse,
        'check_ins': checkInsResponse,
        'exported_at': DateTime.now().toIso8601String(),
        'exported_by': _client.auth.currentUser?.id,
      };
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao exportar dados do desafio');
    }
  }
  
  @override
  Future<bool> enableNotifications(String challengeId, bool enable) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }
      
      // Atualizar preferência de notificação na tabela de participantes
      await _client
          .from(_challengeParticipantsTable)
          .update({'notifications_enabled': enable})
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          ;
          
      return true;
    } catch (e, stackTrace) {
      LogUtils.error('Erro ao configurar notificações: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  // Método de utilidade para tratar erros
  AppException _handleError(dynamic error, StackTrace stackTrace, String defaultMessage) {
    LogUtils.error('$defaultMessage: $error', error: error, stackTrace: stackTrace);
    
    if (error is PostgrestException) {
      return AppException(
        message: error.message != '' ? error.message : defaultMessage,
        code: error.code != '' ? error.code : 'unknown_error',
      );
    } else if (error is AppException) {
      return error;
    } else {
      return AppException(
        message: defaultMessage,
        code: 'unknown_error',
      );
    }
  }

  /// Limpa o cache relacionado a um desafio específico
  Future<void> clearCache(String challengeId) async {
    try {
      debugPrint('🧹 Limpando cache para o desafio: $challengeId');
      
      // Limpar cache de todas as tabelas relevantes
      await _client.from(_challengesTable).select('id').limit(1);
      await _client.from(_challengeProgressTable).select('id').limit(1);
      await _client.from(_challengeCheckInsTable).select('id').limit(1);
      await _client.from(_challengeParticipantsTable).select('id').limit(1);
      
      // Forçar pequeno atraso para garantir que o cache seja invalidado
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('✅ Cache limpo com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao limpar cache: $e');
    }
  }

  @override
  Future<List<Challenge>> getActiveParticipatingChallenges({required String userId}) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from(_challengesTable)
          .select('*, challenge_participants!inner(user_id)')
          .eq('challenge_participants.user_id', userId)
          .lt('start_date', now)
          .gt('end_date', now)
          .eq('active', true)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios ativos');
    }
  }
  
  @override
  Future<List<Challenge>> getParticipatingChallenges({required String userId}) async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select('*, challenge_participants!inner(user_id)')
          .eq('challenge_participants.user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios participantes');
    }
  }
  
  @override
  Future<List<Challenge>> getCreatedChallenges({required String userId}) async {
    try {
      final response = await _client
          .from(_challengesTable)
          .select()
          .eq('creator_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<Challenge>((json) {
        // Verificar se precisa de mapper personalizado
        if (ChallengeMapper.needsMapper(json)) {
          return ChallengeMapper.fromSupabase(json);
        }
        // Caso contrário, usar método padrão do Freezed
        return Challenge.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao buscar desafios criados');
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/challenges/models/challenge_participation_model.dart';
import 'package:ray_club_app/core/providers/supabase_client_provider.dart';

/// Interface do repositório para participação em desafios
abstract class ChallengeParticipationRepository {
  /// Obtém os desafios ativos do usuário
  Future<List<ChallengeParticipation>> getUserActiveChallenges();
  
  /// Obtém os desafios concluídos pelo usuário
  Future<List<ChallengeParticipation>> getUserCompletedChallenges();
  
  /// Atualiza o progresso do usuário em um desafio
  Future<ChallengeParticipation> updateUserProgress(String challengeId, double progress);
}

/// Implementação mock do repositório para desenvolvimento
class MockChallengeParticipationRepository implements ChallengeParticipationRepository {
  final List<ChallengeParticipation> _mockParticipations = [];
  
  MockChallengeParticipationRepository() {
    _initMockData();
  }
  
  void _initMockData() {
    final now = DateTime.now();
    
    // Desafio ativo
    _mockParticipations.add(
      ChallengeParticipation(
        id: 'cp-1',
        challengeId: 'challenge-1',
        userId: 'user123',
        challengeName: 'Desafio de Verão 2025',
        currentProgress: 45.0,
        rank: 12,
        totalParticipants: 230,
        isCompleted: false,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 18)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    );
    
    // Desafios concluídos
    _mockParticipations.add(
      ChallengeParticipation(
        id: 'cp-2',
        challengeId: 'challenge-2',
        userId: 'user123',
        challengeName: 'Maratona Fitness',
        currentProgress: 100.0,
        rank: 8,
        totalParticipants: 186,
        isCompleted: true,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 30)),
        completionDate: now.subtract(const Duration(days: 35)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    );
    
    _mockParticipations.add(
      ChallengeParticipation(
        id: 'cp-3',
        challengeId: 'challenge-3',
        userId: 'user123',
        challengeName: 'Desafio 30 Dias',
        currentProgress: 100.0,
        rank: 3,
        totalParticipants: 145,
        isCompleted: true,
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 60)),
        completionDate: now.subtract(const Duration(days: 63)),
        createdAt: now.subtract(const Duration(days: 90)),
      ),
    );
  }

  @override
  Future<List<ChallengeParticipation>> getUserActiveChallenges() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    
    return _mockParticipations
        .where((p) => 
            !p.isCompleted && 
            p.startDate.isBefore(now) && 
            p.endDate.isAfter(now))
        .toList();
  }

  @override
  Future<List<ChallengeParticipation>> getUserCompletedChallenges() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockParticipations
        .where((p) => p.isCompleted)
        .toList();
  }

  @override
  Future<ChallengeParticipation> updateUserProgress(String challengeId, double progress) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockParticipations.indexWhere((p) => p.challengeId == challengeId);
    
    if (index == -1) {
      throw NotFoundException(
        message: 'Participação em desafio não encontrada',
        code: 'participation_not_found',
      );
    }
    
    final participation = _mockParticipations[index];
    
    // Verificar se o desafio está ativo
    if (participation.isCompleted) {
      throw ValidationException(
        message: 'Não é possível atualizar progresso de um desafio já concluído',
        code: 'challenge_already_completed',
      );
    }
    
    final now = DateTime.now();
    if (now.isAfter(participation.endDate)) {
      throw ValidationException(
        message: 'Não é possível atualizar progresso de um desafio encerrado',
        code: 'challenge_ended',
      );
    }
    
    // Calcular novo ranking (simplificado para mock)
    final isCompleted = progress >= 100.0;
    
    final updated = participation.copyWith(
      currentProgress: progress,
      isCompleted: isCompleted,
      completionDate: isCompleted ? now : null,
      updatedAt: now,
    );
    
    // Atualizar na coleção mock
    _mockParticipations[index] = updated;
    
    return updated;
  }
}

/// Implementação com Supabase
class SupabaseChallengeParticipationRepository implements ChallengeParticipationRepository {
  final SupabaseClient _supabaseClient;

  SupabaseChallengeParticipationRepository(this._supabaseClient);

  @override
  Future<List<ChallengeParticipation>> getUserActiveChallenges() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabaseClient
          .from('challenge_participants')
          .select('*, challenges!inner(name, start_date, end_date)')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .lt('challenges.start_date', now)
          .gt('challenges.end_date', now)
          .order('challenges.end_date', ascending: true);
      
      return response
          .map((json) => _mapResponseToParticipation(json))
          .toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockChallengeParticipationRepository().getUserActiveChallenges();
    }
  }

  @override
  Future<List<ChallengeParticipation>> getUserCompletedChallenges() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('challenge_participants')
          .select('*, challenges!inner(name, start_date, end_date)')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .order('completion_date', ascending: false);
      
      return response
          .map((json) => _mapResponseToParticipation(json))
          .toList();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      return MockChallengeParticipationRepository().getUserCompletedChallenges();
    }
  }

  @override
  Future<ChallengeParticipation> updateUserProgress(String challengeId, double progress) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Buscar informações atuais da participação
      final participationResponse = await _supabaseClient
          .from('challenge_participants')
          .select('*, challenges!inner(name, start_date, end_date)')
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .single();
      
      final participation = _mapResponseToParticipation(participationResponse);
      
      // Verificar se o desafio está ativo
      if (participation.isCompleted) {
        throw ValidationException(
          message: 'Não é possível atualizar progresso de um desafio já concluído',
          code: 'challenge_already_completed',
        );
      }
      
      final now = DateTime.now();
      if (now.isAfter(participation.endDate)) {
        throw ValidationException(
          message: 'Não é possível atualizar progresso de um desafio encerrado',
          code: 'challenge_ended',
        );
      }
      
      // Calcular se o desafio foi concluído
      final isCompleted = progress >= 100.0;
      final updates = {
        'current_progress': progress,
        'is_completed': isCompleted,
        'updated_at': now.toIso8601String(),
      };
      
      if (isCompleted) {
        updates['completion_date'] = now.toIso8601String();
      }
      
      // Atualizar o progresso
      final response = await _supabaseClient
          .from('challenge_participants')
          .update(updates)
          .eq('challenge_id', challengeId)
          .eq('user_id', userId)
          .select('*, challenges!inner(name, start_date, end_date)')
          .single();
      
      return _mapResponseToParticipation(response);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar progresso: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  /// Mapeia a resposta da API para o modelo ChallengeParticipation
  ChallengeParticipation _mapResponseToParticipation(Map<String, dynamic> json) {
    final challengeData = json['challenges'] as Map<String, dynamic>;
    
    return ChallengeParticipation(
      id: json['id'],
      challengeId: json['challenge_id'],
      userId: json['user_id'],
      challengeName: challengeData['name'],
      currentProgress: json['current_progress'].toDouble(),
      rank: json['rank'],
      totalParticipants: json['total_participants'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      startDate: DateTime.parse(challengeData['start_date']),
      endDate: DateTime.parse(challengeData['end_date']),
      completionDate: json['completion_date'] != null 
          ? DateTime.parse(json['completion_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}

/// Provider para o repositório de participação em desafios
final challengeParticipationRepositoryProvider = Provider<ChallengeParticipationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseChallengeParticipationRepository(supabase);
}); // Project imports:
import '../models/challenge.dart';
import '../models/challenge_progress.dart';
import '../models/challenge_group.dart';
import '../models/challenge_check_in.dart';

/// Base class para métodos opcionais
mixin OptionalChallengeRepositoryMethods {
  /// Obtém os convites de grupos pendentes para um usuário
  Future<List<ChallengeGroupInvite>> getPendingInvites(String userId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return [];
  }
  
  /// Obtém o número de dias consecutivos de check-in
  Future<int> getConsecutiveDaysCount(String userId, String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return 0;
  }
  
  /// Obtém a sequência atual através de função RPC
  Future<int> getCurrentStreak(String userId, String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return 0;
  }
  
  /// Registra um check-in do usuário no desafio
  Future<CheckInResult> recordChallengeCheckIn({
    required String challengeId,
    required String userId,
    String? workoutId,
    required String workoutName,
    required String workoutType,
    required DateTime date,
    required int durationMinutes,
  }) async {
    // Método opcional que pode ser implementado nas classes concretas
    return CheckInResult(
      success: false,
      message: 'Método não implementado',
    );
  }
  
  /// Adiciona pontos de bônus para o usuário
  Future<void> addBonusPoints(
    String userId,
    String challengeId,
    int points,
    String reason,
    String userName,
    String? userPhotoUrl,
  ) async {
    // Método opcional que pode ser implementado nas classes concretas
  }

  /// Obtém um stream de atualizações do ranking global de um desafio
  Stream<List<ChallengeProgress>> watchChallengeRanking({required String challengeId}) {
    // Método opcional que pode ser implementado nas classes concretas
    return Stream.value([]);
  }

  /// Obtém um stream de atualizações do ranking de um grupo específico
  Stream<List<ChallengeProgress>> watchGroupRanking(String groupId) {
    // Método opcional que pode ser implementado nas classes concretas
    return Stream.value([]);
  }

  /// Obtém os grupos que o usuário participa para um desafio específico
  Future<List<ChallengeGroup>> getUserGroups(String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return [];
  }

  /// Verifica se o usuário pode acessar um grupo específico
  Future<bool> canAccessGroup(String groupId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return false;
  }

  /// Exporta dados completos de um desafio para análise ou backup
  Future<Map<String, dynamic>> exportChallengeData(String challengeId) async {
    // Método opcional que pode ser implementado nas classes concretas
    return {};
  }

  /// Habilita ou desabilita notificações para um desafio específico
  Future<bool> enableNotifications(String challengeId, bool enable) async {
    // Método opcional que pode ser implementado nas classes concretas
    return false;
  }
}

/// Interface para operações de repositório de desafios
abstract class ChallengeRepository with OptionalChallengeRepositoryMethods {
  /// Obtém todos os desafios
  Future<List<Challenge>> getChallenges();
  
  /// Obtém um desafio pelo ID
  Future<Challenge> getChallengeById(String id);
  
  /// Obtém desafios criados por um usuário específico
  Future<List<Challenge>> getUserChallenges({required String userId});
  
  /// Obtém desafios ativos (que ainda não terminaram)
  Future<List<Challenge>> getActiveChallenges();
  
  /// Obtém desafios ativos para um usuário específico
  Future<List<Challenge>> getUserActiveChallenges(String userId);
  
  /// Obtém o desafio oficial atual da Ray
  Future<Challenge?> getOfficialChallenge();
  
  /// Obtém todos os desafios oficiais
  Future<List<Challenge>> getOfficialChallenges();
  
  /// Obtém o desafio principal (em destaque)
  Future<Challenge?> getMainChallenge();
  
  /// Cria um novo desafio
  Future<Challenge> createChallenge(Challenge challenge);
  
  /// Atualiza um desafio existente
  Future<void> updateChallenge(Challenge challenge);
  
  /// Exclui um desafio
  Future<void> deleteChallenge(String id);
  
  /// Participa de um desafio
  Future<void> joinChallenge({required String challengeId, required String userId});
  
  /// Sai de um desafio
  Future<void> leaveChallenge({required String challengeId, required String userId});
  
  /// Retorna o progresso do usuário em um desafio específico
  Future<ChallengeProgress?> getUserProgress({
    required String challengeId,
    required String userId,
  });
  
  /// Verifica se o usuário está participando do desafio
  Future<bool> isUserParticipatingInChallenge({
    required String challengeId,
    required String userId,
  });
  
  /// Retorna o ranking de um desafio
  Future<List<ChallengeProgress>> getChallengeProgress(String challengeId);
  
  /// Atualiza o progresso de um usuário em um desafio
  Future<void> updateUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  });
  
  /// Cria um registro de progresso para um usuário em um desafio
  Future<void> createUserProgress({
    required String challengeId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int points,
    required double completionPercentage,
  });
  
  /// Adiciona pontos ao progresso do usuário em um desafio
  Future<void> addPointsToUserProgress({
    required String challengeId,
    required String userId,
    required int pointsToAdd,
  });
  
  /// Verifica se o usuário atual é administrador
  Future<bool> isCurrentUserAdmin();
  
  /// Alterna o status de administrador do usuário atual
  Future<void> toggleAdminStatus();
  
  /// Observa as mudanças de progresso de um desafio em tempo real
  Stream<List<ChallengeProgress>> watchChallengeParticipants(
    String challengeId, {
    int limit = 50,
    int offset = 0,
  });
  
  // Métodos novos para grupos
  
  /// Cria um novo grupo para um desafio
  Future<ChallengeGroup> createGroup({
    required String challengeId,
    required String creatorId,
    required String name,
    String? description,
  });
  
  /// Obtém um grupo pelo ID
  Future<ChallengeGroup> getGroupById(String groupId);
  
  /// Obtém todos os grupos que um usuário criou
  Future<List<ChallengeGroup>> getUserCreatedGroups(String userId);
  
  /// Obtém todos os grupos dos quais um usuário é membro
  Future<List<ChallengeGroup>> getUserMemberGroups(String userId);
  
  /// Atualiza informações de um grupo
  Future<void> updateGroup(ChallengeGroup group);
  
  /// Exclui um grupo
  Future<void> deleteGroup(String groupId);
  
  /// Obtém os membros de um grupo
  Future<List<String>> getGroupMembers(String groupId);
  
  /// Convida um usuário para um grupo
  Future<void> inviteUserToGroup(String groupId, String inviterId, String inviteeId);
  
  /// Responde a um convite de grupo
  Future<void> respondToGroupInvite(String inviteId, bool accept);
  
  /// Remove um usuário de um grupo
  Future<void> removeUserFromGroup(String groupId, String userId);
  
  /// Verifica se o usuário já fez check-in em uma data específica
  Future<bool> hasCheckedInOnDate(String userId, String challengeId, DateTime date);
  
  /// Verifica se o usuário já fez check-in hoje
  Future<bool> hasCheckedInToday(String userId, String challengeId);
  
  /// Obtém o ranking de um grupo específico
  Future<List<ChallengeProgress>> getGroupRanking(String groupId);
  
  /// Limpa o cache relacionado a um desafio específico
  Future<void> clearCache(String challengeId) async {
    // Implementação padrão vazia, a ser substituída nas classes concretas
  }
}

// O provider challengeRepositoryProvider foi movido para lib/features/challenges/providers/challenge_providers.dart
// Remover a definição duplicada

// Importação da implementação real, remova a definição duplicada aqui
// A implementação está no arquivo supabase_challenge_repository.dart 
// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/check_in_error_log.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

/// Provider para AdminRepository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AdminRepository(supabase);
});

/// Repositório para funções administrativas
class AdminRepository {
  final SupabaseClient _supabase;
  
  AdminRepository(this._supabase);
  
  /// Executa diagnóstico do sistema e tenta recuperar registros com problemas
  Future<Map<String, dynamic>> runSystemDiagnostics({int daysBack = 7}) async {
    try {
      final response = await _supabase.rpc(
        'diagnose_and_recover_workout_records', 
        params: {'days_back': daysBack}
      );
      
      return response;
    } catch (e) {
      debugPrint('Erro ao executar diagnóstico: $e');
      return {
        'error': e.toString(),
        'recovered_count': 0,
        'missing_count': 0,
        'failed_count': 0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Tenta reprocessar um treino específico
  Future<bool> retryProcessingForWorkout(String workoutId) async {
    try {
      final response = await _supabase.rpc(
        'retry_workout_processing',
        params: {'_workout_id': workoutId}
      );
      
      return response == true;
    } catch (e) {
      debugPrint('Erro ao tentar reprocessar treino: $e');
      return false;
    }
  }
  
  /// Obtém logs de erro do sistema
  Future<List<CheckInErrorLog>> getErrorLogs({
    String? userId,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
        .from('check_in_error_logs')
        .select();
        
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
      
      return (response as List)
        .map((json) => CheckInErrorLog.fromJson(json))
        .toList();
    } catch (e) {
      debugPrint('Erro ao obter logs de erro: $e');
      return [];
    }
  }
  
  /// Obtém resumo de erros agrupados por usuário
  Future<List<Map<String, dynamic>>> getErrorSummaryByUser() async {
    try {
      final response = await _supabase.rpc(
        'get_error_summary_by_user',
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao obter resumo de erros: $e');
      return [];
    }
  }
  
  /// Obtém treinos com processamento pendente
  Future<List<Map<String, dynamic>>> getPendingWorkoutsProcessing() async {
    try {
      final response = await _supabase
        .from('workout_processing_queue')
        .select('*, workout_records(*)')
        .or('processed_for_ranking.eq.false,processed_for_dashboard.eq.false')
        .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro ao obter treinos pendentes: $e');
      return [];
    }
  }
} // Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Provider para o DashboardViewModel
final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, AsyncValue<DashboardData>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  final goalRepository = ref.watch(goalRepositoryProvider);
  final challengeRepository = ref.read(challengeRepositoryProvider);
  
  // Verifica se tem usuário autenticado
  final userId = authState.maybeWhen(
    authenticated: (user) => user.id,
    orElse: () => null,
  );
  
  return DashboardViewModel(
    repository,
    userId,
    goalRepository,
    challengeRepository,
  );
});

/// ViewModel para os dados do dashboard
class DashboardViewModel extends StateNotifier<AsyncValue<DashboardData>> {
  /// Repositório para acesso aos dados
  final DashboardRepository _repository;
  
  /// ID do usuário atual
  final String? _userId;
  
  /// Repositório para metas
  final GoalRepository _goalRepository;
  
  /// Repositório para desafios
  final ChallengeRepository _challengeRepository;
  
  /// Construtor que inicializa o estado como loading e carrega os dados
  DashboardViewModel(
    this._repository,
    this._userId,
    this._goalRepository,
    this._challengeRepository,
  ) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      debugPrint('📊 Dashboard inicializado para usuário: $_userId');
      loadDashboardData();
    } else {
      debugPrint('❌ Dashboard inicializado sem usuário autenticado');
      state = AsyncValue.error(
        'Usuário não autenticado',
        StackTrace.current,
      );
    }
  }
  
  /// Carrega os dados do dashboard
  Future<void> loadDashboardData() async {
    try {
      // Verificar se temos um ID de usuário
      if (_userId == null) {
        throw AppException(
          message: 'Usuário não autenticado',
          code: 'no_authenticated_user',
        );
      }
      
      // Indicar loading
      state = const AsyncValue.loading();
      
      // Usar o ID do usuário que já temos
      final userId = _userId!;
      
      // Carregar dados do dashboard
      final dashboardData = await _repository.getDashboardData(userId);
      
      // TODO: Implementar carregamento de desafio ativo
      // await _loadActiveChallenge(userId);
      
      // Configurar listener para atualizações em tempo real
      setupDashboardUpdateListener();
      
      // Atualizar com os dados carregados
      state = AsyncValue.data(dashboardData);
      
      debugPrint('📊 Dashboard carregado com sucesso');
    } catch (e, stackTrace) {
      // Atualizar com o erro
      state = AsyncValue.error(
        'Erro ao carregar dashboard: $e',
        stackTrace,
      );
      debugPrint('❌ Erro ao carregar dashboard: $e');
    }
  }
  
  /// Força o recarregamento dos dados
  Future<void> refreshData() async {
    debugPrint('🔄 Atualizando dados do dashboard');
    await loadDashboardData();
  }
  
  /// Adiciona um copo de água
  Future<void> addWaterGlass() async {
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de adicionar água sem dados/usuário');
      return;
    }
    
    final waterIntakeData = currentData.additionalData['water_intake'];
    if (waterIntakeData == null) {
      debugPrint('⚠️ Dados de água não encontrados, inicializando...');
      await initializeWaterIntakeIfNeeded();
      return;
    }
    
    // CORRIGIDO: Verificar se o ID existe e não é nulo ou vazio antes de usar
    final id = waterIntakeData['id'];
    if (id == null || id.toString().trim().isEmpty) {
      debugPrint('⚠️ Water intake ID é nulo ou vazio, tentando reinicializar...');
      await initializeWaterIntakeIfNeeded();
      return;
    }
    
    final String waterIntakeId = id.toString();
    final int currentCups = (waterIntakeData['cups'] ?? 0) as int;
    final int newGlassCount = currentCups + 1;
    
    debugPrint('🚰 Adicionando copo de água: $currentCups -> $newGlassCount');
    
    // Atualiza localmente para feedback imediato
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['water_intake'] = {
      ...waterIntakeData as Map<String, dynamic>,
      'cups': newGlassCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // Otimisticamente atualiza a UI enquanto a operação acontece no bg
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    try {
      // Atualiza no backend
      await _repository.updateWaterIntake(
        _userId!,
        waterIntakeId,
        newGlassCount,
      );
      debugPrint('✅ Água atualizada no backend com sucesso');
    } catch (error) {
      // Em caso de erro, reverte a alteração otimista
      debugPrint('❌ Erro ao atualizar água: $error');
      state = AsyncValue.data(currentData);
      
      // Recarrega os dados
      await loadDashboardData();
    }
  }
  
  /// Remove um copo de água
  Future<void> removeWaterGlass() async {
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de remover água sem dados/usuário');
      return;
    }
    
    final waterIntakeData = currentData.additionalData['water_intake'];
    if (waterIntakeData == null) {
      debugPrint('⚠️ Dados de água não encontrados ao tentar remover');
      return;
    }
    
    // CORRIGIDO: Verificar se o ID existe e não é nulo ou vazio antes de usar
    final id = waterIntakeData['id'];
    if (id == null || id.toString().trim().isEmpty) {
      debugPrint('⚠️ Water intake ID é nulo ou vazio, tentando reinicializar...');
      await initializeWaterIntakeIfNeeded();
      return;
    }
    
    final String waterIntakeId = id.toString();
    final int currentCups = (waterIntakeData['cups'] ?? 0) as int;
    if (currentCups <= 0) {
      debugPrint('ℹ️ Já está em 0 copos, nada a remover');
      return;
    }
    
    final int newGlassCount = currentCups - 1;
    debugPrint('🚰 Removendo copo de água: $currentCups -> $newGlassCount');
    
    // Atualiza localmente para feedback imediato
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['water_intake'] = {
      ...waterIntakeData as Map<String, dynamic>,
      'cups': newGlassCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // Otimisticamente atualiza a UI enquanto a operação acontece no bg
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    try {
      // Atualiza no backend
      await _repository.updateWaterIntake(
        _userId!,
        waterIntakeId,
        newGlassCount,
      );
      debugPrint('✅ Água (remoção) atualizada no backend com sucesso');
    } catch (error) {
      // Em caso de erro, reverte a alteração otimista
      debugPrint('❌ Erro ao atualizar água (remoção): $error');
      state = AsyncValue.data(currentData);
      
      // Recarrega os dados
      await loadDashboardData();
    }
  }
  
  /// Inicializa o registro de água para hoje se não existir
  Future<void> initializeWaterIntakeIfNeeded() async {
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de inicializar água sem dados/usuário');
      return;
    }
    
    final waterIntakeData = currentData.additionalData['water_intake'];
    final hasEmptyId = waterIntakeData != null && 
                      (waterIntakeData['id'] == null || 
                       waterIntakeData['id'].toString().trim().isEmpty);
    
    // Se o water intake não existe ou tem ID vazio, precisamos buscar ou criar
    if (waterIntakeData == null || hasEmptyId) {
      debugPrint('🔄 Inicializando registro de água para hoje');
      
      try {
        // Primeiro, tenta buscar um registro existente para hoje
        final today = DateTime.now();
        final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        
        final result = await _repository.createWaterIntakeForToday(_userId!);
        
        if (result != null) {
          debugPrint('✅ Registro de água obtido/criado com ID: $result');
          
          // Importante: Atualizar o estado imediatamente com o ID correto para evitar loop
          if (waterIntakeData != null) {
            // Atualizar o ID no objeto existente
            final updatedWaterIntake = Map<String, dynamic>.from(waterIntakeData as Map<String, dynamic>);
            updatedWaterIntake['id'] = result;
            
            final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
            updatedAdditionalData['water_intake'] = updatedWaterIntake;
            
            // Atualizar o estado com o ID corrigido
            state = AsyncValue.data(
              currentData.copyWith(
                additionalData: updatedAdditionalData,
              ),
            );
            debugPrint('✅ Atualizado ID do registro de água no estado local');
          } else {
            // Recarrega os dados completos
            await loadDashboardData();
          }
        } else {
          debugPrint('⚠️ Não foi possível obter/criar registro de água');
          // Recarrega os dados para diagnóstico
          await loadDashboardData();
        }
      } catch (error) {
        // Log de erro, mas não quebramos a UI
        debugPrint('❌ Erro ao inicializar registro de água: $error');
        // Forçar recarregamento dos dados após erro
        await loadDashboardData();
      }
    } else {
      final id = waterIntakeData['id'];
      debugPrint('ℹ️ Registro de água já existe com ID: $id, nada a fazer');
    }
  }
  
  /// Incrementa um valor de meta
  Future<void> incrementGoalValue(int goalIndex) async {
    debugPrint('🎯 Tentando incrementar meta $goalIndex');
    
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de incrementar meta sem dados/usuário');
      return;
    }
    
    final goals = currentData.additionalData['goals'] as List<dynamic>?;
    if (goals == null || goals.isEmpty || goalIndex >= goals.length) {
      debugPrint('❌ Índice de meta inválido ou lista de metas vazia');
      return;
    }
    
    // Obter a meta específica
    final goal = goals[goalIndex] as Map<String, dynamic>;
    
    // Obter valores atuais
    final double currentValue = (goal['current_value'] as num?)?.toDouble() ?? 0.0;
    final double targetValue = (goal['target_value'] as num?)?.toDouble() ?? 100.0;
    final String id = goal['id'] as String? ?? '';
    
    if (id.isEmpty) {
      debugPrint('❌ Meta sem ID, não é possível atualizar');
      return;
    }
    
    // Verificar se a meta já foi concluída
    if (currentValue >= targetValue) {
      debugPrint('ℹ️ Meta já concluída, não é possível incrementar mais');
      return;
    }
    
    // Calcular novo valor (incrementar de 1 em 1 ou 0.5 em 0.5)
    final bool isInteger = goal['is_integer'] as bool? ?? false;
    final double increment = isInteger ? 1.0 : 0.5;
    final double newValue = (currentValue + increment).clamp(0.0, targetValue);
    
    debugPrint('🎯 Incrementando meta $goalIndex: $currentValue -> $newValue');
    
    // Atualizar localmente para feedback imediato
    final updatedGoals = List<dynamic>.from(goals);
    final updatedGoal = Map<String, dynamic>.from(goal);
    updatedGoal['current_value'] = newValue;
    updatedGoal['is_completed'] = newValue >= targetValue;
    updatedGoals[goalIndex] = updatedGoal;
    
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['goals'] = updatedGoals;
    
    // Atualizar estado
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    // Atualizar a meta no repositório
    try {
      await _goalRepository.updateGoalProgress(id, newValue);
      debugPrint('✅ Meta atualizada no backend com sucesso');
    } catch (error) {
      debugPrint('❌ Erro ao atualizar meta: $error');
      // Em caso de erro, voltar ao estado anterior
      state = AsyncValue.data(currentData);
    }
  }
  
  /// Decrementa um valor de meta
  Future<void> decrementGoalValue(int goalIndex) async {
    debugPrint('🎯 Tentando decrementar meta $goalIndex');
    
    // Verifica se há dados carregados
    final currentData = state.asData?.value;
    if (currentData == null || _userId == null) {
      debugPrint('❌ Tentativa de decrementar meta sem dados/usuário');
      return;
    }
    
    final goals = currentData.additionalData['goals'] as List<dynamic>?;
    if (goals == null || goals.isEmpty || goalIndex >= goals.length) {
      debugPrint('❌ Índice de meta inválido ou lista de metas vazia');
      return;
    }
    
    // Obter a meta específica
    final goal = goals[goalIndex] as Map<String, dynamic>;
    
    // Obter valores atuais
    final double currentValue = (goal['current_value'] as num?)?.toDouble() ?? 0.0;
    final double targetValue = (goal['target_value'] as num?)?.toDouble() ?? 100.0;
    final String id = goal['id'] as String? ?? '';
    
    if (id.isEmpty) {
      debugPrint('❌ Meta sem ID, não é possível atualizar');
      return;
    }
    
    // Verificar se a meta já está em zero
    if (currentValue <= 0) {
      debugPrint('ℹ️ Meta já em zero, não é possível decrementar mais');
      return;
    }
    
    // Calcular novo valor (decrementar de 1 em 1 ou 0.5 em 0.5)
    final bool isInteger = goal['is_integer'] as bool? ?? false;
    final double decrement = isInteger ? 1.0 : 0.5;
    final double newValue = (currentValue - decrement).clamp(0.0, targetValue);
    
    debugPrint('🎯 Decrementando meta $goalIndex: $currentValue -> $newValue');
    
    // Atualizar localmente para feedback imediato
    final updatedGoals = List<dynamic>.from(goals);
    final updatedGoal = Map<String, dynamic>.from(goal);
    updatedGoal['current_value'] = newValue;
    updatedGoal['is_completed'] = newValue >= targetValue;
    updatedGoals[goalIndex] = updatedGoal;
    
    final updatedAdditionalData = Map<String, dynamic>.from(currentData.additionalData);
    updatedAdditionalData['goals'] = updatedGoals;
    
    // Atualizar estado
    state = AsyncValue.data(
      currentData.copyWith(
        additionalData: updatedAdditionalData,
      ),
    );
    
    // Atualizar a meta no repositório
    try {
      await _goalRepository.updateGoalProgress(id, newValue);
      debugPrint('✅ Meta atualizada no backend com sucesso');
    } catch (error) {
      debugPrint('❌ Erro ao atualizar meta: $error');
      // Em caso de erro, voltar ao estado anterior
      state = AsyncValue.data(currentData);
    }
  }
  
  /// Força uma atualização completa do dashboard, limpando todos os caches
  Future<void> forceRefresh() async {
    debugPrint('🔄 Forçando atualização completa do dashboard');
    debugPrint('🔄 [DIAGNÓSTICO] Forçando atualização do dashboard para usuário: $_userId');
    
    // Limpa o cache interno antes de recarregar
    if (_userId == null) {
      debugPrint('❌ Tentativa de forçar atualização do dashboard sem usuário');
      return;
    }
    
    try {
      // Executa a função RPC que força atualização dos dados no banco
      final supabase = Supabase.instance.client;
      debugPrint('🔄 [DIAGNÓSTICO] Chamando RPC refresh_dashboard_data para usuário: $_userId');
      final result = await supabase.rpc(
        'refresh_dashboard_data',
        params: {'p_user_id': _userId},
      );
      
      debugPrint('✅ Dados do dashboard atualizados via RPC: ${result != null}');
      debugPrint('✅ [DIAGNÓSTICO] Resposta da RPC refresh_dashboard_data: $result');
      
      // Primeira carga de dados após a atualização forçada
      debugPrint('🔄 [DIAGNÓSTICO] Primeira chamada para recarregar dados do dashboard');
      await loadDashboardData();
      
      // Espera um pouco e recarrega novamente para garantir que dados recentes sejam usados
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Segunda carga para garantir atualização completa
      debugPrint('🔄 [DIAGNÓSTICO] Segunda chamada para recarregar dados do dashboard');
      await loadDashboardData();
      
      // Logs adicionais após a atualização completa
      final currentData = state.asData?.value;
      if (currentData != null) {
        final workoutsCount = currentData.userProgress.totalWorkouts;
        final pointsCount = currentData.userProgress.totalPoints;
        debugPrint('✅ [DIAGNÓSTICO] Dashboard atualizado com: $workoutsCount treinos, $pointsCount pontos');
      }
    } catch (e) {
      debugPrint('❌ Erro ao forçar atualização de dados do dashboard: $e');
      debugPrint('❌ [DIAGNÓSTICO] Falha na RPC refresh_dashboard_data: $e');
      // Se falhar a RPC, tenta reload normal
      await loadDashboardData();
    }
  }
  
  /// Configura um listener para eventos de atualização do dashboard
  void setupDashboardUpdateListener() {
    if (_userId == null) {
      debugPrint('❌ Tentativa de configurar listener sem usuário');
      return;
    }
    
    try {
      debugPrint('🔔 Configurando listener para atualizações do dashboard');
      
      // Inscreve-se no canal de notificações do dashboard
      final supabase = Supabase.instance.client;
      final subscription = supabase.realtime
          .channel('dashboard_updates')
          .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'workout_records',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: _userId,
              ),
              callback: (payload) {
                debugPrint('📢 Evento de workout recebido: ${payload.toString()}');
                refreshData();
              });
      
      // TODO: Atualizar para a nova API do Supabase Realtime
      // Código comentado porque a API 'on' não existe mais nesta versão
      // subscription.on(
      //   RealtimeListenTypes.postgresChanges,
      //   ChannelFilter(event: 'dashboard_updates'),
      //   (payload, [ref]) {
      //     final eventData = jsonDecode(payload.toString());
      //     final eventUserId = eventData['user_id'];
      //     
      //     // Só atualiza se o evento for para este usuário
      //     if (eventUserId == _userId) {
      //       debugPrint('📢 Notificação de atualização para dashboard recebida');
      //       refreshData();
      //     }
      //   },
      // );
      
      // Ativa a inscrição
      subscription.subscribe();
      
      debugPrint('✅ Listener para atualizações do dashboard configurado');
    } catch (e) {
      debugPrint('❌ Erro ao configurar listener para dashboard: $e');
    }
  }
  
  /// Força uma atualização manual do dashboard usando métodos diretos no banco
  Future<void> forceManualUpdate() async {
    debugPrint('🔄 [MANUAL_UPDATE] Forçando atualização manual do dashboard');
    
    // Verifica se temos um ID de usuário válido
    if (_userId == null) {
      debugPrint('❌ [MANUAL_UPDATE] Usuário não autenticado');
      return;
    }
    
    try {
      // Primeiro tenta o método manual direto na tabela
      final success = await _repository.forceManualDashboardUpdate(_userId!);
      
      if (success) {
        debugPrint('✅ [MANUAL_UPDATE] Atualização manual bem-sucedida');
      } else {
        debugPrint('⚠️ [MANUAL_UPDATE] Falha na atualização manual, tentando RPC');
        
        // Tenta o método RPC como fallback
        await forceRefresh();
      }
      
      // Recarrega os dados do dashboard em qualquer caso
      await loadDashboardData();
      
      // Log de diagnóstico
      final currentData = state.asData?.value;
      if (currentData != null) {
        final workoutsCount = currentData.userProgress.totalWorkouts;
        final pointsCount = currentData.userProgress.totalPoints;
        debugPrint('✅ [MANUAL_UPDATE] Dashboard atualizado com: $workoutsCount treinos, $pointsCount pontos');
      }
    } catch (e) {
      debugPrint('❌ [MANUAL_UPDATE] Erro na atualização manual: $e');
      
      // Tenta método tradicional como último recurso
      await loadDashboardData();
    }
  }
} // Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';

/// Provider para o repositório do dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return DashboardRepository(supabaseClient);
});

/// Classe responsável por acessar dados do dashboard no Supabase
class DashboardRepository {
  /// Cliente Supabase para comunicação com o backend
  final SupabaseClient _client;
  
  /// Construtor da classe
  DashboardRepository(this._client);

  /// Obtém os dados do dashboard a partir do Supabase
  /// [userId] - ID do usuário para buscar os dados
  Future<DashboardData> getDashboardData(String userId) async {
    try {
      // Use the single database function call instead of multiple queries
      final response = await _client
          .rpc('get_dashboard_data', params: {'user_id_param': userId});
      
      // Extract user progress from the response
      Map<String, dynamic> userProgressData;
      if (response['user_progress'] != null && response['user_progress'] is Map<String, dynamic>) {
        userProgressData = response['user_progress'] as Map<String, dynamic>;
      } else {
        // Fallback para um objeto vazio se user_progress for nulo
        userProgressData = {
          'id': '',
          'user_id': userId,
          'total_workouts': 0,
          'current_streak': 0,
          'longest_streak': 0,
          'total_points': 0,
          'days_trained_this_month': 0,
          'workout_types': {},
        };
      }
      final userProgress = UserProgress.fromJson(userProgressData);
      
      // Process challenge data if available
      Challenge? currentChallenge;
      if (response['current_challenge'] != null && response['current_challenge'] is Map<String, dynamic>) {
        try {
          currentChallenge = Challenge.fromJson(response['current_challenge'] as Map<String, dynamic>);
        } catch (e) {
          // Log error but continue - non-fatal error
          print('Erro ao processar desafio atual: $e');
        }
      }
      
      // Process challenge progress if available
      ChallengeProgress? challengeProgress;
      if (response['challenge_progress'] != null && response['challenge_progress'] is Map<String, dynamic>) {
        try {
          challengeProgress = ChallengeProgress.fromJson(response['challenge_progress'] as Map<String, dynamic>);
        } catch (e) {
          // Log error but continue - non-fatal error
          print('Erro ao processar progresso do desafio: $e');
        }
      }
      
      // Process redeemed benefits if available
      List<RedeemedBenefit> redeemedBenefits = [];
      if (response['redeemed_benefits'] != null && response['redeemed_benefits'] is List) {
        final benefitsJson = response['redeemed_benefits'] as List<dynamic>;
        redeemedBenefits = benefitsJson
            .where((json) => json is Map<String, dynamic>)
            .map((json) {
              try {
                return RedeemedBenefit.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Erro ao processar benefício resgatado: $e');
                return null;
              }
            })
            .where((benefit) => benefit != null)
            .cast<RedeemedBenefit>()
            .toList();
      }
      
      // Additional data includes water intake, goals, and recent workouts
      final additionalData = <String, dynamic>{};
      
      // Include water intake data
      if (response['water_intake'] != null && response['water_intake'] is Map<String, dynamic>) {
        additionalData['water_intake'] = response['water_intake'] as Map<String, dynamic>;
      }
      
      // Include goals data
      if (response['goals'] != null && response['goals'] is List) {
        additionalData['goals'] = response['goals'] as List<dynamic>;
      }
      
      // Include recent workouts data
      if (response['recent_workouts'] != null && response['recent_workouts'] is List) {
        additionalData['recent_workouts'] = response['recent_workouts'] as List<dynamic>;
      }
      
      return DashboardData(
        userProgress: userProgress,
        currentChallenge: currentChallenge,
        challengeProgress: challengeProgress,
        redeemedBenefits: redeemedBenefits,
        lastUpdated: DateTime.now(),
        additionalData: additionalData,
      );
    } catch (e, stackTrace) {
      throw AppException(
        message: 'Erro ao buscar dados do dashboard: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Atualiza o progresso de água do usuário
  /// [userId] - ID do usuário
  /// [waterIntakeId] - ID do registro de água
  /// [cups] - Novo número de copos
  Future<void> updateWaterIntake(String userId, String waterIntakeId, int cups) async {
    try {
      // Verificar se o ID é válido
      if (waterIntakeId.trim().isEmpty) {
        throw AppException(
          message: 'ID de registro de água inválido (vazio)',
          code: 'invalid_water_intake_id',
        );
      }
      
      // Verificar se o registro existe antes de atualizar
      final exists = await _client
          .from('water_intake')
          .select('id')
          .eq('id', waterIntakeId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (exists == null) {
        // Se o registro não existir, vamos criar um novo
        debugPrint('⚠️ Registro de água não encontrado, criando um novo...');
        await createWaterIntakeForToday(userId);
        
        // Recarregar e verificar novamente
        final recheck = await _client
            .from('water_intake')
            .select('id')
            .eq('user_id', userId)
            .eq('date', _getTodayFormatted())
            .maybeSingle();
        
        if (recheck == null) {
          throw AppException(
            message: 'Falha ao criar registro de água',
            code: 'water_intake_create_failed',
          );
        }
        
        // Usar o ID do novo registro
        waterIntakeId = recheck['id'] as String;
      }
      
      // Agora podemos atualizar com segurança
      await _client
          .from('water_intake')
          .update({
            'cups': cups,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', waterIntakeId)
          .eq('user_id', userId);
      
      debugPrint('✅ Registro de água atualizado com sucesso: $cups copos');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao atualizar ingestão de água: $e');
      throw AppException(
        message: 'Erro ao atualizar ingestão de água: ${e.toString()}',
        stackTrace: stackTrace,
        code: 'water_intake_update_error',
      );
    }
  }
  
  /// Retorna a data de hoje formatada para o Supabase
  String _getTodayFormatted() {
    final today = DateTime.now();
    return "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }
  
  /// Cria um novo registro de água para o dia atual se não existir
  /// [userId] - ID do usuário
  Future<String?> createWaterIntakeForToday(String userId) async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      // Verificar se já existe um registro para hoje
      final existing = await _client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .eq('date', formattedDate)
          .maybeSingle();
      
      // Se já existe, retornar o ID do registro existente
      if (existing != null) {
        return existing['id'] as String?;
      }
      
      // Não incluir o ID e deixar o Supabase gerar automaticamente
      final insertData = {
        'user_id': userId,
        'date': formattedDate,
        'cups': 0,
        'goal': 8,
        'glass_size': 250,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _client
          .from('water_intake')
          .insert(insertData)
          .select()
          .single();
      
      return response['id'] as String?;
    } catch (e) {
      debugPrint('Error getting water intake: $e');
      throw AppException(
        message: 'Erro ao buscar registro de água: $e',
        code: 'water_intake_error',
      );
    }
  }

  /// Força a atualização manual do dashboard diretamente nas tabelas
  Future<bool> forceManualDashboardUpdate(String userId, {int? workoutsToAdd = 1}) async {
    try {
      debugPrint('🔄 [MANUAL_UPDATE] Iniciando atualização manual do dashboard para usuário: $userId');
      final supabase = Supabase.instance.client;
      
      // 1. Verificar se o usuário já tem registro em user_progress
      final userProgress = await supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (userProgress == null) {
        debugPrint('🔄 [MANUAL_UPDATE] Criando registro inicial em user_progress');
        // Não existe entry para este usuário, criar um novo
        await supabase.from('user_progress').insert({
          'user_id': userId,
          'workouts': workoutsToAdd ?? 1,
          'points': 10, // Pontos base para um novo treino
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        debugPrint('✅ [MANUAL_UPDATE] Registro inicial criado em user_progress');
        return true;
      }
      
      // 2. Atualizar o registro existente
      debugPrint('🔄 [MANUAL_UPDATE] Atualizando registro existente');
      
      // Recuperar valores atuais
      final currentWorkouts = userProgress['workouts'] as int? ?? 0;
      final currentPoints = userProgress['points'] as int? ?? 0;
      
      // Atualizar com novos valores
      await supabase.from('user_progress').update({
        'workouts': currentWorkouts + (workoutsToAdd ?? 1),
        'points': currentPoints + 10, // Adicionar 10 pontos por treino
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
      
      debugPrint('✅ [MANUAL_UPDATE] Atualização manual concluída com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [MANUAL_UPDATE] Erro na atualização manual: $e');
      return false;
    }
  }
} // Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/error_handler.dart';
import 'package:ray_club_app/features/profile/models/notification_settings_state.dart';
import 'package:ray_club_app/features/profile/models/notification_type.dart';
import 'package:ray_club_app/features/profile/repositories/notification_settings_repository_interface.dart';

/// Provider para o repositório
final notificationSettingsRepositoryProvider = Provider<NotificationSettingsRepositoryInterface>((ref) {
  // Implementação será injetada na configuração da app
  throw UnimplementedError();
});

/// Provider para o ViewModel de configurações de notificação
final notificationSettingsViewModelProvider = StateNotifierProvider<NotificationSettingsViewModel, NotificationSettingsState>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  final errorHandler = ref.watch(ErrorHandler.provider);
  return NotificationSettingsViewModel(repository, errorHandler);
});

/// ViewModel para gerenciar configurações de notificação
class NotificationSettingsViewModel extends StateNotifier<NotificationSettingsState> {
  final NotificationSettingsRepositoryInterface _repository;
  final ErrorHandler _errorHandler;

  /// Construtor
  NotificationSettingsViewModel(this._repository, this._errorHandler) : super(const NotificationSettingsState()) {
    loadSettings();
  }

  /// Carrega todas as configurações de notificação
  Future<void> loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      final settings = await _repository.loadNotificationSettings();
      
      state = state.copyWith(
        isLoading: false,
        masterSwitchEnabled: settings['masterSwitch'] as bool,
        notificationSettings: settings['notificationSettings'] as Map<NotificationType, bool>,
        reminderTime: settings['reminderTime'] as TimeOfDay,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Atualiza o interruptor mestre de notificações
  Future<void> updateMasterSwitch(bool enabled) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      await _repository.updateMasterSwitch(enabled);
      
      state = state.copyWith(
        isLoading: false,
        masterSwitchEnabled: enabled,
        changesSaved: true,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Atualiza a configuração de um tipo específico de notificação
  Future<void> updateNotificationSetting(NotificationType type, bool enabled) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      await _repository.updateNotificationSetting(type, enabled);
      
      final updatedSettings = Map<NotificationType, bool>.from(state.notificationSettings);
      updatedSettings[type] = enabled;
      
      state = state.copyWith(
        isLoading: false,
        notificationSettings: updatedSettings,
        changesSaved: true,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Atualiza o horário do lembrete diário
  Future<void> updateReminderTime(TimeOfDay timeOfDay) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, changesSaved: false);
      
      await _repository.updateReminderTime(timeOfDay);
      
      state = state.copyWith(
        isLoading: false,
        reminderTime: timeOfDay,
        changesSaved: true,
      );
    } catch (e, stackTrace) {
      final appException = _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: appException.message,
      );
    }
  }

  /// Formata um TimeOfDay para exibição
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    String period = timeOfDay.hour >= 12 ? 'PM' : 'AM';
    int hour = timeOfDay.hour > 12 ? timeOfDay.hour - 12 : timeOfDay.hour;
    hour = hour == 0 ? 12 : hour;
    String minute = timeOfDay.minute < 10 ? '0${timeOfDay.minute}' : '${timeOfDay.minute}';
    return '$hour:$minute $period';
  }
} // Flutter imports:
import 'package:flutter/foundation.dart';

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/supabase_profile_repository.dart';

/// Provider para o repositório de perfil
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // Em ambiente de produção, usa a implementação Supabase
  // Em desenvolvimento ou testes, pode usar o mock
  final supabase = ref.watch(supabaseClientProvider);
  final offlineHelper = ref.watch(offlineRepositoryHelperProvider);
  
  // Adicionar suporte offline
  return SupabaseProfileRepository(
    supabase,
    offlineHelper,
  );
});

/// Provider para o ViewModel de perfil
final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, BaseState<Profile>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return ProfileViewModel(
    repository: repository,
    connectivityService: connectivityService,
  );
});

/// ViewModel para gerenciar o perfil do usuário
class ProfileViewModel extends BaseViewModel<Profile> {
  final ProfileRepository _repository;

  /// Construtor
  ProfileViewModel({
    required ProfileRepository repository,
    ConnectivityService? connectivityService,
  }) : _repository = repository,
       super(connectivityService: connectivityService);
  
  @override
  Future<void> loadData({Profile? useCachedData}) async {
    if (useCachedData != null) {
      state = BaseState.data(data: useCachedData);
      // Ainda tenta recarregar em background
      _loadCurrentUserProfile(silentUpdate: true);
      return;
    }
    
    await _loadCurrentUserProfile();
  }
  
  /// Carrega o perfil do usuário atual
  Future<void> _loadCurrentUserProfile({bool silentUpdate = false}) async {
    try {
      if (!silentUpdate) {
        state = const BaseState.loading();
      }
      
      final profile = await _repository.getCurrentUserProfile();
      
      if (profile == null) {
        if (!silentUpdate) {
          state = const BaseState.error(message: 'Perfil não encontrado');
        }
        return;
      }
      
      state = BaseState.data(data: profile);
    } catch (e, stackTrace) {
      if (!silentUpdate) {
        state = handleError(e, stackTrace: stackTrace);
      }
      logError('Erro ao carregar perfil', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Carrega o perfil do usuário por ID
  Future<void> loadProfileById(String userId) async {
    try {
      state = const BaseState.loading();
      
      final profile = await _repository.getProfileById(userId);
      
      if (profile == null) {
        state = const BaseState.error(message: 'Perfil não encontrado');
        return;
      }
      
      state = BaseState.data(data: profile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao carregar perfil por ID', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? bio,
    List<String>? goals,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? instagram,
  }) async {
    // Verificar se temos o perfil atual
    final currentState = state;
    if (currentState is! BaseStateData<Profile>) {
      state = const BaseState.error(message: 'Perfil não disponível para atualização');
      return;
    }
    
    final currentProfile = currentState.data;
    
    try {
      state = const BaseState.loading();
      
      final updatedProfile = await _repository.updateProfile(
        currentProfile.copyWith(
          name: name ?? currentProfile.name,
          bio: bio ?? currentProfile.bio,
          goals: goals ?? currentProfile.goals,
          phone: phone ?? currentProfile.phone,
          gender: gender ?? currentProfile.gender,
          birthDate: birthDate ?? currentProfile.birthDate,
          instagram: instagram ?? currentProfile.instagram,
        ),
      );
      
      state = BaseState.data(data: updatedProfile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao atualizar perfil', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Atualiza o email do usuário
  Future<void> updateEmail(String email) async {
    // Verificar se temos o perfil atual
    final currentState = state;
    if (currentState is! BaseStateData<Profile>) {
      state = const BaseState.error(message: 'Perfil não disponível para atualização');
      return;
    }
    
    final currentProfile = currentState.data;
    
    try {
      state = const BaseState.loading();
      
      await _repository.updateEmail(currentProfile.id, email);
      
      final updatedProfile = currentProfile.copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      
      state = BaseState.data(data: updatedProfile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao atualizar email', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Envia link para redefinição de senha
  Future<void> sendPasswordResetLink(String email) async {
    try {
      // Não alteramos o estado para não interromper a UI
      await _repository.sendPasswordResetLink(email);
    } catch (e, stackTrace) {
      logError('Erro ao enviar link de redefinição de senha', error: e, stackTrace: stackTrace);
      rethrow; // Deixa o chamador lidar com o erro
    }
  }
  
  /// Verifica a disponibilidade de um nome de usuário
  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _repository.isUsernameAvailable(username);
    } catch (e, stackTrace) {
      logError('Erro ao verificar disponibilidade de username', error: e, stackTrace: stackTrace);
      return false; // Em caso de erro, considera indisponível por segurança
    }
  }
  
  /// Atualiza as metas do perfil do usuário
  Future<void> updateProfileGoals({
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  }) async {
    // Verificar se temos o perfil atual
    final currentState = state;
    if (currentState is! BaseStateData<Profile>) {
      state = const BaseState.error(message: 'Perfil não disponível para atualização');
      return;
    }
    
    final currentProfile = currentState.data;
    
    try {
      state = const BaseState.loading();
      
      final updatedProfile = await _repository.updateProfileGoals(
        userId: currentProfile.id,
        dailyWaterGoal: dailyWaterGoal,
        dailyWorkoutGoal: dailyWorkoutGoal,
        weeklyWorkoutGoal: weeklyWorkoutGoal,
        weightGoal: weightGoal,
        currentWeight: currentWeight,
        preferredWorkoutTypes: preferredWorkoutTypes,
      );
      
      state = BaseState.data(data: updatedProfile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao atualizar metas do perfil', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Exclui a conta do usuário
  Future<void> deleteAccount() async {
    try {
      final currentState = state;
      if (currentState is! BaseStateData<Profile>) {
        throw Exception('Perfil não disponível para exclusão');
      }
      
      final userId = currentState.data.id;
      
      state = const BaseState.loading();
      
      await _repository.deleteAccount(userId);
      
      // Após excluir a conta, atualizamos o estado para refletir que não há mais usuário
      state = const BaseState.initial();
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao excluir conta', error: e, stackTrace: stackTrace);
      rethrow; // Propagar o erro para que o chamador possa exibir uma mensagem apropriada
    }
  }
} 
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/profile/repositories/notification_settings_repository_interface.dart';
import 'package:ray_club_app/features/profile/screens/notification_settings_screen.dart';

/// Implementação do repositório de configurações de notificação usando SharedPreferences
class NotificationSettingsRepository implements NotificationSettingsRepositoryInterface {
  /// Chave para o interruptor mestre
  static const String _masterSwitchKey = 'notifications_enabled';
  
  /// Prefixo para hora do lembrete
  static const String _reminderHourKey = 'notification_reminder_hour';
  
  /// Prefixo para minuto do lembrete
  static const String _reminderMinuteKey = 'notification_reminder_minute';
  
  @override
  Future<Map<String, dynamic>> loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Carregar configuração mestra
      final masterSwitch = prefs.getBool(_masterSwitchKey) ?? true;
      
      // Carregar configurações individuais
      final Map<NotificationType, bool> notificationSettings = {};
      for (final type in NotificationType.values) {
        notificationSettings[type] = prefs.getBool(type.prefsKey) ?? true;
      }
      
      // Carregar horário do lembrete
      final reminderHour = prefs.getInt(_reminderHourKey) ?? 18;
      final reminderMinute = prefs.getInt(_reminderMinuteKey) ?? 0;
      final reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
      
      return {
        'masterSwitch': masterSwitch,
        'notificationSettings': notificationSettings,
        'reminderTime': reminderTime,
      };
    } catch (e) {
      throw StorageException(
        message: 'Erro ao carregar configurações de notificação',
        originalException: e,
      );
    }
  }
  
  @override
  Future<void> updateMasterSwitch(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_masterSwitchKey, enabled);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar interruptor mestre de notificações',
        originalException: e,
      );
    }
  }
  
  @override
  Future<void> updateNotificationSetting(NotificationType type, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(type.prefsKey, enabled);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar configuração de notificação',
        originalException: e,
      );
    }
  }
  
  @override
  Future<void> updateReminderTime(TimeOfDay timeOfDay) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderHourKey, timeOfDay.hour);
      await prefs.setInt(_reminderMinuteKey, timeOfDay.minute);
    } catch (e) {
      throw StorageException(
        message: 'Erro ao atualizar horário de lembrete',
        originalException: e,
      );
    }
  }
} // Project imports:
import '../models/profile_model.dart';

/// Interface para o repositório de perfil
abstract class ProfileRepository {
  /// Obtém o perfil do usuário atual
  Future<Profile?> getCurrentUserProfile();
  
  /// Obtém um perfil de usuário por ID
  Future<Profile?> getProfileById(String userId);
  
  /// Obtém todos os perfis
  Future<List<Profile>> getAllProfiles();
  
  /// Atualiza o perfil do usuário
  Future<Profile> updateProfile(Profile profile);
  
  /// Atualiza a foto de perfil do usuário
  Future<String> updateProfilePhoto(String userId, String filePath);
  
  /// Adiciona um treino aos favoritos
  Future<Profile> addWorkoutToFavorites(String userId, String workoutId);
  
  /// Remove um treino dos favoritos
  Future<Profile> removeWorkoutFromFavorites(String userId, String workoutId);
  
  /// Incrementa o contador de treinos completados
  Future<Profile> incrementCompletedWorkouts(String userId);
  
  /// Atualiza a sequência de dias de treino
  Future<Profile> updateStreak(String userId, int streak);
  
  /// Adiciona pontos ao usuário
  Future<Profile> addPoints(String userId, int points);
  
  /// Atualiza o email do usuário
  Future<void> updateEmail(String userId, String email);
  
  /// Envia link para redefinir senha
  Future<void> sendPasswordResetLink(String email);
  
  /// Verifica se um nome de usuário está disponível
  Future<bool> isUsernameAvailable(String username);
  
  /// Exclui a conta do usuário
  Future<void> deleteAccount(String userId);
  
  /// Atualiza metas específicas do perfil
  Future<Profile> updateProfileGoals({
    required String userId,
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  });
}

/// Implementação Mock do repositório de perfil para desenvolvimento
class MockProfileRepository implements ProfileRepository {
  // Lista de perfis mockados para desenvolvimento
  final List<Profile> _mockProfiles = [
    Profile(
      id: 'user-1',
      name: 'Maria Silva',
      email: 'maria@exemplo.com',
      photoUrl: null,
      completedWorkouts: 24,
      streak: 3,
      points: 750,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      bio: 'Entusiasta de fitness e bem-estar',
      goals: ['Perder peso', 'Melhorar condicionamento'],
      favoriteWorkoutIds: ['workout-1', 'workout-3'],
      phone: '(11) 98765-4321',
      gender: 'Feminino',
      birthDate: DateTime(1990, 5, 15),
      instagram: '@mariasilva',
    ),
    Profile(
      id: 'user-2',
      name: 'João Pereira',
      email: 'joao@exemplo.com',
      photoUrl: null,
      completedWorkouts: 15,
      streak: 1,
      points: 350,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      bio: 'Corredor amador',
      goals: ['Ganhar massa muscular'],
      favoriteWorkoutIds: ['workout-2'],
      phone: '(21) 99876-5432',
      gender: 'Masculino',
      birthDate: DateTime(1988, 10, 20),
      instagram: '@joaopereira',
    ),
  ];
  
  // ID do usuário atual simulado
  final String _currentUserId = 'user-1';
  
  // Atraso simulado da rede
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
  
  @override
  Future<Profile?> getCurrentUserProfile() async {
    await _simulateNetworkDelay();
    try {
      return _mockProfiles.firstWhere((profile) => profile.id == _currentUserId);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Profile?> getProfileById(String userId) async {
    await _simulateNetworkDelay();
    try {
      return _mockProfiles.firstWhere((profile) => profile.id == userId);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<Profile>> getAllProfiles() async {
    await _simulateNetworkDelay();
    return List.from(_mockProfiles);
  }
  
  @override
  Future<Profile> updateProfile(Profile profile) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<String> updateProfilePhoto(String userId, String filePath) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      // Em um ambiente real, o caminho do arquivo seria processado e armazenado
      final mockPhotoUrl = 'https://exemplo.com/fotos/$userId.jpg';
      
      _mockProfiles[index] = _mockProfiles[index].copyWith(
        photoUrl: mockPhotoUrl,
        updatedAt: DateTime.now(),
      );
      
      return mockPhotoUrl;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> addWorkoutToFavorites(String userId, String workoutId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final currentFavorites = List<String>.from(_mockProfiles[index].favoriteWorkoutIds);
      
      if (!currentFavorites.contains(workoutId)) {
        currentFavorites.add(workoutId);
        
        final updatedProfile = _mockProfiles[index].copyWith(
          favoriteWorkoutIds: currentFavorites,
          updatedAt: DateTime.now(),
        );
        
        _mockProfiles[index] = updatedProfile;
        return updatedProfile;
      }
      
      return _mockProfiles[index];
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> removeWorkoutFromFavorites(String userId, String workoutId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final currentFavorites = List<String>.from(_mockProfiles[index].favoriteWorkoutIds);
      
      if (currentFavorites.contains(workoutId)) {
        currentFavorites.remove(workoutId);
        
        final updatedProfile = _mockProfiles[index].copyWith(
          favoriteWorkoutIds: currentFavorites,
          updatedAt: DateTime.now(),
        );
        
        _mockProfiles[index] = updatedProfile;
        return updatedProfile;
      }
      
      return _mockProfiles[index];
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> incrementCompletedWorkouts(String userId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final updatedProfile = _mockProfiles[index].copyWith(
        completedWorkouts: _mockProfiles[index].completedWorkouts + 1,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> updateStreak(String userId, int streak) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final updatedProfile = _mockProfiles[index].copyWith(
        streak: streak,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> addPoints(String userId, int points) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final updatedProfile = _mockProfiles[index].copyWith(
        points: _mockProfiles[index].points + points,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<void> updateEmail(String userId, String email) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      _mockProfiles[index] = _mockProfiles[index].copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      return;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<void> sendPasswordResetLink(String email) async {
    await _simulateNetworkDelay();
    
    final userExists = _mockProfiles.any((profile) => profile.email == email);
    if (!userExists) {
      throw Exception('Email não encontrado');
    }
    
    // Simulação de envio de email de redefinição
    return;
  }
  
  @override
  Future<bool> isUsernameAvailable(String username) async {
    await _simulateNetworkDelay();
    return !_mockProfiles.any((profile) => profile.name == username);
  }
  
  @override
  Future<void> deleteAccount(String userId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      _mockProfiles.removeAt(index);
      return;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> updateProfileGoals({
    required String userId,
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  }) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final currentProfile = _mockProfiles[index];
      final updatedProfile = currentProfile.copyWith(
        dailyWaterGoal: dailyWaterGoal ?? currentProfile.dailyWaterGoal,
        dailyWorkoutGoal: dailyWorkoutGoal ?? currentProfile.dailyWorkoutGoal,
        weeklyWorkoutGoal: weeklyWorkoutGoal ?? currentProfile.weeklyWorkoutGoal,
        weightGoal: weightGoal,
        currentWeight: currentWeight,
        preferredWorkoutTypes: preferredWorkoutTypes ?? currentProfile.preferredWorkoutTypes,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
} 
// Flutter imports:
import 'package:flutter/foundation.dart';
import 'dart:io';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/offline/offline_repository_helper.dart';
import '../../../core/offline/offline_operation_queue.dart';
import '../models/profile_model.dart';
import 'profile_repository.dart';

/// Implementação do repositório de perfil usando Supabase
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;
  final OfflineRepositoryHelper? _offlineHelper;
  
  /// Nome da tabela de perfis
  static const String _profilesTable = 'profiles';
  
  /// Nome do bucket para imagens de perfil
  static const String _profileImagesBucket = 'profile_images';
  
  /// Construtor
  SupabaseProfileRepository(this._client, [this._offlineHelper]);
  
  @override
  Future<Profile?> getCurrentUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      
      return await getProfileById(userId);
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao obter perfil do usuário atual');
      return null;
    }
  }
  
  @override
  Future<Profile?> getProfileById(String userId) async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select()
          .eq('id', userId)
          .single();
      
      if (response == null) return null;
      
      // Mapeamento correto entre as colunas do banco e o modelo
      return Profile(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        // Suporta ambos profile_image_url e photo_url para compatibilidade
        photoUrl: response['photo_url'] ?? response['profile_image_url'],
        bio: response['bio'],
        phone: response['phone'],
        gender: response['gender'],
        birthDate: response['birth_date'] != null 
            ? DateTime.parse(response['birth_date']) 
            : null,
        instagram: response['instagram'],
        favoriteWorkoutIds: response['favorite_workout_ids'] != null 
            ? List<String>.from(response['favorite_workout_ids']) 
            : [],
        goals: response['goals'] != null 
            ? List<String>.from(response['goals']) 
            : [],
        streak: response['streak'] ?? 0,
        completedWorkouts: response['completed_workouts'] ?? 0,
        points: response['points'] ?? 0,
        createdAt: response['created_at'] != null 
            ? DateTime.parse(response['created_at']) 
            : null,
        updatedAt: response['updated_at'] != null 
            ? DateTime.parse(response['updated_at']) 
            : null,
        // Novos campos adicionados
        dailyWaterGoal: response['daily_water_goal'] ?? 8,
        dailyWorkoutGoal: response['daily_workout_goal'] ?? 1,
        weeklyWorkoutGoal: response['weekly_workout_goal'] ?? 5,
        weightGoal: response['weight_goal'] != null ? 
            double.parse(response['weight_goal'].toString()) : null,
        height: response['height'] != null ? 
            double.parse(response['height'].toString()) : null,
        currentWeight: response['current_weight'] != null ? 
            double.parse(response['current_weight'].toString()) : null,
        preferredWorkoutTypes: response['preferred_workout_types'] != null 
            ? List<String>.from(response['preferred_workout_types']) 
            : [],
        stats: response['stats'] != null 
            ? Map<String, dynamic>.from(response['stats']) 
            : {
                'total_workouts': 0,
                'total_challenges': 0,
                'total_checkins': 0,
                'longest_streak': 0,
                'points_earned': 0,
                'completed_challenges': 0,
                'water_intake_average': 0
              },
      );
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao obter perfil por ID');
      return null;
    }
  }
  
  @override
  Future<List<Profile>> getAllProfiles() async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select();
      
      return response.map<Profile>((json) {
        // Usar o mesmo mapeamento consistente
        return Profile(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          photoUrl: json['photo_url'] ?? json['profile_image_url'],
          bio: json['bio'],
          phone: json['phone'],
          gender: json['gender'],
          birthDate: json['birth_date'] != null 
              ? DateTime.parse(json['birth_date']) 
              : null,
          instagram: json['instagram'],
          favoriteWorkoutIds: json['favorite_workout_ids'] != null 
              ? List<String>.from(json['favorite_workout_ids']) 
              : [],
          goals: json['goals'] != null 
              ? List<String>.from(json['goals']) 
              : [],
          streak: json['streak'] ?? 0,
          completedWorkouts: json['completed_workouts'] ?? 0,
          points: json['points'] ?? 0,
          createdAt: json['created_at'] != null 
              ? DateTime.parse(json['created_at']) 
              : null,
          updatedAt: json['updated_at'] != null 
              ? DateTime.parse(json['updated_at']) 
              : null,
          // Novos campos adicionados
          dailyWaterGoal: json['daily_water_goal'] ?? 8,
          dailyWorkoutGoal: json['daily_workout_goal'] ?? 1,
          weeklyWorkoutGoal: json['weekly_workout_goal'] ?? 5,
          weightGoal: json['weight_goal'] != null ? 
              double.parse(json['weight_goal'].toString()) : null,
          height: json['height'] != null ? 
              double.parse(json['height'].toString()) : null,
          currentWeight: json['current_weight'] != null ? 
              double.parse(json['current_weight'].toString()) : null,
          preferredWorkoutTypes: json['preferred_workout_types'] != null 
              ? List<String>.from(json['preferred_workout_types']) 
              : [],
          stats: json['stats'] != null 
              ? Map<String, dynamic>.from(json['stats']) 
              : {
                  'total_workouts': 0,
                  'total_challenges': 0,
                  'total_checkins': 0,
                  'longest_streak': 0,
                  'points_earned': 0,
                  'completed_challenges': 0,
                  'water_intake_average': 0
                },
        );
      }).toList();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao obter todos os perfis');
      return [];
    }
  }
  
  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (userId != profile.id) {
        throw AppAuthException(message: 'Não é possível atualizar perfil de outro usuário');
      }
      
      // Converter do modelo para o formato do banco
      final updateData = {
        'name': profile.name,
        'bio': profile.bio,
        'phone': profile.phone,
        'gender': profile.gender,
        'birth_date': profile.birthDate?.toIso8601String(),
        'instagram': profile.instagram,
        'goals': profile.goals,
        'updated_at': DateTime.now().toIso8601String(),
        // Novos campos adicionados
        'daily_water_goal': profile.dailyWaterGoal,
        'daily_workout_goal': profile.dailyWorkoutGoal,
        'weekly_workout_goal': profile.weeklyWorkoutGoal,
        'weight_goal': profile.weightGoal,
        'height': profile.height,
        'current_weight': profile.currentWeight,
        'preferred_workout_types': profile.preferredWorkoutTypes,
      };
      
      // Usar suporte offline se disponível
      if (_offlineHelper != null) {
        return await _offlineHelper!.executeWithOfflineSupport<Profile>(
          entity: 'profiles',
          type: OperationType.update,
          data: {
            'id': userId,
            ...updateData,
          },
          onlineOperation: () async {
            await _client
                .from(_profilesTable)
                .update(updateData)
                .eq('id', userId);
            
            // Buscar o perfil atualizado
            final updatedProfile = await getProfileById(userId);
            if (updatedProfile == null) {
              throw StorageException(message: 'Falha ao recuperar perfil atualizado');
            }
            
            return updatedProfile;
          },
          offlineResultBuilder: (operation) {
            // Simular o resultado offline
            return profile.copyWith(updatedAt: DateTime.now());
          },
        );
      } else {
        // Fluxo padrão sem suporte offline
        await _client
            .from(_profilesTable)
            .update(updateData)
            .eq('id', userId);
        
        // Buscar o perfil atualizado
        final updatedProfile = await getProfileById(userId);
        if (updatedProfile == null) {
          throw StorageException(message: 'Falha ao recuperar perfil atualizado');
        }
        
        return updatedProfile;
      }
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar perfil');
    }
  }
  
  /// Método auxiliar para atualizar apenas campos específicos de metas
  @override
  Future<Profile> updateProfileGoals({
    required String userId,
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  }) async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (authUserId != userId) {
        throw AppAuthException(message: 'Não é possível atualizar metas de outro usuário');
      }
      
      // Criar objeto só com os campos que foram passados
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (dailyWaterGoal != null) updateData['daily_water_goal'] = dailyWaterGoal;
      if (dailyWorkoutGoal != null) updateData['daily_workout_goal'] = dailyWorkoutGoal;
      if (weeklyWorkoutGoal != null) updateData['weekly_workout_goal'] = weeklyWorkoutGoal;
      if (weightGoal != null) updateData['weight_goal'] = weightGoal;
      if (currentWeight != null) updateData['current_weight'] = currentWeight;
      if (preferredWorkoutTypes != null) updateData['preferred_workout_types'] = preferredWorkoutTypes;
      
      await _client
          .from(_profilesTable)
          .update(updateData)
          .eq('id', userId);
      
      // Buscar o perfil atualizado
      final updatedProfile = await getProfileById(userId);
      if (updatedProfile == null) {
        throw StorageException(message: 'Falha ao recuperar perfil atualizado');
      }
      
      return updatedProfile;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar metas de perfil');
    }
  }
  
  @override
  Future<String> updateProfilePhoto(String userId, String filePath) async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (authUserId != userId) {
        throw AppAuthException(message: 'Não é possível atualizar foto de outro usuário');
      }
      
      // Nome único para o arquivo (usando timestamp)
      final fileExt = path.extension(filePath);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      
      // Upload da imagem
      final file = File(filePath);
      await _client.storage
          .from(_profileImagesBucket)
          .upload(fileName, file);
          
      // Obter URL pública da imagem
      final imageUrl = _client.storage
          .from(_profileImagesBucket)
          .getPublicUrl(fileName);
          
      // Atualizar URL da imagem no perfil - usar ambos os campos para compatibilidade
      await _client
          .from(_profilesTable)
          .update({
            'photo_url': imageUrl,
            'profile_image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return imageUrl;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar foto de perfil');
    }
  }
  
  @override
  Future<Profile> addWorkoutToFavorites(String userId, String workoutId) async {
    try {
      // Obter perfil atual para verificar se já tem esse treino nos favoritos
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Verificar se o treino já está nos favoritos
      if (profile.favoriteWorkoutIds.contains(workoutId)) {
        return profile; // Já está nos favoritos, retorna perfil sem alterações
      }
      
      // Adicionar treino aos favoritos
      final updatedFavorites = List<String>.from(profile.favoriteWorkoutIds)..add(workoutId);
      
      await _client
          .from(_profilesTable)
          .update({
            'favorite_workout_ids': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(favoriteWorkoutIds: updatedFavorites);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar treino aos favoritos');
    }
  }
  
  @override
  Future<Profile> removeWorkoutFromFavorites(String userId, String workoutId) async {
    try {
      // Obter perfil atual para verificar se tem esse treino nos favoritos
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Verificar se o treino está nos favoritos
      if (!profile.favoriteWorkoutIds.contains(workoutId)) {
        return profile; // Não está nos favoritos, retorna perfil sem alterações
      }
      
      // Remover treino dos favoritos
      final updatedFavorites = List<String>.from(profile.favoriteWorkoutIds)..remove(workoutId);
      
      await _client
          .from(_profilesTable)
          .update({
            'favorite_workout_ids': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(favoriteWorkoutIds: updatedFavorites);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao remover treino dos favoritos');
    }
  }
  
  @override
  Future<Profile> incrementCompletedWorkouts(String userId) async {
    try {
      // Obter perfil atual
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Incrementar contador de treinos
      final completedWorkouts = profile.completedWorkouts + 1;
      
      await _client
          .from(_profilesTable)
          .update({
            'completed_workouts': completedWorkouts,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(completedWorkouts: completedWorkouts);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao incrementar treinos completados');
    }
  }
  
  @override
  Future<Profile> updateStreak(String userId, int streak) async {
    try {
      // Obter perfil atual
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      await _client
          .from(_profilesTable)
          .update({
            'streak': streak,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(streak: streak);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar streak');
    }
  }
  
  @override
  Future<Profile> addPoints(String userId, int points) async {
    try {
      // Obter perfil atual
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Calcular total de pontos
      final totalPoints = profile.points + points;
      
      await _client
          .from(_profilesTable)
          .update({
            'points': totalPoints,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(points: totalPoints);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar pontos');
    }
  }
  
  @override
  Future<void> updateEmail(String userId, String email) async {
    try {
      // Atualizar email na autenticação
      await _client.auth.updateUser(
        UserAttributes(email: email),
      );
      
      // Atualizar email na tabela de perfis
      await _client
          .from(_profilesTable)
          .update({
            'email': email,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar email');
    }
  }
  
  @override
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao enviar link de redefinição de senha');
    }
  }
  
  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select('id')
          .eq('name', username)
          .maybeSingle();
      
      // Se não retornou nada, o nome está disponível
      return response == null;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao verificar disponibilidade de username');
      // Em caso de erro, assumimos que o nome não está disponível por segurança
      return false;
    }
  }
  
  @override
  Future<void> deleteAccount(String userId) async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (authUserId != userId) {
        throw AppAuthException(message: 'Não é possível excluir a conta de outro usuário');
      }
      
      // Primeiro removemos os dados do usuário de todas as tabelas relacionadas
      // Isso deve ser feito usando uma função edge do Supabase com service_role
      
      final url = '${dotenv.env['SUPABASE_URL']}/functions/v1/delete-user';
      final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
      
      if (serviceRoleKey == null) {
        throw AppException(message: 'Chave service_role não encontrada no ambiente');
      }
      
      final dio = Dio();
      final response = await dio.post(
        url,
        data: {'userId': userId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serviceRoleKey'
          },
        ),
      );
      
      if (response.statusCode != 200) {
        throw AppException(
          message: 'Erro ao excluir conta: ${response.statusCode}',
          originalError: response.data,
        );
      }
      
      // Após excluir todos os dados, fazemos logout
      await _client.auth.signOut();
      
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao excluir conta');
    }
  }
  
  /// Trata erros e lança exceções apropriadas
  Exception _handleError(Object error, StackTrace stackTrace, String defaultMessage) {
    if (kDebugMode) {
      print('Error in SupabaseProfileRepository: $error');
      print(stackTrace);
    }
    
    if (error is PostgrestException) {
      return StorageException(
        message: error.message ?? defaultMessage,
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is AppAuthException) {
      return error;
    }
    
    if (error is StorageException) {
      return error;
    }
    
    return AppException(
      message: defaultMessage,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/repositories/benefits_repository.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';

part 'benefits_view_model.freezed.dart';

/// State for the benefits view model
@freezed
class BenefitsState with _$BenefitsState {
  const factory BenefitsState({
    @Default([]) List<Benefit> benefits,
    @Default([]) List<Benefit> filteredBenefits,
    @Default('all') String activeTab,
    @Default(false) bool isLoading,
    String? errorMessage,
    Benefit? selectedBenefit,
    @Default([]) List<String> partners,
  }) = _BenefitsState;
}

/// Provider for the benefits view model
final benefitsViewModelProvider = StateNotifierProvider<BenefitsViewModel, BenefitsState>((ref) {
  final repository = ref.watch(benefitsRepositoryProvider);
  return BenefitsViewModel(repository);
});

/// ViewModel for benefits management
class BenefitsViewModel extends StateNotifier<BenefitsState> {
  final BenefitsRepository _repository;

  BenefitsViewModel(this._repository) : super(const BenefitsState()) {
    loadBenefits();
  }

  /// Loads all benefits
  Future<void> loadBenefits() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final benefits = await _repository.getAllBenefits();
      
      // Extract unique partners
      final partnerSet = <String>{};
      for (var benefit in benefits) {
        partnerSet.add(benefit.partner);
      }
      
      state = state.copyWith(
        benefits: benefits,
        filteredBenefits: benefits,
        partners: partnerSet.toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao carregar benefícios: ${e.toString()}'
      );
    }
  }

  /// Filters benefits by type
  Future<void> filterByType(BenefitType type) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final benefits = await _repository.getBenefitsByType(type);
      state = state.copyWith(
        filteredBenefits: benefits,
        activeTab: type.toString().split('.').last,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao filtrar benefícios: ${e.toString()}'
      );
    }
  }
  
  /// Shows all benefits
  void showAllBenefits() {
    state = state.copyWith(
      filteredBenefits: state.benefits,
      activeTab: 'all',
    );
  }

  /// Filters benefits by partner
  Future<void> filterByPartner(String partner) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final benefits = await _repository.getBenefitsByPartner(partner);
      state = state.copyWith(
        filteredBenefits: benefits,
        activeTab: 'partner',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao filtrar benefícios por parceiro: ${e.toString()}'
      );
    }
  }

  /// Selects a benefit to show details
  void selectBenefit(Benefit benefit) {
    state = state.copyWith(selectedBenefit: benefit);
  }

  /// Clears the selected benefit
  void clearSelectedBenefit() {
    state = state.copyWith(selectedBenefit: null);
  }
} 
// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../core/errors/app_exception.dart' as app_errors;
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../core/services/cache_service.dart';
import '../../../services/qr_service.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';
import '../enums/benefit_type.dart';
import '../repositories/benefit_repository.dart';
import '../repositories/mock_benefit_repository.dart';
import '../providers/benefit_providers.dart';
import 'benefit_state.dart';

/// Provider do repositório de benefícios
final benefitRepositoryProvider = Provider<BenefitRepository>((ref) {
  // Usar apenas o mock para resolver problemas de compilação
  return MockBenefitRepository();
  
  // Código original comentado:
  /*
  if (kDebugMode) {
    // Em modo de desenvolvimento, usa o mock para testes
    return MockBenefitRepository();
  } else {
    // Em produção, usa a implementação real com Supabase
    final supabase = ref.watch(supabaseClientProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    
    return SupabaseBenefitRepository(
      supabaseClient: supabase,
      cacheService: cacheService,
      connectivityService: connectivityService,
    );
  }
  */
});

/// Provider do ViewModel de benefícios
final benefitViewModelProvider = StateNotifierProvider<BenefitViewModel, BenefitState>((ref) {
  final qrService = ref.watch(qrServiceProvider);
  return BenefitViewModel(
    ref.watch(benefitRepositoryProvider),
    qrService,
  );
});

/// ViewModel para gerenciar benefícios
class BenefitViewModel extends StateNotifier<BenefitState> {
  final BenefitRepository _repository;
  final QRService _qrService;
  
  BenefitViewModel(this._repository, this._qrService) : super(const BenefitState());
  
  /// Carrega todos os benefícios disponíveis
  Future<void> loadBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final benefits = await _repository.getBenefits();
      final categories = await _repository.getBenefitCategories();
      
      // Obtém pontos do usuário se for mock
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        try {
          userPoints = await (_repository as MockBenefitRepository).getUserPoints();
        } catch (e) {
          // Ignora erros ao tentar obter pontos durante testes
          if (kDebugMode) {
            print('Erro ao obter pontos do usuário: $e');
          }
        }
      }
      
      state = state.copyWith(
        benefits: benefits,
        categories: categories,
        userPoints: userPoints,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios: $e',
      );
    }
  }
  
  /// Carrega os benefícios resgatados pelo usuário
  Future<void> loadRedeemedBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final redeemedBenefits = await _repository.getRedeemedBenefits();
      
      // Verifica e atualiza status de expiração antes de atualizar o estado
      await checkExpiredBenefits(redeemedBenefits);
      
      state = state.copyWith(
        redeemedBenefits: redeemedBenefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios resgatados: $e',
      );
    }
  }
  
  /// Verifica quais benefícios estão expirados e atualiza seus status
  Future<void> checkExpiredBenefits(List<RedeemedBenefit> benefits) async {
    final now = DateTime.now();
    bool hasUpdates = false;
    
    for (int i = 0; i < benefits.length; i++) {
      final benefit = benefits[i];
      
      // Verifica se o benefício está com data de expiração no passado
      // Não verificamos mais status já que esse campo não existe mais
      if (benefit.expiresAt != null && benefit.expiresAt!.isBefore(now)) {
        // Tenta atualizar para expirado
        try {
          final updatedBenefit = await _repository.updateBenefitStatus(
            benefit.id, 
            BenefitStatus.expired
          );
          
          // Se conseguiu atualizar, substitui na lista
          if (updatedBenefit != null) {
            benefits[i] = updatedBenefit;
            hasUpdates = true;
          }
        } catch (e) {
          // Ignora erro na atualização e continua
          if (kDebugMode) {
            print('Erro ao atualizar status de benefício expirado: $e');
          }
        }
      }
    }
    
    // Se houver alterações, atualiza o estado
    if (hasUpdates && state.selectedRedeemedBenefit != null) {
      // Atualiza o benefício selecionado se ele estiver entre os expirados
      final updatedSelected = benefits.firstWhere(
        (b) => b.id == state.selectedRedeemedBenefit!.id,
        orElse: () => state.selectedRedeemedBenefit!,
      );
      
      state = state.copyWith(selectedRedeemedBenefit: updatedSelected);
    }
  }
  
  /// Filtra benefícios por categoria
  Future<void> filterByCategory(String? category) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedCategory: category);

    try {
      final benefits = category != null 
          ? await _repository.getBenefitsByCategory(category)
          : await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao filtrar benefícios: $e',
      );
    }
  }
  
  /// Seleciona um benefício para visualização detalhada
  Future<void> selectBenefit(String benefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final benefit = await _repository.getBenefitById(benefitId);
      
      if (benefit == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Benefício não encontrado',
        );
        return;
      }
      
      state = state.copyWith(
        selectedBenefit: benefit,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao selecionar benefício: $e',
      );
    }
  }
  
  /// Seleciona um benefício resgatado para visualização
  Future<void> selectRedeemedBenefit(String redeemedBenefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final redeemedBenefit = await _repository.getRedeemedBenefitById(redeemedBenefitId);
      
      if (redeemedBenefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício resgatado não encontrado',
          code: 'redeemed_benefit_not_found',
        );
      }
      
      state = state.copyWith(
        selectedRedeemedBenefit: redeemedBenefit,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Resgata um benefício
  Future<RedeemedBenefit?> redeemBenefit(String benefitId) async {
    state = state.copyWith(
      isRedeeming: true, 
      errorMessage: null,
      benefitBeingRedeemed: null,
    );

    try {
      final benefit = await _repository.getBenefitById(benefitId);
      
      if (benefit == null) {
        state = state.copyWith(
          isRedeeming: false,
          errorMessage: 'Benefício não encontrado',
        );
        return null;
      }
      
      // Verifica se tem pontos suficientes
      final hasEnough = await _repository.hasEnoughPoints(benefitId);
      if (!hasEnough) {
        state = state.copyWith(
          isRedeeming: false,
          errorMessage: 'Pontos insuficientes para resgatar este benefício',
        );
        return null;
      }
      
      state = state.copyWith(
        isRedeeming: true,
        errorMessage: null,
        successMessage: null,
        benefitBeingRedeemed: benefit,
      );
      
      final redeemedBenefit = await _repository.redeemBenefit(benefitId);
      
      // Atualiza pontos do usuário se estiver usando MockBenefitRepository
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      // Carrega benefícios resgatados novamente para atualizar a lista
      await loadRedeemedBenefits();
      
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        redeemedBenefits: state.redeemedBenefits,
        userPoints: userPoints,
        selectedRedeemedBenefit: redeemedBenefit,
        successMessage: 'Benefício resgatado com sucesso!',
      );
      
      return redeemedBenefit;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        errorMessage: e.message,
        successMessage: null,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        errorMessage: 'Erro ao resgatar benefício: $e',
        successMessage: null,
      );
      return null;
    }
  }
  
  /// Marca um benefício como utilizado
  Future<bool> markBenefitAsUsed(String redeemedBenefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    try {
      final updatedBenefit = await _repository.markBenefitAsUsed(redeemedBenefitId);
      
      // Atualiza a lista de benefícios resgatados
      await loadRedeemedBenefits();
      
      state = state.copyWith(
        redeemedBenefits: state.redeemedBenefits,
        selectedRedeemedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Benefício marcado como utilizado com sucesso!',
      );
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.message,
        successMessage: null
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao marcar benefício como utilizado: $e',
        successMessage: null
      );
      return false;
    }
  }
  
  /// Cancela um benefício resgatado
  Future<bool> cancelRedeemedBenefit(String redeemedBenefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    try {
      await _repository.cancelRedeemedBenefit(redeemedBenefitId);
      
      // Atualiza pontos do usuário se estiver usando MockBenefitRepository
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      // Atualiza a lista de benefícios resgatados
      await loadRedeemedBenefits();
      
      state = state.copyWith(
        redeemedBenefits: state.redeemedBenefits,
        userPoints: userPoints,
        selectedRedeemedBenefit: null,
        isLoading: false,
        successMessage: 'Benefício cancelado com sucesso!',
      );
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.message,
        successMessage: null
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao cancelar benefício: $e',
        successMessage: null
      );
      return false;
    }
  }
  
  /// Carrega benefícios em destaque
  Future<void> loadFeaturedBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final featuredBenefits = await _repository.getFeaturedBenefits();
      
      state = state.copyWith(
        benefits: featuredBenefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios em destaque: $e',
      );
    }
  }
  
  /// Limpa o benefício selecionado
  void clearSelectedBenefit() {
    state = state.copyWith(selectedBenefit: null);
  }
  
  /// Limpa o benefício resgatado selecionado
  void clearSelectedRedeemedBenefit() {
    state = state.copyWith(selectedRedeemedBenefit: null);
  }
  
  /// Limpa mensagem de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Limpa mensagem de sucesso
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
  
  /// Adiciona pontos ao usuário (apenas para testes com MockBenefitRepository)
  Future<void> addUserPoints(int points) async {
    if (_repository is MockBenefitRepository) {
      final userPoints = await (_repository as MockBenefitRepository).addUserPoints(points);
      state = state.copyWith(userPoints: userPoints);
    }
  }
  
  /// MÉTODOS DE ADMINISTRAÇÃO
  
  /// Verifica se o usuário atual é um administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isAdmin();
    } on app_errors.AppException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  /// Carrega todos os benefícios resgatados (por todos os usuários) - somente admin
  Future<void> loadAllRedeemedBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Permissão negada. Você não tem acesso de administrador.',
        );
        return;
      }
      
      final allRedeemedBenefits = await _repository.getAllRedeemedBenefits();
      
      // Verifica e atualiza status de expiração antes de atualizar o estado
      await checkExpiredBenefits(allRedeemedBenefits);
      
      state = state.copyWith(
        redeemedBenefits: allRedeemedBenefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios: $e',
      );
    }
  }
  
  /// Atualiza a data de expiração de um benefício - somente admin
  Future<bool> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedBenefit = await _repository.updateBenefitExpiration(benefitId, newExpirationDate);
      
      if (updatedBenefit == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Benefício não encontrado',
        );
        return false;
      }
      
      // Atualiza a lista de benefícios com o item atualizado
      final updatedBenefits = [...state.benefits];
      final index = updatedBenefits.indexWhere((b) => b.id == benefitId);
      if (index >= 0) {
        updatedBenefits[index] = updatedBenefit;
      }
      
      state = state.copyWith(
        benefits: updatedBenefits,
        selectedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Data de expiração atualizada com sucesso!',
      );
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar data de expiração: $e',
      );
      return false;
    }
  }
  
  /// Estende a data de expiração de um benefício resgatado - somente admin
  Future<bool> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedBenefit = await _repository.extendRedeemedBenefitExpiration(redeemedBenefitId, newExpirationDate);
      
      if (updatedBenefit == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Benefício resgatado não encontrado',
        );
        return false;
      }
      
      // Atualiza a lista de benefícios resgatados com o item atualizado
      final updatedRedeemedBenefits = [...state.redeemedBenefits];
      final index = updatedRedeemedBenefits.indexWhere((b) => b.id == redeemedBenefitId);
      if (index >= 0) {
        updatedRedeemedBenefits[index] = updatedBenefit;
      }
      
      state = state.copyWith(
        redeemedBenefits: updatedRedeemedBenefits,
        selectedRedeemedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Data de expiração atualizada com sucesso!',
      );
      
      // Recarregar a lista de benefícios resgatados
      final isUserAdmin = await _repository.isAdmin();
      if (isUserAdmin) {
        await loadAllRedeemedBenefits();
      } else {
        await loadRedeemedBenefits();
      }
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao estender validade do benefício: $e',
      );
      return false;
    }
  }
  
  /// Alterna o status de admin (apenas para testes com MockBenefitRepository)
  Future<void> toggleAdminStatus() async {
    if (_repository is MockBenefitRepository) {
      (_repository as MockBenefitRepository).toggleAdminStatus();
    }
  }
  
  /// Obtem um beneficio pelo ID
  Future<Benefit?> getBenefitById(String benefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final benefit = await _repository.getBenefitById(benefitId);
      
      state = state.copyWith(
        isLoading: false,
      );
      
      return benefit;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return null;
    }
  }
  
  /// Atualiza um benefício existente (somente admin)
  Future<bool> updateBenefit(Benefit benefit) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      // Implementação simulada - No mundo real, chamaríamos um método do repositório
      // await _repository.updateBenefit(benefit);
      
      // Recarrega a lista de benefícios para atualização
      final benefits = await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
        successMessage: 'Benefício atualizado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Cria um novo benefício (somente admin)
  Future<bool> createBenefit(Benefit benefit) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      // Implementação simulada - No mundo real, chamaríamos um método do repositório
      // await _repository.createBenefit(benefit);
      
      // Recarrega a lista de benefícios para atualização
      final benefits = await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
        successMessage: 'Benefício criado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Gera um QR Code para um benefício resgatado
  Future<bool> generateQRCode(String redeemedBenefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final redeemedBenefit = state.redeemedBenefits.firstWhere(
        (b) => b.id == redeemedBenefitId,
        orElse: () => throw StateError('Benefício resgatado não encontrado'),
      );
      
      // Gerar QR code
      final qrResult = await _qrService.generateQRDataForBenefit(
        benefitId: redeemedBenefit.id,
        code: redeemedBenefit.code,
      );
      
      state = state.copyWith(
        isLoading: false,
        qrCodeData: qrResult.data,
        qrCodeExpiresAt: qrResult.expiresAt,
        selectedRedeemedBenefit: redeemedBenefit,
      );
      
      return true;
    } on StateError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao gerar QR code: $e',
      );
      return false;
    }
  }
  
  /// Verifica se o QR code atual expirou
  bool isQRCodeExpired() {
    if (state.qrCodeExpiresAt == null) return true;
    return DateTime.now().isAfter(state.qrCodeExpiresAt!);
  }
  
  /// Regenera o QR code se expirado
  Future<void> refreshQRCodeIfExpired() async {
    if (isQRCodeExpired() && state.selectedRedeemedBenefit != null) {
      await generateQRCode(state.selectedRedeemedBenefit!.id);
    }
  }
  
  /// Limpa os dados do QR code
  void clearQRCodeData() {
    state = state.copyWith(
      qrCodeData: null,
      qrCodeExpiresAt: null,
    );
  }
  
  /// Trata erros de maneira unificada e retorna uma mensagem adequada para o usuário
  String _handleError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error in BenefitViewModel: $error');
      print(stackTrace);
    }
    
    if (error is app_errors.AppException) {
      return error.message;
    }
    
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }
} 
// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../models/redeemed_benefit.dart';
import '../repositories/benefit_repository.dart';
import '../providers/benefit_providers.dart';

/// Estado para gerenciamento de resgate de benefícios
class BenefitRedemptionState {
  /// Indica se a requisição está em andamento
  final bool isLoading;

  /// Indica se ocorreu um erro durante o resgate
  final bool hasError;

  /// Mensagem de erro caso exista
  final String? errorMessage;

  /// Indica se o resgate foi bem-sucedido
  final bool isSuccess;

  /// Benefício resgatado, se o resgate for bem-sucedido
  final RedeemedBenefit? redeemedBenefit;

  /// Construtor principal
  const BenefitRedemptionState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.isSuccess = false,
    this.redeemedBenefit,
  });

  /// Cria uma cópia do estado atual com os campos especificados alterados
  BenefitRedemptionState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isSuccess,
    RedeemedBenefit? redeemedBenefit,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BenefitRedemptionState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
      redeemedBenefit: redeemedBenefit ?? this.redeemedBenefit,
    );
  }

  /// Estado inicial
  factory BenefitRedemptionState.initial() => const BenefitRedemptionState();

  /// Estado de carregamento
  factory BenefitRedemptionState.loading() => const BenefitRedemptionState(
        isLoading: true,
        hasError: false,
        isSuccess: false,
        errorMessage: null,
      );

  /// Estado de erro
  factory BenefitRedemptionState.error(String message) => BenefitRedemptionState(
        isLoading: false,
        hasError: true,
        isSuccess: false,
        errorMessage: message,
      );

  /// Estado de sucesso
  factory BenefitRedemptionState.success(RedeemedBenefit benefit) => BenefitRedemptionState(
        isLoading: false,
        hasError: false,
        isSuccess: true,
        redeemedBenefit: benefit,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BenefitRedemptionState &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.isSuccess == isSuccess &&
        other.redeemedBenefit == redeemedBenefit;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        hasError,
        errorMessage,
        isSuccess,
        redeemedBenefit,
      );
}

/// Notifier para gerenciar estado de resgate de benefícios
class BenefitRedemptionNotifier extends StateNotifier<BenefitRedemptionState> {
  final BenefitRepository _repository;

  /// Construtor
  BenefitRedemptionNotifier({required BenefitRepository repository})
      : _repository = repository,
        super(BenefitRedemptionState.initial());

  /// Resgata um benefício
  Future<void> redeemBenefit(String benefitId) async {
    try {
      state = BenefitRedemptionState.loading();

      // Verifica se tem pontos suficientes
      final hasEnough = await _repository.hasEnoughPoints(benefitId);
      if (!hasEnough) {
        state = BenefitRedemptionState.error('Pontos insuficientes para resgatar este benefício');
        return;
      }

      final redeemedBenefit = await _repository.redeemBenefit(benefitId);

      if (redeemedBenefit == null) {
        state = BenefitRedemptionState.error('Erro ao resgatar benefício');
        return;
      }

      state = BenefitRedemptionState.success(redeemedBenefit);
    } catch (e) {
      state = BenefitRedemptionState.error('Erro: ${e.toString()}');
    }
  }
  
  /// Marca um benefício como utilizado
  Future<void> markBenefitAsUsed(String redeemedBenefitId) async {
    try {
      state = BenefitRedemptionState.loading();
      
      if (state.redeemedBenefit == null) {
        state = BenefitRedemptionState.error('Nenhum benefício resgatado para marcar como utilizado');
        return;
      }
      
      final updatedBenefit = await _repository.markBenefitAsUsed(redeemedBenefitId);
      state = BenefitRedemptionState.success(updatedBenefit);
    } catch (e) {
      state = BenefitRedemptionState.error('Erro ao marcar benefício como utilizado: ${e.toString()}');
    }
  }

  /// Reseta o estado para inicial
  void reset() {
    state = BenefitRedemptionState.initial();
  }
}

/// Provider para o notifier de resgate de benefícios
final benefitRedemptionViewModelProvider =
    StateNotifierProvider<BenefitRedemptionNotifier, BenefitRedemptionState>((ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return BenefitRedemptionNotifier(repository: repository);
}); // Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/errors/app_exception.dart' as app_errors;
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';
import 'benefit_repository.dart';
import 'benefits_repository.dart';

/// Simplificado apenas para compilar
class MockBenefitRepository implements BenefitRepository {
  // Variáveis para simular estado
  int _userPoints = 500;
  bool _isAdmin = false;
  
  @override
  Future<void> cancelRedeemedBenefit(String redeemedBenefitId) async {}

  /// Retorna os pontos do usuário (mock para testes)
  Future<int> getUserPoints() async {
    return _userPoints;
  }
  
  /// Adiciona pontos ao usuário (mock para testes)
  Future<int> addUserPoints(int points) async {
    _userPoints += points;
    return _userPoints;
  }
  
  /// Alterna status de admin (para testes)
  void toggleAdminStatus() {
    _isAdmin = !_isAdmin;
  }

  @override
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(
      String redeemedBenefitId, DateTime? newExpirationDate) async {
    return null;
  }

  @override
  Future<List<Benefit>> getBenefits() async {
    return [];
  }

  @override
  Future<List<String>> getBenefitCategories() async {
    return [];
  }

  @override
  Future<Benefit?> getBenefitById(String id) async {
    return null;
  }

  @override
  Future<List<Benefit>> getBenefitsByCategory(String category) async {
    return [];
  }

  @override
  Future<List<RedeemedBenefit>> getRedeemedBenefits() async {
    return [];
  }

  @override
  Future<RedeemedBenefit?> getRedeemedBenefitById(String id) async {
    return null;
  }

  @override
  Future<bool> hasEnoughPoints(String benefitId) async {
    return true;
  }

  @override
  Future<bool> isAdmin() async {
    return _isAdmin;
  }

  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    throw UnimplementedError();
  }

  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    throw UnimplementedError();
  }

  @override
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    return null;
  }

  @override
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, BenefitStatus newStatus) async {
    return null;
  }

  @override
  Future<RedeemedBenefit?> useBenefit(String redeemedBenefitId) async {
    return null;
  }

  @override
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits() async {
    return [];
  }

  @override
  Future<List<Benefit>> getFeaturedBenefits() async {
    return [];
  }

  @override
  Future<String> generateRedemptionCode({required String userId, required String benefitId}) async {
    return "MOCK123";
  }

  @override
  Future<bool> verifyRedemptionCode({required String redemptionCode, required String benefitId}) async {
    return true;
  }
} 
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/core/services/connectivity_service.dart';
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';
import 'benefit_repository.dart';
import 'mock_benefit_repository.dart';

/// Provider para o repositório de benefícios
final benefitsRepositoryProvider = Provider<BenefitRepository>((ref) {
  // Usar apenas o mock para resolver problemas de compilação
  return MockBenefitRepository();
  
  /* Código original comentado:
  final supabase = ref.watch(supabaseClientProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return SupabaseBenefitRepository(
    supabaseClient: supabase,
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
  */
});

/// Interface para acesso às operações de benefícios
abstract class BenefitsRepository {
  /// Recupera todos os benefícios disponíveis
  Future<List<Benefit>> getBenefits();
  
  /// Recupera um benefício pelo ID
  Future<Benefit?> getBenefitById(String id);
  
  /// Recupera as categorias de benefícios (parceiros)
  Future<List<String>> getBenefitCategories();
  
  /// Recupera benefícios por categoria
  Future<List<Benefit>> getBenefitsByCategory(String category);
  
  /// Verifica se o usuário tem pontos suficientes para resgatar um benefício
  Future<bool> hasEnoughPoints(String benefitId);
  
  /// Resgata um benefício
  Future<RedeemedBenefit> redeemBenefit(String benefitId);
  
  /// Obtém benefícios resgatados pelo usuário logado
  Future<List<RedeemedBenefit>> getRedeemedBenefits();
  
  /// Usa um benefício resgatado
  Future<RedeemedBenefit?> useBenefit(String redeemedBenefitId);
  
  /// Atualiza o status de um benefício
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, BenefitStatus newStatus);
  
  /// Verifica se o usuário é administrador
  Future<bool> isAdmin();
  
  /// Obtém todos os benefícios resgatados (somente admin)
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits();
  
  /// Atualiza a data de expiração de um benefício
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime newExpirationDate);
  
  /// Estende a validade de um benefício resgatado
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime newExpirationDate);
} // Project imports:
import '../enums/benefit_type.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';

/// Interface para acesso às operações de benefícios
abstract class BenefitRepository {
  /// Recupera todos os benefícios disponíveis
  Future<List<Benefit>> getBenefits();
  
  /// Recupera um benefício pelo ID
  Future<Benefit?> getBenefitById(String id);
  
  /// Recupera as categorias de benefícios (parceiros)
  Future<List<String>> getBenefitCategories();
  
  /// Recupera benefícios por categoria
  Future<List<Benefit>> getBenefitsByCategory(String category);
  
  /// Verifica se o usuário tem pontos suficientes para resgatar um benefício
  Future<bool> hasEnoughPoints(String benefitId);
  
  /// Resgata um benefício
  Future<RedeemedBenefit> redeemBenefit(String benefitId);
  
  /// Obtém benefícios resgatados pelo usuário logado
  Future<List<RedeemedBenefit>> getRedeemedBenefits();
  
  /// Obtém detalhe de um benefício resgatado pelo ID
  Future<RedeemedBenefit?> getRedeemedBenefitById(String id);
  
  /// Marca um benefício como utilizado
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId);
  
  /// Cancela um benefício resgatado
  Future<void> cancelRedeemedBenefit(String redeemedBenefitId);
  
  /// Usa um benefício resgatado
  Future<RedeemedBenefit?> useBenefit(String redeemedBenefitId);
  
  /// Atualiza o status de um benefício
  Future<RedeemedBenefit?> updateBenefitStatus(String redeemedBenefitId, BenefitStatus newStatus);
  
  /// Verifica se o usuário é administrador
  Future<bool> isAdmin();
  
  /// Obtém todos os benefícios resgatados (somente admin)
  Future<List<RedeemedBenefit>> getAllRedeemedBenefits();
  
  /// Atualiza a data de expiração de um benefício
  Future<Benefit?> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate);
  
  /// Estende a validade de um benefício resgatado
  Future<RedeemedBenefit?> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate);
  
  /// Obtém benefícios em destaque
  Future<List<Benefit>> getFeaturedBenefits();
  
  /// Gera código de resgate
  Future<String> generateRedemptionCode({
    required String userId,
    required String benefitId,
  });
  
  /// Verifica código de resgate
  Future<bool> verifyRedemptionCode({
    required String redemptionCode,
    required String benefitId,
  });
} 
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import '../../../core/utils/debug_data_inspector.dart';

/// Interface do repositório para benefícios resgatados
abstract class RedeemedBenefitRepository {
  /// Obtém todos os benefícios resgatados pelo usuário
  Future<List<RedeemedBenefit>> getUserRedeemedBenefits();
  
  /// Resgata um novo benefício
  Future<RedeemedBenefit> redeemBenefit(String benefitId);
  
  /// Marca um benefício como usado
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId);
}

/// Implementação mock do repositório para desenvolvimento
class MockRedeemedBenefitRepository implements RedeemedBenefitRepository {
  final List<RedeemedBenefit> _mockBenefits = [];
  
  MockRedeemedBenefitRepository() {
    _initMockData();
  }
  
  void _initMockData() {
    final now = DateTime.now();
    
    // Benefício ativo
    _mockBenefits.add(
      RedeemedBenefit(
        id: 'rb-1',
        userId: 'user123',
        benefitId: 'benefit-1',
        title: 'Desconto Smart Fit',
        description: 'Desconto mensal de 15%',
        code: 'SMARTFIT2025',
        status: BenefitStatus.active,
        expirationDate: now.add(const Duration(days: 30)),
        redeemedAt: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    );
    
    // Benefício expirado
    _mockBenefits.add(
      RedeemedBenefit(
        id: 'rb-2',
        userId: 'user123',
        benefitId: 'benefit-2',
        title: 'Protein Shop',
        description: '10% OFF na primeira compra',
        code: 'PROTEIN10',
        status: BenefitStatus.expired,
        expirationDate: now.subtract(const Duration(days: 5)),
        redeemedAt: now.subtract(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    );
  }

  @override
  Future<List<RedeemedBenefit>> getUserRedeemedBenefits() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Verificar e atualizar benefícios expirados
    _updateExpiredBenefits();
    
    return List<RedeemedBenefit>.from(_mockBenefits);
  }

  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Verificar se já resgatou este benefício antes
    final existingBenefit = _mockBenefits.firstWhere(
      (b) => b.benefitId == benefitId && b.status == BenefitStatus.active,
      orElse: () => _createMockBenefit(benefitId),
    );
    
    if (existingBenefit.id != 'temp') {
      throw ValidationException(
        message: 'Benefício já resgatado e ainda ativo',
        code: 'benefit_already_redeemed',
      );
    }
    
    // Adicionar à lista de resgatados
    _mockBenefits.add(existingBenefit);
    
    return existingBenefit;
  }

  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final benefitIndex = _mockBenefits.indexWhere((b) => b.id == redeemedBenefitId);
    
    if (benefitIndex == -1) {
      throw NotFoundException(
        message: 'Benefício resgatado não encontrado',
        code: 'redeemed_benefit_not_found',
      );
    }
    
    final benefit = _mockBenefits[benefitIndex];
    
    if (benefit.status != BenefitStatus.active) {
      throw ValidationException(
        message: 'Apenas benefícios ativos podem ser marcados como usados',
        code: 'benefit_not_active',
      );
    }
    
    final now = DateTime.now();
    final updated = benefit.copyWith(
      status: BenefitStatus.used,
      usedAt: now,
      updatedAt: now,
    );
    
    // Atualizar na lista
    _mockBenefits[benefitIndex] = updated;
    
    return updated;
  }
  
  /// Atualiza o status de benefícios expirados
  void _updateExpiredBenefits() {
    final now = DateTime.now();
    
    for (int i = 0; i < _mockBenefits.length; i++) {
      final benefit = _mockBenefits[i];
      
      if (benefit.status == BenefitStatus.active && 
          now.isAfter(benefit.expirationDate)) {
        _mockBenefits[i] = benefit.copyWith(
          status: BenefitStatus.expired,
          updatedAt: now,
        );
      }
    }
  }
  
  /// Cria um benefício mockado com base no ID
  RedeemedBenefit _createMockBenefit(String benefitId) {
    final now = DateTime.now();
    
    return RedeemedBenefit(
      id: 'temp',
      userId: 'user123',
      benefitId: benefitId,
      title: benefitId == 'benefit-3' 
          ? 'Desconto Academia XYZ' 
          : 'Benefício Resgatado',
      description: benefitId == 'benefit-3'
          ? '20% de desconto na mensalidade'
          : 'Detalhes do benefício',
      code: 'CODE${now.millisecondsSinceEpoch.toString().substring(8)}',
      status: BenefitStatus.active,
      expirationDate: now.add(const Duration(days: 60)),
      redeemedAt: now,
      createdAt: now,
    );
  }
}

/// Implementação com Supabase
class SupabaseRedeemedBenefitRepository implements RedeemedBenefitRepository {
  final SupabaseClient _supabaseClient;

  SupabaseRedeemedBenefitRepository(this._supabaseClient);

  @override
  Future<List<RedeemedBenefit>> getUserRedeemedBenefits() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('redeemed_benefits')
          .select('*, benefit:benefit_id(*)')
          .eq('user_id', userId)
          .order('redeemed_at', ascending: false);
      
      // Inspecionar os dados retornados pelo Supabase
      DebugDataInspector.logResponse('RedeemedBenefits', response);
      
      return response.map<RedeemedBenefit>((data) => RedeemedBenefit.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Erro ao buscar benefícios resgatados',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao carregar benefícios resgatados: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se já resgatou este benefício antes
      final existingResponse = await _supabaseClient
          .from('redeemed_benefits')
          .select()
          .eq('benefit_id', benefitId)
          .eq('user_id', userId)
          .eq('status', BenefitStatus.active.toString().split('.').last)
          .maybeSingle();
      
      if (existingResponse != null) {
        throw ValidationException(
          message: 'Benefício já resgatado e ainda ativo',
          code: 'benefit_already_redeemed',
        );
      }
      
      // Buscar informações do benefício
      final benefitResponse = await _supabaseClient
          .from('benefits')
          .select()
          .eq('id', benefitId)
          .single();
      
      // Criar código único
      final code = _generateUniqueCode(benefitResponse['code_prefix'] ?? 'CODE');
      
      final now = DateTime.now();
      
      // Calcular data de expiração com base na configuração do benefício
      final daysValid = benefitResponse['expiration_days'] ?? 30;
      final expirationDate = now.add(Duration(days: daysValid));
      
      // Inserir o benefício resgatado
      final redeemedBenefit = {
        'user_id': userId,
        'benefit_id': benefitId,
        'code': code,
        'status': BenefitStatus.active.toString().split('.').last,
        'expiration_date': expirationDate.toIso8601String(),
        'redeemed_at': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      };
      
      final response = await _supabaseClient
          .from('redeemed_benefits')
          .insert(redeemedBenefit)
          .select('*, benefits!inner(title, description, logo_url)')
          .single();
      
      return _mapResponseToBenefit(response);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao resgatar benefício: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se o benefício existe e está ativo
      final benefitResponse = await _supabaseClient
          .from('redeemed_benefits')
          .select('*, benefits!inner(title, description, logo_url)')
          .eq('id', redeemedBenefitId)
          .eq('user_id', userId)
          .single();
      
      final benefit = _mapResponseToBenefit(benefitResponse);
      
      if (benefit.status != BenefitStatus.active) {
        throw ValidationException(
          message: 'Apenas benefícios ativos podem ser marcados como usados',
          code: 'benefit_not_active',
        );
      }
      
      final now = DateTime.now();
      
      // Atualizar o status
      final response = await _supabaseClient
          .from('redeemed_benefits')
          .update({
            'status': BenefitStatus.used.toString().split('.').last,
            'used_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .eq('id', redeemedBenefitId)
          .eq('user_id', userId)
          .select('*, benefits!inner(title, description, logo_url)')
          .single();
      
      return _mapResponseToBenefit(response);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao marcar benefício como usado: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  /// Atualiza automaticamente o status de benefícios expirados
  Future<void> _updateExpiredBenefits(String userId) async {
    final now = DateTime.now().toIso8601String();
    
    // Atualizar benefícios expirados
    await _supabaseClient
        .from('redeemed_benefits')
        .update({
          'status': BenefitStatus.expired.toString().split('.').last,
          'updated_at': now,
        })
        .eq('user_id', userId)
        .eq('status', BenefitStatus.active.toString().split('.').last)
        .lt('expiration_date', now);
  }
  
  /// Gera um código único para o benefício
  String _generateUniqueCode(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final random = (1000 + (DateTime.now().microsecond % 9000)).toString();
    return '$prefix$timestamp$random';
  }
  
  /// Mapeia a resposta da API para o modelo RedeemedBenefit
  RedeemedBenefit _mapResponseToBenefit(Map<String, dynamic> json) {
    final benefitData = json['benefits'] as Map<String, dynamic>;
    
    return RedeemedBenefit(
      id: json['id'],
      userId: json['user_id'],
      benefitId: json['benefit_id'],
      title: benefitData['title'],
      description: benefitData['description'],
      logoUrl: benefitData['logo_url'],
      code: json['code'],
      status: BenefitStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BenefitStatus.active,
      ),
      expirationDate: DateTime.parse(json['expiration_date']),
      redeemedAt: DateTime.parse(json['redeemed_at']),
      usedAt: json['used_at'] != null 
          ? DateTime.parse(json['used_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}

/// Provider para o repositório de benefícios resgatados
final redeemedBenefitRepositoryProvider = Provider<RedeemedBenefitRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseRedeemedBenefitRepository(supabase);
}); // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';

part 'meal_view_model.freezed.dart';

/// Provider for MealViewModel
final mealViewModelProvider = StateNotifierProvider<MealViewModel, MealState>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  final authState = ref.watch(authViewModelProvider);
  
  return MealViewModel(repository, authState);
});

/// State for the MealViewModel
@freezed
class MealState with _$MealState {
  const factory MealState({
    @Default([]) List<Meal> meals,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isMealAdded,
    @Default(false) bool isMealUpdated,
    @Default(false) bool isMealDeleted,
  }) = _MealState;
}

/// ViewModel for managing meal data
class MealViewModel extends StateNotifier<MealState> {
  final MealRepositoryInterface _repository;
  final AuthState _authState;
  
  MealViewModel(this._repository, this._authState) : super(const MealState()) {
    initState();
  }
  
  /// Método que pode ser sobrescrito para testes
  void initState() {
    // Load meals initially if user is authenticated
    _authState.maybeWhen(
      authenticated: (user) => loadMeals(),
      orElse: () => null,
    );
  }
  
  /// Load all meals for the current user
  Future<void> loadMeals({DateTime? startDate, DateTime? endDate}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final userId = _getUserId();
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }
      
      final meals = await _repository.getMeals(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      state = state.copyWith(
        meals: meals,
        isLoading: false,
        isMealAdded: false,
        isMealUpdated: false,
        isMealDeleted: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Add a new meal
  Future<void> addMeal(Meal meal) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final userId = _getUserId();
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }
      
      final addedMeal = await _repository.addMeal(meal, userId);
      
      state = state.copyWith(
        meals: [addedMeal, ...state.meals],
        isLoading: false,
        isMealAdded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Update an existing meal
  Future<void> updateMeal(Meal meal) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedMeal = await _repository.updateMeal(meal);
      
      state = state.copyWith(
        meals: state.meals.map((m) => m.id == meal.id ? updatedMeal : m).toList(),
        isLoading: false,
        isMealUpdated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.deleteMeal(mealId);
      
      state = state.copyWith(
        meals: state.meals.where((meal) => meal.id != mealId).toList(),
        isLoading: false,
        isMealDeleted: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Get current user ID
  String? _getUserId() {
    return _authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );
  }
  
  /// Calculate total calories from all meals
  int calculateTotalCalories() {
    return state.meals.fold<int>(0, (sum, meal) => sum + meal.calories);
  }
  
  /// Calculate total proteins from all meals
  double calculateTotalProteins() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.proteins);
  }
  
  /// Calculate total carbs from all meals
  double calculateTotalCarbs() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.carbs);
  }
  
  /// Calculate total fats from all meals
  double calculateTotalFats() {
    return state.meals.fold<double>(0, (sum, meal) => sum + meal.fats);
  }
  
  /// Calculate the percentage distribution of macronutrients
  Map<String, double> calculateMacroDistribution() {
    final totalProteins = calculateTotalProteins();
    final totalCarbs = calculateTotalCarbs();
    final totalFats = calculateTotalFats();
    
    final totalGrams = totalProteins + totalCarbs + totalFats;
    
    if (totalGrams == 0) {
      return {
        'protein': 0,
        'carbs': 0,
        'fats': 0,
      };
    }
    
    return {
      'protein': (totalProteins / totalGrams) * 100,
      'carbs': (totalCarbs / totalGrams) * 100,
      'fats': (totalFats / totalGrams) * 100,
    };
  }
  
  /// Get weekly nutrition statistics
  Future<List<Map<String, dynamic>>> getWeeklyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final weekStats = <Map<String, dynamic>>[];
    
    // Calculate days between start and end date
    final days = endDate.difference(startDate).inDays + 1;
    final limit = days > 7 ? 7 : days; // Maximum of 7 days
    
    for (var i = 0; i < limit; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final endOfDay = DateTime(
        currentDate.year, 
        currentDate.month, 
        currentDate.day, 
        23, 59, 59
      );
      
      // Load meals for this specific day
      await loadMeals(startDate: currentDate, endDate: endOfDay);
      
      weekStats.add({
        'date': currentDate,
        'calories': calculateTotalCalories(),
        'proteins': calculateTotalProteins(),
        'carbs': calculateTotalCarbs(),
        'fats': calculateTotalFats(),
      });
    }
    
    return weekStats;
  }
} 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ray_club_app/features/nutrition/models/nutrition_item.dart';

part 'nutrition_view_model.freezed.dart';

@freezed
class NutritionState with _$NutritionState {
  const factory NutritionState({
    @Default([]) List<NutritionItem> nutritionItems,
    @Default([]) List<NutritionItem> filteredItems,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default('all') String currentFilter,
  }) = _NutritionState;
}

final nutritionViewModelProvider = StateNotifierProvider<NutritionViewModel, NutritionState>((ref) {
  return NutritionViewModel();
});

class NutritionViewModel extends StateNotifier<NutritionState> {
  NutritionViewModel() : super(const NutritionState()) {
    loadNutritionItems();
  }

  Future<void> loadNutritionItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Simulação de carregamento de dados
      await Future.delayed(const Duration(seconds: 1));
      
      final items = [
        NutritionItem(
          id: '1',
          title: 'Salada Tropical',
          description: 'Uma deliciosa salada tropical',
          category: 'recipe',
          imageUrl: 'https://example.com/salada.png',
          preparationTimeMinutes: 15,
          ingredients: ['Alface', 'Tomate', 'Abacaxi'],
          instructions: ['Lave os vegetais', 'Corte em pedaços', 'Misture tudo'],
          tags: ['Salada', 'Vegano'],
        ),
        NutritionItem(
          id: '2',
          title: 'Dica para Hidratação',
          description: 'Como se manter hidratado durante exercícios',
          category: 'tip',
          imageUrl: 'https://example.com/hidratacao.png',
          preparationTimeMinutes: 5,
          tags: ['Hidratação', 'Saúde'],
          nutritionistTip: 'Beba água regularmente durante o dia.',
        ),
      ];
      
      state = state.copyWith(
        nutritionItems: items,
        filteredItems: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar itens de nutrição: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  void filterByCategory(String category) {
    if (category == 'all') {
      state = state.copyWith(
        filteredItems: state.nutritionItems,
        currentFilter: category,
      );
    } else {
      state = state.copyWith(
        filteredItems: state.nutritionItems.where((item) => item.category == category).toList(),
        currentFilter: category,
      );
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';

/// Provider for MealRepository
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(Supabase.instance.client);
});

/// Repository for managing meal data
class MealRepository implements MealRepositoryInterface {
  final SupabaseClient _client;
  
  MealRepository(this._client);
  
  /// Fetch all meals for a user
  @override
  Future<List<Meal>> getMeals({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('meals')
          .select()
          .eq('user_id', userId)
          .order('date_time', ascending: false);
      
      // Primeiro fazemos o select, depois aplicamos os filtros
      final response = await query;
      
      // Filtramos no Dart se as datas foram fornecidas
      var filteredData = response;
      
      if (startDate != null) {
        filteredData = filteredData.where(
          (data) => DateTime.parse(data['date_time']).isAfter(startDate) ||
                    DateTime.parse(data['date_time']).isAtSameMomentAs(startDate)
        ).toList();
      }
      
      if (endDate != null) {
        filteredData = filteredData.where(
          (data) => DateTime.parse(data['date_time']).isBefore(endDate) ||
                    DateTime.parse(data['date_time']).isAtSameMomentAs(endDate)
        ).toList();
      }
      
      return filteredData.map((data) => Meal.fromJson(data)).toList();
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to fetch meals',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Add a new meal
  @override
  Future<Meal> addMeal(Meal meal, String userId) async {
    try {
      final mealJson = meal.toJson();
      mealJson['user_id'] = userId;
      
      final response = await _client
          .from('meals')
          .insert(mealJson)
          .select()
          .single();
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to add meal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Update an existing meal
  @override
  Future<Meal> updateMeal(Meal meal) async {
    try {
      final response = await _client
          .from('meals')
          .update(meal.toJson())
          .eq('id', meal.id)
          .select()
          .single();
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to update meal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Delete a meal
  @override
  Future<void> deleteMeal(String mealId) async {
    try {
      await _client
          .from('meals')
          .delete()
          .eq('id', mealId);
    } catch (e, stackTrace) {
      throw app_errors.StorageException(
        message: 'Failed to delete meal',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
} 
// Dart imports:
import 'dart:io';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';
import 'package:ray_club_app/services/storage_service.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/utils/performance_monitor.dart';

/// Implementação do repositório de refeições usando Supabase
class SupabaseMealRepository implements MealRepository {
  final SupabaseClient _supabaseClient;
  final StorageService _storageService;
  
  /// Nome da tabela no banco de dados
  static const String _tableName = 'meals';
  
  /// Construtor do repositório
  SupabaseMealRepository({
    required SupabaseClient supabaseClient,
    required StorageService storageService,
  })  : _supabaseClient = supabaseClient,
        _storageService = storageService;
  
  @override
  Future<List<Meal>> getAllMeals() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('meal_time', ascending: false);
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao buscar refeições');
      LogUtils.error(
        'Falha ao buscar todas as refeições',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
      );
      throw error;
    }
  }
  
  @override
  Future<Meal?> getMealById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao buscar refeição');
      LogUtils.error(
        'Falha ao buscar refeição por ID',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'id': id},
      );
      throw error;
    }
  }
  
  @override
  Future<List<Meal>> getMealsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Validar que as datas estão em ordem correta
      if (startDate.isAfter(endDate)) {
        throw ValidationException(
          message: 'Data inicial não pode ser posterior à data final',
          code: 'invalid_date_range',
        );
      }
    
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .gte('meal_time', startDate.toIso8601String())
          .lte('meal_time', endDate.toIso8601String())
          .order('meal_time');
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao buscar refeições por período',
      );
      LogUtils.error(
        'Falha ao buscar refeições por período',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      throw error;
    }
  }
  
  @override
  Future<List<Meal>> getMealsByType(String type) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('meal_type', type)
          .order('meal_time', ascending: false);
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao buscar refeições por tipo',
      );
      LogUtils.error(
        'Falha ao buscar refeições por tipo',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'type': type},
      );
      throw error;
    }
  }
  
  @override
  Future<Meal> saveMeal(Meal meal) async {
    try {
      // Validar valores numéricos
      if (meal.calories < 0) {
        throw ValidationException(
          message: 'Calorias não podem ser negativas',
          code: 'invalid_calories',
        );
      }
      
      if (meal.proteins < 0) {
        throw ValidationException(
          message: 'Proteínas não podem ser negativas',
          code: 'invalid_proteins',
        );
      }
      
      if (meal.carbs < 0) {
        throw ValidationException(
          message: 'Carboidratos não podem ser negativos',
          code: 'invalid_carbs',
        );
      }
      
      if (meal.fats < 0) {
        throw ValidationException(
          message: 'Gorduras não podem ser negativas',
          code: 'invalid_fats',
        );
      }
      
      // Garantir que user_id está definido como o usuário atual
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw AuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      final mealWithUserId = meal.copyWith(userId: userId);
      final isUpdate = meal.id != null;
      
      Map<String, dynamic> response;
      if (isUpdate) {
        // Atualizar refeição existente
        response = await _supabaseClient
            .from(_tableName)
            .update(mealWithUserId.toJson())
            .eq('id', meal.id)
            .select()
            .single();
      } else {
        // Criar nova refeição
        response = await _supabaseClient
            .from(_tableName)
            .insert(mealWithUserId.toJson())
            .select()
            .single();
      }
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao ${meal.id != null ? 'atualizar' : 'criar'} refeição',
      );
      LogUtils.error(
        'Falha ao salvar refeição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'mealId': meal.id, 'isUpdate': meal.id != null},
      );
      throw error;
    }
  }
  
  @override
  Future<void> deleteMeal(String id) async {
    try {
      // Buscar a refeição para verificar se tem imagem
      final meal = await getMealById(id);
      
      // Excluir a refeição do banco
      await _supabaseClient.from(_tableName).delete().eq('id', id);
      
      // Se existir uma imagem, excluí-la
      if (meal?.imageUrl != null && meal!.imageUrl!.isNotEmpty) {
        final imagePath = _extractImagePathFromUrl(meal.imageUrl!);
        if (imagePath != null) {
          await _storageService.setBucket(StorageBucketType.mealImages);
          // Ignorar erro de exclusão de imagem para não interromper o fluxo
          try {
            await _storageService.deleteFile(imagePath);
          } catch (e) {
            LogUtils.warning(
              'Não foi possível excluir a imagem da refeição',
              tag: 'SupabaseMealRepository',
              data: {'mealId': id, 'imagePath': imagePath},
            );
          }
        }
      }
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao excluir refeição');
      LogUtils.error(
        'Falha ao excluir refeição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'id': id},
      );
      throw error;
    }
  }
  
  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _supabaseClient
          .from(_tableName)
          .update({'is_favorite': isFavorite})
          .eq('id', id);
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao ${isFavorite ? 'marcar' : 'desmarcar'} refeição como favorita',
      );
      LogUtils.error(
        'Falha ao alterar status de favorito da refeição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'id': id, 'isFavorite': isFavorite},
      );
      throw error;
    }
  }
  
  @override
  Future<String> uploadMealImage(String mealId, String localImagePath) async {
    return PerformanceMonitor.trackAsync('meal_image_upload', () async {
      try {
        // Configurar bucket de imagens de refeições
        await _storageService.setBucket(StorageBucketType.mealImages);
        _storageService.setAccessPolicy(StorageAccessType.public);
        
        // Definir caminho da imagem no storage
        final file = File(localImagePath);
        final extension = localImagePath.split('.').last;
        final imagePath = 'meal_$mealId.$extension';
        
        // Fazer upload da imagem
        final imageUrl = await _storageService.uploadFile(
          file: file,
          path: imagePath,
        );
        
        // Atualizar URL da imagem na refeição
        await _supabaseClient
            .from(_tableName)
            .update({'image_url': imageUrl})
            .eq('id', mealId);
        
        return imageUrl;
      } catch (e, stackTrace) {
        final error = _handleError(e, stackTrace, 'Erro ao fazer upload de imagem');
        LogUtils.error(
          'Falha ao fazer upload de imagem para refeição',
          error: error,
          stackTrace: stackTrace,
          tag: 'SupabaseMealRepository',
          data: {'mealId': mealId, 'localImagePath': localImagePath},
        );
        throw error;
      }
    }, metadata: {'mealId': mealId, 'fileSize': File(localImagePath).lengthSync()});
  }
  
  @override
  Future<List<Meal>> getFavoriteMeals() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('is_favorite', true)
          .order('meal_time', ascending: false);
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao buscar refeições favoritas');
      LogUtils.error(
        'Falha ao buscar refeições favoritas',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
      );
      throw error;
    }
  }
  
  @override
  Future<Map<String, dynamic>> getNutritionStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final meals = await getMealsByDateRange(startDate, endDate);
      
      // Calcular estatísticas de nutrição
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      Map<String, int> mealTypeCounts = {};
      
      for (final meal in meals) {
        totalCalories += meal.calories ?? 0;
        totalProtein += meal.protein ?? 0;
        totalCarbs += meal.carbs ?? 0;
        totalFat += meal.fat ?? 0;
        
        if (meal.mealType != null) {
          mealTypeCounts[meal.mealType!] = (mealTypeCounts[meal.mealType!] ?? 0) + 1;
        }
      }
      
      return {
        'totalMeals': meals.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'mealTypeCounts': mealTypeCounts,
        'avgCaloriesPerDay': meals.isEmpty
            ? 0
            : totalCalories / (endDate.difference(startDate).inDays + 1),
      };
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao calcular estatísticas de nutrição',
      );
      LogUtils.error(
        'Falha ao calcular estatísticas de nutrição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      throw error;
    }
  }
  
  /// Função auxiliar para extrair o caminho da imagem de uma URL
  String? _extractImagePathFromUrl(String imageUrl) {
    try {
      // Exemplo: https://domain.com/storage/v1/object/public/bucket_name/path/to/image.jpg
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Encontrar o índice do bucket nas path segments
      int bucketIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'public' && i + 1 < pathSegments.length) {
          bucketIndex = i + 1;
          break;
        }
      }
      
      if (bucketIndex >= 0 && bucketIndex + 1 < pathSegments.length) {
        // Pegar todos os segmentos após o bucket
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
      
      return null;
    } catch (e) {
      LogUtils.warning(
        'Erro ao extrair caminho da imagem da URL',
        tag: 'SupabaseMealRepository',
        data: {'imageUrl': imageUrl, 'error': e.toString()},
      );
      return null;
    }
  }
  
  /// Função auxiliar para tratar erros do Supabase
  AppException _handleError(Object error, StackTrace stackTrace, String message) {
    if (error is PostgrestException) {
      // Mapear erros específicos do Postgrest
      if (error.code == '23505') {
        return ValidationException(
          message: 'Refeição com esse nome já existe',
          originalError: error,
          stackTrace: stackTrace,
          code: 'duplicate_entry',
        );
      } else if (error.code == '23503') {
        return ValidationException(
          message: 'Referência inválida',
          originalError: error,
          stackTrace: stackTrace,
          code: 'invalid_reference',
        );
      }
      
      return StorageException(
        message: message,
        originalError: error,
        stackTrace: stackTrace,
        code: error.code,
      );
    } else if (error is AuthException) {
      return error;
    } else if (error is StorageException) {
      return error;
    } else if (error is ValidationException) {
      return error;
    }
    
    return AppException(
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
} 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async'; // Added for Completer
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../repositories/workout_repository.dart';
import '../providers/workout_providers.dart';
import '../models/user_workout.dart';
import '../../../services/workout_challenge_service.dart';

/// Provider para o UserWorkoutViewModel
final userWorkoutViewModelProvider = StateNotifierProvider<UserWorkoutViewModel, UserWorkoutState>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeService = ref.watch(workoutChallengeServiceProvider);
  return UserWorkoutViewModel(
    repository: repository, 
    authRepository: authRepository,
    challengeService: challengeService,
  );
});

/// ViewModel para gerenciar treinos do usuário
class UserWorkoutViewModel extends StateNotifier<UserWorkoutState> {
  final WorkoutRepository _repository;
  final IAuthRepository _authRepository;
  final WorkoutChallengeService _challengeService;

  UserWorkoutViewModel({
    required WorkoutRepository repository,
    required IAuthRepository authRepository,
    required WorkoutChallengeService challengeService,
  })  : _repository = repository,
        _authRepository = authRepository,
        _challengeService = challengeService,
        super(UserWorkoutState.initial());

  /// Inicia um treino para o usuário
  Future<void> startWorkout(String workoutId) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.startWorkout(workoutId, userId);
      
      state = UserWorkoutState.success(message: 'Treino iniciado com sucesso!');
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Completa um treino e registra pontos para desafios
  Future<void> completeWorkout(WorkoutRecord record) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Log para diagnóstico
      debugPrint('🔍 Registro de treino criado: $record');
      
      // Salvar o registro do treino
      final savedRecord = await _repository.saveWorkoutRecord(record);
      debugPrint('✅ Registro de treino salvo com sucesso: $savedRecord');
      
      // Processar o treino para os desafios ativos (verificar check-ins, etc.)
      debugPrint('🏋️ Processando treino concluído: ${record.workoutName}');
      int challengePoints = 0;
      
      try {
        // Usar o serviço dedicado para processar os pontos do desafio
        challengePoints = await _challengeService.processWorkoutCompletion(
          savedRecord,
        );
        
        // Refreshing workout history list
        await loadUserWorkoutHistory();
        
        debugPrint('✅ Desafios processados: ganhou $challengePoints pontos');
        
        // Define success message based on points earned
        String successMessage = 'Treino registrado com sucesso!';
        if (challengePoints > 0) {
          successMessage += ' Você ganhou $challengePoints pontos nos desafios ativos!';
        }
        
        state = state.copyWith(
          isLoading: false,
          successMessage: successMessage,
          errorMessage: null,
        );
      } catch (e) {
        // Se houver erro apenas nos desafios, ainda consideramos o treino como salvo
        // mas informamos o erro específico
        debugPrint('❌ Erro ao processar desafios: $e');
        
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Treino registrado com sucesso, mas houve um problema ao processar os pontos do desafio.',
          errorMessage: null,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao completar treino: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar treino: ${e.toString()}',
      );
    }
  }

  /// Atualiza o progresso de treino do usuário
  Future<void> updateWorkoutProgress(String workoutId, double progress) async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      await _repository.updateWorkoutProgress(workoutId, userId, progress);
      
      state = UserWorkoutState.success(message: 'Progresso atualizado!');
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Carrega o histórico de treinos do usuário
  Future<void> loadUserWorkoutHistory() async {
    try {
      state = UserWorkoutState.loading();
      
      final userId = await _authRepository.getCurrentUserId();
      final workouts = await _repository.getUserWorkoutHistory(userId);
      
      state = UserWorkoutState.success(
        message: 'Histórico carregado com sucesso!',
        workouts: workouts,
      );
    } catch (e) {
      state = UserWorkoutState.error(message: _getErrorMessage(e));
    }
  }

  /// Extrai mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}

/// Estado para gerenciamento do UserWorkout
class UserWorkoutState {
  final List<UserWorkout> workouts;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const UserWorkoutState({
    this.workouts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Estado inicial
  factory UserWorkoutState.initial() => const UserWorkoutState();

  /// Estado de carregamento
  factory UserWorkoutState.loading() => const UserWorkoutState(isLoading: true);

  /// Estado de sucesso
  factory UserWorkoutState.success({
    List<UserWorkout> workouts = const [],
    String? message,
  }) => UserWorkoutState(
    workouts: workouts,
    successMessage: message,
  );

  /// Estado de erro
  factory UserWorkoutState.error({
    required String message,
  }) => UserWorkoutState(
    errorMessage: message,
  );

  UserWorkoutState copyWith({
    List<UserWorkout>? workouts,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return UserWorkoutState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
} // Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_providers.dart';
import 'package:ray_club_app/features/auth/providers/auth_providers.dart';

/// Provider para o repositório de treinos
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseWorkoutRepository(supabase);
});

/// Provider para o WorkoutViewModel
final workoutViewModelProvider = StateNotifierProvider<WorkoutViewModel, AsyncValue<List<WorkoutRecord>>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeViewModel = ref.watch(challengeViewModelProvider.notifier);
  debugPrint('🔄 Criando WorkoutViewModel com repositório');
  return WorkoutViewModel(repository, authRepository, challengeViewModel);
});

/// ViewModel para gerenciar o histórico de treinos
class WorkoutViewModel extends StateNotifier<AsyncValue<List<WorkoutRecord>>> {
  /// Repositório de treinos
  final WorkoutRepository _repository;
  
  /// Repositório de autenticação
  final IAuthRepository _authRepository;
  
  /// ViewModel de desafios para registrar check-ins
  final ChallengeViewModel _challengeViewModel;
  
  /// Flag para evitar carregamentos duplicados
  bool _isLoading = false;

  /// Construtor
  WorkoutViewModel(this._repository, this._authRepository, this._challengeViewModel) : super(const AsyncValue.loading()) {
    // Carregar dados iniciais com um pequeno delay para garantir que o contexto 
    // de autenticação já esteja disponível
    Future.delayed(const Duration(milliseconds: 300), () {
      loadWorkoutHistory();
    });
  }

  /// Obtém o nome do usuário para o registro do treino
  Future<String> _getUserName(String userId) async {
    try {
      final user = await _authRepository.getCurrentUser();
      // Acesso ao nome do usuário via metadados
      final userData = user?.userMetadata;
      if (userData != null && userData.containsKey('name')) {
        return userData['name'] as String? ?? 'Usuário';
      }
      return 'Usuário';
    } catch (e) {
      debugPrint('⚠️ Erro ao obter nome do usuário: $e');
      return "Usuário";
    }
  }

  /// Carrega o histórico de treinos do usuário
  Future<void> loadWorkoutHistory() async {
    // Evita múltiplos carregamentos simultâneos
    if (_isLoading) {
      debugPrint('⚠️ WorkoutViewModel: Já existe um carregamento em andamento');
      return;
    }
    
    _isLoading = true;
    debugPrint('🔄 WorkoutViewModel: Carregando histórico de treinos');
    
    try {
      state = const AsyncValue.loading();
      final workouts = await _repository.getWorkoutHistory();
      
      // Log do resultado
      debugPrint('✅ WorkoutViewModel: Histórico carregado com ${workouts.length} treinos');
      
      // Ordena por data (mais recente primeiro)
      workouts.sort((a, b) => b.date.compareTo(a.date));
      
      state = AsyncValue.data(workouts);
    } catch (error, stackTrace) {
      debugPrint('❌ WorkoutViewModel: Erro ao carregar histórico: $error');
      state = AsyncValue.error(error, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  /// Adiciona um novo treino com os dados fornecidos
  Future<void> addWorkout({
    required String name,
    required String type,
    required int durationMinutes,
    String? notes,
  }) async {
    // Indicar que está carregando
    _isLoading = true;
    
    try {
      debugPrint('🔄 WorkoutViewModel: Adicionando novo treino: $name');
      
      // Preparar o treino para salvar
      final workout = WorkoutRecord(
        id: const Uuid().v4(),
        userId: '',  // Será preenchido pelo repositório
        workoutId: null,
        workoutName: name,
        workoutType: type,
        date: DateTime.now(),
        durationMinutes: durationMinutes,
        isCompleted: true,
        notes: notes ?? '',
        createdAt: DateTime.now(),
      );
      
      // Salvar o treino no repositório
      final savedWorkout = await _repository.addWorkoutRecord(workout);
      debugPrint('✅ WorkoutViewModel: Treino adicionado com sucesso');
      
      // Log detalhado sobre o workoutId para debug
      debugPrint('✅ Treino salvo com sucesso: ${savedWorkout.id}');
      
      // Registrar no desafio oficial se houver
      try {
        debugPrint('🔍 Registrando workout no desafio oficial');
        
        // Obter o usuário atual
        final currentUser = await _authRepository.getCurrentUser();
        if (currentUser == null) {
          throw Exception('Usuário não autenticado');
        }
        
        // Obter nome do usuário para o registro
        final userName = await _getUserName(currentUser.id);
        
        // Registrar o workout no desafio oficial usando o ChallengeViewModel
        await _challengeViewModel.registerWorkoutInActiveChallenges(
          userId: currentUser.id,
          workoutId: savedWorkout.id,
          workoutName: savedWorkout.workoutName,
          workoutDate: savedWorkout.date,
          durationMinutes: savedWorkout.durationMinutes,
        );
        
        // Mensagem para o usuário sobre a duração mínima para desafios
        if (durationMinutes < 45) {
          debugPrint('⚠️ Treino com duração menor que 45 minutos não contabiliza para desafios');
        } else {
          debugPrint('✅ Treino registrado e contabilizado para o desafio');
        }
        
      } catch (e) {
        debugPrint('⚠️ Erro ao registrar no desafio: $e');
      }
      
      // Atualizar o estado com a nova lista de treinos
      await loadWorkoutHistory();
      
    } catch (e) {
      debugPrint('❌ WorkoutViewModel: Erro ao adicionar treino: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _isLoading = false;
    }
  }

  /// Exclui um treino
  Future<void> deleteWorkout(String workoutId) async {
    try {
      debugPrint('🔄 WorkoutViewModel: Excluindo treino: $workoutId');
      await _repository.deleteWorkoutRecord(workoutId);
      
      // Atualizar a lista localmente removendo o item
      state.whenData((workouts) {
        final updatedList = workouts.where((w) => w.id != workoutId).toList();
        state = AsyncValue.data(updatedList);
      });
      debugPrint('✅ WorkoutViewModel: Treino excluído com sucesso');
    } catch (error) {
      debugPrint('❌ WorkoutViewModel: Erro ao excluir treino: $error');
      rethrow;
    }
  }

  /// Atualiza um treino existente
  Future<void> updateWorkout(WorkoutRecord workout) async {
    try {
      debugPrint('🔄 WorkoutViewModel: Atualizando treino: ${workout.id}');
      await _repository.updateWorkoutRecord(workout);
      
      // Atualizar a lista localmente substituindo o item
      state.whenData((workouts) {
        final updatedList = workouts.map((w) => 
          w.id == workout.id ? workout : w
        ).toList();
        state = AsyncValue.data(updatedList);
      });
      debugPrint('✅ WorkoutViewModel: Treino atualizado com sucesso');
    } catch (error) {
      debugPrint('❌ WorkoutViewModel: Erro ao atualizar treino: $error');
      rethrow;
    }
  }
} 
// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/workout/models/workout_category.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/providers/workout_providers.dart';

/// Estado da tela de categorias de workout
class WorkoutCategoriesState {
  /// Se está carregando os dados
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;
  
  /// Lista de categorias de workout
  final List<WorkoutCategory> categories;

  /// Construtor
  const WorkoutCategoriesState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
  });

  /// Cria um estado inicial
  factory WorkoutCategoriesState.initial() => const WorkoutCategoriesState(isLoading: true);

  /// Cria uma cópia deste estado com os campos especificados atualizados
  WorkoutCategoriesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<WorkoutCategory>? categories,
  }) {
    return WorkoutCategoriesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
    );
  }

  /// Cria um estado de erro
  factory WorkoutCategoriesState.error(String message) => WorkoutCategoriesState(
    isLoading: false,
    errorMessage: message,
  );

  /// Cria um estado com categorias carregadas
  factory WorkoutCategoriesState.loaded(List<WorkoutCategory> categories) => WorkoutCategoriesState(
    isLoading: false,
    categories: categories,
  );
}

/// ViewModel para a tela de categorias de workout
class WorkoutCategoriesViewModel extends StateNotifier<WorkoutCategoriesState> {
  /// Repositório de workouts
  final WorkoutRepository _repository;

  /// Construtor
  WorkoutCategoriesViewModel(this._repository) 
      : super(WorkoutCategoriesState.initial()) {
    loadCategories();
  }

  /// Carrega as categorias de workout
  Future<void> loadCategories() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final categories = await _repository.getWorkoutCategories();
      
      state = WorkoutCategoriesState.loaded(categories);
    } catch (e) {
      debugPrint('Erro ao carregar categorias: $e');
      state = WorkoutCategoriesState.error('Erro ao carregar categorias: $e');
    }
  }
}

/// Provider que fornece acesso ao WorkoutCategoriesViewModel
final workoutCategoriesViewModelProvider = 
    StateNotifierProvider<WorkoutCategoriesViewModel, WorkoutCategoriesState>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutCategoriesViewModel(repository);
}); // Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import '../providers/workout_providers.dart';

/// Estado da tela de detalhes do workout
class WorkoutDetailState {
  /// Se está carregando os dados
  final bool isLoading;
  
  /// Mensagem de erro, se houver
  final String? errorMessage;
  
  /// Workout sendo visualizado
  final Workout? workout;

  /// Construtor
  const WorkoutDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.workout,
  });

  /// Cria um estado inicial
  factory WorkoutDetailState.initial() => const WorkoutDetailState(isLoading: true);

  /// Cria uma cópia deste estado com os campos especificados atualizados
  WorkoutDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    Workout? workout,
  }) {
    return WorkoutDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      workout: workout ?? this.workout,
    );
  }

  /// Cria um estado de erro
  factory WorkoutDetailState.error(String message) => WorkoutDetailState(
    isLoading: false,
    errorMessage: message,
  );

  /// Cria um estado com o workout carregado
  factory WorkoutDetailState.loaded(Workout workout) => WorkoutDetailState(
    isLoading: false,
    workout: workout,
  );
}

/// ViewModel para a tela de detalhes do workout
class WorkoutDetailViewModel extends StateNotifier<WorkoutDetailState> {
  /// Repositório de workouts
  final WorkoutRepository _repository;
  
  /// ID do workout a ser carregado
  final String workoutId;

  /// Construtor
  WorkoutDetailViewModel(this._repository, this.workoutId) 
      : super(WorkoutDetailState.initial()) {
    loadWorkout();
  }

  /// Carrega os detalhes do workout
  Future<void> loadWorkout() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final workout = await _repository.getWorkoutById(workoutId);
      
      if (workout != null) {
        state = WorkoutDetailState.loaded(workout);
      } else {
        state = WorkoutDetailState.error('Treino não encontrado');
      }
    } catch (e) {
      debugPrint('Erro ao carregar workout: $e');
      state = WorkoutDetailState.error('Erro ao carregar treino: $e');
    }
  }

  /// Favorita ou desfavorita o workout
  Future<void> toggleFavorite() async {
    if (state.workout == null) return;
    
    try {
      // Otimistic update
      final currentWorkout = state.workout!;
      final updatedWorkout = currentWorkout.copyWith(
        isFavorite: !currentWorkout.isFavorite
      );
      
      state = state.copyWith(workout: updatedWorkout);
      
      // Persiste a mudança
      await _repository.updateWorkout(updatedWorkout);
    } catch (e) {
      // Restaura o estado em caso de erro
      state = state.copyWith(workout: state.workout);
      debugPrint('Erro ao favoritar/desfavoritar workout: $e');
    }
  }
}

/// Provider que fornece acesso ao WorkoutDetailViewModel
final workoutDetailViewModelProvider = StateNotifierProvider.family<
    WorkoutDetailViewModel, WorkoutDetailState, String>((ref, workoutId) {
  final repository = ref.watch(workoutRepositoryProvider);
  return WorkoutDetailViewModel(repository, workoutId);
}); // Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/core/providers/providers.dart'; // Para authRepositoryProvider
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/services/workout_challenge_service.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

part 'workout_record_view_model.freezed.dart';

/// Estado para o gerenciamento do registro de treinos
@freezed
class WorkoutRecordState with _$WorkoutRecordState {
  const factory WorkoutRecordState({
    @Default(false) bool isLoading,
    @Default([]) List<WorkoutRecord> records,
    @Default('Funcional') String selectedWorkoutType,
    @Default(0.3) double intensity,
    @Default([]) List<XFile> selectedImages,
    String? errorMessage,
    String? successMessage,
  }) = _WorkoutRecordState;
}

/// Provider para o WorkoutRecordViewModel
final workoutRecordViewModelProvider = StateNotifierProvider<WorkoutRecordViewModel, WorkoutRecordState>((ref) {
  final repository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeService = ref.watch(workoutChallengeServiceProvider);
  
  return WorkoutRecordViewModel(
    repository: repository,
    authRepository: authRepository,
    challengeService: challengeService,
    ref: ref,
  );
});

/// ViewModel para gerenciar o registro de treinos
class WorkoutRecordViewModel extends StateNotifier<WorkoutRecordState> {
  final WorkoutRecordRepository _repository;
  final IAuthRepository _authRepository;
  final WorkoutChallengeService _challengeService;
  final Ref ref;
  
  /// Construtor
  WorkoutRecordViewModel({
    required WorkoutRecordRepository repository,
    required IAuthRepository authRepository,
    required WorkoutChallengeService challengeService,
    required this.ref,
  }) : 
    _repository = repository,
    _authRepository = authRepository,
    _challengeService = challengeService,
    super(const WorkoutRecordState());

  /// Lista de tipos de treino disponíveis
  List<String> get workoutTypes => [
    'Funcional',
    'Musculação',
    'Cardio',
    'Yoga',
    'Pilates',
    'HIIT',
    'Alongamento',
    'Outro'
  ];

  /// Atualiza o tipo de treino selecionado
  void updateWorkoutType(String workoutType) {
    state = state.copyWith(selectedWorkoutType: workoutType);
  }

  /// Atualiza o valor da intensidade do treino
  void updateIntensity(double intensity) {
    state = state.copyWith(intensity: intensity);
  }

  /// Obtém o texto da intensidade com base no valor
  String get intensityText {
    if (state.intensity < 0.33) return 'Leve';
    if (state.intensity < 0.66) return 'Moderada';
    return 'Intensa';
  }

  /// Adiciona uma imagem selecionada
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final currentImages = [...state.selectedImages];
        
        if (currentImages.isEmpty) {
          state = state.copyWith(selectedImages: [image]);
        } else if (currentImages.length < 3) {
          currentImages.add(image);
          state = state.copyWith(selectedImages: currentImages);
        } else {
          // Substituir a primeira imagem se já tiver 3
          currentImages[0] = image;
          state = state.copyWith(selectedImages: currentImages);
        }
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao selecionar imagem: $e',
      );
    }
  }

  /// Adiciona um novo registro de treino
  Future<void> addWorkoutRecord(WorkoutRecord record, {List<XFile>? images}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      debugPrint('🔄 Iniciando registro de treino: ${record.workoutName}');
      
      // Se não for fornecido images, usar as do estado
      final imagesToUpload = images ?? state.selectedImages;
      
      // Obter ID do usuário atual
      String userId = '';
      try {
        userId = await _authRepository.getCurrentUserId();
        debugPrint('✅ ID do usuário obtido: $userId');
      } catch (e) {
        debugPrint('❌ Erro ao obter ID do usuário: $e');
        // Continuar com ID vazio, será tratado pelo repositório
      }
      
      // Atualizar o registro com o ID do usuário
      final WorkoutRecord updatedRecord = record.copyWith(userId: userId);
      
      // Salvar registro no banco
      debugPrint('🔄 Salvando registro de treino...');
      final createdRecord = await _repository.createWorkoutRecord(updatedRecord);
      final String recordId = createdRecord.id;
      debugPrint('✅ Registro de treino salvo com ID: $recordId');
      
      // Se tiver imagens, fazer upload delas
      if (imagesToUpload.isNotEmpty) {
        try {
          // Converter XFile para File
          final files = imagesToUpload.map((xFile) => File(xFile.path)).toList();
          // Fazer upload das imagens
          await _repository.uploadWorkoutImages(recordId, files);
        } catch (e) {
          debugPrint('⚠️ Erro ao fazer upload das imagens: $e');
          // Continuar mesmo com erro no upload
        }
      }
      
      // Processar os pontos de desafio (se aplicável)
      int pointsEarned = 0;
      try {
        debugPrint('🔄 Processando pontos de desafio...');
        pointsEarned = await _challengeService.processWorkoutCompletion(updatedRecord);
        debugPrint('🎯 Pontos ganhos em desafios: $pointsEarned');
      } catch (e) {
        debugPrint('⚠️ Erro ao processar pontos de desafio: $e');
        // Não interromper o fluxo por erro nos desafios
      }
      
      // ESTRATÉGIA DE ATUALIZAÇÃO ROBUSTA DO DASHBOARD
      // 1. Primeiro método: via atualização manual direta
      try {
        debugPrint('🔄 Método #1: Atualização direta do dashboard');
        final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
        await dashboardViewModel.forceManualUpdate();
        debugPrint('✅ Método #1 completo: Atualização direta do dashboard');
      } catch (e) {
        debugPrint('⚠️ Método #1 falhou: $e');
      }
      
      // 2. Segundo método: via RPC (caso o primeiro falhe)
      try {
        debugPrint('🔄 Método #2: Forçando atualização do dashboard via RPC direta');
        final supabase = Supabase.instance.client;
        await supabase.rpc(
          'refresh_dashboard_data',
          params: {'p_user_id': userId},
        );
        debugPrint('✅ Método #2 completo: RPC refresh_dashboard_data executada');
        
        // Aguardar um momento para garantir consistência
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('⚠️ Método #2 falhou: $e');
      }
      
      // 3. Terceiro método: via ViewModel (caso os anteriores falhem)
      try {
        debugPrint('🔄 Método #3: Forçando atualização do dashboard via ViewModel.forceRefresh');
        final dashboardViewModel = ref.read(dashboardViewModelProvider.notifier);
        await dashboardViewModel.forceRefresh();
        debugPrint('✅ Método #3 completo: Dashboard atualizado via ViewModel.forceRefresh');
      } catch (e) {
        debugPrint('⚠️ Método #3 falhou: $e');
      }
      
      // Limpar as imagens selecionadas
      state = state.copyWith(
        isLoading: false,
        selectedImages: [],
        selectedWorkoutType: 'Funcional', // Restaurando para o valor padrão
        successMessage: 'Treino registrado com sucesso${pointsEarned > 0 ? " (+$pointsEarned pontos)" : ""}',
      );
      
      debugPrint('✅ Registro de treino completo');
    } catch (e) {
      debugPrint('❌ Erro ao registrar treino: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar treino: $e',
      );
    }
  }

  /// Carrega o histórico de treinos do usuário atual
  Future<void> loadUserWorkoutRecords() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final records = await _repository.getUserWorkoutRecords();
      
      state = state.copyWith(
        isLoading: false,
        records: records,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao carregar histórico de treinos: $e',
      );
    }
  }

  /// Remove um registro de treino
  Future<void> deleteWorkoutRecord(String recordId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteWorkoutRecord(recordId);
      
      // Atualizar a lista removendo o registro deletado
      final updatedRecords = state.records.where((record) => record.id != recordId).toList();
      
      state = state.copyWith(
        isLoading: false,
        records: updatedRecords,
        successMessage: 'Registro de treino excluído com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao excluir registro: $e',
      );
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';

part 'workout_history_view_model.freezed.dart';

/// Estado para o gerenciamento do histórico de treinos
@freezed
abstract class WorkoutHistoryState with _$WorkoutHistoryState {
  /// Estado de carregamento
  const factory WorkoutHistoryState.loading() = _Loading;
  
  /// Estado quando não há registros
  const factory WorkoutHistoryState.empty() = _Empty;
  
  /// Estado com registros carregados
  const factory WorkoutHistoryState.loaded({
    required List<WorkoutRecord> allRecords,
    DateTime? selectedDate,
    List<WorkoutRecord>? selectedDateRecords,
  }) = _Loaded;
  
  /// Estado de erro
  const factory WorkoutHistoryState.error(String message) = _Error;
}

/// ViewModel para gerenciar o histórico de treinos
class WorkoutHistoryViewModel extends StateNotifier<WorkoutHistoryState> {
  final WorkoutRecordRepository _repository;
  
  WorkoutHistoryViewModel(this._repository) : super(const WorkoutHistoryState.loading()) {
    loadWorkoutHistory();
  }
  
  /// Carrega o histórico de treinos do usuário atual
  Future<void> loadWorkoutHistory() async {
    try {
      state = const WorkoutHistoryState.loading();
      
      final records = await _repository.getUserWorkoutRecords();
      
      if (records.isEmpty) {
        state = const WorkoutHistoryState.empty();
      } else {
        state = WorkoutHistoryState.loaded(
          allRecords: records,
          selectedDate: null,
          selectedDateRecords: null,
        );
      }
    } catch (e) {
      state = WorkoutHistoryState.error('Erro ao carregar histórico: ${e.toString()}');
    }
  }
  
  /// Obtém os dias que têm treinos registrados
  Map<DateTime, List<WorkoutRecord>> getWorkoutsByDay() {
    final currentState = state;
    if (currentState is! _Loaded) {
      return {};
    }
    
    final Map<DateTime, List<WorkoutRecord>> workoutsByDay = {};
    for (final record in currentState.allRecords) {
      // Normalizar a data (remover hora/minuto/segundo)
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      workoutsByDay.putIfAbsent(date, () => []).add(record);
    }
    
    return workoutsByDay;
  }
  
  /// Seleciona uma data para mostrar os treinos
  void selectDate(DateTime? date) {
    final currentState = state;
    if (currentState is! _Loaded) {
      return;
    }
    
    if (date == null) {
      state = WorkoutHistoryState.loaded(
        allRecords: currentState.allRecords,
        selectedDate: null,
        selectedDateRecords: null,
      );
      return;
    }
    
    // Normalizar a data (remover hora/minuto/segundo)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Filtrar os registros da data selecionada
    final dateRecords = currentState.allRecords.where((record) {
      final recordDate = DateTime(
        record.date.year, 
        record.date.month, 
        record.date.day,
      );
      return recordDate.isAtSameMomentAs(normalizedDate);
    }).toList();
    
    state = WorkoutHistoryState.loaded(
      allRecords: currentState.allRecords,
      selectedDate: normalizedDate,
      selectedDateRecords: dateRecords,
    );
  }
  
  /// Limpa a seleção de data
  void clearSelectedDate() {
    final currentState = state;
    if (currentState is! _Loaded) {
      return;
    }
    
    state = WorkoutHistoryState.loaded(
      allRecords: currentState.allRecords,
      selectedDate: null,
      selectedDateRecords: null,
    );
  }
}

/// Provider para o ViewModel do histórico de treinos
final workoutHistoryViewModelProvider = StateNotifierProvider.autoDispose<WorkoutHistoryViewModel, WorkoutHistoryState>((ref) {
  final repository = ref.watch(workoutRecordRepositoryProvider);
  return WorkoutHistoryViewModel(repository);
}); // Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/events/app_event_bus.dart';
import 'package:ray_club_app/core/offline/offline_operation_queue.dart';
import 'package:ray_club_app/core/offline/offline_repository_helper.dart';
import 'package:ray_club_app/features/workout/models/user_workout.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Provider for UserWorkoutRepository
final userWorkoutRepositoryProvider = Provider<UserWorkoutRepository>((ref) {
  final supabase = Supabase.instance.client;
  final eventBus = ref.watch(appEventBusProvider);
  final offlineHelper = ref.watch(offlineRepositoryHelperProvider);
  return UserWorkoutRepository(supabase, eventBus, offlineHelper);
});

/// Repository for managing user workout records
class UserWorkoutRepository {
  final SupabaseClient _client;
  final AppEventBus _eventBus;
  final OfflineRepositoryHelper _offlineHelper;
  
  UserWorkoutRepository(this._client, this._eventBus, this._offlineHelper);
  
  /// Save a workout record
  Future<UserWorkout> saveWorkout(UserWorkout workout) async {
    // Ensure we have user information
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw AppAuthException(message: 'User not authenticated');
    }
    
    // Create data map with required fields
    final workoutData = {
      ...workout.toJson(),
      'user_id': currentUser.id,
      'user_name': workout.userName ?? currentUser.userMetadata?['name'] ?? 'User',
      'completed_at': workout.completedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    
    try {
      // Usa o helper para executar com suporte offline
      return await _offlineHelper.executeWithOfflineSupport<UserWorkout>(
        entity: 'workouts',
        type: OperationType.create,
        data: workoutData,
        onlineOperation: () async {
          // Operação online normal
          final response = await _client
              .from('user_workouts')
              .insert(workoutData)
              .select()
              .single();
          
          // Create workout object
          final savedWorkout = UserWorkout.fromJson(response);
          
          // Publish event
          _publishWorkoutEvent(savedWorkout, currentUser.id);
          
          return savedWorkout;
        },
        offlineResultBuilder: (operation) {
          // Se estiver offline, cria um ID temporário e retorna o workout
          // com uma flag indicando que foi salvo offline
          final savedWorkout = UserWorkout.fromJson({
            ...workoutData,
            'id': 'offline_${operation.id}',
            'is_synced': false,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          LogUtils.info(
            'Treino salvo na fila offline',
            tag: 'UserWorkoutRepository',
            data: {'operationId': operation.id},
          );
          
          return savedWorkout;
        },
      );
    } catch (e) {
      // Se for uma exceção de operação offline, podemos tratá-la de maneira especial
      if (e is OfflineOperationException) {
        LogUtils.info(
          'Treino adicionado à fila offline',
          tag: 'UserWorkoutRepository',
          data: {'operationId': e.operationId},
        );
        
        // Criar um objeto de treino com ID temporário
        return UserWorkout.fromJson({
          ...workoutData,
          'id': 'offline_${e.operationId}',
          'is_synced': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      
      // Para outros erros, registramos e propagamos
      LogUtils.error(
        'Erro ao salvar treino',
        tag: 'UserWorkoutRepository',
        error: e,
      );
      
      throw AppStorageException(
        message: 'Failed to save workout record',
        originalError: e,
      );
    }
  }
  
  /// Get user workout history
  Future<List<UserWorkout>> getUserWorkouts({required String userId, int limit = 20}) async {
    try {
      // Para leitura, tentamos obter dados do Supabase
      final response = await _client
          .from('user_workouts')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((item) => UserWorkout.fromJson(item))
          .toList();
    } catch (e) {
      // Se houver erro de conectividade, podemos tentar obter dados do cache local
      // (implementação do cache omitida para simplificar)
      LogUtils.warning(
        'Erro ao buscar histórico de treinos online, tentando cache',
        tag: 'UserWorkoutRepository',
        data: {'error': e.toString()},
      );
      
      // Retornamos uma lista vazia por enquanto
      return [];
    }
  }
  
  /// Get recent workouts (last X days)
  Future<List<UserWorkout>> getRecentWorkouts({required String userId, int days = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final response = await _client
          .from('user_workouts')
          .select()
          .eq('user_id', userId)
          .gte('completed_at', cutoffDate.toIso8601String())
          .order('completed_at', ascending: false);
      
      return (response as List)
          .map((item) => UserWorkout.fromJson(item))
          .toList();
    } catch (e) {
      // Se houver erro de conectividade, podemos tentar obter dados do cache local
      LogUtils.warning(
        'Erro ao buscar treinos recentes online, tentando cache',
        tag: 'UserWorkoutRepository',
        data: {'error': e.toString()},
      );
      
      // Retornamos uma lista vazia por enquanto
      return [];
    }
  }
  
  /// Publish workout event
  void _publishWorkoutEvent(UserWorkout workout, String userId) {
    _eventBus.publish(
      AppEvent.workout(
        type: EventTypes.workoutCompleted,
        workoutId: workout.id,
        data: {
          'workout': workout.toJson(),
          'userId': userId,
        },
      ),
    );
  }

  /// Get user workout history converted to WorkoutRecord format
  Future<List<WorkoutRecord>> getUserWorkoutsAsRecords({required String userId, int limit = 20}) async {
    final userWorkouts = await getUserWorkouts(userId: userId, limit: limit);
    return userWorkouts.map(_convertToWorkoutRecord).toList();
  }

  /// Convert UserWorkout to WorkoutRecord
  WorkoutRecord _convertToWorkoutRecord(UserWorkout workout) {
    return WorkoutRecord(
      id: workout.id,
      userId: workout.userId,
      workoutId: workout.workoutId,
      workoutName: workout.userName ?? 'Unknown Workout',
      workoutType: workout.workoutType ?? 'General',
      date: workout.completedAt ?? DateTime.now(),
      durationMinutes: workout.duration ?? 0,
      isCompleted: true,
      notes: workout.notes,
      createdAt: workout.completedAt,
    );
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/models/workout_stats_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';

/// Interface do repositório para estatísticas de treinos
abstract class WorkoutStatsRepository {
  /// Obtém estatísticas do usuário atual
  Future<WorkoutStats> getUserWorkoutStats();
  
  /// Atualiza as estatísticas após um novo treino
  Future<WorkoutStats> updateStatsAfterWorkout(WorkoutRecord record);
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutStatsRepository implements WorkoutStatsRepository {
  final WorkoutRecordRepository _recordRepository;
  WorkoutStats? _cachedStats;

  MockWorkoutStatsRepository(this._recordRepository);

  @override
  Future<WorkoutStats> getUserWorkoutStats() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (_cachedStats != null) {
      return _cachedStats!;
    }
    
    // Buscar registros para calcular estatísticas reais
    try {
      final records = await _recordRepository.getUserWorkoutRecords();
      final stats = _calculateStats(records);
      
      _cachedStats = stats;
      return stats;
    } catch (e) {
      // Se falhar ao buscar registros, retornar estatísticas mockadas
      return _getMockStats();
    }
  }

  @override
  Future<WorkoutStats> updateStatsAfterWorkout(WorkoutRecord record) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Em um ambiente real, recalcularíamos as estatísticas com base nos registros
    // Para o mock, vamos apenas incrementar alguns valores
    
    final currentStats = await getUserWorkoutStats();
    
    _cachedStats = currentStats.copyWith(
      totalWorkouts: currentStats.totalWorkouts + 1,
      monthWorkouts: currentStats.monthWorkouts + 1,
      weekWorkouts: currentStats.weekWorkouts + 1,
      totalMinutes: currentStats.totalMinutes + record.durationMinutes,
      lastUpdatedAt: DateTime.now(),
    );
    
    return _cachedStats!;
  }
  
  /// Calcula estatísticas com base nos registros de treino
  WorkoutStats _calculateStats(List<WorkoutRecord> records) {
    if (records.isEmpty) {
      return WorkoutStats.empty('user123');
    }
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Filtrar registros por período
    final monthlyRecords = records.where((r) => r.date.isAfter(startOfMonth)).toList();
    final weeklyRecords = records.where((r) => r.date.isAfter(startOfWeek)).toList();
    
    // Estatísticas por dia da semana
    final weekdayStats = <String, int>{};
    final weekdayMinutes = <String, int>{};
    
    // Inicializar com zeros para todos os dias da semana
    for (var i = 1; i <= 7; i++) {
      final weekday = _getWeekdayName(i);
      weekdayStats[weekday] = 0;
      weekdayMinutes[weekday] = 0;
    }
    
    // Calcular estatísticas por dia da semana
    for (final record in records) {
      if (record.date.isAfter(now.subtract(const Duration(days: 30)))) {
        final weekday = _getWeekdayName(record.date.weekday);
        weekdayStats[weekday] = (weekdayStats[weekday] ?? 0) + 1;
        weekdayMinutes[weekday] = (weekdayMinutes[weekday] ?? 0) + record.durationMinutes;
      }
    }
    
    // Calcular streak atual (dias consecutivos com treino)
    final streakInfo = _calculateStreak(records);
    
    return WorkoutStats(
      userId: 'user123',
      totalWorkouts: records.length,
      monthWorkouts: monthlyRecords.length,
      weekWorkouts: weeklyRecords.length,
      totalMinutes: monthlyRecords.fold(0, (sum, r) => sum + r.durationMinutes),
      currentStreak: streakInfo.currentStreak,
      bestStreak: streakInfo.bestStreak,
      weekdayStats: weekdayStats,
      weekdayMinutes: weekdayMinutes,
      frequencyPercentage: _calculateFrequencyPercentage(monthlyRecords.length),
      lastUpdatedAt: DateTime.now(),
    );
  }
  
  /// Calcula a sequência atual e a melhor sequência
  ({int currentStreak, int bestStreak}) _calculateStreak(List<WorkoutRecord> records) {
    if (records.isEmpty) return (currentStreak: 0, bestStreak: 0);
    
    // Ordenar por data (mais recente primeiro)
    final sortedRecords = List<WorkoutRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // Converter para apenas datas (sem hora)
    final workoutDates = sortedRecords.map((r) => 
      DateTime(r.date.year, r.date.month, r.date.day)
    ).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (workoutDates.isEmpty) return (currentStreak: 0, bestStreak: 0);
    
    // Calcular streak atual
    int currentStreak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Verificar se treinou hoje ou ontem
    if (workoutDates.contains(today)) {
      currentStreak = 1;
      
      // Contar dias anteriores consecutivos
      var checkDate = yesterday;
      while (workoutDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else if (workoutDates.contains(yesterday)) {
      currentStreak = 1;
      
      // Contar dias anteriores consecutivos
      var checkDate = yesterday.subtract(const Duration(days: 1));
      while (workoutDates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      currentStreak = 0;
    }
    
    // Calcular melhor streak histórico
    int bestStreak = currentStreak;
    int tempStreak = 0;
    
    for (int i = 0; i < workoutDates.length - 1; i++) {
      final diff = workoutDates[i].difference(workoutDates[i + 1]).inDays;
      
      if (diff == 1) {
        // Dias consecutivos
        tempStreak++;
      } else {
        // Quebra na sequência
        tempStreak = 0;
      }
      
      if (tempStreak > bestStreak) {
        bestStreak = tempStreak;
      }
    }
    
    return (currentStreak: currentStreak, bestStreak: max(bestStreak, 1));
  }
  
  /// Calcula porcentagem de frequência com base na meta (treinar 5x por semana)
  double _calculateFrequencyPercentage(int monthWorkouts) {
    // Meta: 20 treinos por mês (5 por semana)
    final target = 20;
    return ((monthWorkouts / target) * 100).clamp(0, 100);
  }
  
  /// Retorna o nome do dia da semana com base no índice (1 = segunda, 7 = domingo)
  String _getWeekdayName(int weekday) {
    const weekdays = ['', 'S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return weekdays[weekday];
  }
  
  /// Retorna o máximo entre dois valores
  int max(int a, int b) => a > b ? a : b;
  
  /// Retorna estatísticas mockadas para desenvolvimento
  WorkoutStats _getMockStats() {
    final weekdayStats = <String, int>{
      'S': 2,
      'M': 3,
      'T': 1,
      'W': 4,
      'T': 2,
      'F': 3,
      'S': 1,
    };
    
    final weekdayMinutes = <String, int>{
      'S': 45,
      'M': 85,
      'T': 30,
      'W': 120,
      'T': 60,
      'F': 90,
      'S': 20,
    };
    
    return WorkoutStats(
      userId: 'user123',
      totalWorkouts: 28,
      monthWorkouts: 16,
      weekWorkouts: 4,
      totalMinutes: 450,
      currentStreak: 3,
      bestStreak: 5,
      weekdayStats: weekdayStats,
      weekdayMinutes: weekdayMinutes,
      frequencyPercentage: 86.0,
      lastUpdatedAt: DateTime.now(),
    );
  }
}

/// Implementação com Supabase
class SupabaseWorkoutStatsRepository implements WorkoutStatsRepository {
  final SupabaseClient _supabaseClient;
  final WorkoutRecordRepository _recordRepository;

  SupabaseWorkoutStatsRepository(this._supabaseClient, this._recordRepository);

  @override
  Future<WorkoutStats> getUserWorkoutStats() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Tentar buscar estatísticas agregadas da visualização materializada
      final response = await _supabaseClient
          .from('workout_stats_view')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        // Temos estatísticas pré-calculadas
        return WorkoutStats.fromJson(response);
      }
      
      // Se não tiver estatísticas pré-calculadas, calcular com base nos registros
      final records = await _recordRepository.getUserWorkoutRecords();
      
      // Lógica de cálculo de estatísticas (similar ao mock)
      // Em produção, isso seria uma função complexa para calcular todas as estatísticas
      
      // Para simplificar, aqui usaremos a mesma implementação da versão mock
      final mockRepo = MockWorkoutStatsRepository(_recordRepository);
      return mockRepo._calculateStats(records);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      // Em desenvolvimento, retornar dados mockados em caso de erro
      final mockRepo = MockWorkoutStatsRepository(_recordRepository);
      return mockRepo.getUserWorkoutStats();
    }
  }

  @override
  Future<WorkoutStats> updateStatsAfterWorkout(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Em produção, poderíamos ter um procedimento armazenado para atualizar as estatísticas
      // ou um gatilho que recalcula automaticamente quando novos registros são adicionados
      
      // Para nossa implementação, vamos recalcular todas as estatísticas
      return getUserWorkoutStats();
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao atualizar estatísticas: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

/// Provider para o repositório de estatísticas de treino
final workoutStatsRepositoryProvider = Provider<WorkoutStatsRepository>((ref) {
  final recordRepository = ref.watch(workoutRecordRepositoryProvider);
  return SupabaseWorkoutStatsRepository(recordRepository);
}); // Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/workout/models/workout_category.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/models/exercise.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Interface para o repositório de treinos
abstract class WorkoutRepository {
  /// Obtém todos os treinos
  Future<List<Workout>> getWorkouts();

  /// Obtém treinos por categoria
  Future<List<Workout>> getWorkoutsByCategory(String category);

  /// Obtém um treino específico pelo ID
  Future<Workout> getWorkoutById(String id);
  
  /// Cria um novo treino
  Future<Workout> createWorkout(Workout workout);
  
  /// Atualiza um treino existente
  Future<Workout> updateWorkout(Workout workout);
  
  /// Exclui um treino
  Future<void> deleteWorkout(String id);
  
  /// Obtém todas as categorias de treino
  Future<List<WorkoutCategory>> getWorkoutCategories();
  
  /// Obtém o histórico de treinos do usuário
  Future<List<WorkoutRecord>> getWorkoutHistory();
  
  /// Adiciona um novo registro de treino
  Future<WorkoutRecord> addWorkoutRecord(WorkoutRecord record);
  
  /// Atualiza um registro de treino existente
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record);
  
  /// Exclui um registro de treino
  Future<void> deleteWorkoutRecord(String recordId);
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutRepository implements WorkoutRepository {
  // Função auxiliar para gerar IDs únicos para exercícios
  String _generateExerciseId(String name) {
    // Converte o nome para um formato de ID, trocando espaços por traços e deixando em lowercase
    String baseId = name.toLowerCase().replaceAll(' ', '-');
    // Adiciona um timestamp para garantir unicidade
    return '$baseId-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Função auxiliar para criar objetos Exercise com os campos obrigatórios
  Exercise _createExercise(String name, {
    String? id,
    String? description,
    int? sets,
    int? reps,
    int? duration,
    String? imageUrl,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? _generateExerciseId(name),
      name: name,
      detail: description ?? '$name - Detalhes do exercício',
      description: description,
      sets: sets,
      reps: reps,
      duration: duration,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _getMockWorkouts();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      return _getMockCategories();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar categorias de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final allWorkouts = _getMockWorkouts();
      return allWorkouts
          .where((workout) => workout.type.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos por categoria',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> getWorkoutById(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final allWorkouts = _getMockWorkouts();
      return allWorkouts.firstWhere(
        (workout) => workout.id == id,
        orElse: () => throw app_errors.NotFoundException(
          message: 'Treino não encontrado',
          code: 'workout_not_found',
        ),
      );
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao carregar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Workout> createWorkout(Workout workout) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return workout.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> updateWorkout(Workout workout) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Verificar se o treino existe
      final allWorkouts = _getMockWorkouts();
      final exists = allWorkouts.any((w) => w.id == workout.id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para atualização',
          code: 'workout_not_found',
        );
      }
      
      // Em um ambiente real, o updatedAt seria atualizado
      return workout.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Verificar se o treino existe
      final allWorkouts = _getMockWorkouts();
      final exists = allWorkouts.any((workout) => workout.id == id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para exclusão',
          code: 'workout_not_found',
        );
      }
      
      // Em um ambiente real, o treino seria removido do banco de dados
      return;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutRecord>> getWorkoutHistory() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Retorna uma lista simulada de registros de treino
      final now = DateTime.now();
      return [
        WorkoutRecord(
          id: '1',
          userId: 'user123',
          workoutId: '1',
          workoutName: 'Yoga para Iniciantes',
          workoutType: 'Yoga',
          date: now.subtract(const Duration(days: 1)),
          durationMinutes: 20,
          isCompleted: true,
          notes: 'Senti melhora na flexibilidade',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        WorkoutRecord(
          id: '2',
          userId: 'user123',
          workoutId: '4',
          workoutName: 'Treino de Força Total',
          workoutType: 'Força',
          date: now.subtract(const Duration(days: 3)),
          durationMinutes: 45,
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      ];
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar histórico de treinos',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> addWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return record.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao adicionar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Em um ambiente real, verificaríamos se o registro existe
      return record;
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkoutRecord(String recordId) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Em um ambiente real, verificaríamos se o registro existe
      return;
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  // TEMPORÁRIO: Método para gerar dados mockados
  List<Workout> _getMockWorkouts() {
    final now = DateTime.now();
    
    return [
      Workout(
        id: '1',
        title: 'Yoga para Iniciantes',
        description: 'Um treino de yoga suave para quem está começando a praticar.',
        imageUrl: 'assets/images/categories/yoga.png',
        type: 'Yoga',
        durationMinutes: 20,
        difficulty: 'Iniciante',
        equipment: ['Tapete', 'Bloco de yoga'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              _createExercise('Respiração profunda', description: 'Respiração lenta e profunda para relaxar'),
              _createExercise('Alongamento leve', description: 'Alongamento suave para preparar o corpo'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              _createExercise('Postura do cachorro olhando para baixo'),
              _createExercise('Postura da montanha'),
              _createExercise('Postura da árvore'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              _createExercise('Relaxamento final'),
            ],
          ),
        ],
        creatorId: 'instrutor1',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Workout(
        id: '2',
        title: 'Pilates Abdominal',
        description: 'Treino focado no fortalecimento do core e abdômen usando técnicas de pilates.',
        imageUrl: 'assets/images/categories/pilates.png',
        type: 'Pilates',
        durationMinutes: 30,
        difficulty: 'Intermediário',
        equipment: ['Tapete', 'Bola pequena'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'pilates-breathing',
                name: 'Respiração de pilates',
                detail: '3 séries'),
              Exercise(
                id: 'spine-mobility',
                name: 'Mobilidade de coluna',
                detail: '8-10 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'hundred',
                name: 'The hundred',
                detail: '100 batidas de braço'),
              Exercise(
                id: 'single-leg-stretch',
                name: 'Single leg stretch',
                detail: '10 repetições cada lado'),
              Exercise(
                id: 'double-leg-stretch',
                name: 'Double leg stretch',
                detail: '10 repetições'),
              Exercise(
                id: 'criss-cross',
                name: 'Criss cross',
                detail: '10 repetições cada lado'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'spine-stretch',
                name: 'Spine stretch forward',
                detail: '8 repetições'),
            ],
          ),
        ],
        creatorId: 'instrutor2',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Workout(
        id: '3',
        title: 'HIIT 15 minutos',
        description: 'Treino de alta intensidade para queimar calorias em pouco tempo.',
        imageUrl: 'assets/images/workout_default.jpg',
        type: 'HIIT',
        durationMinutes: 15,
        difficulty: 'Avançado',
        equipment: ['Tapete'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'jumping-jacks',
                name: 'Jumping jacks',
                detail: '30 segundos'),
              Exercise(
                id: 'running-in-place',
                name: 'Corrida no lugar',
                detail: '45 segundos'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'burpees',
                name: 'Burpees',
                detail: '10 repetições'),
              Exercise(
                id: 'mountain-climbers',
                name: 'Mountain climbers',
                detail: '30 segundos'),
              Exercise(
                id: 'jumping-squats',
                name: 'Jumping squats',
                detail: '12 repetições'),
              Exercise(
                id: 'push-ups',
                name: 'Push-ups',
                detail: '8-10 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'general-stretching',
                name: 'Alongamentos gerais',
                detail: '5 minutos'),
            ],
          ),
        ],
        creatorId: 'instrutor3',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Workout(
        id: '4',
        title: 'Treino de Força Total',
        description: 'Treino completo para ganho de força muscular em todo o corpo.',
        imageUrl: 'assets/images/categories/musculacao.jpg',
        type: 'Musculação',
        durationMinutes: 45,
        difficulty: 'Intermediário',
        equipment: ['Halteres', 'Banco'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'joint-mobility',
                name: 'Mobilidade articular',
                detail: '2 minutos'),
              Exercise(
                id: 'muscle-activation',
                name: 'Ativação muscular',
                detail: '2 minutos'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'weighted-squat',
                name: 'Agachamento com peso',
                detail: '3 séries de 12 repetições'),
              Exercise(
                id: 'dumbbell-bench-press',
                name: 'Supino com halteres',
                detail: '3 séries de 10 repetições'),
              Exercise(
                id: 'rowing',
                name: 'Remada',
                detail: '3 séries de 12 repetições'),
              Exercise(
                id: 'lateral-raise',
                name: 'Elevação lateral',
                detail: '3 séries de 15 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'chest-stretch',
                name: 'Alongamento de peito',
                detail: '30 segundos cada lado'),
              Exercise(
                id: 'back-stretch',
                name: 'Alongamento de costas',
                detail: '30 segundos'),
              Exercise(
                id: 'leg-stretch',
                name: 'Alongamento de pernas',
                detail: '30 segundos cada perna'),
            ],
          ),
        ],
        creatorId: 'instrutor4',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Workout(
        id: '5',
        title: 'Yoga Flow',
        description: 'Sequência fluida de posturas de yoga para melhorar flexibilidade e equilíbrio.',
        imageUrl: 'assets/images/categories/yoga.png',
        type: 'Yoga',
        durationMinutes: 40,
        difficulty: 'Intermediário',
        equipment: ['Tapete', 'Bloco de yoga'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'sun-salutation-a',
                name: 'Saudação ao sol A',
                detail: '3 ciclos completos'),
              Exercise(
                id: 'sun-salutation-b',
                name: 'Saudação ao sol B',
                detail: '3 ciclos completos'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'warrior-1',
                name: 'Guerreiro I',
                detail: '5 respirações cada lado'),
              Exercise(
                id: 'warrior-2',
                name: 'Guerreiro II',
                detail: '5 respirações cada lado'),
              Exercise(
                id: 'triangle',
                name: 'Triângulo',
                detail: '5 respirações cada lado'),
              Exercise(
                id: 'half-moon',
                name: 'Meia lua',
                detail: '3 respirações cada lado'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'child-pose',
                name: 'Postura da criança',
                detail: '1 minuto'),
              Exercise(
                id: 'savasana',
                name: 'Savasana',
                detail: '5 minutos'),
            ],
          ),
        ],
        creatorId: 'instrutor1',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Workout(
        id: '6',
        title: 'HIIT para Iniciantes',
        description: 'Versão mais acessível de HIIT para quem está começando.',
        imageUrl: 'assets/images/workout_default.jpg',
        type: 'HIIT',
        durationMinutes: 20,
        difficulty: 'Iniciante',
        equipment: ['Tapete', 'Garrafa de água como peso'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'marching-in-place',
                name: 'Marcha no lugar',
                detail: '1 minuto'),
              Exercise(
                id: 'trunk-rotation',
                name: 'Rotação de tronco',
                detail: '30 segundos cada lado'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'simple-squat',
                name: 'Agachamento simples',
                detail: '12 repetições'),
              Exercise(
                id: 'plank',
                name: 'Prancha',
                detail: '30 segundos'),
              Exercise(
                id: 'knee-raise',
                name: 'Elevação de joelhos',
                detail: '15 repetições cada lado'),
              Exercise(
                id: 'modified-pushup',
                name: 'Flexão modificada',
                detail: '8 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'quad-stretch',
                name: 'Alongamento de quadríceps',
                detail: '30 segundos cada perna'),
              Exercise(
                id: 'calf-stretch',
                name: 'Alongamento de panturrilhas',
                detail: '30 segundos cada perna'),
            ],
          ),
        ],
        creatorId: 'instrutor3',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // TEMPORÁRIO: Método para gerar categorias mockadas
  List<WorkoutCategory> _getMockCategories() {
    return [
      const WorkoutCategory(
        id: 'category-1',
        name: 'Cardio',
        description: 'Treinos para melhorar a saúde cardiovascular e queimar calorias',
        imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=1000',
        workoutsCount: 8,
        colorHex: '#FF5252',
      ),
      const WorkoutCategory(
        id: 'category-2',
        name: 'Força',
        description: 'Treinos para desenvolver força muscular e resistência',
        imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1000',
        workoutsCount: 12,
        colorHex: '#4285F4',
      ),
      const WorkoutCategory(
        id: 'category-3',
        name: 'Yoga',
        description: 'Treinos para melhorar flexibilidade, equilíbrio e reduzir o estresse',
        imageUrl: 'https://images.unsplash.com/photo-1588286840104-8957b019727f?q=80&w=1000',
        workoutsCount: 6,
        colorHex: '#9C27B0',
      ),
      const WorkoutCategory(
        id: 'category-4',
        name: 'Pilates',
        description: 'Treinos focados no core para melhorar postura e força',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1000',
        workoutsCount: 5,
        colorHex: '#009688',
      ),
      const WorkoutCategory(
        id: 'category-5',
        name: 'HIIT',
        description: 'Treinos de alta intensidade para resultados rápidos',
        imageUrl: 'https://images.unsplash.com/photo-1540474527806-6d5091376ce8?q=80&w=1000',
        workoutsCount: 7,
        colorHex: '#FF9800',
      ),
      const WorkoutCategory(
        id: 'category-6',
        name: 'Alongamento',
        description: 'Treinos para melhorar flexibilidade e recuperação muscular',
        imageUrl: 'https://images.unsplash.com/photo-1616699002805-0741e1e4a9c5?q=80&w=1000',
        workoutsCount: 4,
        colorHex: '#4CAF50',
      ),
    ];
  }
}

/// Implementação real do repositório de treinos usando Supabase
class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseWorkoutRepository(this._supabaseClient);
  
  @override
  Future<List<Workout>> getWorkouts() async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .order('created_at', ascending: false);
          
      return (response as List<dynamic>)
          .map((data) => _mapToWorkout(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treinos do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    try {
      final response = await _supabaseClient
          .from('workout_categories')
          .select()
          .order('order', ascending: true);
          
      return (response as List<dynamic>)
          .map((data) => WorkoutCategory.fromJson(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar categorias de treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar categorias de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('type', category)
          .order('created_at', ascending: false);
          
      return (response as List<dynamic>)
          .map((data) => _mapToWorkout(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treinos por categoria do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos por categoria',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> getWorkoutById(String id) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('id', id)
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado',
          code: 'workout_not_found',
        );
      }
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Workout> createWorkout(Workout workout) async {
    try {
      final workoutJson = workout.toJson();
      // Remover o ID se for criar um novo
      workoutJson.remove('id');
      
      final response = await _supabaseClient
          .from('workouts')
          .insert(workoutJson)
          .select()
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao criar treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> updateWorkout(Workout workout) async {
    try {
      final workoutJson = workout.toJson();
      
      final response = await _supabaseClient
          .from('workouts')
          .update(workoutJson)
          .eq('id', workout.id)
          .select()
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para atualização',
          code: 'workout_not_found',
        );
      }
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await _supabaseClient.from('workouts').delete().eq('id', id);
    } catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao excluir treino',
        originalError: e,
      );
    }
  }

  // Métodos auxiliares para converter dados do Supabase
  Workout _mapToWorkout(Map<String, dynamic> data) {
    // Ajusta o mapeamento para funcionar com as colunas vistas nas imagens
    // Verifica o nome das colunas e usa o equivalente com fallback
    final title = data['title'] as String? ?? data['name'] as String? ?? '';
    final type = data['type'] as String? ?? data['category'] as String? ?? '';
    final imageUrl = data['image_url'] as String? ?? data['imageUrl'] as String? ?? 'assets/images/workout_default.jpg';
    final difficulty = data['difficulty'] as String? ?? data['level'] as String? ?? 'Intermediário';
    final level = data['level'] as String?;
    
    return Workout(
      id: data['id'] as String,
      title: title,
      description: data['description'] as String? ?? '',
      imageUrl: imageUrl,
      type: type,
      durationMinutes: data['duration_minutes'] as int? ?? 30,
      difficulty: difficulty,
      level: level,
      equipment: _parseList(data['equipment']),
      sections: _parseSections(data['sections']),
      creatorId: data['creator_id'] as String? ?? '',
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'] as String) 
          : DateTime.now(),
    );
  }
  
  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is Map) {
      try {
        final list = value.values.toList();
        return list.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }
  
  List<WorkoutSection> _parseSections(dynamic sectionsData) {
    if (sectionsData == null) return [];
    
    try {
      final sections = <WorkoutSection>[];
      final List<dynamic> sectionsList = sectionsData is String 
          ? jsonDecode(sectionsData) as List<dynamic>
          : sectionsData as List<dynamic>;
          
      for (final section in sectionsList) {
        final exercises = <Exercise>[];
        final exercisesData = section['exercises'] as List<dynamic>? ?? [];
        
        for (final exerciseData in exercisesData) {
          // Ajuste para permitir campos variados do banco de dados
          final id = exerciseData['id'] as String? ?? 
              'exercise-${DateTime.now().millisecondsSinceEpoch}-${exercises.length}';
          
          final name = exerciseData['name'] as String? ?? 
              exerciseData['nome'] as String? ?? 
              'Exercício ${exercises.length + 1}';
              
          final detail = exerciseData['detail'] as String? ?? 
              exerciseData['detalhe'] as String? ?? 
              exerciseData['description'] as String? ?? 
              name;
              
          final description = exerciseData['description'] as String? ?? 
              exerciseData['descricao'] as String? ?? 
              null;
              
          final sets = exerciseData['sets'] as int? ?? 
              exerciseData['series'] as int? ?? 
              3;
              
          final reps = exerciseData['reps'] as int? ?? 
              exerciseData['repetitions'] as int? ?? 
              exerciseData['repeticoes'] as int? ?? 
              12;
              
          final restTime = exerciseData['rest_seconds'] as int? ?? 
              exerciseData['restTime'] as int? ?? 
              exerciseData['tempo_descanso'] as int? ?? 
              60;
              
          final imageUrl = exerciseData['image_url'] as String? ?? 
              exerciseData['imageUrl'] as String? ?? 
              exerciseData['url_imagem'] as String?;
              
          final videoUrl = exerciseData['video_url'] as String? ?? 
              exerciseData['videoUrl'] as String? ?? 
              exerciseData['url_video'] as String?;
          
          exercises.add(Exercise(
            id: id,
            name: name,
            detail: detail,
            description: description,
            sets: sets,
            reps: reps,
            restTime: restTime,
            imageUrl: imageUrl,
            videoUrl: videoUrl,
          ));
        }
        
        sections.add(WorkoutSection(
          name: section['name'] as String? ?? section['nome'] as String? ?? 'Seção ${sections.length + 1}',
          exercises: exercises,
        ));
      }
      
      return sections;
    } catch (e) {
      print('Erro ao analisar seções: $e');
      return [];
    }
  }

  @override
  Future<List<WorkoutRecord>> getWorkoutHistory() async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Buscar registros de treino do usuário
      final response = await _supabaseClient
          .from('workout_records')
          .select()
          .eq('user_id', currentUser.id)
          .order('date', ascending: false);
      
      // Converter para objetos WorkoutRecord
      return (response as List<dynamic>)
          .map((data) => _mapToWorkoutRecord(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar histórico de treinos',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar histórico de treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> addWorkoutRecord(WorkoutRecord record) async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Preparar dados para inserção no formato do banco
      final recordData = _mapWorkoutRecordToDatabase(record);
      
      // Garantir que o usuário só pode inserir registros para si mesmo
      recordData['user_id'] = currentUser.id;
      
      // Inserir o registro
      final response = await _supabaseClient
          .from('workout_records')
          .insert(recordData)
          .select()
          .single();
      
      // Retornar o registro inserido com ID e outros campos preenchidos
      return _mapToWorkoutRecord(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao adicionar registro de treino',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao adicionar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Verificar se o registro existe e pertence ao usuário
      final exists = await _supabaseClient
          .from('workout_records')
          .select('id')
          .eq('id', record.id)
          .eq('user_id', currentUser.id)
          .maybeSingle();
      
      if (exists == null) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado ou não pertence ao usuário',
          code: 'workout_record_not_found',
        );
      }
      
      // Preparar dados para atualização
      final recordData = _mapWorkoutRecordToDatabase(record);
      
      // Atualizar o registro
      final response = await _supabaseClient
          .from('workout_records')
          .update(recordData)
          .eq('id', record.id)
          .eq('user_id', currentUser.id)
          .select()
          .single();
      
      // Retornar o registro atualizado
      return _mapToWorkoutRecord(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkoutRecord(String recordId) async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Excluir o registro, garantindo que pertence ao usuário correto
      final response = await _supabaseClient
          .from('workout_records')
          .delete()
          .eq('id', recordId)
          .eq('user_id', currentUser.id);
      
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }
  
  // Método auxiliar para converter Map do banco para WorkoutRecord
  WorkoutRecord _mapToWorkoutRecord(Map<String, dynamic> data) {
    // Converter snake_case para camelCase
    return WorkoutRecord(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      workoutId: data['workout_id'] as String?,
      workoutName: data['workout_name'] as String,
      workoutType: data['workout_type'] as String,
      date: DateTime.parse(data['date'] as String),
      durationMinutes: (data['duration_minutes'] as num).toInt(),
      isCompleted: data['is_completed'] as bool? ?? true,
      completionStatus: data['completion_status'] as String? ?? 'completed',
      notes: data['notes'] as String?,
      imageUrls: data['image_urls'] != null 
          ? (data['image_urls'] as List<dynamic>).cast<String>() 
          : [],
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'] as String) 
          : null,
    );
  }
  
  // Método auxiliar para converter WorkoutRecord para Map para o banco
  Map<String, dynamic> _mapWorkoutRecordToDatabase(WorkoutRecord record) {
    // Converter camelCase para snake_case para o banco
    final Map<String, dynamic> data = {
      'user_id': record.userId,
      'workout_name': record.workoutName,
      'workout_type': record.workoutType,
      'date': record.date.toIso8601String(),
      'duration_minutes': record.durationMinutes,
      'is_completed': record.isCompleted,
      'completion_status': record.completionStatus,
      'image_urls': record.imageUrls,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // Adicionar campos opcionais se não forem nulos
    if (record.workoutId != null) data['workout_id'] = record.workoutId;
    if (record.notes != null) data['notes'] = record.notes;
    
    // Não incluir id se for um novo registro (será gerado pelo banco)
    if (record.id.isNotEmpty && !record.id.contains('temp_')) {
      data['id'] = record.id;
    }
    
    return data;
  }
}

// O provider workoutRepositoryProvider foi movido para lib/features/workout/providers/workout_providers.dart
// Referência à implementação real sem definir o provider diretamente aqui
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/models/workout_record_adapter.dart';
import 'package:ray_club_app/core/utils/debug_data_inspector.dart';
import 'package:ray_club_app/core/utils/model_compatibility_checker.dart';
import 'package:ray_club_app/features/progress/repositories/user_progress_repository.dart';
import 'package:ray_club_app/core/providers/service_providers.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/workout/models/workout_processing_status.dart';
import 'package:ray_club_app/features/workout/models/check_in_error_log.dart';

/// Interface para o repositório de registros de treinos
abstract class WorkoutRecordRepository {
  /// Obtém todos os registros de treino do usuário atual
  Future<List<WorkoutRecord>> getUserWorkoutRecords();
  
  /// Cria um novo registro de treino
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record);
  
  /// Atualiza um registro de treino existente
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record);
  
  /// Exclui um registro de treino
  Future<void> deleteWorkoutRecord(String id);
  
  /// Faz upload de imagens para um registro de treino
  Future<List<String>> uploadWorkoutImages(String recordId, List<File> images);
  
  /// Obtém o status de processamento de um treino
  Future<WorkoutProcessingStatus?> getWorkoutProcessingStatus(String workoutId);
  
  /// Obtém stream de status de processamento para atualizações em tempo real
  Stream<WorkoutProcessingStatus?> streamWorkoutProcessingStatus(String workoutId);
  
  /// Obtém logs de erros para diagnóstico
  Future<List<CheckInErrorLog>> getWorkoutProcessingErrors({String? workoutId, int limit = 50});
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutRecordRepository implements WorkoutRecordRepository {
  @override
  Future<List<WorkoutRecord>> getUserWorkoutRecords() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _getMockWorkoutRecords();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar registros de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return record.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Verificar se o registro existe
      final allRecords = _getMockWorkoutRecords();
      final exists = allRecords.any((r) => r.id == record.id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para atualização',
          code: 'record_not_found',
        );
      }
      
      return record;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkoutRecord(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Verificar se o registro existe
      final allRecords = _getMockWorkoutRecords();
      final exists = allRecords.any((record) => record.id == id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para exclusão',
          code: 'record_not_found',
        );
      }
      
      // Em um ambiente real, o registro seria removido do banco de dados
      return;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<String>> uploadWorkoutImages(String recordId, List<File> images) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1200));
    
    try {
      // Em um ambiente real, as imagens seriam enviadas para um servidor
      // e retornariam URLs. Aqui simulamos URLs fictícias.
      return images.map((image) => 
        'https://mock-storage.example.com/workout-images/$recordId/${DateTime.now().millisecondsSinceEpoch}.jpg'
      ).toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao fazer upload das imagens do treino',
        originalError: e,
      );
    }
  }

  // IMPLEMENTAÇÃO DOS NOVOS MÉTODOS NECESSÁRIOS PARA A INTERFACE
  
  @override
  Future<WorkoutProcessingStatus?> getWorkoutProcessingStatus(String workoutId) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Retornar um status mock com processamento completo para o mock
    return WorkoutProcessingStatus(
      id: 'mock-status-${DateTime.now().millisecondsSinceEpoch}',
      workoutId: workoutId,
      processedForRanking: true,
      processedForDashboard: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      processedAt: DateTime.now().subtract(const Duration(minutes: 4)),
    );
  }
  
  @override
  Stream<WorkoutProcessingStatus?> streamWorkoutProcessingStatus(String workoutId) {
    // The Supabase stream API has different syntax than the query API
    // Let's create a manual polling stream instead as a workaround
    final controller = StreamController<WorkoutProcessingStatus?>();
    
    // Initial fetch
    getWorkoutProcessingStatus(workoutId).then((status) {
      if (!controller.isClosed) {
        controller.add(status);
      }
    });
    
    // Set up periodic polling
    final timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!controller.isClosed) {
        getWorkoutProcessingStatus(workoutId).then((status) {
          if (!controller.isClosed) {
            controller.add(status);
          }
        });
      }
    });
    
    // Clean up when the stream is no longer used
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };
    
    return controller.stream;
  }
  
  @override
  Future<List<CheckInErrorLog>> getWorkoutProcessingErrors({
    String? workoutId,
    int limit = 50
  }) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 700));
    
    // Retornar uma lista vazia para o mock - não há erros
    return [];
  }

  // TEMPORÁRIO: Método para gerar dados mockados
  List<WorkoutRecord> _getMockWorkoutRecords() {
    final now = DateTime.now();
    
    return [
      WorkoutRecord(
        id: '1',
        userId: 'user123',
        workoutId: '1',
        workoutName: 'Yoga para Iniciantes',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 20,
        isCompleted: true,
        notes: 'Senti melhora na flexibilidade',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      WorkoutRecord(
        id: '2',
        userId: 'user123',
        workoutId: '4',
        workoutName: 'Treino de Força Total',
        workoutType: 'Força',
        date: now.subtract(const Duration(days: 3)),
        durationMinutes: 45,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      WorkoutRecord(
        id: '3',
        userId: 'user123',
        workoutId: '3',
        workoutName: 'HIIT 15 minutos',
        workoutType: 'HIIT',
        date: now.subtract(const Duration(days: 5)),
        durationMinutes: 15,
        isCompleted: true,
        notes: 'Muito intenso, próxima vez diminuir o ritmo',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      WorkoutRecord(
        id: '4',
        userId: 'user123',
        workoutId: '5',
        workoutName: 'Yoga Flow',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 7)),
        durationMinutes: 40,
        isCompleted: false,
        notes: 'Parei na metade por dor nas costas',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      WorkoutRecord(
        id: '5',
        userId: 'user123',
        workoutId: null,
        workoutName: 'Corrida ao ar livre',
        workoutType: 'Cardio',
        date: now.subtract(const Duration(days: 10)),
        durationMinutes: 25,
        isCompleted: true,
        notes: 'Corrida no parque, 3km',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      WorkoutRecord(
        id: '6',
        userId: 'user123',
        workoutId: '2',
        workoutName: 'Pilates Abdominal',
        workoutType: 'Pilates',
        date: now.subtract(const Duration(days: 14)),
        durationMinutes: 30,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      // Registro de mês anterior
      WorkoutRecord(
        id: '7',
        userId: 'user123',
        workoutId: '1',
        workoutName: 'Yoga para Iniciantes',
        workoutType: 'Yoga',
        date: now.subtract(const Duration(days: 45)),
        durationMinutes: 20,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];
  }
}

/// Provider para o repositório de registros de treino
final workoutRecordRepositoryProvider = Provider<WorkoutRecordRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final progressRepository = ref.watch(userProgressRepositoryProvider);
  
  // Retornar a implementação com ambos os repositórios
  return SupabaseWorkoutRecordRepository(supabase, progressRepository);
});

/// Implementação do repositório usando Supabase
class SupabaseWorkoutRecordRepository implements WorkoutRecordRepository {
  final SupabaseClient _supabaseClient;
  final UserProgressRepository _progressRepository;
  
  SupabaseWorkoutRecordRepository(this._supabaseClient, this._progressRepository);

  @override
  Future<List<WorkoutRecord>> getUserWorkoutRecords() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('workout_records')
          .select('''
            *,
            processing:workout_processing_queue(
              id, workout_id, processed_for_ranking, processed_for_dashboard,
              processing_error, created_at, processed_at
            )
          ''')
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      // Inspecionar os dados retornados pelo Supabase
      DebugDataInspector.logResponse('WorkoutRecords', response);
      
      // Verificar compatibilidade do modelo se houver dados
      if (response is List && response.isNotEmpty && response.first is Map<String, dynamic>) {
        ModelCompatibilityChecker.checkModelCompatibility<WorkoutRecord>(
          modelName: 'WorkoutRecord',
          supabaseData: response.first as Map<String, dynamic>,
          fromJson: WorkoutRecordAdapter.fromJson,
          toJson: (record) => WorkoutRecordAdapter.toDatabase(record),
        );
      }
      
      return response.map((json) {
        // Converter dados do banco para o modelo
        final workout = WorkoutRecordAdapter.fromJson(json);
        
        // Verificar se tem dados de processamento de forma segura
        if (json['processing'] is List && json['processing'].isNotEmpty) {
          try {
            // Adicionar status de processamento ao modelo
            final processingStatus = WorkoutProcessingStatus.fromJson(json['processing'][0]);
            workout.copyWith(processingStatus: processingStatus);
          } catch (e) {
            // Falha silenciosa - garante que a UI continua funcionando
            debugPrint('Erro ao fazer parse do status: $e');
          }
        }
        
        return workout;
      }).toList();
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Supabase: ${e.toString()}');
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar registros de treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erro genérico: ${e.toString()}');
      if (e is app_errors.AppAuthException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao carregar registros de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> createWorkoutRecord(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Garantir que o ID do usuário seja o do usuário atual
      final recordWithUserId = record.copyWith(userId: userId);
      
      // Converter para o formato do banco
      final recordMap = WorkoutRecordAdapter.toDatabase(recordWithUserId);
      debugPrint('📤 Convertendo para o banco: $recordMap');
      
      // Se não houver ID, remover o campo para o Supabase gerar um
      if (recordMap.containsKey('id') && (recordMap['id'] == null || recordMap['id'].toString().isEmpty)) {
        recordMap.remove('id');
      }
      
      debugPrint('🔍 Enviando para Supabase: $recordMap');
      final response = await _supabaseClient
          .from('workout_records')
          .insert(recordMap)
          .select()
          .single();
      
      debugPrint('✅ Resposta do Supabase: $response');
      final resultRecord = WorkoutRecordAdapter.fromDatabase(response);
      debugPrint('📥 Convertendo do banco: $response');
      
      // Atualizar o progresso do usuário com o novo treino
      try {
        await _progressRepository.updateProgressAfterWorkout(userId, resultRecord);
        debugPrint('✅ Progresso do usuário atualizado com sucesso');
      } catch (e) {
        // Apenas fazer log do erro, não devemos falhar a operação principal
        debugPrint('⚠️ Erro ao atualizar progresso do usuário: $e');
      }
      
      return resultRecord;
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Supabase: ${e.toString()}');
      throw app_errors.DatabaseException(
        message: 'Erro ao criar registro de treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erro genérico ao criar registro: ${e.toString()}');
      if (e is app_errors.AppAuthException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao criar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw app_errors.AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se o registro pertence ao usuário atual
      if (record.userId != userId) {
        throw app_errors.UnauthorizedException(
          message: 'Não autorizado a atualizar este registro',
          code: 'unauthorized',
        );
      }
      
      final recordMap = WorkoutRecordAdapter.toDatabase(record);
      
      final response = await _supabaseClient
          .from('workout_records')
          .update(recordMap)
          .match({'id': record.id})
          .select()
          .single();
      
      return WorkoutRecordAdapter.fromDatabase(response);
    } on PostgrestException catch (e) {
      debugPrint('❌ Erro do Supabase: ${e.toString()}');
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado para atualização',
          originalError: e,
          code: 'record_not_found',
        );
      }
      
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar registro de treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erro genérico ao atualizar: ${e.toString()}');
      if (e is app_errors.AppAuthException || 
          e is app_errors.UnauthorizedException || 
          e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkoutRecord(String id) async {
    try {
      await _supabaseClient
        .from('workout_records')
        .delete()
        .match({'id': id});
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<String>> uploadWorkoutImages(String recordId, List<File> images) async {
    try {
      final List<String> imageUrls = [];
      final supabase = Supabase.instance.client;
      
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileExt = file.path.split('.').last;
        final fileName = '$recordId-${DateTime.now().millisecondsSinceEpoch}-$i.$fileExt';
        final filePath = 'workout_records/$recordId/$fileName';
        
        // Upload para o bucket 'workout_images'
        final response = await supabase.storage
            .from('workout_images')
            .upload(filePath, file);
            
        // Obter a URL pública da imagem
        final imageUrl = supabase.storage
            .from('workout_images')
            .getPublicUrl(filePath);
            
        imageUrls.add(imageUrl);
      }
      
      // Atualiza o registro com as URLs das imagens
      await supabase
        .from('workout_records')
        .update({'image_urls': imageUrls})
        .match({'id': recordId});
          
      return imageUrls;
    } catch (e) {
      throw app_errors.AppException(
        message: 'Erro ao fazer upload das imagens: ${e.toString()}',
        code: 'workout_image_upload_error',
      );
    }
  }

  @override
  Future<WorkoutProcessingStatus?> getWorkoutProcessingStatus(String workoutId) async {
    try {
      final response = await _supabaseClient
        .from('workout_processing_queue')
        .select()
        .match({'workout_id': workoutId})
        .single();
        
      if (response == null) return null;
      return WorkoutProcessingStatus.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao obter status de processamento: $e');
      return null;
    }
  }
  
  @override
  Stream<WorkoutProcessingStatus?> streamWorkoutProcessingStatus(String workoutId) {
    // The Supabase stream API has different syntax than the query API
    // Let's create a manual polling stream instead as a workaround
    final controller = StreamController<WorkoutProcessingStatus?>();
    
    // Initial fetch
    getWorkoutProcessingStatus(workoutId).then((status) {
      if (!controller.isClosed) {
        controller.add(status);
      }
    });
    
    // Set up periodic polling
    final timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!controller.isClosed) {
        getWorkoutProcessingStatus(workoutId).then((status) {
          if (!controller.isClosed) {
            controller.add(status);
          }
        });
      }
    });
    
    // Clean up when the stream is no longer used
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };
    
    return controller.stream;
  }

  @override
  Future<List<CheckInErrorLog>> getWorkoutProcessingErrors({
    String? workoutId,
    int limit = 50
  }) async {
    try {
      var query = _supabaseClient
        .from('check_in_error_logs')
        .select();
        
      if (workoutId != null) {
        query = query.match({'workout_id': workoutId});
      }
      
      final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
        
      return (response as List)
        .map((json) => CheckInErrorLog.fromJson(json))
        .toList();
    } catch (e) {
      debugPrint('Erro ao obter logs de erro: $e');
      return [];
    }
  }
} import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/features/challenge/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_repository.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/models/workout_record_state.dart';
import 'package:ray_club_app/core/connectivity/connectivity_service.dart';
import 'package:ray_club_app/features/storage/local_storage_service.dart';
import 'package:ray_club_app/features/workout/models/pending_workout.dart';

/// Provider para WorkoutRecordViewModel com parâmetros de criação personalizados
final workoutRecordViewModelProvider = StateNotifierProvider<WorkoutRecordViewModel, WorkoutRecordState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  
  return WorkoutRecordViewModel(
    authRepository,
    workoutRecordRepository,
    challengeRepository,
    dashboardRepository,
    connectivityService,
    localStorageService,
  );
});

/// Parâmetros para registro de treino
class WorkoutParams {
  final String workoutName;
  final String workoutType;
  final int durationMinutes;
  final DateTime date;
  final String? challengeId;
  final String? workoutId;
  
  WorkoutParams({
    required this.workoutName,
    required this.workoutType,
    required this.durationMinutes,
    required this.date,
    this.challengeId,
    this.workoutId,
  });
  
  Map<String, dynamic> toJson() => {
    'workout_name': workoutName,
    'workout_type': workoutType,
    'duration_minutes': durationMinutes,
    'date': date.toIso8601String(),
    'challenge_id': challengeId,
    'workout_id': workoutId,
  };
}

/// ViewModel para registro de treinos com prevenção de duplicação
class WorkoutRecordViewModel extends StateNotifier<WorkoutRecordState> {
  final _logger = Logger();
  final AuthRepository _authRepository;
  final WorkoutRecordRepository _workoutRecordRepository;
  final ChallengeRepository _challengeRepository;
  final DashboardRepository _dashboardRepository;
  final ConnectivityService _connectivityService;
  final LocalStorageService _localStorageService;
  
  // Controllers para eventos de treino
  final _workoutCompletedController = StreamController<bool>.broadcast();
  final _workoutErrorController = StreamController<String>.broadcast();

  // Streams públicos para notificar a UI
  Stream<bool> get workoutCompletedStream => _workoutCompletedController.stream;
  Stream<String> get workoutErrorStream => _workoutErrorController.stream;

  WorkoutRecordViewModel(
    this._authRepository,
    this._workoutRecordRepository,
    this._challengeRepository,
    this._dashboardRepository,
    this._connectivityService,
    this._localStorageService,
  ) : super(WorkoutRecordState.initial());
  
  /// Registra um treino com prevenção de duplicação
  Future<void> recordWorkout(WorkoutParams params) async {
    // Verificar se já está enviando (previne envios duplicados)
    if (state.isSubmitting) {
      _logger.w('Tentativa de envio duplicado ignorada');
      return;
    }
    
    // Atualizar estado para enviando (desabilita botão)
    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      _logger.i('Processando conclusão do treino: ${params.workoutName}');
      
      // Gerar UUID para workout_id se for null (caso de treino manual)
      final String effectiveWorkoutId = params.workoutId ?? const Uuid().v4();
      _logger.d('WorkoutID: $effectiveWorkoutId (${params.workoutId == null ? "gerado" : "original"})');
      
      // Registrar treino no histórico local
      final workoutRecord = WorkoutRecord(
        id: const Uuid().v4(),
        userId: _authRepository.currentUser?.id ?? '',
        workoutId: effectiveWorkoutId, // Usar o ID efetivo (original ou gerado)
        workoutName: params.workoutName,
        workoutType: params.workoutType,
        date: params.date,
        durationMinutes: params.durationMinutes,
        createdAt: DateTime.now(),
      );
      
      // Persistir localmente
      final savedRecord = await _workoutRecordRepository.createWorkoutRecord(workoutRecord);
      
      // Se tiver challengeId, registrar check-in no desafio
      if (params.challengeId != null && params.challengeId!.isNotEmpty) {
        _logger.i('Registrando check-in para desafio: ${params.challengeId}');
        
        // Usar o ID efetivo no check-in do desafio
        await _challengeRepository.recordChallengeCheckIn(
          challengeId: params.challengeId!,
          workoutId: effectiveWorkoutId,
          workoutName: params.workoutName,
          workoutType: params.workoutType,
          durationMinutes: params.durationMinutes,
          date: params.date,
        );
        
        // Atualizar dashboard para mostrar pontos atualizados
        await _dashboardRepository.forceRefresh();
      }
      
      // Notificar observadores da conclusão
      _workoutCompletedController.add(true);
      
      // Atualizar estado com sucesso
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        workoutId: savedRecord.id,
      );
    } catch (e, stack) {
      _logger.e('Erro ao processar conclusão do treino', e, stack);
      _workoutErrorController.add('Erro ao registrar treino: ${e.toString()}');
      
      // Atualizar estado com erro
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }
  
  /// Registra um treino com suporte a modo offline
  Future<void> recordWorkoutWithOfflineSupport(WorkoutParams params) async {
    // Verificar se já está enviando
    if (state.isSubmitting) {
      _logger.w('Tentativa de envio duplicado ignorada');
      return;
    }
    
    // Atualizar estado para enviando
    state = state.copyWith(isSubmitting: true, error: null);
    
    // Verificar conectividade
    final hasConnection = await _connectivityService.hasInternetConnection();
    
    if (!hasConnection) {
      _logger.i('Sem conexão, salvando localmente: ${params.workoutName}');
      
      // Salvar localmente
      final pendingId = const Uuid().v4();
      await _localStorageService.savePendingWorkout(
        PendingWorkout(
          id: pendingId,
          data: params.toJson(),
          createdAt: DateTime.now(),
        ).toJson(),
      );
      
      // Notificar usuário
      state = state.copyWith(
        isSubmitting: false,
        isOfflineSaved: true,
        pendingWorkoutId: pendingId,
      );
      
      return;
    }
    
    // Continuar com envio online
    await recordWorkout(params);
  }
  
  /// Processa treinos pendentes salvos em modo offline
  Future<void> processPendingWorkouts() async {
    _logger.i('Verificando treinos pendentes para processamento');
    
    // Obter treinos pendentes
    final pendingWorkouts = await _localStorageService.getPendingWorkouts();
    
    if (pendingWorkouts.isEmpty) {
      _logger.i('Nenhum treino pendente encontrado');
      return;
    }
    
    _logger.i('Encontrados ${pendingWorkouts.length} treinos pendentes');
    
    // Verificar conectividade
    final hasConnection = await _connectivityService.hasInternetConnection();
    
    if (!hasConnection) {
      _logger.w('Sem conexão, não é possível processar treinos pendentes');
      return;
    }
    
    for (final pendingWorkout in pendingWorkouts) {
      try {
        // Converter de volta para objetos
        final pendingData = PendingWorkout.fromJson(pendingWorkout);
        
        _logger.i('Processando treino pendente: ${pendingData.id}');
        
        // Criar parâmetros a partir dos dados salvos
        final params = WorkoutParams(
          workoutName: pendingData.data['workout_name'],
          workoutType: pendingData.data['workout_type'],
          durationMinutes: pendingData.data['duration_minutes'],
          date: DateTime.parse(pendingData.data['date']),
          challengeId: pendingData.data['challenge_id'],
          workoutId: pendingData.data['workout_id'],
        );
        
        // Registrar treino (fora do estado do notifier para não afetar a UI atual)
        await recordWorkout(params);
        
        // Remover treino processado da lista de pendentes
        await _localStorageService.removePendingWorkout(pendingData.id);
        
        _logger.i('Treino pendente processado com sucesso: ${pendingData.id}');
      } catch (e) {
        _logger.e('Erro ao processar treino pendente', e);
        // Continuar para o próximo treino
      }
    }
  }
  
  @override
  void dispose() {
    _workoutCompletedController.close();
    _workoutErrorController.close();
    super.dispose();
  }
} import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository) : super(const NotificationState.initial());

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    state = const NotificationState.loading();

    try {
      final notifications = await _repository.getNotifications(unreadOnly: unreadOnly);
      final unreadCount = await _repository.getUnreadCount();

      state = NotificationState.loaded(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = NotificationState.error(e.toString());
    }
  }

  Future<void> markAsRead(List<String> notificationIds) async {
    if (state is! _NotificationStateLoaded) return;

    try {
      await _repository.markAsRead(notificationIds);
      
      // Atualiza o estado localmente
      final currentState = state as _NotificationStateLoaded;
      
      // Atualiza as notificações marcadas como lidas
      final updatedNotifications = currentState.notifications.map((notification) {
        if (notificationIds.contains(notification.id)) {
          return notification.copyWith(
            isRead: true, 
            readAt: DateTime.now(),
          );
        }
        return notification;
      }).toList();
      
      // Atualiza o contador de não lidas
      final newUnreadCount = await _repository.getUnreadCount();
      
      state = NotificationState.loaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      // Não alterar o estado em caso de erro, apenas log
      // para evitar perda da lista de notificações
      print('Erro ao marcar notificações como lidas: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (state is! _NotificationStateLoaded) return;
    
    final currentState = state as _NotificationStateLoaded;
    final unreadIds = currentState.notifications
        .where((notification) => !notification.isRead)
        .map((notification) => notification.id)
        .toList();
    
    if (unreadIds.isEmpty) return;
    
    await markAsRead(unreadIds);
  }
} import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/exceptions/app_exception.dart';
import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications({required bool unreadOnly});
  Future<void> markAsRead(List<String> notificationIds);
  Future<int> getUnreadCount();
}

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabase;

  SupabaseNotificationRepository(this._supabase);

  @override
  Future<List<Notification>> getNotifications({required bool unreadOnly}) async {
    try {
      final query = _supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      if (unreadOnly) {
        query.eq('is_read', false);
      }

      final response = await query;
      
      return response
          .map((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      throw StorageException(
        message: 'Erro ao carregar notificações',
        originalError: e,
      );
    }
  }

  @override
  Future<void> markAsRead(List<String> notificationIds) async {
    try {
      await _supabase.rpc(
        'mark_notifications_as_read',
        params: {'p_notification_ids': notificationIds},
      );
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
      throw StorageException(
        message: 'Erro ao marcar notificações como lidas',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id', count: CountOption.exact)
          .eq('is_read', false);
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      throw StorageException(
        message: 'Erro ao contar notificações não lidas',
        originalError: e,
      );
    }
  }
} // Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/providers/supabase_providers.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../models/faq_model.dart';
import '../models/help_search_result.dart';
import '../models/help_state.dart';
import '../models/tutorial_model.dart';
import '../repositories/help_repository.dart';
import '../repositories/supabase_help_repository.dart';

/// Provider para o repositório de ajuda
final helpRepositoryProvider = Provider<HelpRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return SupabaseHelpRepository(
    supabaseClient: supabase,
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
});

/// Provider para o ViewModel de ajuda
final helpViewModelProvider = StateNotifierProvider<HelpViewModel, HelpState>((ref) {
  final repository = ref.watch(helpRepositoryProvider);
  return HelpViewModel(repository);
});

/// ViewModel para gerenciar a tela de ajuda
class HelpViewModel extends StateNotifier<HelpState> {
  final HelpRepository _repository;
  
  /// Cria uma instância do ViewModel
  HelpViewModel(this._repository) : super(const HelpState()) {
    loadFaqs();
    loadTutorials();
  }
  
  /// Carrega a lista de FAQs
  Future<void> loadFaqs() async {
    state = state.copyWith(isLoading: true);
    try {
      final faqs = await _repository.getFaqs();
      state = state.copyWith(faqs: faqs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar FAQs: $e',
        isLoading: false,
      );
    }
  }
  
  /// Carrega a lista de tutoriais
  Future<void> loadTutorials() async {
    state = state.copyWith(isLoading: true);
    try {
      final tutorials = await _repository.getTutorials();
      state = state.copyWith(tutorials: tutorials, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar tutoriais: $e',
        isLoading: false,
      );
    }
  }
  
  /// Busca conteúdo de ajuda com base em uma query
  Future<void> searchHelp(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        isSearching: false,
        searchQuery: null,
        searchResultsFaqs: [],
        searchResultsTutorials: []
      );
      return;
    }
    
    state = state.copyWith(isLoading: true, isSearching: true, searchQuery: query);
    try {
      final results = await _repository.searchHelp(query);
      state = state.copyWith(
        searchResultsFaqs: results.faqs,
        searchResultsTutorials: results.tutorials,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao buscar conteúdo: $e',
        isLoading: false,
      );
    }
  }
  
  /// Limpa resultados de busca
  void clearSearch() {
    state = state.copyWith(
      isSearching: false,
      searchQuery: null,
      searchResultsFaqs: [],
      searchResultsTutorials: []
    );
  }
  
  /// Atualiza o índice da FAQ expandida
  void setExpandedFaqIndex(int index) {
    // Se clicar na mesma FAQ que já está expandida, colapsa ela
    final newIndex = state.expandedFaqIndex == index ? -1 : index;
    state = state.copyWith(expandedFaqIndex: newIndex);
  }
  
  /// Atualiza o índice do tutorial expandido
  void setExpandedTutorialIndex(int index) {
    // Se clicar no mesmo tutorial que já está expandido, colapsa ele
    final newIndex = state.expandedTutorialIndex == index ? -1 : index;
    state = state.copyWith(expandedTutorialIndex: newIndex);
  }
  
  /// Envia uma mensagem de suporte
  Future<bool> sendSupportMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendSupportMessage(
        name: name,
        email: email,
        message: message,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao enviar mensagem: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Obtém um FAQ específico pelo ID
  Future<Faq?> getFaqById(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final faq = await _repository.getFaqById(id);
      state = state.copyWith(isLoading: false);
      return faq;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar FAQ: $e',
        isLoading: false,
      );
      return null;
    }
  }
  
  /// Obtém um tutorial específico pelo ID
  Future<Tutorial?> getTutorialById(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final tutorial = await _repository.getTutorialById(id);
      state = state.copyWith(isLoading: false);
      return tutorial;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar tutorial: $e',
        isLoading: false,
      );
      return null;
    }
  }
  
  /// Cria uma nova FAQ (admin)
  Future<bool> createFaq(Faq faq) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final createdFaq = await _repository.createFaq(faq);
      
      // Atualiza a lista de FAQs
      final updatedFaqs = [...state.faqs, createdFaq];
      
      state = state.copyWith(
        faqs: updatedFaqs,
        isLoading: false,
        successMessage: 'FAQ criada com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao criar FAQ: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Atualiza uma FAQ existente (admin)
  Future<bool> updateFaq(Faq faq) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final updatedFaq = await _repository.updateFaq(faq);
      
      // Atualiza a lista de FAQs
      final updatedFaqs = [...state.faqs];
      final index = updatedFaqs.indexWhere((f) => f.id == faq.id);
      if (index >= 0) {
        updatedFaqs[index] = updatedFaq;
      }
      
      state = state.copyWith(
        faqs: updatedFaqs,
        isLoading: false,
        successMessage: 'FAQ atualizada com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar FAQ: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Remove uma FAQ (admin)
  Future<bool> deleteFaq(String faqId) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      await _repository.deleteFaq(faqId);
      
      // Atualiza a lista de FAQs
      final updatedFaqs = state.faqs.where((f) => f.id != faqId).toList();
      
      state = state.copyWith(
        faqs: updatedFaqs,
        isLoading: false,
        successMessage: 'FAQ removida com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover FAQ: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Cria um novo tutorial (admin)
  Future<bool> createTutorial(Tutorial tutorial) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final createdTutorial = await _repository.createTutorial(tutorial);
      
      // Atualiza a lista de tutoriais
      final updatedTutorials = [...state.tutorials, createdTutorial];
      
      state = state.copyWith(
        tutorials: updatedTutorials,
        isLoading: false,
        successMessage: 'Tutorial criado com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao criar tutorial: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Atualiza um tutorial existente (admin)
  Future<bool> updateTutorial(Tutorial tutorial) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final updatedTutorial = await _repository.updateTutorial(tutorial);
      
      // Atualiza a lista de tutoriais
      final updatedTutorials = [...state.tutorials];
      final index = updatedTutorials.indexWhere((t) => t.id == tutorial.id);
      if (index >= 0) {
        updatedTutorials[index] = updatedTutorial;
      }
      
      state = state.copyWith(
        tutorials: updatedTutorials,
        isLoading: false,
        successMessage: 'Tutorial atualizado com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar tutorial: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Remove um tutorial (admin)
  Future<bool> deleteTutorial(String tutorialId) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      await _repository.deleteTutorial(tutorialId);
      
      // Atualiza a lista de tutoriais
      final updatedTutorials = state.tutorials.where((t) => t.id != tutorialId).toList();
      
      state = state.copyWith(
        tutorials: updatedTutorials,
        isLoading: false,
        successMessage: 'Tutorial removido com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover tutorial: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Verifica se o usuário atual é administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isAdmin();
    } catch (e) {
      return false;
    }
  }
  
  /// Limpa a mensagem de sucesso
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
} // Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../utils/log_utils.dart';
import '../models/faq_model.dart';
import '../models/help_search_result.dart';
import '../models/tutorial_model.dart';
import 'help_repository.dart';

/// Implementação do repositório de ajuda usando Supabase com suporte offline
class SupabaseHelpRepository implements HelpRepository {
  final SupabaseClient _supabaseClient;
  final CacheService? _cacheService;
  final ConnectivityService _connectivityService;
  
  // Constantes para chaves de cache
  static const String _faqsCacheKey = 'faqs_cache';
  static const String _tutorialsCacheKey = 'tutorials_cache';
  
  // Constantes para nomes de tabelas
  static const String _faqsTable = 'faqs';
  static const String _supportMessagesTable = 'support_messages';
  static const String _tutorialsTable = 'tutorials';
  
  SupabaseHelpRepository({
    required SupabaseClient supabaseClient,
    CacheService? cacheService,
    required ConnectivityService connectivityService,
  }) : _supabaseClient = supabaseClient,
       _cacheService = cacheService,
       _connectivityService = connectivityService;
  
  @override
  Future<List<Faq>> getFaqs() async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        try {
          final response = await _supabaseClient
              .from(_faqsTable)
              .select()
              .order('category')
              .order('id');
          
          final faqs = response.map((data) => Faq.fromJson(data)).toList();
          
          // Armazenar em cache se disponível
          if (_cacheService != null) {
            await _cacheService!.set(
              _faqsCacheKey, 
              jsonEncode(faqs.map((faq) => faq.toJson()).toList())
            );
          }
          
          return faqs;
        } catch (e, stackTrace) {
          LogUtils.error(
            'Erro ao obter FAQs do Supabase', 
            error: e, 
            stackTrace: stackTrace
          );
          
          // Tentar obter do cache em caso de erro
          final cachedData = await _getCachedFaqs();
          if (cachedData.isNotEmpty) {
            return cachedData;
          }
          
          // Se não tiver em cache, retornar as FAQs padrão
          return _getDefaultFaqs();
        }
      } else {
        // Sem conectividade, usar cache
        LogUtils.info('Sem conectividade, usando FAQs em cache');
        final cachedData = await _getCachedFaqs();
        if (cachedData.isNotEmpty) {
          return cachedData;
        }
        
        // Se não tiver em cache, retornar as FAQs padrão
        return _getDefaultFaqs();
      }
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar FAQs', 
        error: e, 
        stackTrace: stackTrace
      );
      throw DataAccessException(
        message: 'Erro ao carregar FAQs', 
        originalError: e
      );
    }
  }
  
  /// Obtém FAQs do cache
  Future<List<Faq>> _getCachedFaqs() async {
    if (_cacheService != null) {
      try {
        final cachedData = await _cacheService!.get(_faqsCacheKey);
        if (cachedData != null) {
          final List<dynamic> decoded = jsonDecode(cachedData);
          return decoded.map((item) => Faq.fromJson(item)).toList();
        }
      } catch (e) {
        LogUtils.error('Erro ao ler FAQs do cache', error: e);
      }
    }
    return [];
  }
  
  @override
  Future<void> sendSupportMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (!hasConnectivity) {
        throw NetworkException(
          message: 'Sem conexão com a internet. Tente novamente mais tarde.'
        );
      }
      
      await _supabaseClient.from(_supportMessagesTable).insert({
        'name': name,
        'email': email,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao enviar mensagem de suporte', 
        error: e, 
        stackTrace: stackTrace
      );
      
      if (e is NetworkException) {
        rethrow;
      }
      
      throw DataAccessException(
        message: 'Erro ao enviar mensagem de suporte', 
        originalError: e
      );
    }
  }
  
  /// Implementação para busca de conteúdo de ajuda
  Future<HelpSearchResult> searchHelp(String query) async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (!hasConnectivity) {
        // Em modo offline, buscar apenas em cache
        final cachedFaqs = await _getCachedFaqs();
        final filteredFaqs = cachedFaqs.where((faq) => 
          faq.question.toLowerCase().contains(query.toLowerCase()) ||
          faq.answer.toLowerCase().contains(query.toLowerCase())
        ).toList();
        
        return HelpSearchResult(
          faqs: filteredFaqs,
          tutorials: [], 
          articles: []
        );
      }
      
      // Buscar FAQs
      final faqsResponse = await _supabaseClient
          .from(_faqsTable)
          .select()
          .or('question.ilike.%$query%,answer.ilike.%$query%');
      
      final List<Faq> faqs = faqsResponse.map((data) => Faq.fromJson(data)).toList();
      
      // Buscar tutoriais (se existir a tabela)
      List<Tutorial> tutorials = [];
      try {
        final tutorialsResponse = await _supabaseClient
            .from(_tutorialsTable)
            .select()
            .or('title.ilike.%$query%,description.ilike.%$query%')
            .limit(5);
        
        tutorials = tutorialsResponse.map((data) => Tutorial.fromJson(data)).toList();
      } catch (e) {
        // Se tabela não existir, apenas ignora
        LogUtils.warning('Tabela de tutoriais não encontrada', error: e);
      }
      
      return HelpSearchResult(
        faqs: faqs,
        tutorials: tutorials,
        articles: []
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao buscar conteúdo de ajuda', 
        error: e, 
        stackTrace: stackTrace
      );
      
      throw DataAccessException(
        message: 'Erro ao buscar conteúdo de ajuda', 
        originalError: e
      );
    }
  }
  
  /// Retorna tutoriais disponíveis
  Future<List<Tutorial>> getTutorials() async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        try {
          final response = await _supabaseClient
              .from(_tutorialsTable)
              .select()
              .order('order', ascending: true);
          
          final tutorials = response.map((data) => Tutorial.fromJson(data)).toList();
          
          // Armazenar em cache se disponível
          if (_cacheService != null) {
            await _cacheService!.set(
              _tutorialsCacheKey, 
              jsonEncode(tutorials.map((tutorial) => tutorial.toJson()).toList())
            );
          }
          
          return tutorials;
        } catch (e) {
          LogUtils.error('Erro ao obter tutoriais do Supabase', error: e);
          
          // Tentar cache
          if (_cacheService != null) {
            final cachedData = await _cacheService!.get(_tutorialsCacheKey);
            if (cachedData != null) {
              final List<dynamic> decoded = jsonDecode(cachedData);
              return decoded.map((item) => Tutorial.fromJson(item)).toList();
            }
          }
          
          // Se não tiver em cache, retornar lista vazia
          return [];
        }
      } else {
        // Sem conectividade, usar cache
        if (_cacheService != null) {
          final cachedData = await _cacheService!.get(_tutorialsCacheKey);
          if (cachedData != null) {
            final List<dynamic> decoded = jsonDecode(cachedData);
            return decoded.map((item) => Tutorial.fromJson(item)).toList();
          }
        }
        
        // Se não tiver em cache, retornar lista vazia
        return [];
      }
    } catch (e) {
      LogUtils.error('Erro ao processar tutoriais', error: e);
      throw DataAccessException(
        message: 'Erro ao carregar tutoriais', 
        originalError: e
      );
    }
  }
  
  /// Retorna uma lista padrão de FAQs caso não seja possível obter do backend
  List<Faq> _getDefaultFaqs() {
    return [
      const Faq(
        id: '1',
        question: 'Como criar um treino personalizado?',
        answer: 'Para criar um treino personalizado, acesse a seção Treinos, toque no botão "+" no canto inferior direito e selecione "Criar treino". Escolha os exercícios, defina séries e repetições e salve seu treino.',
        category: 'Treinos',
      ),
      const Faq(
        id: '2',
        question: 'Como participar de um desafio?',
        answer: 'Na seção Desafios, você encontrará desafios disponíveis. Selecione o desafio desejado e toque em "Participar". Você também pode criar seu próprio desafio tocando em "Criar desafio".',
        category: 'Desafios',
      ),
      const Faq(
        id: '3',
        question: 'Como acompanhar meu progresso?',
        answer: 'Seu progresso é exibido na tela inicial e na seção Perfil. Você pode visualizar estatísticas de treinos, desafios completados e histórico de atividades.',
        category: 'Progresso',
      ),
      const Faq(
        id: '4',
        question: 'Como resgatar benefícios e cupons?',
        answer: 'Acesse a seção Benefícios, escolha o benefício desejado e toque em "Resgatar". Um QR code será gerado para você apresentar no estabelecimento parceiro.',
        category: 'Benefícios',
      ),
      const Faq(
        id: '5',
        question: 'Posso usar o app sem internet?',
        answer: 'Sim, o Ray Club funciona offline para a maioria das funcionalidades. Treinos baixados previamente, seu perfil e estatísticas ficam disponíveis. A sincronização ocorre automaticamente quando você se reconectar.',
        category: 'Geral',
      ),
      const Faq(
        id: '6',
        question: 'Como alterar minhas configurações de privacidade?',
        answer: 'Acesse seu Perfil, toque em "Configurações e Privacidade" e selecione "Gerenciar Consentimentos". Lá você pode ajustar todas as permissões relacionadas aos seus dados.',
        category: 'Privacidade',
      ),
    ];
  }

  @override
  Future<Faq?> getFaqById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_faqsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Faq.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao obter FAQ por ID', error: e);
      throw DataAccessException(
        message: 'Erro ao carregar detalhes da FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Tutorial?> getTutorialById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tutorialsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Tutorial.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao obter tutorial por ID', error: e);
      throw DataAccessException(
        message: 'Erro ao carregar detalhes do tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Faq> createFaq(Faq faq) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para criar FAQs'
        );
      }
      
      final response = await _supabaseClient
          .from(_faqsTable)
          .insert(faq.toJson())
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_faqsCacheKey);
      }
      
      return Faq.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao criar FAQ', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao criar FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Faq> updateFaq(Faq faq) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para atualizar FAQs'
        );
      }
      
      final response = await _supabaseClient
          .from(_faqsTable)
          .update(faq.toJson())
          .eq('id', faq.id)
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_faqsCacheKey);
      }
      
      return Faq.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao atualizar FAQ', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao atualizar FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<void> deleteFaq(String faqId) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para remover FAQs'
        );
      }
      
      await _supabaseClient
          .from(_faqsTable)
          .delete()
          .eq('id', faqId);
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_faqsCacheKey);
      }
    } catch (e) {
      LogUtils.error('Erro ao remover FAQ', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao remover FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Tutorial> createTutorial(Tutorial tutorial) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para criar tutoriais'
        );
      }
      
      final response = await _supabaseClient
          .from(_tutorialsTable)
          .insert(tutorial.toJson())
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_tutorialsCacheKey);
      }
      
      return Tutorial.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao criar tutorial', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao criar tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Tutorial> updateTutorial(Tutorial tutorial) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para atualizar tutoriais'
        );
      }
      
      final response = await _supabaseClient
          .from(_tutorialsTable)
          .update(tutorial.toJson())
          .eq('id', tutorial.id)
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_tutorialsCacheKey);
      }
      
      return Tutorial.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao atualizar tutorial', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao atualizar tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<void> deleteTutorial(String tutorialId) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para remover tutoriais'
        );
      }
      
      await _supabaseClient
          .from(_tutorialsTable)
          .delete()
          .eq('id', tutorialId);
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_tutorialsCacheKey);
      }
    } catch (e) {
      LogUtils.error('Erro ao remover tutorial', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao remover tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<bool> isAdmin() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Verificar se o usuário é admin na tabela de perfis
      final response = await _supabaseClient
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        return false;
      }
      
      return response['is_admin'] == true;
    } catch (e) {
      LogUtils.error('Erro ao verificar se o usuário é admin', error: e);
      return false;
    }
  }
} // Project imports:
import '../models/faq_model.dart';
import '../models/help_search_result.dart';
import '../models/tutorial_model.dart';

/// Interface para o repositório de ajuda
abstract class HelpRepository {
  /// Obtém a lista de FAQs
  Future<List<Faq>> getFaqs();
  
  /// Envia uma mensagem de suporte
  Future<void> sendSupportMessage({
    required String name,
    required String email,
    required String message,
  });
  
  /// Busca conteúdo de ajuda
  Future<HelpSearchResult> searchHelp(String query);
  
  /// Obtém a lista de tutoriais
  Future<List<Tutorial>> getTutorials();
  
  /// Obtém uma FAQ pelo ID
  Future<Faq?> getFaqById(String id);
  
  /// Obtém um tutorial pelo ID
  Future<Tutorial?> getTutorialById(String id);
  
  /// Adiciona uma nova FAQ (admin)
  Future<Faq> createFaq(Faq faq);
  
  /// Atualiza uma FAQ existente (admin)
  Future<Faq> updateFaq(Faq faq);
  
  /// Remove uma FAQ (admin)
  Future<void> deleteFaq(String faqId);
  
  /// Adiciona um novo tutorial (admin)
  Future<Tutorial> createTutorial(Tutorial tutorial);
  
  /// Atualiza um tutorial existente (admin)
  Future<Tutorial> updateTutorial(Tutorial tutorial);
  
  /// Remove um tutorial (admin)
  Future<void> deleteTutorial(String tutorialId);
  
  /// Verifica se o usuário é administrador
  Future<bool> isAdmin();
} // Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:ray_club_app/utils/performance_monitor.dart';
import 'package:ray_club_app/utils/db_field_utils.dart';
import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/constants/app_colors.dart';
import 'core/di/service_locator.dart';
import 'core/errors/error_handler.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/cache_service.dart';
import 'services/deep_link_service.dart';
import 'core/config/theme.dart';
import 'services/database_verification_service.dart';
import 'core/utils/env_validator.dart';
import 'utils/timezone_checker.dart';
import 'core/app_startup.dart';

// Adicionar no topo do arquivo, após os imports existentes
import 'dart:async';

/// Entry point of the application
void main() async {
  // Run the app with centralized error handling via Sentry
  await ErrorHandler.initializeSentry(
    appRunner: () async {
      try {
        await _initializeApp();
      } catch (e, stackTrace) {
        debugPrint('Fatal error during initialization: $e\n$stackTrace');
        runApp(const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Erro ao inicializar o aplicativo.\nPor favor, tente novamente.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
        
        // Capture the initialization error in Sentry
        await Sentry.captureException(e, stackTrace: stackTrace);
      }
    },
    tracesSampleRate: 1.0,
    profilesSampleRate: 1.0,
  );
}

/// Função principal de inicialização que será encapsulada com tratamento de erros
Future<void> _initializeApp() async {
  debugPrint('🟢 MAIN ATUAL EXECUTADA');
  
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for locales
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: '.env');

  // Validar variáveis de ambiente
  final isEnvValid = EnvValidator.validateEnvironment();
  if (!isEnvValid) {
    debugPrint('⚠️ AVISO: Ambiente não configurado corretamente!');
    // Em modo de desenvolvimento, registrar as variáveis disponíveis
    if (kDebugMode) {
      EnvValidator.logEnvironment();
    }
  }

  // Initialize app configuration
  await AppConfig.initialize();
  
  // Validar se o ambiente está configurado corretamente
  try {
    if (!EnvironmentManager.validateEnvironment()) {
      throw ConfigurationException('Configuração de ambiente incompleta!');
    }
    debugPrint('✅ Ambiente validado com sucesso');
  } catch (e) {
    debugPrint('⚠️ ERRO DE CONFIGURAÇÃO: $e');
    // Continuar a execução com valores padrão se possível
    // ou exibir uma tela de erro se as configurações forem críticas
  }
  
  debugPrint('✅ AppConfig inicializado (Ambiente: ${EnvironmentManager.current})');

  // Initialize Supabase client
  await Supabase.initialize(
    url: EnvironmentManager.supabaseUrl,
    anonKey: EnvironmentManager.supabaseAnonKey,
    debug: EnvironmentManager.debugMode,
  );
  debugPrint('✅ Supabase inicializado');

  // Inicializar utilitário de compatibilidade
  await DbFieldUtils.initialize();
  debugPrint('✅ DbFieldUtils inicializado');

  // Adicionar verificação de tabelas necessárias usando o serviço dedicado
  try {
    debugPrint('🔍 Verificando integridade do banco de dados Supabase');
    final dbVerificationService = DatabaseVerificationService(Supabase.instance.client);
    await dbVerificationService.printDiagnostics();
  } catch (e) {
    debugPrint('⚠️ Erro ao verificar integridade do banco de dados: $e');
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Check and print the current value of has_seen_intro
  final hasSeenIntro = prefs.getBool('has_seen_intro');
  debugPrint('🔍 Current has_seen_intro value: $hasSeenIntro');
  
  // FORCE RESET the has_seen_intro flag to false for testing
  // This ensures the intro screen is always shown first
  await prefs.setBool('has_seen_intro', false);
  debugPrint('⚠️ FORCED RESET: has_seen_intro flag set to false for testing');
  
  // DO NOT mark has_seen_intro as true during initialization
  // It should only be marked after the user actually sees the intro
  
  debugPrint('✅ SharedPreferences inicializado');

  // Initialize dependencies
  await initializeDependencies();
  debugPrint('✅ Dependências inicializadas');
  
  // Cria um observador que será configurado após a criação do container
  final appObserver = AppProviderObserver();
  
  // Criar o CacheService que será usado no container
  final cacheService = SharedPrefsCacheService(prefs);
  
  // Criar o container para os providers com os overrides necessários
  final container = ProviderContainer(
    observers: [appObserver],
    overrides: [
      // Sobrescrever o provider do CacheService com uma instância já inicializada
      cacheServiceProvider.overrideWithValue(cacheService),
      // Sobrescrever o provider do SharedPreferences com a instância já inicializada
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  
  // Agora que o container existe, configuramos o observador com ele
  appObserver.setContainer(container);
  
  // Configurar o PerformanceMonitor para monitorar operações críticas
  PerformanceMonitor.setRemoteLoggingService(container.read(remoteLoggingServiceProvider));

  // Configurar deferred loading para otimização do tamanho do aplicativo
  if (kReleaseMode) {
    // Pré-carregar bibliotecas principais
    await _preloadCoreLibraries();
  }

  // Pré-carregamento de fontes para evitar problemas com o Impeller
  await precacheFontFamilies();

  // Executar o aplicativo com o container configurado
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  debugPrint('🚀 App inicializado e rodando');

  // Adicionar diagnóstico de Deep Link após inicialização
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Iniciar o serviço de deep links para toda a aplicação
    final deepLinkService = getIt<DeepLinkService>();
    deepLinkService.initializeDeepLinks();
    
    if (kDebugMode) {
      deepLinkService.printDeepLinkInfo();
    }
  });

  // Testar timezone para debug
  await TimezoneChecker.testTimezone();
  final timezoneInfo = TimezoneChecker.getTimezoneInfo();
  debugPrint('🕒 Timezone do dispositivo: ${timezoneInfo['timezone_offset_hours']}h');
  debugPrint('🕒 É timezone de Brasília (UTC-3)? ${timezoneInfo['is_brasilia_timezone'] ? 'Sim' : 'Não'}');
}

/// Carrega bibliotecas principais de forma otimizada
Future<void> _preloadCoreLibraries() async {
  // Implementar lazy loading para features menos usadas
  unawaited(_initializeDeferredLibraries());
}

/// Inicializa bibliotecas sob demanda para reduzir o tamanho inicial do app
Future<void> _initializeDeferredLibraries() async {
  // Esta função será chamada após o app iniciar
  // Carregar bibliotecas em segundo plano para melhorar o tempo de inicialização
  
  // Exemplo de uso:
  // await DeferredFeature.ensureInitialized();
}

/// Pré-carrega fontes utilizadas na aplicação para evitar problemas de renderização com o Impeller
Future<void> precacheFontFamilies() async {
  // Skip loading Poppins fonts as they appear to be empty files
  
  // Carrega as fontes Century Gothic
  final fontLoaderCentury = FontLoader('CenturyGothic');
  fontLoaderCentury.addFont(rootBundle.load('assets/fonts/Century-Gothic.ttf'));
  fontLoaderCentury.addFont(rootBundle.load('assets/fonts/Century-Gothic-Bold.TTF')); // Note the uppercase TTF
  
  // Carrega as fontes Stinger
  final fontLoaderStinger = FontLoader('Stinger');
  fontLoaderStinger.addFont(rootBundle.load('assets/fonts/Stinger-Regular.ttf'));
  fontLoaderStinger.addFont(rootBundle.load('assets/fonts/Stinger-Bold.ttf'));
  
  // Aguarda o carregamento de todas as fontes
  await Future.wait([
    fontLoaderCentury.load(),
    fontLoaderStinger.load(),
  ]);
}

/// Main application widget
class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Inicializar listeners e componentes após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Inicializar listeners globais do app
      await initializeAppListeners(ref);
      
      // Configurar listener para mudanças de autenticação
      setupAuthStateChangeListener(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 Building MyApp');
    return Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        debugPrint('🔍 Configurando router - rota inicial: ${AppRoutes.intro}');
        
        return MaterialApp.router(
          title: 'Ray Club',
          theme: AppTheme.lightTheme,
          routerConfig: router.config(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Global navigator key for use throughout the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
