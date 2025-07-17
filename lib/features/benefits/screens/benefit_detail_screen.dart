// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../viewmodels/benefit_view_model.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit.dart';
import '../repositories/benefit_repository.dart';
import '../viewmodels/benefit_redemption_view_model.dart';
import '../enums/benefit_type.dart';

/// Tela de detalhes de um benefício
@RoutePage()
class BenefitDetailScreen extends ConsumerStatefulWidget {
  final String benefitId;

  const BenefitDetailScreen({
    Key? key,
    @PathParam('id') required this.benefitId,
  }) : super(key: key);

  @override
  ConsumerState<BenefitDetailScreen> createState() => _BenefitDetailScreenState();
}

class _BenefitDetailScreenState extends ConsumerState<BenefitDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Obter detalhes do benefício
    _loadBenefitDetails();
  }

  Future<void> _loadBenefitDetails() async {
    // Usando o provider diretamente porque estamos no initState
    final repository = ref.read(benefitRepositoryProvider);
    await repository.getBenefitById(widget.benefitId);
  }

  @override
  Widget build(BuildContext context) {
    // Observar o benefício selecionado
    final benefitAsync = ref.watch(benefitDetailProvider(widget.benefitId));
    // Observar o estado de resgate
    final redemptionState = ref.watch(benefitRedemptionViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Benefício'),
      ),
      body: benefitAsync.when(
        data: (benefit) => _buildContent(context, benefit, redemptionState),
        loading: () => const LoadingView(message: 'Carregando detalhes...'),
        error: (error, stack) => ErrorView(
          message: 'Erro ao carregar detalhes: $error',
          onRetry: _loadBenefitDetails,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    Benefit benefit, 
    BenefitRedemptionState redemptionState,
  ) {
    final hasRedeemed = redemptionState.isSuccess && redemptionState.redeemedBenefit != null;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do benefício
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
                image: benefit.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(benefit.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: benefit.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: 20),
            
            // Título e tipo
            Text(
              benefit.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Oferecido por ${benefit.partner}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Badge de pontos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${benefit.pointsRequired} pontos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Se já resgatou, mostrar QR code
            if (hasRedeemed) _buildRedeemedContent(redemptionState),
            
            // Se não resgatou, mostrar descrição e botão
            if (!hasRedeemed) ...[
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                benefit.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 16),
              
              // Termos e condições
              if (benefit.terms != null && benefit.terms!.isNotEmpty) ...[
                const Text(
                  'Termos e Condições',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  benefit.terms!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Data de expiração
              if (benefit.expirationDate != null) ...[
                Text(
                  'Válido até: ${DateFormat('dd/MM/yyyy').format(benefit.expirationDate!)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Botão de resgate
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: redemptionState.isLoading 
                    ? null 
                    : () => _redeemBenefit(benefit.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: redemptionState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Resgatar Benefício',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
            
            // Mensagem de erro
            if (redemptionState.hasError && redemptionState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  redemptionState.errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemedContent(BenefitRedemptionState state) {
    final redeemedBenefit = state.redeemedBenefit;
    if (redeemedBenefit == null) return const SizedBox();

    // Verificar se o benefício já foi usado
    final isUsed = redeemedBenefit.status == BenefitStatus.used;
    // Verificar se o benefício está expirado
    final isExpired = redeemedBenefit.status == BenefitStatus.expired || 
        (redeemedBenefit.expiresAt != null && redeemedBenefit.expiresAt!.isBefore(DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUsed || isExpired 
                    ? Colors.grey.shade200
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUsed ? Icons.check_circle : isExpired ? Icons.timer_off : Icons.verified,
                    size: 16,
                    color: isUsed || isExpired ? Colors.grey.shade700 : Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUsed 
                        ? 'Utilizado' 
                        : isExpired 
                            ? 'Expirado' 
                            : 'Resgatado com Sucesso',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUsed || isExpired ? Colors.grey.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Código QR
        if (!isUsed && !isExpired) ...[
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: redeemedBenefit.redemptionCode ?? redeemedBenefit.code,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Código: ${redeemedBenefit.redemptionCode ?? redeemedBenefit.code}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                if (redeemedBenefit.expiresAt != null) ...[
                  Text(
                    'Válido até: ${DateFormat('dd/MM/yyyy HH:mm').format(redeemedBenefit.expiresAt!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
                
                const Text(
                  'Apresente este código QR no estabelecimento para utilizar seu benefício.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botão para marcar como usado
          Center(
            child: TextButton.icon(
              onPressed: () => _markAsUsed(redeemedBenefit.id),
              icon: const Icon(Icons.check_circle),
              label: const Text('Marcar como Utilizado'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          ),
        ],
        
        // Se já usado ou expirado, mostrar mensagem
        if (isUsed || isExpired) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  isUsed ? Icons.check_circle : Icons.timer_off,
                  size: 48,
                  color: Colors.grey.shade500,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  isUsed 
                      ? 'Este benefício já foi utilizado' 
                      : 'Este benefício expirou',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  isUsed
                      ? 'Utilizado em: ${redeemedBenefit.usedAt != null ? DateFormat('dd/MM/yyyy').format(redeemedBenefit.usedAt!) : "Data não disponível"}'
                      : 'O período de validade deste benefício expirou.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Botão para resgatar novamente
        if (isUsed || isExpired) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Limpar estado atual e permitir novo resgate
                ref.read(benefitRedemptionViewModelProvider.notifier).reset();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Resgatar Novamente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _redeemBenefit(String benefitId) {
    ref.read(benefitRedemptionViewModelProvider.notifier).redeemBenefit(benefitId);
  }

  void _markAsUsed(String redeemedBenefitId) {
    ref.read(benefitRedemptionViewModelProvider.notifier).markBenefitAsUsed(redeemedBenefitId);
  }
}

/// Provider para detalhes de um benefício específico
final benefitDetailProvider = FutureProvider.family<Benefit, String>((ref, benefitId) async {
  final repository = ref.watch(benefitRepositoryProvider);
  final benefit = await repository.getBenefitById(benefitId);
  
  if (benefit == null) {
    throw Exception('Benefício não encontrado');
  }
  
  return benefit;
}); 
