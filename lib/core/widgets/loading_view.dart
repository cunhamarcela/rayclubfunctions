import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget para exibir mensagem de carregamento e indicador
class LoadingView extends StatelessWidget {
  /// Mensagem a ser exibida durante o carregamento 
  final String? message;
  
  /// Se verdadeiro, exibe apenas o indicador de carregamento sem mensagem
  final bool compactMode;
  
  /// Cor do indicador de carregamento
  final Color? color;
  
  /// Estilo da mensagem
  final TextStyle? messageStyle;
  
  const LoadingView({
    Key? key,
    this.message,
    this.compactMode = false,
    this.color,
    this.messageStyle,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (compactMode) {
      return Center(
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: messageStyle ?? AppTypography.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 