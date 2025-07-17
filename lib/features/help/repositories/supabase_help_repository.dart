// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../utils/log_utils.dart';
import '../models/faq_model.dart';
import '../models/help_search_result.dart';
import '../models/tutorial_model.dart';
import 'help_repository.dart';

/// Implementação do repositório de ajuda usando Supabase com suporte offline
class SupabaseHelpRepository implements HelpRepository {
  final SupabaseClient _supabaseClient;
  final CacheService? _cacheService;
  final ConnectivityService _connectivityService;
  
  // Constantes para chaves de cache
  static const String _faqsCacheKey = 'faqs_cache';
  static const String _tutorialsCacheKey = 'tutorials_cache';
  
  // Constantes para nomes de tabelas
  static const String _faqsTable = 'faqs';
  static const String _supportMessagesTable = 'support_messages';
  static const String _tutorialsTable = 'tutorials';
  
  SupabaseHelpRepository({
    required SupabaseClient supabaseClient,
    CacheService? cacheService,
    required ConnectivityService connectivityService,
  }) : _supabaseClient = supabaseClient,
       _cacheService = cacheService,
       _connectivityService = connectivityService;
  
  @override
  Future<List<Faq>> getFaqs() async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        try {
          final response = await _supabaseClient
              .from(_faqsTable)
              .select()
              .order('category')
              .order('id');
          
          final faqs = response.map((data) => Faq.fromJson(data)).toList();
          
          // Armazenar em cache se disponível
          if (_cacheService != null) {
            await _cacheService!.set(
              _faqsCacheKey, 
              jsonEncode(faqs.map((faq) => faq.toJson()).toList())
            );
          }
          
          return faqs;
        } catch (e, stackTrace) {
          LogUtils.error(
            'Erro ao obter FAQs do Supabase', 
            error: e, 
            stackTrace: stackTrace
          );
          
          // Tentar obter do cache em caso de erro
          final cachedData = await _getCachedFaqs();
          if (cachedData.isNotEmpty) {
            return cachedData;
          }
          
          // Se não tiver em cache, retornar as FAQs padrão
          return _getDefaultFaqs();
        }
      } else {
        // Sem conectividade, usar cache
        LogUtils.info('Sem conectividade, usando FAQs em cache');
        final cachedData = await _getCachedFaqs();
        if (cachedData.isNotEmpty) {
          return cachedData;
        }
        
        // Se não tiver em cache, retornar as FAQs padrão
        return _getDefaultFaqs();
      }
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao processar FAQs', 
        error: e, 
        stackTrace: stackTrace
      );
      throw DataAccessException(
        message: 'Erro ao carregar FAQs', 
        originalError: e
      );
    }
  }
  
  /// Obtém FAQs do cache
  Future<List<Faq>> _getCachedFaqs() async {
    if (_cacheService != null) {
      try {
        final cachedData = await _cacheService!.get(_faqsCacheKey);
        if (cachedData != null) {
          final List<dynamic> decoded = jsonDecode(cachedData);
          return decoded.map((item) => Faq.fromJson(item)).toList();
        }
      } catch (e) {
        LogUtils.error('Erro ao ler FAQs do cache', error: e);
      }
    }
    return [];
  }
  
  @override
  Future<void> sendSupportMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (!hasConnectivity) {
        throw NetworkException(
          message: 'Sem conexão com a internet. Tente novamente mais tarde.'
        );
      }
      
      await _supabaseClient.from(_supportMessagesTable).insert({
        'name': name,
        'email': email,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao enviar mensagem de suporte', 
        error: e, 
        stackTrace: stackTrace
      );
      
      if (e is NetworkException) {
        rethrow;
      }
      
      throw DataAccessException(
        message: 'Erro ao enviar mensagem de suporte', 
        originalError: e
      );
    }
  }
  
  /// Implementação para busca de conteúdo de ajuda
  Future<HelpSearchResult> searchHelp(String query) async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (!hasConnectivity) {
        // Em modo offline, buscar apenas em cache
        final cachedFaqs = await _getCachedFaqs();
        final filteredFaqs = cachedFaqs.where((faq) => 
          faq.question.toLowerCase().contains(query.toLowerCase()) ||
          faq.answer.toLowerCase().contains(query.toLowerCase())
        ).toList();
        
        return HelpSearchResult(
          faqs: filteredFaqs,
          tutorials: [], 
          articles: []
        );
      }
      
      // Buscar FAQs
      final faqsResponse = await _supabaseClient
          .from(_faqsTable)
          .select()
          .or('question.ilike.%$query%,answer.ilike.%$query%');
      
      final List<Faq> faqs = faqsResponse.map((data) => Faq.fromJson(data)).toList();
      
      // Buscar tutoriais (se existir a tabela)
      List<Tutorial> tutorials = [];
      try {
        final tutorialsResponse = await _supabaseClient
            .from(_tutorialsTable)
            .select()
            .or('title.ilike.%$query%,description.ilike.%$query%')
            .limit(5);
        
        tutorials = tutorialsResponse.map((data) => Tutorial.fromJson(data)).toList();
      } catch (e) {
        // Se tabela não existir, apenas ignora
        LogUtils.warning('Tabela de tutoriais não encontrada', error: e);
      }
      
      return HelpSearchResult(
        faqs: faqs,
        tutorials: tutorials,
        articles: []
      );
    } catch (e, stackTrace) {
      LogUtils.error(
        'Erro ao buscar conteúdo de ajuda', 
        error: e, 
        stackTrace: stackTrace
      );
      
      throw DataAccessException(
        message: 'Erro ao buscar conteúdo de ajuda', 
        originalError: e
      );
    }
  }
  
  /// Retorna tutoriais disponíveis
  Future<List<Tutorial>> getTutorials() async {
    try {
      // Verificar conectividade
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        try {
          final response = await _supabaseClient
              .from(_tutorialsTable)
              .select()
              .order('order', ascending: true);
          
          final tutorials = response.map((data) => Tutorial.fromJson(data)).toList();
          
          // Armazenar em cache se disponível
          if (_cacheService != null) {
            await _cacheService!.set(
              _tutorialsCacheKey, 
              jsonEncode(tutorials.map((tutorial) => tutorial.toJson()).toList())
            );
          }
          
          return tutorials;
        } catch (e) {
          LogUtils.error('Erro ao obter tutoriais do Supabase', error: e);
          
          // Tentar cache
          if (_cacheService != null) {
            final cachedData = await _cacheService!.get(_tutorialsCacheKey);
            if (cachedData != null) {
              final List<dynamic> decoded = jsonDecode(cachedData);
              return decoded.map((item) => Tutorial.fromJson(item)).toList();
            }
          }
          
          // Se não tiver em cache, retornar lista vazia
          return [];
        }
      } else {
        // Sem conectividade, usar cache
        if (_cacheService != null) {
          final cachedData = await _cacheService!.get(_tutorialsCacheKey);
          if (cachedData != null) {
            final List<dynamic> decoded = jsonDecode(cachedData);
            return decoded.map((item) => Tutorial.fromJson(item)).toList();
          }
        }
        
        // Se não tiver em cache, retornar lista vazia
        return [];
      }
    } catch (e) {
      LogUtils.error('Erro ao processar tutoriais', error: e);
      throw DataAccessException(
        message: 'Erro ao carregar tutoriais', 
        originalError: e
      );
    }
  }
  
  /// Retorna uma lista padrão de FAQs caso não seja possível obter do backend
  List<Faq> _getDefaultFaqs() {
    return [
      const Faq(
        id: '1',
        question: 'Como criar um treino personalizado?',
        answer: 'Para criar um treino personalizado, acesse a seção Treinos, toque no botão "+" no canto inferior direito e selecione "Criar treino". Escolha os exercícios, defina séries e repetições e salve seu treino.',
        category: 'Treinos',
      ),
      const Faq(
        id: '2',
        question: 'Como participar de um desafio?',
        answer: 'Na seção Desafios, você encontrará desafios disponíveis. Selecione o desafio desejado e toque em "Participar". Você também pode criar seu próprio desafio tocando em "Criar desafio".',
        category: 'Desafios',
      ),
      const Faq(
        id: '3',
        question: 'Como acompanhar meu progresso?',
        answer: 'Seu progresso é exibido na tela inicial e na seção Perfil. Você pode visualizar estatísticas de treinos, desafios completados e histórico de atividades.',
        category: 'Progresso',
      ),
      const Faq(
        id: '4',
        question: 'Como resgatar benefícios e cupons?',
        answer: 'Acesse a seção Benefícios, escolha o benefício desejado e toque em "Resgatar". Um QR code será gerado para você apresentar no estabelecimento parceiro.',
        category: 'Benefícios',
      ),
      const Faq(
        id: '5',
        question: 'Posso usar o app sem internet?',
        answer: 'Sim, o Ray Club funciona offline para a maioria das funcionalidades. Treinos baixados previamente, seu perfil e estatísticas ficam disponíveis. A sincronização ocorre automaticamente quando você se reconectar.',
        category: 'Geral',
      ),
      const Faq(
        id: '6',
        question: 'Como alterar minhas configurações de privacidade?',
        answer: 'Acesse seu Perfil, toque em "Configurações e Privacidade" e selecione "Gerenciar Consentimentos". Lá você pode ajustar todas as permissões relacionadas aos seus dados.',
        category: 'Privacidade',
      ),
    ];
  }

  @override
  Future<Faq?> getFaqById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_faqsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Faq.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao obter FAQ por ID', error: e);
      throw DataAccessException(
        message: 'Erro ao carregar detalhes da FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Tutorial?> getTutorialById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tutorialsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return Tutorial.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao obter tutorial por ID', error: e);
      throw DataAccessException(
        message: 'Erro ao carregar detalhes do tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Faq> createFaq(Faq faq) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para criar FAQs'
        );
      }
      
      final response = await _supabaseClient
          .from(_faqsTable)
          .insert(faq.toJson())
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_faqsCacheKey);
      }
      
      return Faq.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao criar FAQ', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao criar FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Faq> updateFaq(Faq faq) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para atualizar FAQs'
        );
      }
      
      final response = await _supabaseClient
          .from(_faqsTable)
          .update(faq.toJson())
          .eq('id', faq.id)
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_faqsCacheKey);
      }
      
      return Faq.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao atualizar FAQ', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao atualizar FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<void> deleteFaq(String faqId) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para remover FAQs'
        );
      }
      
      await _supabaseClient
          .from(_faqsTable)
          .delete()
          .eq('id', faqId);
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_faqsCacheKey);
      }
    } catch (e) {
      LogUtils.error('Erro ao remover FAQ', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao remover FAQ', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Tutorial> createTutorial(Tutorial tutorial) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para criar tutoriais'
        );
      }
      
      final response = await _supabaseClient
          .from(_tutorialsTable)
          .insert(tutorial.toJson())
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_tutorialsCacheKey);
      }
      
      return Tutorial.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao criar tutorial', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao criar tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<Tutorial> updateTutorial(Tutorial tutorial) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para atualizar tutoriais'
        );
      }
      
      final response = await _supabaseClient
          .from(_tutorialsTable)
          .update(tutorial.toJson())
          .eq('id', tutorial.id)
          .select()
          .single();
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_tutorialsCacheKey);
      }
      
      return Tutorial.fromJson(response);
    } catch (e) {
      LogUtils.error('Erro ao atualizar tutorial', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao atualizar tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<void> deleteTutorial(String tutorialId) async {
    try {
      // Verificar se usuário é admin
      if (!await isAdmin()) {
        throw PermissionException(
          message: 'Você não tem permissão para remover tutoriais'
        );
      }
      
      await _supabaseClient
          .from(_tutorialsTable)
          .delete()
          .eq('id', tutorialId);
      
      // Invalidar cache
      if (_cacheService != null) {
        await _cacheService!.delete(_tutorialsCacheKey);
      }
    } catch (e) {
      LogUtils.error('Erro ao remover tutorial', error: e);
      
      if (e is PermissionException) rethrow;
      
      throw DataAccessException(
        message: 'Erro ao remover tutorial', 
        originalError: e
      );
    }
  }
  
  @override
  Future<bool> isAdmin() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Verificar se o usuário é admin na tabela de perfis
      final response = await _supabaseClient
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        return false;
      }
      
      return response['is_admin'] == true;
    } catch (e) {
      LogUtils.error('Erro ao verificar se o usuário é admin', error: e);
      return false;
    }
  }
} 