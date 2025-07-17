// Diagnóstico de problemas no perfil
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  final supabase = Supabase.instance.client;
  
  print('🔍 ===== DIAGNÓSTICO DE PROBLEMAS DO PERFIL =====');
  
  // 1. Verificar estrutura da tabela profiles
  await checkProfileTableStructure(supabase);
  
  // 2. Verificar bucket de imagens
  await checkStorageBucket(supabase);
  
  // 3. Verificar políticas RLS
  await checkRLSPolicies(supabase);
  
  // 4. Verificar função RPC
  await checkRPCFunction(supabase);
  
  // 5. Verificar usuário atual
  await checkCurrentUser(supabase);
  
  print('🔍 ===== FIM DO DIAGNÓSTICO =====');
}

Future<void> checkProfileTableStructure(SupabaseClient supabase) async {
  print('\n📋 1. VERIFICANDO ESTRUTURA DA TABELA PROFILES');
  
  try {
    // Verificar se a tabela profiles existe e suas colunas
    final result = await supabase.rpc('get_table_info', params: {
      'table_schema': 'public',
      'table_name': 'profiles'
    });
    
    print('✅ Tabela profiles encontrada');
    print('📊 Colunas da tabela:');
    
    for (final column in result) {
      print('   - ${column['column_name']}: ${column['data_type']}');
    }
    
  } catch (e) {
    // Se a função RPC não existir, tentar uma consulta direta
    try {
      final sample = await supabase
          .from('profiles')
          .select()
          .limit(1);
      
      print('✅ Tabela profiles acessível');
      if (sample.isNotEmpty) {
        print('📊 Campos disponíveis: ${sample.first.keys.join(', ')}');
      }
    } catch (tableError) {
      print('❌ Erro ao acessar tabela profiles: $tableError');
    }
  }
}

Future<void> checkStorageBucket(SupabaseClient supabase) async {
  print('\n📁 2. VERIFICANDO BUCKET DE STORAGE');
  
  try {
    // Verificar se o bucket profile-images existe
    final buckets = await supabase.storage.listBuckets();
    
    final profileImagesBucket = buckets.firstWhere(
      (bucket) => bucket.name == 'profile-images',
      orElse: () => throw Exception('Bucket não encontrado'),
    );
    
    print('✅ Bucket "profile-images" encontrado');
    print('   - ID: ${profileImagesBucket.id}');
    print('   - Público: ${profileImagesBucket.public}');
    print('   - Criado em: ${profileImagesBucket.createdAt}');
    
    // Tentar listar arquivos no bucket
    try {
      final files = await supabase.storage
          .from('profile-images')
          .list();
      
      print('✅ Acesso ao bucket bem-sucedido');
      print('   - Arquivos no bucket: ${files.length}');
    } catch (listError) {
      print('⚠️  Erro ao listar arquivos: $listError');
    }
    
  } catch (e) {
    print('❌ Erro ao verificar bucket: $e');
    
    // Verificar buckets disponíveis
    try {
      final allBuckets = await supabase.storage.listBuckets();
      print('📋 Buckets disponíveis:');
      for (final bucket in allBuckets) {
        print('   - ${bucket.name}');
      }
    } catch (bucketsError) {
      print('❌ Erro ao listar buckets: $bucketsError');
    }
  }
}

Future<void> checkRLSPolicies(SupabaseClient supabase) async {
  print('\n🔒 3. VERIFICANDO POLÍTICAS RLS');
  
  try {
    final policies = await supabase.rpc('get_table_policies', params: {
      'table_name': 'profiles'
    });
    
    print('✅ Políticas RLS encontradas:');
    for (final policy in policies) {
      print('   - ${policy['policyname']}: ${policy['cmd']}');
    }
    
  } catch (e) {
    // Se a função RPC não existir, fazer uma consulta SQL direta
    try {
      final result = await supabase.rpc('check_rls_status');
      print('✅ RLS Status verificado');
    } catch (rlsError) {
      print('⚠️  Não foi possível verificar políticas RLS: $rlsError');
    }
  }
}

Future<void> checkRPCFunction(SupabaseClient supabase) async {
  print('\n⚙️  4. VERIFICANDO FUNÇÃO RPC');
  
  try {
    // Verificar se a função update_user_photo_url existe
    final testResult = await supabase.rpc('update_user_photo_url', params: {
      'p_user_id': '00000000-0000-0000-0000-000000000000', // UUID de teste
      'p_photo_url': 'https://test.com/test.jpg'
    });
    
    print('✅ Função update_user_photo_url encontrada');
    print('   - Resultado do teste: $testResult');
    
  } catch (e) {
    print('❌ Função update_user_photo_url não encontrada ou erro: $e');
    
    // Tentar verificar outras funções disponíveis
    try {
      final functions = await supabase.rpc('list_functions');
      print('📋 Funções RPC disponíveis:');
      for (final func in functions) {
        print('   - ${func['function_name']}');
      }
    } catch (funcError) {
      print('⚠️  Não foi possível listar funções: $funcError');
    }
  }
}

Future<void> checkCurrentUser(SupabaseClient supabase) async {
  print('\n👤 5. VERIFICANDO USUÁRIO ATUAL');
  
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    print('❌ Nenhum usuário autenticado');
    return;
  }
  
  print('✅ Usuário autenticado:');
  print('   - ID: ${user.id}');
  print('   - Email: ${user.email}');
  print('   - Provider: ${user.appMetadata['provider']}');
  
  // Tentar buscar o perfil do usuário
  try {
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    print('✅ Perfil do usuário encontrado:');
    print('   - Nome: ${profile['name']}');
    print('   - Photo URL: ${profile['photo_url']}');
    print('   - Profile Image URL: ${profile['profile_image_url']}');
    
  } catch (e) {
    print('❌ Erro ao buscar perfil: $e');
  }
  
  // Tentar fazer uma atualização de teste
  try {
    await supabase
        .from('profiles')
        .update({
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);
    
    print('✅ Atualização de perfil bem-sucedida');
    
  } catch (e) {
    print('❌ Erro ao atualizar perfil: $e');
  }
} 