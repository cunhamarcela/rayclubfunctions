// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../../core/providers/providers.dart';
import '../models/challenge.dart';
import '../models/challenge_group.dart';
import '../providers/challenge_provider.dart';
import '../viewmodels/challenge_view_model.dart';
import '../viewmodels/challenge_group_view_model.dart';
import '../widgets/challenge_card.dart';

// Adicionando o provider para o usuário atual
final currentUserProvider = FutureProvider<String?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final user = await authRepository.getCurrentUser();
  return user?.id;
});

@RoutePage()
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('⚠️ NOVA IMPLEMENTAÇÃO: ChallengesScreen - initState chamado');
    
    // Carrega o desafio oficial quando a tela aparece pela primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('⚠️ NOVA IMPLEMENTAÇÃO: ChallengesScreen - postFrameCallback executado');
      ref.read(challengeViewModelProvider.notifier).loadOfficialChallenge();
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeViewModelProvider);
    
    // Log para debug
    debugPrint('⚠️ NOVA IMPLEMENTAÇÃO: ChallengesScreen - build');
    debugPrint('⚠️ NOVA IMPLEMENTAÇÃO: isLoading=${challengeState.isLoading}, challenge=${challengeState.officialChallenge?.title}');
    
    // Redireciona automaticamente para os detalhes do desafio oficial se disponível
    if (!challengeState.isLoading && challengeState.officialChallenge != null) {
      // Executa a navegação após a construção do frame atual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('⚠️ NOVA IMPLEMENTAÇÃO: Redirecionando para detalhes do desafio oficial');
        context.router.replace(ChallengeDetailRoute(challengeId: challengeState.officialChallenge!.id));
      });
    }
    
    // Mostra uma tela de carregamento enquanto espera o desafio oficial
    return Scaffold(
      appBar: AppBar(
        title: Text('Desafios', 
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.textDark,
            fontFamily: 'StingerTrial',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/logos/app/headerdesafio.png'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child: Center(
            child: challengeState.isLoading
                ? const LoadingIndicator()
                : challengeState.officialChallenge == null
                    ? EmptyState(
                        icon: Icons.emoji_events_outlined,
                        message: challengeState.errorMessage ?? 'Não há desafio oficial disponível no momento',
                        actionLabel: challengeState.errorMessage != null ? 'Tentar novamente' : null,
                        onAction: challengeState.errorMessage != null
                            ? () => ref.read(challengeViewModelProvider.notifier).loadOfficialChallenge()
                            : null,
                      )
                    : const LoadingIndicator(), // Exibe loading durante o redirecionamento
          ),
        ),
      ),
    );
  }
} 