// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script CLI para limpar os desafios existentes e criar um novo desafio de teste
/// 
/// Como usar: 
/// 1. Execute o comando no terminal:
///    dart lib/scripts/create_challenge_cli.dart
///
/// ATENÇÃO: Este script apagará todos os desafios existentes!
void main() async {
  print('====================================================');
  print('      SCRIPT DE CRIAÇÃO DE DESAFIO DE TESTE');
  print('====================================================');
  print('ATENÇÃO: Este script APAGARÁ TODOS os desafios existentes!');
  print('');
  
  print('Deseja continuar? (s/n)');
  final response = stdin.readLineSync()?.toLowerCase();
  
  if (response != 's') {
    print('Operação cancelada pelo usuário.');
    exit(0);
  }
  
  print('Inicializando ambiente...');
  
  // Carregar variáveis de ambiente
  await dotenv.load();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  final client = Supabase.instance.client;
  
  print('Conectado ao Supabase com sucesso!');
  print('');
  
  try {
    // 1. Apagar todos os desafios existentes e dados relacionados
    print('Apagando registros de check-in...');
    await client.from('challenge_check_ins').delete().neq('id', '');
    
    print('Apagando registros de progresso...');
    await client.from('challenge_progress').delete().neq('id', '');
    
    print('Apagando registros de participantes...');
    await client.from('challenge_participants').delete().neq('id', '');
    
    print('Apagando desafios...');
    await client.from('challenges').delete().neq('id', '');
    
    print('Todos os desafios e dados relacionados foram apagados!');
    print('');
    
    // 2. Criar novo desafio de teste
    print('Criando novo desafio de teste...');
    
    // Data inicial = hoje
    final startDate = DateTime.now();
    
    // Data final = hoje + 3 dias
    final endDate = startDate.add(const Duration(days: 3));
    
    // Formatar datas para ISO 8601
    final startIso = startDate.toIso8601String();
    final endIso = endDate.toIso8601String();
    
    // Dados do desafio
    final challengeData = {
      'title': 'Desafio de Teste (3 dias)',
      'description': 'Este é um desafio de teste com duração de 3 dias criado para fins de teste.',
      'start_date': startIso,
      'end_date': endIso,
      'image_url': 'https://picsum.photos/seed/rayclub/800/600',
      'type': 'workout',
      'points': 100,
      'is_official': true,
      'active': true,
      'created_at': startIso,
      'updated_at': startIso,
    };
    
    // Inserir desafio
    final response = await client.from('challenges').insert(challengeData).select();
    
    if (response.isEmpty) {
      throw Exception('Falha ao criar desafio: resposta vazia');
    }
    
    final challengeId = response[0]['id'] as String;
    
    print('');
    print('====================================================');
    print('            DESAFIO CRIADO COM SUCESSO!');
    print('====================================================');
    print('');
    print('Informações do desafio:');
    print('- ID: $challengeId');
    print('- Título: Desafio de Teste (3 dias)');
    print('- Descrição: Este é um desafio de teste com duração de 3 dias.');
    print('- Data de início: ${startDate.toString().split('.')[0]}');
    print('- Data de término: ${endDate.toString().split('.')[0]}');
    print('- Duração: 3 dias');
    print('');
    print('Próximos passos:');
    print('1. Faça login com diferentes usuários no app');
    print('2. Entre no desafio recém-criado');
    print('3. Verifique se o desafio aparece no dashboard');
    print('====================================================');
    
  } catch (e) {
    print('ERRO: $e');
    exit(1);
  }
  
  exit(0);
} 