/// COMO EXECUTAR O TESTE DE PERSISTÊNCIA DO PERFIL
/// 
/// OPÇÃO 1: Via Developer Menu
/// 1. Abra o app
/// 2. Va em Settings > Developer 
/// 3. Adicione este botão no developer_screen.dart:
///
/// ElevatedButton(
///   onPressed: () => testePersistenciaPerfil(),
///   child: Text('🧪 Testar Persistência'),
/// ),
///
/// OPÇÃO 2: Executar SQL direto no Supabase
/// 1. Acesse https://supabase.com/dashboard
/// 2. Projeto ray-club
/// 3. SQL Editor
/// 4. Cole e execute o SQL abaixo

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Função simples para testar persistência
Future<void> testePersistenciaPerfil() async {
  debugPrint('🧪 === TESTE SIMPLES DE PERSISTÊNCIA ===');
  
  try {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    
    if (userId == null) {
      debugPrint('❌ Usuário não logado');
      return;
    }
    
    debugPrint('1️⃣ Lendo perfil atual...');
    final perfil = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    debugPrint('📋 Perfil atual:');
    debugPrint('   - Nome: ${perfil['name']}');
    debugPrint('   - Telefone: ${perfil['phone']}');
    debugPrint('   - Email: ${perfil['email']}');
    
    debugPrint('2️⃣ Testando atualização...');
    final novoNome = 'Teste ${DateTime.now().millisecondsSinceEpoch}';
    final novoTelefone = '11999${DateTime.now().millisecond}';
    
    debugPrint('   - Atualizando nome para: $novoNome');
    debugPrint('   - Atualizando telefone para: $novoTelefone');
    
    await client
        .from('profiles')
        .update({
          'name': novoNome,
          'phone': novoTelefone,
        })
        .eq('id', userId);
    
    debugPrint('3️⃣ Verificando se salvou...');
    await Future.delayed(Duration(seconds: 1));
    
    final perfilAtualizado = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    debugPrint('📋 Perfil após update:');
    debugPrint('   - Nome: ${perfilAtualizado['name']}');
    debugPrint('   - Telefone: ${perfilAtualizado['phone']}');
    
    if (perfilAtualizado['name'] == novoNome && 
        perfilAtualizado['phone'] == novoTelefone) {
      debugPrint('✅ TESTE PASSOU! Dados foram persistidos corretamente');
    } else {
      debugPrint('❌ TESTE FALHOU! Dados não foram persistidos');
      debugPrint('   - Nome esperado: $novoNome, encontrado: ${perfilAtualizado['name']}');
      debugPrint('   - Telefone esperado: $novoTelefone, encontrado: ${perfilAtualizado['phone']}');
    }
    
  } catch (e) {
    debugPrint('❌ Erro no teste: $e');
  }
}


/// SQL PARA EXECUTAR DIRETO NO SUPABASE:
/// 
/// -- 1. Ver seu perfil atual
/// SELECT id, name, phone, email, profile_image_url, photo_url 
/// FROM profiles 
/// WHERE id = auth.uid();
/// 
/// -- 2. Testar update
/// UPDATE profiles 
/// SET name = 'Teste Manual', phone = '11999999999'
/// WHERE id = auth.uid();
/// 
/// -- 3. Verificar se salvou
/// SELECT id, name, phone, email, profile_image_url, photo_url 
/// FROM profiles 
/// WHERE id = auth.uid();
/// 
/// -- 4. Verificar triggers
/// SELECT trigger_name, event_manipulation, action_timing 
/// FROM information_schema.triggers 
/// WHERE event_object_table = 'profiles'; 