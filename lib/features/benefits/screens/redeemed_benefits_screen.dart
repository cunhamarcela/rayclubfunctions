// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/core/widgets/app_loading_indicator.dart';
import 'package:ray_club_app/core/widgets/error_view.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_view_model.dart';
import 'package:ray_club_app/features/benefits/widgets/redeemed_benefit_card.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';

/// Tela de listagem de benefícios resgatados pelo usuário
@RoutePage()
class RedeemedBenefitsScreen extends ConsumerStatefulWidget {
  /// Construtor
  const RedeemedBenefitsScreen({super.key});

  @override
  ConsumerState<RedeemedBenefitsScreen> createState() => _RedeemedBenefitsScreenState();
}

class _RedeemedBenefitsScreenState extends ConsumerState<RedeemedBenefitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializa o TabController
    _tabController = TabController(length: 3, vsync: this);
    
    // Carrega os benefícios resgatados quando a tela é inicializada
    Future.microtask(() {
      ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtém o estado do ViewModel
    final state = ref.watch(benefitViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Benefícios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ativos'),
            Tab(text: 'Utilizados'),
            Tab(text: 'Expirados'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: AppLoadingIndicator())
          : state.errorMessage != null
              ? Center(
                  child: ErrorView(
                    message: state.errorMessage!,
                    actionLabel: 'Tentar novamente',
                    onAction: () => ref.read(benefitViewModelProvider.notifier).loadRedeemedBenefits(),
                  ),
                )
              : _buildContent(state.redeemedBenefits),
    );
  }
  
  Widget _buildContent(List<RedeemedBenefit> benefits) {
    if (benefits.isEmpty) {
      return _buildEmptyState();
    }
    
    // Filtra os benefícios por status
    final activeAndAvailable = benefits.where((b) => 
      b.status == BenefitStatus.active).toList();
    
    final used = benefits.where((b) => 
      b.status == BenefitStatus.used).toList();
    
    final expiredOrCancelled = benefits.where((b) => 
      b.status == BenefitStatus.expired || 
      b.status == BenefitStatus.cancelled).toList();
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTabContent(activeAndAvailable, 'Você não tem benefícios ativos'),
        _buildTabContent(used, 'Você não tem benefícios utilizados'),
        _buildTabContent(expiredOrCancelled, 'Você não tem benefícios expirados ou cancelados'),
      ],
    );
  }
  
  // Constrói o conteúdo de uma tab
  Widget _buildTabContent(List<RedeemedBenefit> benefits, String emptyMessage) {
    if (benefits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: AppTypography.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RedeemedBenefitCard(
            redeemedBenefit: benefit,
            onTap: () => _navigateToRedeemedBenefitDetail(benefit.id),
          ),
        );
      },
    );
  }
  
  // Constrói o estado vazio (quando não há benefícios resgatados)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Você ainda não resgatou nenhum benefício',
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Resgate benefícios utilizando seus pontos e eles aparecerão aqui',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Verificar acesso antes de navegar para benefícios
                final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
                if (hasAccess) {
                  Navigator.pushReplacementNamed(context, '/benefits');
                } else {
                  // Mostrar diálogo de bloqueio profissional
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (dialogContext) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6A5ACD),
                              Color(0xFF9370DB),
                              Color(0xFFBA55D3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Benefícios Exclusivos',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Continue evoluindo para desbloquear acesso aos benefícios exclusivos dos nossos parceiros.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF6A5ACD),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Entendi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Ver benefícios disponíveis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Navega para a tela de detalhes de um benefício resgatado
  void _navigateToRedeemedBenefitDetail(String redeemedBenefitId) {
    ref.read(benefitViewModelProvider.notifier).selectRedeemedBenefit(redeemedBenefitId);
    Navigator.pushNamed(context, '/benefits/redeemed/detail');
  }
} 
