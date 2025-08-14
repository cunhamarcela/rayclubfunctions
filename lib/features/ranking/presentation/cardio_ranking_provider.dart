import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ranking/data/ranking_service.dart';
import '../../ranking/data/cardio_ranking_entry.dart';
import 'cardio_ranking_filters.dart';

const _pageSize = 50;

final cardioRankingPagedProvider = FutureProvider.family.autoDispose<List<CardioRankingEntry>, int>((ref, pageIndex) async {
  final service = RankingService();
  final window = ref.watch(cardioWindowProvider);

  DateTime? from;
  DateTime? to;
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

  final offset = pageIndex * _pageSize;
  return service.getCardioRanking(from: from, to: to, limit: _pageSize, offset: offset);
});


