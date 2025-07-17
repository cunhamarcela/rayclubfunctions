import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget para exibir mensagem de erro com ação opcional
class ErrorView extends StatelessWidget {
  /// Mensagem de erro a ser exibida
  final String message;
  
  /// Ícone opcional
  final IconData? icon;
  
  /// Texto do botão de ação (ex: "Tentar novamente")
  final String? actionLabel;
  
  /// Callback que será chamado quando o botão de ação for pressionado
  final VoidCallback? onAction;
  
  /// Estilo para a mensagem de erro
  final TextStyle? messageStyle;
  
  /// Cor do ícone
  final Color? iconColor;
  
  /// Tamanho do ícone
  final double iconSize;
  
  const ErrorView({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline,
    this.actionLabel,
    this.onAction,
    this.messageStyle,
    this.iconColor,
    this.iconSize = 48.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.error,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle ?? AppTypography.bodyMedium.copyWith(
                color: AppColors.textDark,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 