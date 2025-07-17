// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/theme/app_typography.dart';
import '../models/challenge.dart';
import '../services/challenge_image_service.dart';

class ChallengeCard extends ConsumerWidget {
  final Challenge challenge;
  final VoidCallback? onTap;
  
  const ChallengeCard({
    required this.challenge,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    final isActive = challenge.isActiveBrazil;
    final daysLeft = challenge.daysRemainingBrazil;
    
    // Obter o serviço de imagens
    final imageService = ref.watch(challengeImageServiceProvider);
    
    // Calcular total de dias do desafio
    final totalDays = challenge.endDate.difference(challenge.startDate).inDays + 1;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: AppColors.backgroundLight, // Fundo claro base #F8F1E7
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do desafio
            Stack(
              children: [
                // Imagem usando o serviço de imagens
                imageService.buildChallengeImage(
                  challenge, 
                  height: 160, 
                  width: double.infinity,
                ),
                
                // Gradiente para melhor legibilidade
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Título sobre a imagem
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    challenge.title,
                    style: TextStyle(
                      fontFamily: 'StingerTrial',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge de status
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.pastelYellow : AppColors.orangeDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.timer : Icons.timer_off,
                          size: 14,
                          color: AppColors.darkGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive
                              ? '$daysLeft dias'
                              : 'Encerrado',
                          style: TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 12,
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge oficial da Ray (se aplicável)
                if (challenge.isOfficial)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.darkGray,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Oficial',
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 12,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Número de participantes (apenas se não for oficial)
                if (!challenge.isOfficial)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            color: AppColors.darkGray,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            challenge.participants.length.toString(),
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 12,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Text(
                    challenge.description,
                    style: TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Informações adicionais
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Período
                      _buildInfoItem(
                        icon: Icons.date_range,
                        label: 'Período',
                        value: '${dateFormat.format(challenge.startDate)} - ${dateFormat.format(challenge.endDate)}',
                      ),
                      const SizedBox(height: 8),
                      // Meta (Check-ins diários em vez de pontos)
                      _buildInfoItem(
                        icon: Icons.check_circle_outline,
                        label: 'Meta',
                        value: 'Check-ins diários',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontSize: 12,
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontSize: 11,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
