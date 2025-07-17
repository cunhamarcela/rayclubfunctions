// Flutter imports:
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
} 