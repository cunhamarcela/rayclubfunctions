import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/ranking/viewmodel/cardio_ranking_view_model.dart';
import 'package:ray_club_app/features/ranking/data/cardio_ranking_entry.dart';
import 'package:ray_club_app/features/ranking/presentation/cardio_ranking_list.dart';

class _FakeRankingService implements RankingService {
  Future<List<CardioRankingEntry>> getCardioRanking({
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    return _seed;
  }

  late List<CardioRankingEntry> _seed;
  @override
  // ignore: unused_element
  SupabaseClient get supabase => throw UnimplementedError();

  // ignore: unused_element
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // Sem inicializar plugins; evitamos Supabase.instance usando client dummy.
  testWidgets('CardioRankingList shows items from provider', (tester) async {
    final sample = [
      const CardioRankingEntry(
        userId: 'u1',
        fullName: 'Ana Ray',
        avatarUrl: null,
        totalCardioMinutes: 120,
      ),
      const CardioRankingEntry(
        userId: 'u2',
        fullName: 'Bruno Ray',
        avatarUrl: null,
        totalCardioMinutes: 90,
      ),
    ];

    final fake = _FakeRankingService().._seed = sample;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardioRankingViewModelProvider.overrideWith((ref) {
            final vm = CardioRankingViewModel(service: fake, ref: ref);
            // seed inicial
            vm.state = vm.state.copyWith(items: sample, isLoading: false, hasMore: false);
            return vm;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CardioRankingList()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Ana Ray'), findsOneWidget);
    expect(find.textContaining('Bruno Ray'), findsOneWidget);
    expect(find.text('Minutos de cardio: 120'), findsOneWidget);
    expect(find.text('Minutos de cardio: 90'), findsOneWidget);
  }, skip: true);
}


