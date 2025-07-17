// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classe de utilidades para garantir contraste adequado entre cores
class ColorContrastHelper {
  /// O valor mínimo de contraste para conformidade de acessibilidade (WCAG 2.0 AA)
  static const double minContrastRatio = 4.5;
  
  /// O valor de contraste recomendado para texto grande ou elementos acentuados
  static const double enhancedContrastRatio = 7.0;
  
  /// Calcula a luminância relativa de uma cor conforme WCAG
  static double calculateRelativeLuminance(Color color) {
    // Normalizar os valores RGB para o intervalo [0, 1]
    double r = color.red / 255.0;
    double g = color.green / 255.0;
    double b = color.blue / 255.0;
    
    // Ajustar valores conforme especificação WCAG
    r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
    
    // Calcular luminância usando fórmula WCAG
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// Calcula a razão de contraste entre duas cores
  static double calculateContrastRatio(Color foreground, Color background) {
    final luminance1 = calculateRelativeLuminance(foreground);
    final luminance2 = calculateRelativeLuminance(background);
    
    // Garantir que o maior valor está no numerador
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Verifica se o contraste atende aos requisitos mínimos de acessibilidade
  static bool hasMinimumContrast(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= minContrastRatio;
  }
  
  /// Verifica se o contraste atende aos requisitos de contraste aprimorado
  static bool hasEnhancedContrast(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= enhancedContrastRatio;
  }
  
  /// Ajusta uma cor para garantir contraste mínimo com o fundo
  static Color ensureMinimumContrast(Color foreground, Color background) {
    if (hasMinimumContrast(foreground, background)) {
      return foreground;
    }
    
    // Determinar se devemos escurecer ou clarear a cor
    final bgLuminance = calculateRelativeLuminance(background);
    final shouldDarken = bgLuminance > 0.5;
    
    Color adjustedColor = foreground;
    double step = shouldDarken ? -0.05 : 0.05;
    int maxAttempts = 20; // Evitar loop infinito
    
    // Ajustar até atingir contraste mínimo ou número máximo de tentativas
    while (!hasMinimumContrast(adjustedColor, background) && maxAttempts > 0) {
      final hsl = HSLColor.fromColor(adjustedColor);
      final newLightness = math.max(0.0, math.min(1.0, hsl.lightness + step));
      adjustedColor = hsl.withLightness(newLightness).toColor();
      maxAttempts--;
    }
    
    return adjustedColor;
  }
} 