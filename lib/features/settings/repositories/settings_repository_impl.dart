// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'settings_repository.dart';

/// Implementação do repositório de configurações usando SharedPreferences.
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  
  /// Chaves para os valores armazenados no SharedPreferences
  static const String _themeKey = 'ray_club_theme_mode';
  static const String _languageKey = 'ray_club_language';
  
  /// Construtor que recebe uma instância de SharedPreferences
  SettingsRepositoryImpl(this._prefs);
  
  @override
  Future<bool> getThemeMode() async {
    try {
      return _prefs.getBool(_themeKey) ?? false;
    } catch (e) {
      debugPrint('Erro ao obter o tema: $e');
      return false;
    }
  }
  
  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      await _prefs.setBool(_themeKey, isDarkMode);
    } catch (e) {
      debugPrint('Erro ao salvar o tema: $e');
    }
  }
  
  @override
  Future<String> getLanguage() async {
    try {
      return _prefs.getString(_languageKey) ?? 'Português';
    } catch (e) {
      debugPrint('Erro ao obter o idioma: $e');
      return 'Português';
    }
  }
  
  @override
  Future<void> saveLanguage(String language) async {
    try {
      await _prefs.setString(_languageKey, language);
    } catch (e) {
      debugPrint('Erro ao salvar o idioma: $e');
    }
  }
} 