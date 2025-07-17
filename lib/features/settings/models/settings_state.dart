// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Estado para o gerenciamento de configurações do aplicativo.
@freezed
class SettingsState with _$SettingsState {
  /// Factory para o estado de configurações
  const factory SettingsState({
    /// Indica se o modo escuro está ativado
    @Default(false) bool isDarkMode,
    
    /// Idioma selecionado pelo usuário
    @Default('Português') String selectedLanguage,
    
    /// Indica se o usuário atual é administrador
    @Default(false) bool isAdmin,
    
    /// Indica se está carregando dados
    @Default(false) bool isLoading,
    
    /// Mensagem de erro, se houver
    String? errorMessage,
  }) = _SettingsState;
} 