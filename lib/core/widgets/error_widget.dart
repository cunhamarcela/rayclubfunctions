// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/error_handler.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';

/// Widget padrão para exibir erros na aplicação.
/// Mostra uma mensagem amigável e um botão para tentar novamente.
class AppErrorWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool showDetails;

  const AppErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de erro
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mensagem de erro
            Text(
              error.message,
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            
            // Detalhes do erro (opcional)
            if (showDetails && error.code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Código: ${error.code}',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Botão para tentar novamente
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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

/// Widget para exibir um mensagem de erro em linha (para formulários, etc).
class AppInlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppInlineErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(20, 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 