// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/weekly_highlight.dart';

part 'weekly_highlights_state.freezed.dart';

/// Estado para o ViewModel de destaques da semana
@freezed
class WeeklyHighlightsState with _$WeeklyHighlightsState {
  const factory WeeklyHighlightsState({
    /// Lista de destaques da semana
    @Default([]) List<WeeklyHighlight> highlights,
    
    /// Destaque selecionado atualmente
    WeeklyHighlight? selectedHighlight,
    
    /// Flag indicando se está carregando
    @Default(false) bool isLoading,
    
    /// Mensagem de erro, se houver
    String? error,
  }) = _WeeklyHighlightsState;
} 