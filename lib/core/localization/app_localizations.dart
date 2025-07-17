// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'translations/en_us.dart';
import 'translations/es_es.dart';
import 'translations/pt_br.dart';

/// Enum que representa os idiomas suportados no aplicativo
enum AppLanguage {
  /// Português (Brasil)
  ptBR,
  
  /// Inglês (EUA)
  enUS,
  
  /// Espanhol (Espanha)
  esES
}

/// Extensão para converter AppLanguage para Locale
extension AppLanguageExtension on AppLanguage {
  /// Converte AppLanguage para Locale do Flutter
  Locale get locale {
    switch (this) {
      case AppLanguage.ptBR:
        return const Locale('pt', 'BR');
      case AppLanguage.enUS:
        return const Locale('en', 'US');
      case AppLanguage.esES:
        return const Locale('es', 'ES');
    }
  }
  
  /// Retorna o nome do idioma em seu próprio idioma
  String get nativeName {
    switch (this) {
      case AppLanguage.ptBR:
        return 'Português';
      case AppLanguage.enUS:
        return 'English';
      case AppLanguage.esES:
        return 'Español';
    }
  }
}

/// Classe responsável pelas traduções do aplicativo
class AppLocalizations {
  /// A localidade atual
  final Locale locale;
  
  /// Mapa de traduções
  final Map<String, String> _translations;
  
  /// Construtor
  AppLocalizations(this.locale, this._translations);
  
  /// Factory que carrega as traduções com base na localidade
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  /// Obtém a tradução para a chave
  String translate(String key) {
    return _translations[key] ?? key;
  }
  
  /// Delegate para localização
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  /// Lista de idiomas suportados
  static final List<Locale> supportedLocales = AppLanguage.values.map((e) => e.locale).toList();
  
  /// Método para carregar traduções com base no locale
  static Map<String, String> _getTranslations(Locale locale) {
    if (locale.languageCode == 'pt') {
      return ptBrTranslations;
    } else if (locale.languageCode == 'es') {
      return esEsTranslations;
    } else {
      return enUsTranslations;
    }
  }
}

/// Delegate para carregar as localizações
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'es'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale, AppLocalizations._getTranslations(locale));
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Notifier para gerenciamento de idioma
class LanguageNotifier extends StateNotifier<AppLanguage> {
  /// Chave para o SharedPreferences
  static const _prefsKey = 'app_language';
  
  /// Instância do SharedPreferences
  final SharedPreferences _prefs;
  
  /// Construtor
  LanguageNotifier(this._prefs) : super(_loadSavedLanguage(_prefs));
  
  /// Carrega o idioma salvo do SharedPreferences
  static AppLanguage _loadSavedLanguage(SharedPreferences prefs) {
    final savedLanguage = prefs.getString(_prefsKey);
    
    if (savedLanguage != null) {
      try {
        return AppLanguage.values.firstWhere(
          (lang) => lang.name == savedLanguage
        );
      } catch (_) {
        // Fallback para idioma padrão se não encontrar
      }
    }
    
    return AppLanguage.ptBR; // Idioma padrão
  }
  
  /// Altera o idioma atual
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _prefs.setString(_prefsKey, language.name);
  }
}

/// Provider para o idioma atual
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  throw UnimplementedError('Precisa ser inicializado com um override e SharedPreferences');
});

/// Extensão para adicionar acessibilidade aos textos traduzidos
extension TranslateExtension on String {
  /// Traduz uma string
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}

/// Widget que gerencia a alteração de idioma
class LanguageSelector extends ConsumerWidget {
  /// Construtor
  const LanguageSelector({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Idioma do aplicativo',
            child: Text(
              'Selecione o idioma:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...AppLanguage.values.map((language) => 
            RadioListTile<AppLanguage>(
              value: language,
              groupValue: currentLanguage,
              title: Text(language.nativeName),
              onChanged: (newValue) {
                if (newValue != null) {
                  ref.read(languageProvider.notifier).setLanguage(newValue);
                }
              },
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
              // Acessibilidade para leitores de tela
              secondary: Semantics(
                label: language.nativeName,
                selected: language == currentLanguage,
                excludeSemantics: true,
                child: Icon(
                  language == currentLanguage 
                    ? Icons.check_circle 
                    : Icons.language,
                  color: language == currentLanguage
                    ? Theme.of(context).primaryColor
                    : null,
                ),
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }
} 