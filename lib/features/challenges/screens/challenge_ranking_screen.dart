import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../models/challenge_group.dart';
import '../models/challenge_progress.dart';
import '../providers.dart';
import '../providers/challenge_providers.dart';
import '../providers/ranking_favorites_provider.dart';
import '../widgets/favorite_star_button.dart';
import '../viewmodels/challenge_ranking_view_model.dart' show ChallengeRankingState;

/// Tela temporária para visualizar o ranking de um desafio
@RoutePage()
class ChallengeRankingScreen extends HookConsumerWidget {
  final String challengeId;
  
  const ChallengeRankingScreen({
    Key? key,
    @PathParam('challengeId') required this.challengeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar o ViewModel com o ID do desafio
    useEffect(() {
      Future.microtask(() {
        ref.read(challengeRankingViewModelProvider.notifier).init(challengeId);
        ref.read(rankingFavoritesProvider.notifier).loadFavorites(challengeId);
      });
      return null;
    }, [challengeId]);

    final state = ref.watch(challengeRankingViewModelProvider);
    final showOnlyFavorites = ref.watch(showOnlyFavoritesProvider);
    final favorites = ref.watch(rankingFavoritesProvider);
    
    // Filtrar lista baseado na pesquisa e favoritos
    var filteredList = state.filteredProgressList;
    
    // Aplicar filtro de favoritos se necessário
    if (showOnlyFavorites) {
      filteredList = filteredList.where((progress) => favorites.contains(progress.userId)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Participantes do Desafio',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(challengeRankingViewModelProvider.notifier).loadChallengeRanking();
        },
        child: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
                  ? Center(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : Column(
                      children: [
                        // Adicionar o filtro de grupo
                        if (state.userGroups.isNotEmpty)
                          _buildGroupFilter(context, ref, state.userGroups, state.selectedGroupIdForFilter),
                        // Indicador de filtro ativo
                        if (state.selectedGroupIdForFilter != null)
                          _buildActiveFilterIndicator(context, ref, state),
                        // Toggle de favoritos
                        _buildFavoritesToggle(context, ref),
                        // Barra de pesquisa
                        _buildSearchBar(context, ref, state),
                        // Lista de ranking
                        Expanded(
                          child: filteredList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        state.searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
                                        size: 64,
                                        color: AppColors.darkGray.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        state.searchQuery.isNotEmpty
                                            ? 'Nenhum participante encontrado para "${state.searchQuery}"'
                                            : 'Nenhum participante encontrado',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.darkGray,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (state.searchQuery.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(challengeRankingViewModelProvider.notifier).clearSearch();
                                          },
                                          child: const Text('Limpar pesquisa'),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    final progress = filteredList[index];
                                    return _buildRankingItem(context, ref, progress, index + 1);
                                  },
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  /// Constrói o filtro de grupos
  Widget _buildGroupFilter(
    BuildContext context,
    WidgetRef ref,
    List<ChallengeGroup> userGroups,
    String? selectedGroupId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por grupo:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String?>(
                value: selectedGroupId,
                icon: const Icon(Icons.filter_list),
                isExpanded: true,
                hint: const Text('Todos os participantes'),
                items: [
                  // Opção para todos os participantes
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos os participantes'),
                  ),
                  // Opções para cada grupo do usuário
                  ...userGroups.map((group) => DropdownMenuItem<String?>(
                        value: group.id,
                        child: Text(
                          group.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                ],
                onChanged: (String? newGroupId) {
                  ref.read(challengeRankingViewModelProvider.notifier).filterRankingByGroup(newGroupId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um indicador de filtro ativo
  Widget _buildActiveFilterIndicator(
    BuildContext context,
    WidgetRef ref,
    ChallengeRankingState state,
  ) {
    // Encontra o nome do grupo selecionado
    final selectedGroup = state.userGroups
        .firstWhere((group) => group.id == state.selectedGroupIdForFilter, orElse: () => ChallengeGroup.empty);

    if (selectedGroup.id.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.purple.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: AppColors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtrando por: ${selectedGroup.name}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              ref.read(challengeRankingViewModelProvider.notifier).filterRankingByGroup(null);
            },
            child: Icon(Icons.close, size: 16, color: AppColors.purple),
          ),
        ],
      ),
    );
  }

  /// Constrói um item da lista de ranking
  Widget _buildRankingItem(BuildContext context, WidgetRef ref, ChallengeProgress progress, int position) {
    final isCurrentUser = progress.userId == ref.watch(currentUserProvider)?.id;
    
    return FadeInRight(
      duration: const Duration(milliseconds: 300),
      delay: Duration(milliseconds: position * 30),
      child: _buildUserRow(context, ref, progress, position, isCurrentUser, challengeId),
    );
  }

  Widget _buildUserRow(BuildContext context, WidgetRef ref, ChallengeProgress progress, int position, bool isHighlighted, String challengeId) {
    
    // Definir cor de posição adequada
    final Color positionBgColor;
    if (position == 1) {
      positionBgColor = AppColors.pastelYellow; // Ouro
    } else if (position == 2) {
      positionBgColor = AppColors.lightGray; // Prata 
    } else if (position == 3) {
      positionBgColor = AppColors.softPink; // Bronze
    } else {
      positionBgColor = AppColors.backgroundSecondary;
    }

    // Verificar se é o usuário atual para permitir edição
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isCurrentUser = currentUserId != null && progress.userId == currentUserId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.orange.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? AppColors.orange : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position
          Expanded(
            flex: 1,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: position <= 3 ? positionBgColor : (isHighlighted ? AppColors.orange : AppColors.backgroundSecondary),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  position.toString(),
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: position <= 3 ? AppColors.darkGray : (isHighlighted ? Colors.white : AppColors.darkGray),
                  ),
                ),
              ),
            ),
          ),
          // Participant info
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isHighlighted ? AppColors.orange : AppColors.backgroundSecondary,
                    shape: BoxShape.circle,
                    image: progress.userPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(progress.userPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: progress.userPhotoUrl == null
                      ? Icon(
                          Icons.person,
                          color: isHighlighted ? Colors.white : AppColors.darkGray,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Verificar se é o próprio usuário para oferecer opções extras
                          if (isCurrentUser) {
                            _showUserWorkoutOptions(context, ref, progress, challengeId);
                          } else {
                            // Comportamento padrão para outros usuários
                            _navigateToUserWorkouts(context, progress, challengeId);
                          }
                        },
                        child: Row(
                          children: [
                            // Text with clickable styling
                            Expanded(
                              child: Text(
                                progress.userName,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isHighlighted ? AppColors.orange : AppColors.purple,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Icon indicating it's clickable or editable
                            Icon(
                              isCurrentUser ? Icons.edit : Icons.fitness_center,
                              size: 14,
                              color: isHighlighted ? AppColors.orange : AppColors.purple,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Última atualização: ${_formatLastUpdated(progress.lastUpdated)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.darkGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Points
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighlighted 
                      ? AppColors.orange.withOpacity(0.1)
                      : (position <= 3 ? positionBgColor.withOpacity(0.2) : AppColors.backgroundSecondary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${progress.points}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isHighlighted ? AppColors.orange : AppColors.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Check-ins
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.purple,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.checkInsCount}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                  if (progress.consecutiveDays != null && progress.consecutiveDays! > 1) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: AppColors.orange,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${progress.consecutiveDays}',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Estrela de favorito
          FavoriteStarButton(
            userId: progress.userId,
            challengeId: challengeId,
          ),
        ],
      ),
    );
  }



  String _formatLastUpdated(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'há ${difference.inMinutes} min';
      }
      return 'há ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else {
      return 'há ${difference.inDays} dias';
    }
  }

  /// Navega para a tela de treinos do usuário
  void _navigateToUserWorkouts(
    BuildContext context, 
    ChallengeProgress progress, 
    String challengeId
  ) {
    // Verificar se o userId é válido antes de navegar
    if (progress.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do usuário não disponível.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.pushRoute(
      UserChallengeWorkoutsRoute(
        challengeId: challengeId,
        userId: progress.userId,
        userName: progress.userName,
      ),
    );
  }
  
  /// Exibe opções para o usuário atual
  void _showUserWorkoutOptions(
    BuildContext context, 
    WidgetRef ref,
    ChallengeProgress progress, 
    String challengeId
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility, color: AppColors.purple),
                title: const Text('Ver meus treinos'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToUserWorkouts(context, progress, challengeId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.orange),
                title: const Text('Editar meus treinos'),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Obter dados para exibir lista de treinos para edição
                  final repository = ref.read(challengeRepositoryProvider);
                  
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    
                    final workouts = await repository.getUserChallengeWorkoutRecords(
                      challengeId,
                      progress.userId,
                      limit: 100,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context); // Fechar diálogo de carregamento
                      
                      if (workouts.isEmpty) {
                        SnackbarHelper.showInfo(
                          context: context, 
                          message: 'Você ainda não tem treinos neste desafio.',
                        );
                        return;
                      }
                      
                      // Navegar para a tela de treinos com opções de edição
                      context.pushRoute(
                        UserChallengeWorkoutsRoute(
                          challengeId: challengeId,
                          userId: progress.userId,
                          userName: progress.userName,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Fechar diálogo de carregamento
                      SnackbarHelper.showError(
                        context: context, 
                        message: 'Erro ao carregar treinos: $e',
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói a barra de pesquisa
  Widget _buildSearchBar(BuildContext context, WidgetRef ref, ChallengeRankingState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(challengeRankingViewModelProvider.notifier).updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Pesquisar participante...',
          hintStyle: TextStyle(
            color: AppColors.darkGray.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.purple,
            size: 20,
          ),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.darkGray,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(challengeRankingViewModelProvider.notifier).clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(
          color: AppColors.darkGray,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Constrói o toggle de favoritos
  Widget _buildFavoritesToggle(BuildContext context, WidgetRef ref) {
    final showOnlyFavorites = ref.watch(showOnlyFavoritesProvider);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrar apenas favoritos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Switch(
            value: showOnlyFavorites,
            onChanged: (value) {
              ref.read(showOnlyFavoritesProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}

// Stream provider para o ranking em tempo real
final realtimeProgressProvider = StreamProvider.family<List<ChallengeProgress>, String>((ref, challengeId) {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.watchChallengeParticipants(challengeId);
}); 