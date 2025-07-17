// Abstract repository for settings

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
} 