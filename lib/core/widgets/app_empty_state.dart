// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget que exibe um estado vazio com uma mensagem e um ícone personalizáveis.
///
/// Usado para mostrar estados onde não há dados para exibir, como listas vazias,
/// resultados de busca sem correspondência, etc.
class AppEmptyState extends StatelessWidget {
  /// Mensagem a ser exibida ao usuário
  final String message;
  
  /// Ícone a ser mostrado acima da mensagem
  final IconData icon;
  
  /// Mensagem do botão de ação (opcional)
  final String? actionLabel;
  
  /// Callback a ser chamado quando o botão de ação for pressionado
  final VoidCallback? onAction;
  
  /// Tamanho do ícone
  final double iconSize;
  
  /// Cor do ícone
  final Color? iconColor;

  const AppEmptyState({
    Key? key,
    required this.message,
    this.icon = Icons.inbox,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 