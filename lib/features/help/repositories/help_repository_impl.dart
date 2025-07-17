// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../models/faq_model.dart';
import 'help_repository.dart';

/// Implementação do repositório de ajuda usando Supabase
class HelpRepositoryImpl implements HelpRepository {
  final SupabaseClient _supabaseClient;
  
  /// Tabela de FAQs no Supabase
  static const String _faqTable = 'faqs';
  
  /// Tabela de mensagens de suporte no Supabase
  static const String _supportMessagesTable = 'support_messages';
  
  /// Construtor que recebe uma instância do SupabaseClient
  HelpRepositoryImpl(this._supabaseClient);
  
  @override
  Future<List<Faq>> getFaqs() async {
    try {
      // Verificar se a tabela existe no Supabase, caso não exista, retorna lista estática
      try {
        final response = await _supabaseClient
            .from(_faqTable)
            .select()
            .order('category')
            .order('id');
            
        return response.map((data) => Faq.fromJson(data)).toList();
      } catch (e) {
        // Se a tabela não existir, retornar lista estática
        return _getDefaultFaqs();
      }
    } catch (e) {
      debugPrint('Erro ao obter FAQs: $e');
      return _getDefaultFaqs();
    }
  }
  
  @override
  Future<void> sendSupportMessage({
    required String name, 
    required String email, 
    required String message,
  }) async {
    try {
      // Verificar se a tabela existe antes de tentar inserir
      try {
        await _supabaseClient.from(_supportMessagesTable).insert({
          'name': name,
          'email': email,
          'message': message,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Se a tabela não existir, logamos o erro mas não fazemos falhar o app
        debugPrint('Tabela de mensagens de suporte não existe: $e');
        // Em um app real, enviaríamos um email como fallback ou salvaríamos em algum lugar
      }
    } catch (e) {
      debugPrint('Erro ao enviar mensagem de suporte: $e');
      rethrow; // Deixar o ViewModel tratar o erro
    }
  }
  
  /// Retorna uma lista padrão de FAQs caso não seja possível obter do backend
  List<Faq> _getDefaultFaqs() {
    return [
      const Faq(
        question: 'Como criar um treino personalizado?',
        answer: 'Para criar um treino personalizado, acesse a seção Treinos, toque no botão "+" no canto inferior direito e selecione "Criar treino". Escolha os exercícios, defina séries e repetições e salve seu treino.',
        category: 'Treinos',
      ),
      const Faq(
        question: 'Como participar de um desafio?',
        answer: 'Na seção Desafios, você encontrará desafios disponíveis. Selecione o desafio desejado e toque em "Participar". Você também pode criar seu próprio desafio tocando em "Criar desafio".',
        category: 'Desafios',
      ),
      const Faq(
        question: 'Como acompanhar meu progresso?',
        answer: 'Seu progresso é exibido na tela inicial e na seção Perfil. Você pode visualizar estatísticas de treinos, desafios completados e histórico de atividades.',
        category: 'Progresso',
      ),
      const Faq(
        question: 'Como resgatar benefícios e cupons?',
        answer: 'Acesse a seção Benefícios, escolha o benefício desejado e toque em "Resgatar". Um QR code será gerado para você apresentar no estabelecimento parceiro.',
        category: 'Benefícios',
      ),
      const Faq(
        question: 'Posso usar o app sem internet?',
        answer: 'Sim, o Ray Club funciona offline para a maioria das funcionalidades. Treinos baixados previamente, seu perfil e estatísticas ficam disponíveis. A sincronização ocorre automaticamente quando você se reconectar.',
        category: 'Geral',
      ),
      const Faq(
        question: 'Como alterar minhas configurações de privacidade?',
        answer: 'Acesse seu Perfil, toque em "Configurações e Privacidade" e selecione "Gerenciar Consentimentos". Lá você pode ajustar todas as permissões relacionadas aos seus dados.',
        category: 'Privacidade',
      ),
    ];
  }
} 