// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Níveis de tamanho de texto disponíveis
enum TextSizeLevel {
  /// Tamanho de texto pequeno (0.85x)
  small,
  
  /// Tamanho de texto normal (1.0x)
  normal,
  
  /// Tamanho de texto médio (1.15x)
  medium,
  
  /// Tamanho de texto grande (1.3x)
  large,
  
  /// Tamanho de texto extra grande (1.5x)
  extraLarge
}

/// Extensão para obter o fator de escala de cada nível
extension TextSizeLevelExtension on TextSizeLevel {
  /// Retorna o fator de escala para o nível selecionado
  double get scaleFactor {
    switch (this) {
      case TextSizeLevel.small:
        return 0.85;
      case TextSizeLevel.normal:
        return 1.0;
      case TextSizeLevel.medium:
        return 1.15;
      case TextSizeLevel.large:
        return 1.3;
      case TextSizeLevel.extraLarge:
        return 1.5;
    }
  }
  
  /// Retorna o nome do nível para exibição
  String get displayName {
    switch (this) {
      case TextSizeLevel.small:
        return 'Pequeno';
      case TextSizeLevel.normal:
        return 'Normal';
      case TextSizeLevel.medium:
        return 'Médio';
      case TextSizeLevel.large:
        return 'Grande';
      case TextSizeLevel.extraLarge:
        return 'Extra Grande';
    }
  }
}

/// Classe para gerenciar o tamanho de texto do aplicativo
class TextSizeService extends StateNotifier<TextSizeLevel> {
  /// Chave para armazenar a preferência no SharedPreferences
  static const _prefsKey = 'text_size_level';
  
  /// Instância do SharedPreferences
  final SharedPreferences _prefs;
  
  /// Construtor
  TextSizeService(this._prefs) : super(_loadSavedLevel(_prefs));
  
  /// Carrega o nível salvo de TextSizeLevel das preferências
  static TextSizeLevel _loadSavedLevel(SharedPreferences prefs) {
    final savedLevel = prefs.getInt(_prefsKey);
    if (savedLevel != null && savedLevel >= 0 && savedLevel < TextSizeLevel.values.length) {
      return TextSizeLevel.values[savedLevel];
    }
    return TextSizeLevel.normal;
  }
  
  /// Altera o nível de tamanho de texto
  Future<void> setTextSizeLevel(TextSizeLevel level) async {
    state = level;
    await _prefs.setInt(_prefsKey, level.index);
  }
  
  /// Aumenta o tamanho do texto em um nível
  Future<void> increaseTextSize() async {
    final currentIndex = state.index;
    if (currentIndex < TextSizeLevel.values.length - 1) {
      await setTextSizeLevel(TextSizeLevel.values[currentIndex + 1]);
    }
  }
  
  /// Diminui o tamanho do texto em um nível
  Future<void> decreaseTextSize() async {
    final currentIndex = state.index;
    if (currentIndex > 0) {
      await setTextSizeLevel(TextSizeLevel.values[currentIndex - 1]);
    }
  }
  
  /// Reseta para o tamanho normal
  Future<void> resetToNormal() async {
    await setTextSizeLevel(TextSizeLevel.normal);
  }
}

/// Provider para o TextSizeService
final textSizeServiceProvider = StateNotifierProvider<TextSizeService, TextSizeLevel>((ref) {
  throw UnimplementedError('Precisa ser inicializado com um override e SharedPreferences');
});

/// Extensão para aplicar o tamanho de texto dinâmico a estilos de texto
extension DynamicTextStyleExtension on TextStyle {
  /// Aplica o fator de escala do nível de tamanho ao estilo de texto
  TextStyle withDynamicSize(TextSizeLevel level) {
    return copyWith(
      fontSize: fontSize != null ? fontSize! * level.scaleFactor : null,
    );
  }
} 