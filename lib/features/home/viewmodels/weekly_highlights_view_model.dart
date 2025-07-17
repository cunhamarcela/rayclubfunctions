// Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';
import 'package:ray_club_app/features/home/repositories/weekly_highlights_repository.dart';
import 'package:ray_club_app/features/home/viewmodels/states/weekly_highlights_state.dart';
import 'package:ray_club_app/core/providers/supabase_client_provider.dart';

/// Provider para o repositório de destaques da semana
final weeklyHighlightsRepositoryProvider = Provider<WeeklyHighlightsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseWeeklyHighlightsRepository(supabase);
});

/// Provider para o ViewModel de destaques da semana
final weeklyHighlightsViewModelProvider = StateNotifierProvider<WeeklyHighlightsViewModel, WeeklyHighlightsState>((ref) {
  final repository = ref.watch(weeklyHighlightsRepositoryProvider);
  return WeeklyHighlightsViewModel(repository);
});

/// Provider simplificado para lista de destaques da semana (para uso em widgets)
final weeklyHighlightsProvider = Provider<List<WeeklyHighlight>>((ref) {
  return ref.watch(weeklyHighlightsViewModelProvider).highlights;
});

/// ViewModel para os destaques da semana
class WeeklyHighlightsViewModel extends StateNotifier<WeeklyHighlightsState> {
  final WeeklyHighlightsRepository _repository;
  
  WeeklyHighlightsViewModel(this._repository) : super(const WeeklyHighlightsState()) {
    // Carregar dados ao inicializar
    loadHighlights();
  }
  
  /// Carrega a lista de destaques da semana
  Future<void> loadHighlights() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final highlights = await _repository.getWeeklyHighlights();
      state = state.copyWith(highlights: highlights, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  /// Seleciona um destaque específico pelo ID
  Future<void> selectHighlightById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final highlight = await _repository.getHighlightById(id);
      
      state = state.copyWith(
        selectedHighlight: highlight,
        isLoading: false,
      );
      
      if (highlight != null) {
        // Marcar como visualizado assincronamente
        _repository.markHighlightAsViewed(id);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  /// Limpa a seleção atual
  void clearSelection() {
    state = state.copyWith(selectedHighlight: null);
  }
} 