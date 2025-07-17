// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/partner_studio.dart';
import '../repositories/partner_studio_repository.dart';

part 'partner_studio_view_model.freezed.dart';

// Estado para o ViewModel
@freezed
class PartnerStudioState with _$PartnerStudioState {
  const factory PartnerStudioState({
    @Default([]) List<PartnerStudio> studios,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PartnerStudioState;
}

// Provider para o ViewModel
final partnerStudioViewModelProvider = StateNotifierProvider<PartnerStudioViewModel, PartnerStudioState>((ref) {
  final repository = ref.watch(partnerStudioRepositoryProvider);
  return PartnerStudioViewModel(repository);
});

// Provider assíncrono para estúdios parceiros
final partnerStudiosProvider = FutureProvider<List<PartnerStudio>>((ref) async {
  final viewModel = ref.watch(partnerStudioViewModelProvider.notifier);
  await viewModel.loadStudios();
  return ref.watch(partnerStudioViewModelProvider).studios;
});

// ViewModel
class PartnerStudioViewModel extends StateNotifier<PartnerStudioState> {
  final PartnerStudioRepository _repository;
  
  PartnerStudioViewModel(this._repository) : super(const PartnerStudioState());
  
  // Carregar estúdios
  Future<void> loadStudios() async {
    if (state.studios.isNotEmpty) {
      return; // Evita múltiplas chamadas desnecessárias
    }
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final studios = await _repository.getPartnerStudios();
      state = state.copyWith(
        studios: studios,
        isLoading: false,
      );
    } catch (e) {
      final exception = e is AppException 
          ? e 
          : StorageException(message: 'Erro ao carregar estúdios: ${e.toString()}');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      );
    }
  }
  
  // Buscar conteúdos de um estúdio específico
  Future<void> loadStudioContents(String studioId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final contents = await _repository.getStudioContents(studioId);
      
      // Atualizar os conteúdos do estúdio específico
      final updatedStudios = state.studios.map((studio) {
        if (studio.id == studioId) {
          return studio.copyWith(contents: contents);
        }
        return studio;
      }).toList();
      
      state = state.copyWith(
        studios: updatedStudios,
        isLoading: false,
      );
    } catch (e) {
      final exception = e is AppException 
          ? e 
          : StorageException(message: 'Erro ao carregar conteúdos: ${e.toString()}');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      );
    }
  }
} 