import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget de carregamento padronizado para o app
class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AppLoader({
    Key? key,
    this.size = 36.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
          strokeWidth: 3.0,
        ),
      ),
    );
  }
} 