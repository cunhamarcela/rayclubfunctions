import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../presentation/cardio_ranking_filters.dart';
import '../viewmodel/cardio_ranking_view_model.dart';
import '../viewmodel/cardio_ranking_state.dart';
import '../../ranking/data/cardio_ranking_entry.dart';
import '../../ranking/data/ranking_service.dart';

@RoutePage()
class CardioRankingScreen extends ConsumerStatefulWidget {
  const CardioRankingScreen({super.key});

  @override
  ConsumerState<CardioRankingScreen> createState() => _CardioRankingScreenState();
}

class _CardioRankingScreenState extends ConsumerState<CardioRankingScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // O _checkParticipationStatus() já é chamado no construtor do ViewModel
      // Não fazemos mais nada aqui, o ViewModel se encarrega de tudo
    });
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
        ref.read(cardioRankingViewModelProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(cardioRankingViewModelProvider.notifier).refresh();
  }

  void _onWindowChange(CardioWindow w) async {
    ref.read(cardioWindowProvider.notifier).state = w;
    await ref.read(cardioRankingViewModelProvider.notifier).refresh();
  }

  String _getWindowText(CardioWindow window) {
    switch (window) {
      case CardioWindow.all:
        return 'Tudo';
      case CardioWindow.d7:
        return '7 dias';
      case CardioWindow.d30:
        return '30 dias';
      case CardioWindow.d90:
        return '90 dias';
    }
  }

  @override
  Widget build(BuildContext context) {
    final window = ref.watch(cardioWindowProvider);
    final state = ref.watch(cardioRankingViewModelProvider);
    final isParticipating = state.isParticipating; // Use estado do ViewModel

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Desafio Cardio ⚡',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<CardioWindow>(
              initialValue: window,
              onSelected: _onWindowChange,
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getWindowText(window),
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textDark,
                      size: 18,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => const [
                PopupMenuItem(value: CardioWindow.all, child: Text('Tudo')),
                PopupMenuItem(value: CardioWindow.d7, child: Text('Últimos 7 dias')),
                PopupMenuItem(value: CardioWindow.d30, child: Text('Últimos 30 dias')),
                PopupMenuItem(value: CardioWindow.d90, child: Text('Últimos 90 dias')),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            // Challenge Card
            SliverToBoxAdapter(
              child: _ChallengeCard(
                isParticipating: isParticipating,
                isLoading: state.isJoiningLeaving,
                onToggleParticipation: () async {
                  print('DEBUG: Botão clicado! isParticipating: $isParticipating, isLoading: ${state.isJoiningLeaving}');
                  await ref.read(cardioRankingViewModelProvider.notifier).toggleParticipation();
                },
                userMinutes: _getUserMinutes(state),
              ),
            ),
            
            // Ranking Section - Only show when participating
            if (isParticipating) ...[
              // Ranking Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'Ranking 🏆',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              
              // Ranking List or Empty State
              if (state.items.isEmpty && !state.isLoading)
                SliverToBoxAdapter(
                  child: _EmptyRankingState(
                    isParticipating: isParticipating,
                    onJoinChallenge: () async {
                      final service = RankingService();
                      await service.joinCardioChallenge();
                      ref.read(cardioParticipationProvider.notifier).state = true;
                      await ref.read(cardioRankingViewModelProvider.notifier).refresh();
                    },
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == state.items.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: state.hasMore && state.isLoading
                                ? const CircularProgressIndicator(
                                    color: AppColors.orange,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }
                      final entry = state.items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: _CardioRankingTile(
                          position: index + 1, 
                          entry: entry,
                          onTap: () => _navigateToParticipantDetails(context, entry),
                        ),
                      );
                    },
                    childCount: state.items.length + 1,
                  ),
                ),
            ] else ...[
              // Welcome message when not participating
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.group,
                          size: 48,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Participe do Desafio!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Entre no desafio para ver o ranking dos participantes e acompanhar os treinos de todos! 🚀',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getUserMinutes(CardioRankingState state) {
    // Busca os minutos do usuário atual no ranking
    final auth = ref.read(authViewModelProvider);
    String? currentUserId;
    
    auth.whenOrNull(
      authenticated: (user) => currentUserId = user.id,
    );
    
    if (currentUserId == null) return 0;
    
    final userEntry = state.items.where((entry) => entry.userId == currentUserId!).firstOrNull;
    return userEntry?.totalCardioMinutes ?? 0;
  }

  void _navigateToParticipantDetails(BuildContext context, CardioRankingEntry entry) {
    // Passar os mesmos filtros de período para consistência
    final window = ref.read(cardioWindowProvider);
    final now = DateTime.now().toUtc();
    
    DateTime? from;
    DateTime? to;
    
    switch (window) {
      case CardioWindow.d7:
        from = now.subtract(const Duration(days: 7));
        to = now;
        break;
      case CardioWindow.d30:
        from = now.subtract(const Duration(days: 30));
        to = now;
        break;
      case CardioWindow.d90:
        from = now.subtract(const Duration(days: 90));
        to = now;
        break;
      case CardioWindow.all:
        from = null;
        to = null;
        break;
    }
    
    context.router.push(ParticipantWorkoutsRoute(
      participantId: entry.userId,
      participantName: entry.fullName,
      dateFrom: from,
      dateTo: to,
    ));
  }
}

