import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/core/widgets/ray_button.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';

/// Widget para permitir que o usuário tente reconectar quando ocorrer um erro
/// no carregamento ou streaming do ranking
class RetryRankingButton extends ConsumerWidget {
  /// ID do desafio para o qual queremos tentar recarregar o ranking
  final String challengeId;
  
  /// ID do grupo opcional para filtrar o ranking
  final String? groupId;
  
  /// Texto personalizado para o botão
  final String? buttonText;
  
  /// Texto personalizado para mensagem de erro
  final String? errorMessage;
  
  /// Callback adicional a ser executado após a tentativa de reconexão
  final VoidCallback? onAfterRetry;

  /// Construtor
  const RetryRankingButton({
    Key? key,
    required this.challengeId,
    this.groupId,
    this.buttonText,
    this.errorMessage,
    this.onAfterRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone de erro
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 40.0,
          ),
          const SizedBox(height: 8),
          
          // Mensagem de erro
          Text(
            errorMessage ?? 'Erro ao carregar o ranking em tempo real',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Botão para tentar novamente
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Chama o viewmodel para reconectar o stream
              ref.read(challengeViewModelProvider.notifier).watchChallengeRanking(
                challengeId,
                filterByGroupId: groupId,
              );
              
              // Feedback visual
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reconectando ao ranking em tempo real...'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              // Chamada de callback externa
              if (onAfterRetry != null) {
                onAfterRetry!();
              }
            },
          ),
        ],
      ),
    );
  }
} 