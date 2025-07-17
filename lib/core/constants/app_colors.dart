// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_colors.dart' as theme;

// Arquivo mantido por compatibilidade.
// Este arquivo importa as definições de AppColors do tema centralizado.
// Por favor, utilize diretamente a importação de core/theme/app_colors.dart em novos códigos.

/// Exporta a classe AppColors do caminho correto.
export '../theme/app_colors.dart';

/// Atalho para as cores definidas em core/theme/app_colors.dart
@Deprecated('Use o import de core/theme/app_colors.dart')
class AppColors {
  // Todos os getters estáticos redirecionam para o arquivo principal
  static Color get primary => theme.AppColors.primary;
  static Color get primaryLight => theme.AppColors.primaryLight;
  static Color get primaryDark => theme.AppColors.primaryDark;
  static Color get secondary => theme.AppColors.secondary;
  static Color get secondaryLight => theme.AppColors.secondaryLight;
  static Color get secondaryDark => theme.AppColors.secondaryDark;
  static Color get accent => theme.AppColors.accent;
  static Color get brown => theme.AppColors.brown;
  static Color get offWhite => theme.AppColors.offWhite;
  static Color get white => theme.AppColors.white;
  static Color get textDark => theme.AppColors.textDark;
  static Color get textLight => theme.AppColors.textLight;
  static Color get textMedium => theme.AppColors.textMedium;
  static Color get textHint => theme.AppColors.textHint;
  static Color get background => theme.AppColors.background;
  static Color get surface => theme.AppColors.surface;
  static Color get disabled => theme.AppColors.disabled;
  static Color get success => theme.AppColors.success;
  static Color get error => theme.AppColors.error;
  static Color get warning => theme.AppColors.warning;
  static Color get info => theme.AppColors.info;
  static Color get shadow => theme.AppColors.shadow;
  static Color get shadowLight => theme.AppColors.shadowLight;
  static List<Color> get primaryGradient => theme.AppColors.primaryGradient;
} 