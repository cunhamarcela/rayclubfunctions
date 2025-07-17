import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_navigator.dart';
import '../../../core/router/app_router.dart';
import '../../../services/image_service.dart';
import '../models/challenge.dart';
import '../models/challenge_state.dart';
import '../models/challenge_progress.dart';
import '../viewmodels/challenge_view_model.dart';
import '../providers/challenge_provider.dart';
import '../widgets/challenge_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/bottom_navigation_bar.dart';

@RoutePage()
class ChallengesListScreen extends ConsumerStatefulWidget {
  const ChallengesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends ConsumerState<ChallengesListScreen> {
  late final ImageService imageService;

  @override
  void initState() {
    super.initState();
    imageService = ImageService();
    
    // Carregar desafio oficial por múltiplos caminhos para garantir que algum funcione
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Método 1: Usando o ViewModel
      ref.read(challengeViewModelProvider.notifier).loadOfficialChallenge();
      
      // Método 2: Forçar atualização do provider futuro
      ref.refresh(officialChallengeProvider);
    });
  }

  Future<void> _refreshChallenge() async {
    debugPrint('🔄 Atualizando desafio oficial...');
    // Atualizar ambos para garantir
    await ref.read(challengeViewModelProvider.notifier).loadOfficialChallenge();
    ref.refresh(officialChallengeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.id;
    
    // Debug log para verificar o estado atual
    final oficialChallenge = state.officialChallenge;
    debugPrint('🧪 Estado na build: isLoading=${state.isLoading}, '
        'officialChallenge=${oficialChallenge?.title}, '
        'errorMessage=${state.errorMessage}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Desafio Ray',
          style: AppTypography.headingLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        actions: [
          // Ícone para acessar convites de grupos
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              try {
                context.router.pushNamed(AppRoutes.challengeGroupInvites);
              } catch (e) {
                debugPrint('❌ Erro ao navegar para convites: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            },
            tooltip: 'Convites pendentes',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshChallenge,
        color: AppColors.secondary,
        backgroundColor: Colors.white,
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            debugPrint('⏱️ Navegando para grupos de desafio (FAB)');
            context.router.push(const ChallengeGroupsRoute());
          } catch (e) {
            debugPrint('❌ Erro ao navegar para grupos: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao abrir grupos: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.group),
        tooltip: 'Meus grupos',
      ),
      bottomSheet: null,
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildBody(ChallengeState state) {
    // Verifica se está carregando
    if (state.isLoading) {
      return const LoadingView();
    }
    
    // Verifica se há erro
    if (state.errorMessage != null) {
      return ErrorView(
        message: state.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: _refreshChallenge,
      );
    }
    
    // Método 1: Buscar desafio oficial do estado do ViewModel
    final officialChallenge = state.officialChallenge;
    
    // Se não encontrou no estado, tenta o provider assíncrono
    if (officialChallenge == null) {
      // Método 2: Usar o provider específico para desafio oficial
      return ref.watch(officialChallengeProvider).when(
        data: (challenge) {
          if (challenge != null) {
            debugPrint('✅ Desafio encontrado via provider específico: ${challenge.title}');
            return _buildChallengeContent(challenge, state);
          } else {
            return _buildEmptyState();
          }
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: 'Erro ao carregar desafio oficial: $error',
          actionLabel: 'Tentar novamente',
          onAction: _refreshChallenge,
        ),
      );
    }
    
    // Se chegou aqui, temos o desafio no estado
    return _buildChallengeContent(officialChallenge, state);
  }
  
  Widget _buildEmptyState() {
    // Wrap com ListView para permitir o pull-to-refresh quando não há conteúdo
    return ListView(
      // O physics permite que o usuário puxe para baixo para atualizar
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Espaçamento para centralizar o conteúdo
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_score,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum desafio oficial disponível no momento',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshChallenge,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildChallengeContent(Challenge challenge, ChallengeState state) {
    final image = challenge.imageUrl;
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Card principal do desafio com informações básicas
            ChallengeCard(
              challenge: challenge,
              onTap: () {
                try {
                  debugPrint('⏱️ Navegando para detalhes do desafio: ${challenge.id}');
                  context.router.pushNamed(AppRoutes.challengeDetail(challenge.id));
                } catch (e) {
                  debugPrint('❌ Erro ao navegar para detalhes: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao abrir detalhes: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // NOVA SEÇÃO: Progresso simplificado
            Text(
              'Seu Progresso',
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Card de progresso
            _buildProgressCard(state, challenge),
            
            const SizedBox(height: 24),
            
            // NOVA SEÇÃO: Ranking simplificado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ranking',
                  style: AppTypography.headingMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    try {
                      context.router.pushNamed(AppRoutes.challengeRanking(challenge.id));
                    } catch (e) {
                      debugPrint('❌ Erro ao navegar para ranking: $e');
                    }
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Ver Completo'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Lista de top 5 participantes
            _buildTopRankingList(state.progressList),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Novo método para construir o card de progresso
  Widget _buildProgressCard(ChallengeState state, Challenge challenge) {
    final userProgress = state.userProgress;
    
    if (userProgress == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você ainda não está participando deste desafio',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final userId = ref.read(currentUserProvider)?.id;
                  if (userId != null) {
                    // Mostrar loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    // Participar diretamente do desafio
                    ref.read(challengeViewModelProvider.notifier).joinChallenge(
                      challengeId: challenge.id,
                      userId: userId,
                    ).then((_) {
                      // Fechar o diálogo de progresso
                      Navigator.of(context).pop();
                      
                      // Mostrar mensagem de sucesso
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você entrou no desafio com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Recarregar dados após entrar usando múltiplos métodos
                      _refreshChallenge();
                      ref.refresh(officialChallengeProvider);
                      
                      // Navegar para a tela de detalhes atualizada
                      Future.delayed(const Duration(milliseconds: 300), () {
                        context.router.pushNamed(AppRoutes.challengeDetail(challenge.id));
                      });
                    }).catchError((e) {
                      // Fechar o diálogo de progresso
                      Navigator.of(context).pop();
                      
                      // Mostrar erro
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao entrar no desafio: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Você precisa estar logado para participar'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Participar Agora'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Se tiver progresso, mostrar detalhes
    final progressPercentage = userProgress.completionPercentage / 100;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pontuação atual: ${userProgress.points} pts',
                  style: AppTypography.titleMedium.copyWith(
                    color: const Color(0xFF4D4D4D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFB9B7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pos. ${userProgress.position}',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF4D4D4D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Progresso no desafio:',
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFF4D4D4D),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage > 1.0 ? 1.0 : progressPercentage,
              backgroundColor: const Color(0xFFE6E6E6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEFB9B7)),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progressPercentage * 100).toInt()}% concluído',
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF4D4D4D),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF4D4D4D)),
                    const SizedBox(width: 4),
                    Text(
                      'Check-ins: ${userProgress.checkInsCount ?? 0}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFF4D4D4D),
                      ),
                    ),
                  ],
                ),
                if (userProgress.consecutiveDays != null && userProgress.consecutiveDays! > 0)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFEFB9B7)),
                      const SizedBox(width: 4),
                      Text(
                        '${userProgress.consecutiveDays} dias consecutivos',
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFFEFB9B7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Novo método para mostrar o ranking dos 5 primeiros
  Widget _buildTopRankingList(List<ChallengeProgress> progressList) {
    if (progressList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Ainda não há participantes neste desafio'),
        ),
      );
    }
    
    // ✅ USAR DADOS DIRETO DO BANCO (já vem ordenado):
    final topFive = progressList.take(5).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: topFive.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final progress = topFive[index];
          final position = progress.position; // ✅ Usar posição do banco
          
          return ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getPositionColor(position),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  position.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              progress.userName ?? 'Usuário',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${progress.points} pts',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Função auxiliar para definir cores por posição
  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return AppColors.primary;
    }
  }
} 