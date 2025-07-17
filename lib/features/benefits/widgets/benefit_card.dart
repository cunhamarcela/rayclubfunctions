// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/benefit.dart';

/// Widget para exibir um benefício em forma de card
class BenefitCard extends StatelessWidget {
  /// Benefício a ser exibido
  final Benefit benefit;
  
  /// Callback quando o card for tocado
  final VoidCallback? onTap;
  
  /// Quantidade de pontos do usuário
  final int? userPoints;

  /// Construtor
  const BenefitCard({
    super.key,
    required this.benefit,
    this.onTap,
    this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAfford = userPoints != null && userPoints! >= benefit.pointsRequired;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem e badge com pontos
            Stack(
              children: [
                // Imagem do benefício
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: benefit.imageUrl.isNotEmpty
                      ? Image.network(
                          benefit.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.card_giftcard,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
                
                // Overlay gradiente para melhor legibilidade
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Badge com parceiro, se disponível
                if (benefit.partner != null && benefit.partner!.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      benefit.partner!,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Badge com pontos necessários
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: canAfford 
                          ? AppColors.success.withOpacity(0.9)
                          : AppColors.error.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${benefit.pointsRequired} pts',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Badge quando em destaque
                if (benefit.isFeatured)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Destaque',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Informações do benefício
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    benefit.title,
                    style: AppTypography.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Descrição
                  Text(
                    benefit.description,
                    style: AppTypography.body2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Data de expiração e/ou quantidade disponível
                  if (benefit.expirationDate != null || benefit.availableQuantity != null)
                  Row(
                    children: [
                      if (benefit.expirationDate != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Expira em ${_formatDate(benefit.expirationDate!)}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (benefit.availableQuantity != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${benefit.availableQuantity} disponíveis',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
  
  /// Formata a data de expiração para exibição
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference <= 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Amanhã';
    } else if (difference < 30) {
      return '$difference dias';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 
