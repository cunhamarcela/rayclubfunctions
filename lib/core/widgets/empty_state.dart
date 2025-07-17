import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget para exibir um estado vazio (sem dados) com ação opcional
class EmptyState extends StatelessWidget {
  /// Mensagem principal
  final String message;
  
  /// Mensagem secundária/descrição (opcional)
  final String? description;
  
  /// Ícone a ser exibido
  final IconData icon;
  
  /// Tamanho do ícone
  final double iconSize;
  
  /// Cor do ícone
  final Color? iconColor;
  
  /// Texto do botão de ação
  final String? actionLabel;
  
  /// Callback para ação quando o botão é pressionado
  final VoidCallback? onAction;
  
  /// Estilo do texto da mensagem principal
  final TextStyle? messageStyle;
  
  /// Estilo do texto da descrição
  final TextStyle? descriptionStyle;
  
  /// Construtor
  const EmptyState({
    Key? key,
    required this.message,
    this.description,
    this.icon = Icons.search_off,
    this.iconSize = 64.0,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.messageStyle,
    this.descriptionStyle,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle ?? AppTypography.titleMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: descriptionStyle ?? AppTypography.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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