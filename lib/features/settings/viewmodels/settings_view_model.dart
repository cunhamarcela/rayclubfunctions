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
} 