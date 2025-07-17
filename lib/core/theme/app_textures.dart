// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_colors.dart';

/// Classe que define texturas e padrões visuais para sobreposição em componentes
class AppTextures {
  // Método para aplicar textura de ondas sutis em um widget
  static Widget addWaveTexture(Widget child, {Color? color, double opacity = 0.07}) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              painter: WavePatternPainter(color: color ?? AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
  
  // Método para aplicar textura de pontos sutis em um widget
  static Widget addDotTexture(Widget child, {Color? color, double opacity = 0.05}) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              painter: DotPatternPainter(color: color ?? AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
  
  // Método para aplicar gradiente e textura em cartões
  static Widget applyCardTexture(
    Widget child, {
    Gradient? gradient,
    Color? textureColor,
    double opacity = 0.05,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [Colors.white, AppColors.backgroundLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppTextures.addWaveTexture(
        child,
        color: textureColor ?? AppColors.primary,
        opacity: opacity,
      ),
    );
  }
  
  // Método para adicionar textura no banner principal
  static Widget applyBannerTexture(
    Widget child, {
    required Gradient gradient,
    double opacity = 0.08,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppTextures.addWaveTexture(
        child,
        color: Colors.white,
        opacity: opacity,
      ),
    );
  }
}

/// Painter para desenhar padrão de ondas
class WavePatternPainter extends CustomPainter {
  final Color color;
  
  WavePatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Desenhar padrão de ondas horizontais
    final waveHeight = size.height / 15;
    final waveWidth = size.width / 5;
    
    for (var y = 0.0; y < size.height; y += waveHeight * 2) {
      path.moveTo(0.0, y);
      
      for (var x = 0.0; x < size.width; x += waveWidth) {
        path.relativeQuadraticBezierTo(
          waveWidth / 2, waveHeight,
          waveWidth, 0.0,
        );
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para desenhar padrão de pontos
class DotPatternPainter extends CustomPainter {
  final Color color;
  
  DotPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final dotSize = 2.0;
    final spacing = 20.0;
    
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 