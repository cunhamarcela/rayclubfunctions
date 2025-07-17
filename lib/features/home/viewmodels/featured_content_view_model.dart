// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/featured_content.dart';
import 'package:ray_club_app/features/home/repositories/featured_content_repository.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

part 'featured_content_view_model.freezed.dart';

// Estado do ViewModel
@freezed
class FeaturedContentState with _$FeaturedContentState {
  const factory FeaturedContentState({
    @Default([]) List<FeaturedContent> contents,
    @Default(true) bool isLoading,
    String? error,
    FeaturedContent? selectedContent,
  }) = _FeaturedContentState;
}

// Provider para o repositório
final featuredContentRepositoryProvider = Provider<FeaturedContentRepository>((ref) {
  // Aqui podemos facilmente trocar a implementação quando tivermos Supabase configurado
  return MockFeaturedContentRepository();
  // Para produção:
  // return SupabaseFeaturedContentRepository();
});

// Provider para o ViewModel
final featuredContentViewModelProvider = StateNotifierProvider<FeaturedContentViewModel, FeaturedContentState>((ref) {
  final repository = ref.watch(featuredContentRepositoryProvider);
  return FeaturedContentViewModel(repository);
});

// ViewModel
class FeaturedContentViewModel extends StateNotifier<FeaturedContentState> {
  final FeaturedContentRepository _repository;

  FeaturedContentViewModel(this._repository) : super(const FeaturedContentState()) {
    // Carrega os dados ao inicializar
    loadFeaturedContents();
  }

  /// Carrega a lista de conteúdos em destaque
  Future<void> loadFeaturedContents() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final contents = await _repository.getFeaturedContents();
      state = state.copyWith(contents: contents, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Seleciona um conteúdo específico pelo ID
  Future<void> selectContentById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final content = await _repository.getFeaturedContentById(id);
      state = state.copyWith(selectedContent: content, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Limpa a seleção atual
  void clearSelection() {
    state = state.copyWith(selectedContent: null);
  }

  /// Filtra conteúdos por categoria
  void filterByCategory(String categoryId) {
    // Implementação futura
  }
} 
