// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget que exibe um indicador de carregamento com uma mensagem opcional.
///
/// Usado para mostrar estados de carregamento em todo o aplicativo.
class AppLoading extends StatelessWidget {
  /// Mensagem opcional para exibir junto com o indicador de carregamento
  final String? message;
  
  const AppLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 