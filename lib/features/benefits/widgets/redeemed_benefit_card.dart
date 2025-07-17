// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Package imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';

/// Widget para exibir um benefício resgatado em forma de card
class RedeemedBenefitCard extends StatelessWidget {
  /// Benefício resgatado a ser exibido
  final RedeemedBenefit redeemedBenefit;
  
  /// Callback quando o card for tocado
  final VoidCallback? onTap;

  /// Construtor
  const RedeemedBenefitCard({
    super.key,
    required this.redeemedBenefit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no status
    final Color statusColor = _getStatusColor();
    final String statusText = _getStatusText();
    
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
            // Imagem e badge com status
            Stack(
              children: [
                // Imagem do benefício
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: redeemedBenefit.imageUrl != null && redeemedBenefit.imageUrl!.isNotEmpty
                      ? Image.network(
                          redeemedBenefit.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.card_giftcard,
                            size: 50,
                            color: Colors.grey[400],
                          ),
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
                
                // Badge com status
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
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
                    redeemedBenefit.benefitTitle ?? '',
                    style: AppTypography.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Parceiro
                  Text(
                    redeemedBenefit.partnerName ?? '',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Código de resgate
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Código: ${redeemedBenefit.redemptionCode ?? ''}',
                          style: AppTypography.body2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Data de resgate
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resgatado em ${_formatDate(redeemedBenefit.redeemedAt)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Data de expiração
                  if (redeemedBenefit.expiresAt != null && 
                      redeemedBenefit.status != BenefitStatus.used &&
                      redeemedBenefit.status != BenefitStatus.cancelled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: _isNearExpiry() ? AppColors.warning : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expira em ${_formatDate(redeemedBenefit.expiresAt!)}',
                          style: AppTypography.caption.copyWith(
                            color: _isNearExpiry() ? AppColors.warning : AppColors.textSecondary,
                            fontWeight: _isNearExpiry() ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Data de uso para benefícios usados
                  if (redeemedBenefit.status == BenefitStatus.used && redeemedBenefit.usedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Utilizado em ${_formatDate(redeemedBenefit.usedAt!)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Retorna a cor associada ao status do benefício
  Color _getStatusColor() {
    switch (redeemedBenefit.status) {
      case BenefitStatus.active:
        return AppColors.success;
      case BenefitStatus.used:
        return AppColors.primary;
      case BenefitStatus.expired:
        return AppColors.error;
      case BenefitStatus.cancelled:
        return Colors.grey;
    }
  }
  
  /// Retorna texto representando o status do benefício
  String _getStatusText() {
    switch (redeemedBenefit.status) {
      case BenefitStatus.active:
        return 'Ativo';
      case BenefitStatus.used:
        return 'Utilizado';
      case BenefitStatus.expired:
        return 'Expirado';
      case BenefitStatus.cancelled:
        return 'Cancelado';
    }
  }
  
  /// Verifica se o benefício está próximo da data de expiração
  bool _isNearExpiry() {
    if (redeemedBenefit.expiresAt == null) return false;
    
    final now = DateTime.now();
    final daysUntilExpiry = redeemedBenefit.expiresAt!.difference(now).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
  
  /// Formata uma data para exibição
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }
} 
