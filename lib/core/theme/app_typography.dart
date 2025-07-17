// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_colors.dart';

/// Classe que define as tipografias utilizadas no aplicativo
class AppTypography {
  // Headings com fonte Century Gothic (substituindo Stinger)
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textDark,
    letterSpacing: -0.25,
  );
  
  // Aliases para compatibilidade
  static const TextStyle headline = headingSmall;
  static const TextStyle title = headingSmall;
  static const TextStyle h3 = headingSmall;
  static const TextStyle subtitle = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textDark,
  );
  
  // Title variants
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textDark,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textDark,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textDark,
  );
  
  // Body com fonte Century Gothic (fonte secundária)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textDark,
  );
  
  // Alias para compatibilidade
  static const TextStyle body = bodyMedium;
  static const TextStyle body1 = bodyMedium;
  static const TextStyle body2 = bodySmall;
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: Colors.white,
  );
  
  // Label
  static const TextStyle label = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.25,
    color: AppColors.textDark,
  );
  
  // Label variants
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.25,
    color: AppColors.textDark,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.25,
    color: AppColors.textDark,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.25,
    color: AppColors.textDark,
  );
} 