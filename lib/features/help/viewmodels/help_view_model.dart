// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/providers/supabase_providers.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../models/faq_model.dart';
import '../models/help_search_result.dart';
import '../models/help_state.dart';
import '../models/tutorial_model.dart';
import '../repositories/help_repository.dart';
import '../repositories/supabase_help_repository.dart';

/// Provider para o repositório de ajuda
final helpRepositoryProvider = Provider<HelpRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return SupabaseHelpRepository(
    supabaseClient: supabase,
    cacheService: cacheService,
    connectivityService: connectivityService,
  );
});

/// Provider para o ViewModel de ajuda
final helpViewModelProvider = StateNotifierProvider<HelpViewModel, HelpState>((ref) {
  final repository = ref.watch(helpRepositoryProvider);
  return HelpViewModel(repository);
});

/// ViewModel para gerenciar a tela de ajuda
class HelpViewModel extends StateNotifier<HelpState> {
  final HelpRepository _repository;
  
  /// Cria uma instância do ViewModel
  HelpViewModel(this._repository) : super(const HelpState()) {
    loadFaqs();
    loadTutorials();
  }
  
  /// Carrega a lista de FAQs
  Future<void> loadFaqs() async {
    state = state.copyWith(isLoading: true);
    try {
      final faqs = await _repository.getFaqs();
      state = state.copyWith(faqs: faqs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar FAQs: $e',
        isLoading: false,
      );
    }
  }
  
  /// Carrega a lista de tutoriais
  Future<void> loadTutorials() async {
    state = state.copyWith(isLoading: true);
    try {
      final tutorials = await _repository.getTutorials();
      state = state.copyWith(tutorials: tutorials, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar tutoriais: $e',
        isLoading: false,
      );
    }
  }
  
  /// Busca conteúdo de ajuda com base em uma query
  Future<void> searchHelp(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        isSearching: false,
        searchQuery: null,
        searchResultsFaqs: [],
        searchResultsTutorials: []
      );
      return;
    }
    
    state = state.copyWith(isLoading: true, isSearching: true, searchQuery: query);
    try {
      final results = await _repository.searchHelp(query);
      state = state.copyWith(
        searchResultsFaqs: results.faqs,
        searchResultsTutorials: results.tutorials,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao buscar conteúdo: $e',
        isLoading: false,
      );
    }
  }
  
  /// Limpa resultados de busca
  void clearSearch() {
    state = state.copyWith(
      isSearching: false,
      searchQuery: null,
      searchResultsFaqs: [],
      searchResultsTutorials: []
    );
  }
  
  /// Atualiza o índice da FAQ expandida
  void setExpandedFaqIndex(int index) {
    // Se clicar na mesma FAQ que já está expandida, colapsa ela
    final newIndex = state.expandedFaqIndex == index ? -1 : index;
    state = state.copyWith(expandedFaqIndex: newIndex);
  }
  
  /// Atualiza o índice do tutorial expandido
  void setExpandedTutorialIndex(int index) {
    // Se clicar no mesmo tutorial que já está expandido, colapsa ele
    final newIndex = state.expandedTutorialIndex == index ? -1 : index;
    state = state.copyWith(expandedTutorialIndex: newIndex);
  }
  
  /// Envia uma mensagem de suporte
  Future<bool> sendSupportMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendSupportMessage(
        name: name,
        email: email,
        message: message,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao enviar mensagem: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Obtém um FAQ específico pelo ID
  Future<Faq?> getFaqById(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final faq = await _repository.getFaqById(id);
      state = state.copyWith(isLoading: false);
      return faq;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar FAQ: $e',
        isLoading: false,
      );
      return null;
    }
  }
  
  /// Obtém um tutorial específico pelo ID
  Future<Tutorial?> getTutorialById(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final tutorial = await _repository.getTutorialById(id);
      state = state.copyWith(isLoading: false);
      return tutorial;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao carregar tutorial: $e',
        isLoading: false,
      );
      return null;
    }
  }
  
  /// Cria uma nova FAQ (admin)
  Future<bool> createFaq(Faq faq) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final createdFaq = await _repository.createFaq(faq);
      
      // Atualiza a lista de FAQs
      final updatedFaqs = [...state.faqs, createdFaq];
      
      state = state.copyWith(
        faqs: updatedFaqs,
        isLoading: false,
        successMessage: 'FAQ criada com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao criar FAQ: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Atualiza uma FAQ existente (admin)
  Future<bool> updateFaq(Faq faq) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final updatedFaq = await _repository.updateFaq(faq);
      
      // Atualiza a lista de FAQs
      final updatedFaqs = [...state.faqs];
      final index = updatedFaqs.indexWhere((f) => f.id == faq.id);
      if (index >= 0) {
        updatedFaqs[index] = updatedFaq;
      }
      
      state = state.copyWith(
        faqs: updatedFaqs,
        isLoading: false,
        successMessage: 'FAQ atualizada com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar FAQ: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Remove uma FAQ (admin)
  Future<bool> deleteFaq(String faqId) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      await _repository.deleteFaq(faqId);
      
      // Atualiza a lista de FAQs
      final updatedFaqs = state.faqs.where((f) => f.id != faqId).toList();
      
      state = state.copyWith(
        faqs: updatedFaqs,
        isLoading: false,
        successMessage: 'FAQ removida com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover FAQ: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Cria um novo tutorial (admin)
  Future<bool> createTutorial(Tutorial tutorial) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final createdTutorial = await _repository.createTutorial(tutorial);
      
      // Atualiza a lista de tutoriais
      final updatedTutorials = [...state.tutorials, createdTutorial];
      
      state = state.copyWith(
        tutorials: updatedTutorials,
        isLoading: false,
        successMessage: 'Tutorial criado com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao criar tutorial: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Atualiza um tutorial existente (admin)
  Future<bool> updateTutorial(Tutorial tutorial) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      final updatedTutorial = await _repository.updateTutorial(tutorial);
      
      // Atualiza a lista de tutoriais
      final updatedTutorials = [...state.tutorials];
      final index = updatedTutorials.indexWhere((t) => t.id == tutorial.id);
      if (index >= 0) {
        updatedTutorials[index] = updatedTutorial;
      }
      
      state = state.copyWith(
        tutorials: updatedTutorials,
        isLoading: false,
        successMessage: 'Tutorial atualizado com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar tutorial: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Remove um tutorial (admin)
  Future<bool> deleteTutorial(String tutorialId) async {
    state = state.copyWith(isLoading: true, successMessage: null, errorMessage: null);
    try {
      await _repository.deleteTutorial(tutorialId);
      
      // Atualiza a lista de tutoriais
      final updatedTutorials = state.tutorials.where((t) => t.id != tutorialId).toList();
      
      state = state.copyWith(
        tutorials: updatedTutorials,
        isLoading: false,
        successMessage: 'Tutorial removido com sucesso'
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover tutorial: $e',
        isLoading: false,
      );
      return false;
    }
  }
  
  /// Verifica se o usuário atual é administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isAdmin();
    } catch (e) {
      return false;
    }
  }
  
  /// Limpa a mensagem de sucesso
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
} 