// Project imports:
import '../models/faq_model.dart';
import '../models/help_search_result.dart';
import '../models/tutorial_model.dart';

/// Interface para o repositório de ajuda
abstract class HelpRepository {
  /// Obtém a lista de FAQs
  Future<List<Faq>> getFaqs();
  
  /// Envia uma mensagem de suporte
  Future<void> sendSupportMessage({
    required String name,
    required String email,
    required String message,
  });
  
  /// Busca conteúdo de ajuda
  Future<HelpSearchResult> searchHelp(String query);
  
  /// Obtém a lista de tutoriais
  Future<List<Tutorial>> getTutorials();
  
  /// Obtém uma FAQ pelo ID
  Future<Faq?> getFaqById(String id);
  
  /// Obtém um tutorial pelo ID
  Future<Tutorial?> getTutorialById(String id);
  
  /// Adiciona uma nova FAQ (admin)
  Future<Faq> createFaq(Faq faq);
  
  /// Atualiza uma FAQ existente (admin)
  Future<Faq> updateFaq(Faq faq);
  
  /// Remove uma FAQ (admin)
  Future<void> deleteFaq(String faqId);
  
  /// Adiciona um novo tutorial (admin)
  Future<Tutorial> createTutorial(Tutorial tutorial);
  
  /// Atualiza um tutorial existente (admin)
  Future<Tutorial> updateTutorial(Tutorial tutorial);
  
  /// Remove um tutorial (admin)
  Future<void> deleteTutorial(String tutorialId);
  
  /// Verifica se o usuário é administrador
  Future<bool> isAdmin();
} 