// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_colors.dart';

/// Classe que define os gradientes utilizados no aplicativo
class AppGradients {
  // Gradiente principal - laranja para bege claro
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.orange, AppColors.backgroundLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente secundário - roxo para rosa
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [AppColors.purple, AppColors.softPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente laranja quente
  static const LinearGradient warmGradient = LinearGradient(
    colors: [AppColors.orange, AppColors.orangeDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente para cards com fundo escuro
  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [AppColors.darkGray, Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.0, 0.7],
  );
  
  // Gradiente suave para fundos claros
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [AppColors.backgroundLight, Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Gradiente para destacar conteúdo
  static const LinearGradient highlightGradient = LinearGradient(
    colors: [AppColors.backgroundLight, AppColors.softPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente para banners principais
  static LinearGradient get bannerGradient => LinearGradient(
    colors: [AppColors.purple.withOpacity(0.8), AppColors.orange.withOpacity(0.8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Gradiente para botões especiais
  static const LinearGradient actionButtonGradient = LinearGradient(
    colors: [AppColors.orange, AppColors.purple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente para cards com textura
  static const LinearGradient texturedCardGradient = LinearGradient(
    colors: [
      AppColors.backgroundLight,
      Colors.white,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Gradiente para alertas e notificações
  static const LinearGradient alertGradient = LinearGradient(
    colors: [AppColors.orangeDark, AppColors.pastelYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradiente para seções de sucesso
  static const LinearGradient successGradient = LinearGradient(
    colors: [AppColors.purple, AppColors.softPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
} 