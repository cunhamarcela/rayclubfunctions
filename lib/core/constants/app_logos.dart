/// Constantes para os logos utilizados no aplicativo Ray Club
///
/// Este arquivo contém constantes organizadas para todos os logos
/// utilizados no aplicativo, agrupados por categoria.

import 'package:flutter/material.dart' show Color;

// Enum para categorias de logos
enum LogoCategory {
  app,        // Logos do próprio Ray Club 
  partners,   // Logos de parceiros/patrocinadores
  brands,     // Logos de marcas relacionadas
  social,     // Logos de redes sociais
  background  // Imagens de background/fundo
}

// Extensão para obter informações da categoria
extension LogoCategoryExtension on LogoCategory {
  String get displayName {
    switch (this) {
      case LogoCategory.app:
        return 'App';
      case LogoCategory.partners:
        return 'Parceiros';
      case LogoCategory.brands:
        return 'Marcas';
      case LogoCategory.social:
        return 'Redes Sociais';
      case LogoCategory.background:
        return 'Backgrounds';
    }
  }
  
  String get path {
    switch (this) {
      case LogoCategory.app:
        return 'assets/images/logos/app';
      case LogoCategory.partners:
        return 'assets/images/logos/partners';
      case LogoCategory.brands:
        return 'assets/images/logos/brands';
      case LogoCategory.social:
        return 'assets/images/logos/social';
      case LogoCategory.background:
        return 'assets/images/logos/backgrounds';
    }
  }
}

/// Classe que representa um logo
class Logo {
  final String id;
  final String name;
  final String path;
  final LogoCategory category;
  final bool hasTransparency;
  final double? aspectRatio;
  final Color? backgroundColor;
  
  const Logo({
    required this.id,
    required this.name,
    required this.path,
    required this.category,
    this.hasTransparency = true,
    this.aspectRatio,
    this.backgroundColor,
  });
  
  /// Retorna o caminho completo do logo
  String get fullPath => path;
}

/// Constantes para todos os logos utilizados no aplicativo
class AppLogos {
  // Impedir instanciação
  AppLogos._();
  
  // Caminhos base
  static const String _appPath = 'assets/images/logos/app';
  static const String _partnersPath = 'assets/images/logos/partners';
  static const String _brandsPath = 'assets/images/logos/brands';
  static const String _socialPath = 'assets/images/logos/social';
  static const String _backgroundPath = 'assets/images/logos/backgrounds';
  
  // Logos do Ray Club
  static const Logo rayClubPrimary = Logo(
    id: 'ray_club_primary',
    name: 'Ray Club Principal',
    path: '$_appPath/ray_club_primary.png',
    category: LogoCategory.app,
  );
  
  static const Logo rayClubHorizontal = Logo(
    id: 'ray_club_horizontal',
    name: 'Ray Club Horizontal',
    path: '$_appPath/ray_club_horizontal.png',
    category: LogoCategory.app,
  );
  
  static const Logo rayClubIcon = Logo(
    id: 'ray_club_icon',
    name: 'Ray Club Ícone',
    path: '$_appPath/ray_club_icon.png',
    category: LogoCategory.app,
  );
  
  static const Logo rayClubLight = Logo(
    id: 'ray_club_light',
    name: 'Ray Club Versão Clara',
    path: '$_appPath/ray_club_light.png',
    category: LogoCategory.app,
  );
  
  // Logos de redes sociais
  static const Logo instagram = Logo(
    id: 'instagram',
    name: 'Instagram',
    path: '$_socialPath/instagram.png',
    category: LogoCategory.social,
  );
  
  static const Logo facebook = Logo(
    id: 'facebook',
    name: 'Facebook',
    path: '$_socialPath/facebook.png',
    category: LogoCategory.social,
  );
  
  static const Logo twitter = Logo(
    id: 'twitter',
    name: 'Twitter',
    path: '$_socialPath/twitter.png',
    category: LogoCategory.social,
  );
  
  // Lista completa de logos por categoria
  static const List<Logo> appLogos = [
    rayClubPrimary,
    rayClubHorizontal,
    rayClubIcon,
    rayClubLight,
  ];
  
  static const List<Logo> socialLogos = [
    instagram,
    facebook,
    twitter,
  ];
  
  // Backgrounds
  static const Logo loginBackground = Logo(
    id: 'login_background',
    name: 'Background de Login',
    path: '$_backgroundPath/login_background.jpg',
    category: LogoCategory.background,
    hasTransparency: false,
  );
  
  static const Logo homeBackground = Logo(
    id: 'home_background',
    name: 'Background da Home',
    path: '$_backgroundPath/home_background.jpg',
    category: LogoCategory.background,
    hasTransparency: false,
  );
  
  static const List<Logo> backgroundLogos = [
    loginBackground,
    homeBackground,
  ];
  
  // Lista completa de todos os logos
  static const List<Logo> allLogos = [
    ...appLogos,
    ...socialLogos,
    ...backgroundLogos,
  ];
  
  /// Obtém um logo pelo ID
  static Logo? getLogoById(String id) {
    try {
      return allLogos.firstWhere((logo) => logo.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Obtém todos os logos de uma categoria
  static List<Logo> getLogosByCategory(LogoCategory category) {
    return allLogos.where((logo) => logo.category == category).toList();
  }
} 