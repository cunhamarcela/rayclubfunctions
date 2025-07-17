// Flutter imports:
import 'package:flutter/material.dart';

/// Classe que define as cores padronizadas para a aplicação
/// Arquivo consolidado que une as definições de cores de constants e theme
class AppColors {
  // 🔹 Cores principais (conforme guia de design)
  static const Color primary = Color(0xFFF38638); // Laranja principal
  static const Color secondary = Color(0xFFCDA8F0); // Roxo destaque
  static const Color accent = Color(0xFFCDA8F0); // Roxo destaque
  
  // Variações da cor primária
  static const Color primaryLight = Color(0xFFF8F1E7); // Bege mais claro (#F8F1E7)
  static const Color primaryDark = Color(0xFFF38638); // Laranja principal
  
  // Variações da cor secundária
  static const Color secondaryLight = Color(0xFFCDA8F0); // Versão mais clara do roxo
  static const Color secondaryDark = Color(0xFFCDA8F0); // Roxo destaque
  
  // Cores oficiais da identidade visual
  static const Color backgroundLight = Color(0xFFF8F1E7); // Fundo claro base
  static const Color purple = Color(0xFFCDA8F0); // Roxo destaque
  static const Color orange = Color(0xFFF38638); // Laranja principal
  static const Color orangeDark = Color(0xFFEE583F); // Laranja escuro alerta
  static const Color softPink = Color(0xFFEFB9B7); // Rosa suave
  static const Color darkGray = Color(0xFF4D4D4D); // Cinza escuro
  static const Color lightGray = Color(0xFFE6E6E6); // Cinza claro neutro
  static const Color pastelYellow = Color(0xFFFEDC94); // Amarelo pastel
  
  // Legados do arquivo original (mapeado para cores atuais)
  static const Color brown = Color(0xFFF38638); // Laranja/âmbar (#F38638)
  static const Color cream = Color(0xFFF8F1E7); // Bege (#F8F1E7)
  static const Color charcoal = Color(0xFF4D4D4D); // Cinza escuro (#4D4D4D)
  
  // 🔹 Cores de texto 
  static const Color textPrimary = Color(0xFF4D4D4D); // Texto principal, cinza escuro (#4D4D4D)
  static const Color textSecondary = Color(0xFF777777); // Texto secundário, cinza médio (#777777)
  static const Color textDark = Color(0xFF4D4D4D); // Texto em fundo claro (#4D4D4D)
  static const Color textLight = Color(0xFF777777); // Texto secundário/subtítulos (#777777)
  static const Color textMedium = Color(0xFF666666); // Texto médio (#666666)
  static const Color textHint = Color(0xFF999999); // Texto de dica (#999999)
  static const Color textDisabled = Color(0xFFCCCCCC); // Texto desabilitado (#CCCCCC)
  
  // 🔹 Background e containers
  static const Color background = Color(0xFFF8F1E7); // Fundo geral (#F8F1E7)
  static const Color backgroundMedium = Color(0xFFE6E6E6); // Fundo médio (#E6E6E6)
  static const Color backgroundDark = Color(0xFF4D4D4D); // Fundo escuro (#4D4D4D)
  static const Color backgroundSecondary = Color(0xFFE6E6E6); // Fundo secundário (#E6E6E6)
  static const Color secondaryBackground = Color(0xFFF8F1E7); // Alias para fundo secundário
  static const Color offWhite = Color(0xFFE6E6E6); // Cinza claro (#E6E6E6)
  static const Color surface = Colors.white; // Surface
  static const Color card = Colors.white; // Cards
  static const Color cardBackground = Colors.white; // Fundo de cards
  
  // 🔹 Estados e feedbacks
  static const Color disabled = Color(0xFFE6E6E6); // Cinza claro (#E6E6E6)
  static const Color success = Color(0xFFCDA8F0); // Roxo destaque para sucesso
  static const Color error = Color(0xFFEE583F); // Laranja escuro alerta
  static const Color warning = Color(0xFFFEDC94); // Amarelo pastel
  static const Color info = Color(0xFFEFB9B7); // Rosa suave
  
  // 🔹 Cores para elementos de UI
  static const Color divider = Color(0xFFE6E6E6); // Cinza claro para divisores (#E6E6E6)
  static const Color border = Color(0xFFE6E6E6); // Borda (#E6E6E6)
  static const Color icon = Color(0xFF4D4D4D); // Ícones
  static const Color pink = Color(0xFFEFB9B7); // Rosa (#EFB9B7)
  
  // 🔹 Cores básicas
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  // 🔹 Sombras
  static const Color shadow = Color(0x1A4D4D4D); // Sombra leve
  static const Color shadowLight = Color(0x0D4D4D4D); // Sombra mais leve
  static const Color cardShadow = Color(0x1A000000); // Sombra para cards
  
  // 🔹 Gradientes
  static const List<Color> primaryGradient = [
    Color(0xFFF38638), // Laranja principal
    Color(0xFFCDA8F0), // Roxo destaque
  ];
  
  // 🔹 Outros gradientes (adicionar conforme necessário)
  static const List<Color> accentGradient = [
    Color(0xFFCDA8F0), // Roxo destaque
    Color(0xFFEFB9B7), // Rosa suave
  ];
  
  // 🔹 Métodos de utilidade para substituir o withOpacity() depreciado
  
  /// Cria uma versão translúcida da cor com um valor alpha específico
  /// Um substituto para o método withOpacity() depreciado
  /// @param alpha Valor entre 0 e 255
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }
  
  /// Cria uma versão translúcida da cor com 10% de opacidade
  static Color opacity10(Color color) {
    return color.withAlpha(26); // ~10% de 255
  }
  
  /// Cria uma versão translúcida da cor com 20% de opacidade
  static Color opacity20(Color color) {
    return color.withAlpha(51); // ~20% de 255
  }
  
  /// Cria uma versão translúcida da cor com 30% de opacidade
  static Color opacity30(Color color) {
    return color.withAlpha(77); // ~30% de 255
  }
  
  /// Cria uma versão translúcida da cor com 50% de opacidade
  static Color opacity50(Color color) {
    return color.withAlpha(128); // ~50% de 255
  }
  
  /// Cria uma versão translúcida da cor com 70% de opacidade
  static Color opacity70(Color color) {
    return color.withAlpha(179); // ~70% de 255
  }
} 
