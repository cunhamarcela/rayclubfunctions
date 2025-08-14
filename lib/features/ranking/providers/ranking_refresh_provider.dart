import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para notificar quando treinos são registrados
/// e o ranking precisa ser atualizado
final rankingRefreshNotifierProvider = StateProvider<int>((ref) => 0);

/// Função helper para notificar refresh do ranking
void notifyRankingRefresh(WidgetRef ref) {
  final current = ref.read(rankingRefreshNotifierProvider);
  ref.read(rankingRefreshNotifierProvider.notifier).state = current + 1;
  print('DEBUG: Notificando refresh do ranking cardio');
}