class _ChallengeCard extends StatelessWidget {
  final bool isParticipating;
  final VoidCallback onToggleParticipation;
  final int userMinutes;
  final bool isLoading;

  const _ChallengeCard({
    required this.isParticipating,
    required this.onToggleParticipation,
    required this.userMinutes,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isParticipating ? AppGradients.primaryGradient : AppGradients.lightBackgroundGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.orangeDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Desafio Cardio',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isParticipating ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isParticipating 
                            ? 'Você está participando! 🔥'
                            : 'Junte-se ao desafio e conquiste seu coração! ✨',
                        style: TextStyle(
                          fontSize: 14,
                          color: isParticipating 
                              ? Colors.white.withOpacity(0.9) 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (isParticipating) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Seus minutos: $userMinutes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isLoading ? null : () {
                  print('DEBUG: GestureDetector ativado! isLoading: $isLoading');
                  onToggleParticipation();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isLoading 
                        ? Colors.grey 
                        : (isParticipating ? Colors.white.withOpacity(0.2) : AppColors.orange),
                    borderRadius: BorderRadius.circular(16),
                    border: isParticipating 
                        ? const Border.fromBorderSide(BorderSide(color: Colors.white, width: 1))
                        : null,
                  ),
                  child: isLoading 
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isParticipating ? 'Sair do Desafio' : 'Entrar no Desafio',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRankingState extends StatelessWidget {
  final bool isParticipating;
  final VoidCallback onJoinChallenge;

  const _EmptyRankingState({
    required this.isParticipating,
    required this.onJoinChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 48,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isParticipating 
                ? 'Nenhum treino registrado ainda'
                : 'O ranking está vazio',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isParticipating 
                ? 'Que tal começar seu primeiro treino de cardio? Cada minuto conta! 💪'
                : 'Entre no desafio e seja o primeiro a aparecer aqui! 🚀',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isParticipating) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onJoinChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Entrar no Desafio',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardioRankingTile extends StatelessWidget {
  final int position;
  final CardioRankingEntry entry;
  final VoidCallback? onTap;
  
  const _CardioRankingTile({
    required this.position, 
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty;
    final initials = entry.fullName.trim().isNotEmpty
        ? entry.fullName.trim().split(RegExp(r'\s+')).take(2).map((e) => e[0].toUpperCase()).join()
        : position.toString();

    Color? medalColor;
    IconData? medalIcon;
    
    if (position == 1) {
      medalColor = const Color(0xFFFFD700); // Ouro
      medalIcon = Icons.emoji_events;
    } else if (position == 2) {
      medalColor = const Color(0xFFC0C0C0); // Prata
      medalIcon = Icons.emoji_events;
    } else if (position == 3) {
      medalColor = const Color(0xFFCD7F32); // Bronze
      medalIcon = Icons.emoji_events;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Position with medal
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: medalColor?.withOpacity(0.1) ?? AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: medalIcon != null
                      ? Icon(
                          medalIcon,
                          color: medalColor,
                          size: 24,
                        )
                      : Text(
                          '$position',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.backgroundLight,
                backgroundImage: hasAvatar ? NetworkImage(entry.avatarUrl!) : null,
                child: hasAvatar 
                    ? null 
                    : Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Name and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.totalCardioMinutes} min',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Minutes badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.totalCardioMinutes}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}