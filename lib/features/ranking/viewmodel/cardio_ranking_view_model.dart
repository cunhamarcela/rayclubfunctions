import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ranking_service.dart';
import '../data/cardio_ranking_entry.dart';
import '../presentation/cardio_ranking_filters.dart';
import '../providers/ranking_refresh_provider.dart';
import 'cardio_ranking_state.dart';

class CardioRankingViewModel extends StateNotifier<CardioRankingState> {
  final RankingService service;
  final Ref ref;
  static const int pageSize = 50;

  CardioRankingViewModel({required this.service, required this.ref})
      : super(const CardioRankingState()) {
    _checkParticipationStatus();
    
    // Escutar notificações de refresh
    ref.listen(rankingRefreshNotifierProvider, (previous, next) {
      if (previous != next && state.isParticipating) {
        print('DEBUG: Detectou novo treino registrado, atualizando ranking');
        refresh();
      }
    });
  }

  Future<void> refresh() async {
    // Só tentar carregar se estiver participando
    if (!state.isParticipating) {
      print('DEBUG: Usuário não está participando, limpando estado');
      state = state.copyWith(
        isLoading: false, 
        pageIndex: 0, 
        items: [], 
        hasMore: false
      );
      return;
    }
    
    state = state.copyWith(isLoading: true, pageIndex: 0, items: [], hasMore: true);
    await loadMore(reset: true);
  }

  Future<void> loadMore({bool reset = false}) async {
    print('DEBUG: loadMore INICIADO - reset: $reset, isParticipating: ${state.isParticipating}');
    
    // Só carregar se estiver participando
    if (!state.isParticipating) {
      print('DEBUG: Usuário não está participando, não carregando ranking');
      return;
    }
    
    if ((state.isLoading && !reset) || (!state.hasMore && !reset)) {
      print('DEBUG: loadMore CANCELADO - isLoading: ${state.isLoading}, hasMore: ${state.hasMore}, reset: $reset');
      return;
    }
    
    state = state.copyWith(isLoading: true);

    try {
      DateTime? from;
      DateTime? to;
      final window = ref.read(cardioWindowProvider);
      final now = DateTime.now().toUtc();
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

      final offset = reset ? 0 : state.pageIndex * pageSize;
      print('DEBUG: Tentando carregar ranking - offset: $offset, limit: $pageSize');
      
      final page = await service.getCardioRanking(
        from: from, 
        to: to, 
        limit: pageSize, 
        offset: offset
      );
      
      print('DEBUG: Loaded ${page.length} items, offset: $offset');
      
      final List<CardioRankingEntry> newItems = reset ? page : [...state.items, ...page];
      
      state = state.copyWith(
        items: newItems,
        pageIndex: reset ? 1 : state.pageIndex + 1,
        isLoading: false,
        hasMore: page.length == pageSize,
      );
    } catch (error, stackTrace) {
      print('ERROR loading ranking: $error');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        hasMore: false,
      );
    }
  }

    /// Verifica o status de participação do usuário no desafio
  Future<void> _checkParticipationStatus() async {
    try {
      final isParticipating = await service.getCardioParticipationStatus();
      ref.read(cardioParticipationProvider.notifier).state = isParticipating;

      state = state.copyWith(isParticipating: isParticipating);
      print('DEBUG: Status de participação verificado no banco: $isParticipating');

      // Se estiver participando, carregar os dados do ranking
      if (isParticipating) {
        print('DEBUG: Usuário participando, iniciando carregamento do ranking...');
        await refresh();
      } else {
        print('DEBUG: Usuário NÃO participando, limpando estado do ranking');
      }
    } catch (error) {
      print('ERROR checking participation status: $error');
      ref.read(cardioParticipationProvider.notifier).state = false;
      state = state.copyWith(isParticipating: false);
    }
  }

    /// Alterna a participação do usuário no desafio (entrar/sair)
  Future<void> toggleParticipation() async {
    if (state.isJoiningLeaving) return;

    state = state.copyWith(isJoiningLeaving: true);

    try {
      final currentStatus = ref.read(cardioParticipationProvider);
      print('DEBUG: Status atual antes do toggle: $currentStatus');

      if (currentStatus) {
        // Usuário quer sair do desafio
        print('DEBUG: Tentando sair do desafio...');
        await service.leaveCardioChallenge();
        print('DEBUG: ✅ Usuário saiu do desafio');
      } else {
        // Usuário quer entrar no desafio
        print('DEBUG: Tentando entrar no desafio...');
        await service.joinCardioChallenge();
        print('DEBUG: ✅ Usuário entrou no desafio');
      }

      // Aguardar um pouco para processar
      await Future.delayed(const Duration(milliseconds: 500));

      // Verificar novamente o status no banco para ter certeza
      print('DEBUG: Verificando status no banco...');
      final actualStatus = await service.getCardioParticipationStatus();
      print('DEBUG: ✅ Status confirmado no banco após toggle: $actualStatus');

      // Atualizar estado local com o status confirmado
      ref.read(cardioParticipationProvider.notifier).state = actualStatus;
      state = state.copyWith(
        isParticipating: actualStatus,
        isJoiningLeaving: false,
      );

      if (actualStatus) {
        // Se entrou no desafio, carregar dados
        print('DEBUG: Carregando dados do ranking...');
        await refresh();
      } else {
        // Se saiu, limpar a lista
        print('DEBUG: Limpando lista do ranking...');
        state = state.copyWith(
          items: [],
          pageIndex: 0,
          hasMore: true,
        );
      }
    } catch (error) {
      print('ERROR toggling participation: $error');
      print('ERROR details: ${error.toString()}');
      state = state.copyWith(isJoiningLeaving: false);
      
      // Tentar recuperar o status real
      try {
        final recoveredStatus = await service.getCardioParticipationStatus();
        print('DEBUG: Status recuperado após erro: $recoveredStatus');
        ref.read(cardioParticipationProvider.notifier).state = recoveredStatus;
        state = state.copyWith(isParticipating: recoveredStatus);
      } catch (e) {
        print('ERROR recovering status: $e');
      }
    }
  }

  /// Método público para refresh completo (usado após registrar treino)
  Future<void> refreshParticipationAndRanking() async {
    print('DEBUG: Refreshing participation and ranking after workout');
    await _checkParticipationStatus();
  }
}

final cardioRankingViewModelProvider =
    StateNotifierProvider<CardioRankingViewModel, CardioRankingState>((ref) {
  return CardioRankingViewModel(service: RankingService(), ref: ref);
});


