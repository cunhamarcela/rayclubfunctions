// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'faq_model.dart';
import 'tutorial_model.dart';

part 'help_state.freezed.dart';

/// Estado para a tela de ajuda
@freezed
class HelpState with _$HelpState {
  /// Factory para o estado da tela de ajuda
  const factory HelpState({
    /// Lista de perguntas frequentes
    @Default([]) List<Faq> faqs,
    
    /// Lista de tutoriais disponíveis
    @Default([]) List<Tutorial> tutorials,
    
    /// Índice da FAQ expandida, -1 se nenhuma estiver expandida
    @Default(-1) int expandedFaqIndex,
    
    /// Índice do tutorial expandido, -1 se nenhum estiver expandido
    @Default(-1) int expandedTutorialIndex,
    
    /// Indica se está carregando dados
    @Default(false) bool isLoading,
    
    /// Indica se está em modo de busca
    @Default(false) bool isSearching,
    
    /// Termo de busca atual
    String? searchQuery,
    
    /// Resultados da busca: FAQs
    @Default([]) List<Faq> searchResultsFaqs,
    
    /// Resultados da busca: Tutoriais 
    @Default([]) List<Tutorial> searchResultsTutorials,
    
    /// Mensagem de erro, se houver
    String? errorMessage,
    
    /// Mensagem de sucesso após operações de CRUD
    String? successMessage,
  }) = _HelpState;
} 