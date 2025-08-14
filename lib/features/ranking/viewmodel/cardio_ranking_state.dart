import '../../ranking/data/cardio_ranking_entry.dart';

class CardioRankingState {
  final List<CardioRankingEntry> items;
  final bool isLoading;
  final int pageIndex;
  final bool hasMore;
  final bool isParticipating;
  final bool isJoiningLeaving;

  const CardioRankingState({
    this.items = const [],
    this.isLoading = false,
    this.pageIndex = 0,
    this.hasMore = true,
    this.isParticipating = false,
    this.isJoiningLeaving = false,
  });

  CardioRankingState copyWith({
    List<CardioRankingEntry>? items,
    bool? isLoading,
    int? pageIndex,
    bool? hasMore,
    bool? isParticipating,
    bool? isJoiningLeaving,
  }) {
    return CardioRankingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      pageIndex: pageIndex ?? this.pageIndex,
      hasMore: hasMore ?? this.hasMore,
      isParticipating: isParticipating ?? this.isParticipating,
      isJoiningLeaving: isJoiningLeaving ?? this.isJoiningLeaving,
    );
  }
}


