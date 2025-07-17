import 'package:flutter/material.dart';

/// Extensões para o BuildContext para facilitar o acesso a recursos do Theme
extension BuildContextExtensions on BuildContext {
  /// Acesso rápido ao ThemeData
  ThemeData get theme => Theme.of(this);
  
  /// Acesso rápido ao TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Acesso rápido às cores
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Acesso à largura da tela
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Acesso à altura da tela 
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Acessa se o dispositivo é móvel (baseado na largura)
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  
  /// Acessa se o dispositivo é tablet (baseado na largura)
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 1200;
  
  /// Acessa se o dispositivo é desktop (baseado na largura)
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
  
  /// Acessa o padding seguro atual do dispositivo
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  /// Verifica se o tema atual é escuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Exibe um SnackBar com mensagem
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
} 