// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';

/// Utilitário para navegação entre telas
class AppNavigator {
  /// Navega para uma rota genérica usando string
  static void navigateTo(BuildContext context, String route) {
    try {
      context.router.pushNamed(route);
    } catch (e) {
      debugPrint('Erro ao navegar para $route: $e');
    }
  }

  /// Navega para a lista de desafios
  static void navigateToChallenges(BuildContext context) {
    context.router.push(const ChallengesListRoute());
  }

  /// Navega para a tela de benefícios com verificação de acesso
  static void navigateToBenefits(BuildContext context, WidgetRef ref) {
    // Verificar acesso antes de navegar
    final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
    if (hasAccess) {
      context.router.pushNamed('/benefits');
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
  }

  /// Navega para o dashboard enhanced
  static void navigateToDashboardEnhanced(BuildContext context) {
    context.router.pushNamed('/dashboard-enhanced');
  }

  /// Navega para o dashboard principal
  static void navigateToDashboard(BuildContext context) {
    try {
      context.router.push(const DashboardRoute());
    } catch (e) {
      debugPrint('Erro ao navegar para dashboard: $e');
      context.router.pushNamed('/dashboard');
    }
  }

  /// Navega para as configurações
  static void navigateToSettings(BuildContext context) {
    context.router.pushNamed('/settings');
  }

  /// Navega para a ajuda
  static void navigateToHelp(BuildContext context) {
    context.router.pushNamed('/help');
  }

  /// Navega para o plano de progresso
  static void navigateToProgressPlan(BuildContext context) {
    try {
      context.router.push(const ProgressPlanRoute());
    } catch (e) {
      debugPrint('Erro ao navegar para plano de progresso: $e');
      context.router.pushNamed('/progress/plan');
    }
  }

  /// Navega para a tela de detalhes de um desafio
  static void navigateToChallengeDetail(BuildContext context, String challengeId) {
    context.router.pushNamed('/challenges/$challengeId');
  }
  
  /// Navega para o formulário de criação/edição de desafio
  static void navigateToChallengeForm(BuildContext context, {String? id}) {
    final route = id != null ? '/challenges/form/$id' : '/challenges/form';
    context.router.pushNamed(route);
  }

  /// Navega para a lista de grupos do usuário
  static void navigateToChallengeGroups(BuildContext context) {
    context.router.pushNamed(AppRoutes.challengeGroups);
  }
  
  /// Navega para os detalhes de um grupo específico
  static void navigateToChallengeGroupDetail(BuildContext context, String groupId) {
    context.router.pushNamed('/challenges/groups/$groupId');
  }
  
  /// Navega para a tela de convites de grupos pendentes
  static void navigateToChallengeGroupInvites(BuildContext context) {
    context.router.pushNamed(AppRoutes.challengeGroupInvites);
  }
  
  /// Navega para a tela de ranking de um desafio
  static void navigateToChallengeRanking(BuildContext context, String challengeId) {
    context.router.pushNamed('/challenges/ranking/$challengeId');
  }
  
  /// Navega para o detalhe do dia específico no progresso
  /// Implementação robusta com múltiplos fallbacks
  static void navigateToProgressDay(BuildContext context, int day) {
    try {
      debugPrint('AppNavigator: Tentando navegar para ProgressDayRoute(day: $day)');
      // Forçar o uso da versão tipada diretamente
      context.router.push(ProgressDayRoute(day: day));
    } catch (e) {
      debugPrint('Erro ao navegar para dashboard via route typed: $e');
      
      try {
        // Tenta via route string se o typed falhar
        context.router.pushNamed('/progress/day/$day');
      } catch (e2) {
        debugPrint('Erro ao navegar para dashboard via string: $e2');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar o dashboard.'))
        );
      }
    }
  }

  /// Navega para a tela administrativa de erros
  static void navigateToAdminErrors(BuildContext context) {
    context.router.pushNamed(AppRoutes.adminErrors);
  }
} 