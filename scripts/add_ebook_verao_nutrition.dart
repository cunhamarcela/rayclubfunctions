// Script para adicionar Ebook de Verão na seção de materiais de nutrição
// Execute com: dart run scripts/add_ebook_verao_nutrition.dart

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🚀 Iniciando adição do Ebook de Verão...');
  
  try {
    // Carregar variáveis de ambiente
    await dotenv.load(fileName: '.env');
    
    // Inicializar Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Conectado ao Supabase');
    
    // Verificar se o arquivo existe no storage
    print('\n📁 Verificando arquivo no storage...');
    try {
      final files = await supabase.storage
          .from('materials')
          .list();
      
      final ebookExists = files.any((file) => 
          file.name.toLowerCase().contains('ebook de verao') ||
          file.name.toLowerCase().contains('ebook de verao.pdf'));
      
      if (ebookExists) {
        print('✅ Arquivo "Ebook de Verao.pdf" encontrado no storage');
      } else {
        print('⚠️ Arquivo não encontrado. Arquivos disponíveis:');
        for (var file in files) {
          print('   - ${file.name}');
        }
      }
    } catch (e) {
      print('⚠️ Erro ao verificar storage: $e');
    }
    
    // Verificar se o material já existe
    print('\n🔍 Verificando se o material já existe...');
    final existingMaterials = await supabase
        .from('materials')
        .select()
        .eq('material_context', 'nutrition')
        .ilike('title', '%ebook%verão%');
    
    if (existingMaterials.isNotEmpty) {
      print('ℹ️ Material já existe:');
      for (var material in existingMaterials) {
        print('   - ${material['title']} (ID: ${material['id']})');
      }
      print('❌ Cancelando inserção para evitar duplicatas');
      return;
    }
    
    // Inserir o ebook
    print('\n📚 Inserindo Ebook de Verão...');
    final result = await supabase
        .from('materials')
        .insert({
          'title': 'Ebook de Verão ☀️',
          'description': 'Guia completo com receitas leves e refrescantes para os dias mais quentes. Inclui dicas de hidratação, lanches saudáveis e refeições nutritivas perfeitas para o verão.',
          'material_type': 'ebook',
          'material_context': 'nutrition',
          'file_path': 'Ebook de Verao.pdf',
          'author_name': 'Ray Club',
          'order_index': 1,
          'is_featured': true,
          'requires_expert_access': false,
        })
        .select()
        .single();
    
    print('✅ Ebook inserido com sucesso!');
    print('📋 Detalhes:');
    print('   - ID: ${result['id']}');
    print('   - Título: ${result['title']}');
    print('   - Tipo: ${result['material_type']}');
    print('   - Contexto: ${result['material_context']}');
    print('   - Caminho: ${result['file_path']}');
    print('   - Em destaque: ${result['is_featured']}');
    
    // Verificar total de materiais de nutrição
    final nutritionMaterials = await supabase
        .from('materials')
        .select()
        .eq('material_context', 'nutrition');
    
    print('\n📊 Total de materiais de nutrição: ${nutritionMaterials.length}');
    
    print('\n🎉 Concluído! O ebook agora está disponível na aba "Materiais" da tela de nutrição.');
    
  } catch (e) {
    print('❌ Erro: $e');
    exit(1);
  }
} 