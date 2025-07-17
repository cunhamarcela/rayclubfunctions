import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget padronizado para o botão de voltar na AppBar
class AppBarLeading extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final IconData icon;
  
  const AppBarLeading({
    super.key,
    this.onPressed,
    this.iconColor,
    this.icon = Icons.arrow_back_ios,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: iconColor ?? AppColors.textPrimary,
        size: 22,
      ),
      onPressed: onPressed ?? () {
        // Usar o Navigator padrão para navegação
        Navigator.of(context).pop();
      },
      splashRadius: 24,
    );
  }
} 