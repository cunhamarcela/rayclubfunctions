// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'faq_model.dart';
import 'tutorial_model.dart';

part 'help_search_result.freezed.dart';

/// Modelo para armazenar resultados de busca no módulo de ajuda
@freezed
class HelpSearchResult with _$HelpSearchResult {
  /// Construtor padrão para resultados de busca
  const factory HelpSearchResult({
    /// Lista de FAQs encontradas na busca
    @Default([]) List<Faq> faqs,
    
    /// Lista de tutoriais encontrados na busca
    @Default([]) List<Tutorial> tutorials,
    
    /// Lista de artigos encontrados na busca (para implementação futura)
    @Default([]) List<dynamic> articles,
  }) = _HelpSearchResult;
} 