// Package imports:
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Classe auxiliar para inicialização do banco de dados
class DbInitHelper {
  static final SupabaseClient _client = Supabase.instance.client;
  
  /// Verifica se uma tabela existe no Supabase
  static Future<bool> tableExists(String tableName) async {
    try {
      await _client.from(tableName).select('*').limit(1);
      return true;
    } catch (e) {
      if (e is PostgrestException) {
        // Se o erro contém informações sobre uma tabela não existente
        if (e.message.contains('does not exist') || e.code == 'PGRST116') {
          return false;
        }
      }
      // Outros erros: assumir que a tabela existe para evitar criação desnecessária
      debugPrint('Erro ao verificar existência da tabela $tableName: $e');
      return true;
    }
  }
  
  /// Função para criar as tabelas essenciais caso não existam
  static Future<void> ensureTablesExist() async {
    if (kReleaseMode) {
      debugPrint('❌ Em modo de produção, não criaremos tabelas automaticamente');
      return;
    }
    
    try {
      debugPrint('🔍 Verificando e criando tabelas necessárias se não existirem');
      
      // Verificar tabela de banners
      if (!await tableExists('banners')) {
        debugPrint('🛠️ Criando tabela banners');
        await _client.rpc('create_banners_table');
      }
      
      // Verificar tabela de progresso do usuário
      if (!await tableExists('user_progress')) {
        debugPrint('🛠️ Criando tabela user_progress');
        await _client.rpc('create_user_progress_table');
      }
      
      // Verificar tabela de categorias de treinos
      if (!await tableExists('workout_categories')) {
        debugPrint('🛠️ Criando tabela workout_categories');
        await _client.rpc('create_workout_categories_table');
      }
      
      // Verificar tabela de treinos
      if (!await tableExists('workouts')) {
        debugPrint('🛠️ Criando tabela workouts');
        await _client.rpc('create_workouts_table');
      }
      
      debugPrint('✅ Verificação e criação de tabelas concluída');
    } catch (e) {
      debugPrint('❌ Erro ao verificar/criar tabelas: $e');
    }
  }
  
  /// Criar stored procedures de criação de tabelas no Supabase
  static Future<void> createStoredProcedures() async {
    if (kReleaseMode) {
      debugPrint('❌ Em modo de produção, não criaremos procedures');
      return;
    }
    
    try {
      debugPrint('🔍 Criando procedures para inicialização de tabelas');
      
      // Exemplos simplificados de criação de procedures
      // Na prática, você deve adaptar de acordo com seu esquema real
      
      // Criar procedure para tabela banners
      await _client.rpc('create_or_replace_function', params: {
        'function_name': 'create_banners_table',
        'function_body': '''
        BEGIN
          CREATE TABLE IF NOT EXISTS banners (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            title TEXT NOT NULL,
            subtitle TEXT,
            image_url TEXT,
            action_url TEXT,
            is_active BOOLEAN DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
          RETURN 'Table banners created';
        END;
        ''',
        'return_type': 'text'
      });
      
      // Outros procedures semelhantes para outras tabelas
      
      debugPrint('✅ Procedures criados com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao criar procedures: $e');
    }
  }
  
  /// Insere dados iniciais nas tabelas
  static Future<void> insertSampleData() async {
    if (kReleaseMode) {
      debugPrint('❌ Em modo de produção, não inseriremos dados de amostra');
      return;
    }
    
    try {
      debugPrint('🔍 Inserindo dados de amostra');
      
      // Inserir amostras na tabela banners (apenas se estiver vazia)
      final banners = await _client.from('banners').select('id');
      if (banners.isEmpty) {
        await _client.from('banners').insert([
          {
            'title': 'Novo Treino de HIIT',
            'subtitle': 'Queime calorias em 20 minutos',
            'image_url': 'assets/images/challenge_default.jpg',
            'is_active': true
          },
          {
            'title': 'Parceiros com 30% OFF',
            'subtitle': 'Produtos fitness com descontos exclusivos',
            'image_url': 'assets/images/workout_default.jpg',
            'is_active': false
          }
        ]);
        debugPrint('✅ Dados de amostra para banners inseridos');
      }
      
      // Inserir dados em outras tabelas conforme necessário
      
    } catch (e) {
      debugPrint('❌ Erro ao inserir dados de amostra: $e');
    }
  }
} 